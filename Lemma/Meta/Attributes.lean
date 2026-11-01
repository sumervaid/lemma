import Lemma.Meta.Overlap
import Lemma.Meta.Scope
import Lemma.Meta.Compose

/-!
# Registration attributes

The five attributes below are the library's interface to the compiler
checks. Each runs when the tagged declaration is elaborated, which is why
a file that declares a construct emits overlap warnings as soon as it is
compiled, with no separate lint step.

* `@[primitive]` on a structure extending `Lemma.Primitive`.
* `@[construct]` on a structure extending `Construct l h` or on a `def`
  unfolding to registered constructs. Runs Q1 (reduction). On success,
  generates the `IsConstruct` instance which the kernel's `Proposition`,
  `Aggregation` and `Temporal` types demand, then runs Q2 (overlap) and
  logs one warning per undeclared overlap.
* `@[proposition]` on a `def p : Proposition A B := {...}`. Runs Q3 (scope)
  and rejects an unroutable scope. Runs Q4 (contradiction) against the
  registry and warns on cross-theory contradictions; a contradiction inside
  one theory is an error.
* `@[aggregation]` and `@[temporal]` on rules; the kernel already enforces
  the level and horizon constraints by `decide`, the attribute registers
  the rule so that Q3 can route through it.

The `lemma.linter.overlap` option switches the attribute-time overlap
warnings off (they remain available on demand through `#check_overlap`).
-/

open Lean Meta

namespace Lemma.Meta

register_option lemma.linter.overlap : Bool := {
  defValue := true
  descr := "emit overlap warnings when a construct is registered with `@[construct]`"
}

register_option lemma.linter.contradiction : Bool := {
  defValue := true
  descr := "emit cross-theory contradiction warnings when a proposition is registered with `@[proposition]`"
}

register_option lemma.linter.scopeRouting : Bool := {
  defValue := true
  descr := "emit an informational message when a proposition is routed through an aggregation or temporal rule"
}

/-! ## Helpers -/

def Level.ctorName : Level → Name
  | .Individual => ``Level.Individual
  | .Dyad => ``Level.Dyad
  | .Team => ``Level.Team
  | .Unit => ``Level.Unit
  | .Organization => ``Level.Organization

def Horizon.ctorName : Horizon → Name
  | .Momentary => ``Horizon.Momentary
  | .Daily => ``Horizon.Daily
  | .Weekly => ``Horizon.Weekly
  | .Monthly => ``Horizon.Monthly
  | .Annual => ``Horizon.Annual
  | .Static => ``Horizon.Static

/-- Head constant name of an expression after weak head normalization. -/
def headName (e : Expr) : MetaM Name := do
  let e ← whnf (← instantiateMVars e)
  let fn := e.getAppFn
  unless fn.isConst do
    throwError "expected a constructor application, found `{← ppExpr e}`"
  return fn.constName!

/-- Head constant name of an expression *without* unfolding definitions, so
that a composite construct such as `def Thriving := Vitality × Learning` is
read by name rather than unfolded to `Prod`. -/
def constName (e : Expr) : MetaM Name := do
  let e ← instantiateMVars e
  let fn := e.getAppFn
  if fn.isConst then return fn.constName!
  headName e

/-- A string literal after weak head normalization, or its printed form. -/
def readString (e : Expr) : MetaM String := do
  let e ← whnf (← instantiateMVars e)
  match e with
  | .lit (.strVal s) => return s
  | _ => return toString (← ppExpr e)

def readLevel (e : Expr) : MetaM Level := do
  let n ← headName e
  match levelOfName? n with
  | some l => return l
  | none => throwError "expected a `Level` constructor, found `{n}`"

def readHorizon (e : Expr) : MetaM Horizon := do
  let n ← headName e
  match horizonOfName? n with
  | some h => return h
  | none => throwError "expected a `Horizon` constructor, found `{n}`"

def readDirection (e : Expr) : MetaM Direction := do
  let n ← headName e
  match directionOfName? n with
  | some d => return d
  | none => throwError "expected a `Direction` constructor, found `{n}`"

def readEvidence (e : Expr) : MetaM EvidenceKind := do
  let n ← headName e
  match evidenceOfName? n with
  | some d => return d
  | none => throwError "expected an `EvidenceKind` constructor, found `{n}`"

def readBoundary (e : Expr) : MetaM BoundaryEntry := do
  let e ← whnf (← instantiateMVars e)
  let fn := e.getAppFn
  let args := e.getAppArgs
  if fn.isConstOf ``Boundary.none then
    return .none
  else if fn.isConstOf ``Boundary.moderator then
    unless args.size == 3 do throwError "malformed `Boundary.moderator`"
    let m ← constName args[0]!
    let effName ← headName args[2]!
    match moderationOfName? effName with
    | some eff => return .moderator m eff
    | none => throwError "expected a `ModerationEffect` constructor, found `{effName}`"
  else if fn.isConstOf ``Boundary.scope then
    unless args.size == 1 do throwError "malformed `Boundary.scope`"
    return .scope (← readString args[0]!)
  else
    throwError "expected a `Boundary` constructor, found `{← ppExpr e}`"

def docOf (declName : Name) : CoreM String := do
  match ← findDocString? (← getEnv) declName with
  | some d => return d.trim
  | none => return ""

def requireDoc (what : String) (declName : Name) : CoreM String := do
  let d ← docOf declName
  if d.isEmpty then
    throwError "{what} `{shortName declName}` requires a citation docstring (see CONTRIBUTING.md)"
  return d

/-! ## `@[primitive]` -/

def registerPrimitive (declName : Name) : MetaM Unit := do
  let env ← getEnv
  unless isStructure env declName do
    throwError "`@[primitive]` expects a structure extending `Lemma.Primitive`, and `{declName}` is not a structure"
  let parents ← getAllParentStructures declName
  unless parents.contains ``Lemma.Primitive do
    throwError "`@[primitive]` expects a structure extending `Lemma.Primitive`; `{shortName declName}` does not"
  let doc ← requireDoc "primitive" declName
  let module ← getMainModule
  modifyEnv fun env => primitiveExt.addEntry env { name := declName, module, doc }

initialize registerBuiltinAttribute {
  name := `primitive
  applicationTime := .afterCompilation
  descr := "register a structure extending `Lemma.Primitive` as an atomic value type"
  add := fun declName _stx kind => do
    unless kind == .global do throwError "`@[primitive]` must be global"
    MetaM.run' (registerPrimitive declName)
}

/-! ## `@[construct]` -/

/-- Generate and register the `IsConstruct` instance for a construct type. -/
def mkIsConstructInstance (declName : Name) (l : Level) (h : Horizon) : MetaM Unit := do
  let instName := Name.str declName "instIsConstruct"
  let ty := mkApp (mkConst ``Lemma.IsConstruct) (mkConst declName)
  let val := mkApp3 (mkConst ``Lemma.IsConstruct.mk) (mkConst declName)
    (mkConst (Level.ctorName l)) (mkConst (Horizon.ctorName h))
  addAndCompile <| .defnDecl {
    name := instName, levelParams := [], type := ty, value := val,
    hints := .abbrev, safety := .safe }
  setReducibilityStatus instName .reducible
  addInstance instName .global (eval_prio default)

/-- Format a Q1 failure. -/
def formatFailures (declName : Name) (fs : Array ReduceFailure) : String :=
  let lines := fs.map fun f =>
    let at_ := if f.path.isEmpty then "" else s!" at {String.intercalate "." (f.path.map toString)}"
    s!"  {f.type}{at_}: {f.reason}"
  s!"construct `{shortName declName}` does not reduce to primitives\n" ++
    String.intercalate "\n" lines.toList

/-- Log overlap warnings for a construct, respecting declarations. Returns the reports. -/
def warnOverlaps (declName : Name) (leaves : Array PrimLeaf) (components : Array Name) :
    CoreM (Array OverlapReport) := do
  let env ← getEnv
  let reports := overlapsOf env declName leaves components
  if (← getOptions).get lemma.linter.overlap.name lemma.linter.overlap.defValue then
    for r in reports do
      if r.declared.isNone then
        logWarning (r.message)
  return reports

def registerConstruct (declName : Name) : MetaM Unit := do
  let doc ← requireDoc "construct" declName
  let r ← reduceConstruct declName
  unless r.failures.isEmpty do
    throwError (formatFailures declName r.failures)
  if r.leaves.isEmpty then
    throwError "construct `{shortName declName}` has no primitive leaves"
  let (level, horizon) ← match r.scope? with
    | .ok s => pure s
    | .error msg => throwError "construct `{shortName declName}`: {msg}"
  let module ← getMainModule
  let entry : ConstructEntry := {
    name := declName, theory := theoryOfModule module, module, kind := r.kind,
    level, horizon, leaves := r.leaves, components := r.components, doc }
  mkIsConstructInstance declName level horizon
  let _ ← warnOverlaps declName r.leaves r.components
  modifyEnv fun env => constructExt.addEntry env entry

initialize registerBuiltinAttribute {
  name := `construct
  applicationTime := .afterCompilation
  descr := "register a construct: check reduction to primitives (Q1), generate its `IsConstruct` instance, and report overlaps (Q2)"
  add := fun declName _stx kind => do
    unless kind == .global do throwError "`@[construct]` must be global"
    MetaM.run' (registerConstruct declName)
}

/-! ## `@[proposition]` -/

/-- Read the two construct type arguments of `Proposition A B`, `Aggregation A B`
or `Temporal A B` from a declaration's type. -/
def readPairType (declName : Name) (head : Name) : MetaM (Name × Name) := do
  let some ci := (← getEnv).find? declName | throwError "unknown constant {declName}"
  let ty ← whnf (← instantiateMVars ci.type)
  unless ty.getAppFn.isConstOf head do
    throwError "`{shortName declName}` must have type `{head} A B`, found `{← ppExpr ty}`"
  let args := ty.getAppArgs
  unless args.size == 4 do throwError "malformed `{head}` type"
  return (← constName args[0]!, ← constName args[1]!)

/-- The constructor arguments of a declaration's value after unfolding. -/
def readCtorArgs (declName : Name) (ctor : Name) (arity : Nat) : MetaM (Array Expr) := do
  let some ci := (← getEnv).find? declName | throwError "unknown constant {declName}"
  let some v := ci.value? | throwError "`{shortName declName}` has no value"
  let v ← whnf (← instantiateMVars v)
  unless v.getAppFn.isConstOf ctor && v.getAppNumArgs == arity do
    throwError "`{shortName declName}` must be a structure instance `\{ ... }` of `{ctor}`, found `{← ppExpr v}`"
  return v.getAppArgs

def registerProposition (declName : Name) : MetaM Unit := do
  let doc ← requireDoc "proposition" declName
  let (a, b) ← readPairType declName ``Lemma.Proposition
  let args ← readCtorArgs declName ``Lemma.Proposition.mk 10
  let direction ← readDirection args[4]!
  let level ← readLevel args[5]!
  let horizon ← readHorizon args[6]!
  let boundary ← readBoundary args[7]!
  let evidence ← readEvidence args[8]!
  let citation ← readString args[9]!
  let env ← getEnv
  let scope ← match scopeStatus env a b level horizon with
    | .ok s => pure s
    | .error msg => throwError "scope mismatch in `{shortName declName}`: {msg}"
  if let .routed rules := scope then
    if (← getOptions).get lemma.linter.scopeRouting.name lemma.linter.scopeRouting.defValue then
      logInfo s!"`{shortName declName}` is routed through {String.intercalate ", " (rules.map shortName)}"
  let module ← getMainModule
  let entry : PropositionEntry := {
    name := declName, theory := theoryOfModule module, module, antecedent := a, consequent := b,
    direction, level, horizon, boundary, evidence, citation, doc, scope }
  let existing := propositionExt.all env
  for q in contradictionsOf entry existing do
    if q.theory == entry.theory then
      throwError "`{shortName declName}` ({direction}) contradicts `{shortName q.name}` ({q.direction}) in the same theory `{q.theory}` on {shortName a} → {shortName b} at {level} / {horizon}"
    else if (← getOptions).get lemma.linter.contradiction.name lemma.linter.contradiction.defValue then
      logWarning s!"contradicts {shortName q.name} ({q.theory}): {shortName a} → {shortName b} is {direction} here and {q.direction} there at {level} / {horizon}"
  for q in existing do
    if q.name != declName && comparable entry q && entry.direction.shapeDisagrees q.direction then
      logInfo s!"shape disagreement with {shortName q.name} ({q.theory}): {shortName a} → {shortName b} is {direction} here and {q.direction} there"
  modifyEnv fun env => propositionExt.addEntry env entry

initialize registerBuiltinAttribute {
  name := `proposition
  applicationTime := .afterCompilation
  descr := "register a proposition: check scope (Q3) and contradictions (Q4)"
  add := fun declName _stx kind => do
    unless kind == .global do throwError "`@[proposition]` must be global"
    MetaM.run' (registerProposition declName)
}

/-! ## `@[aggregation]` and `@[temporal]` -/

def registerAggregation (declName : Name) : MetaM Unit := do
  let _ ← requireDoc "aggregation rule" declName
  let (a, b) ← readPairType declName ``Lemma.Aggregation
  let args ← readCtorArgs declName ``Lemma.Aggregation.mk 8
  let ruleName ← headName args[4]!
  let some rule := aggregationRuleOfName? ruleName
    | throwError "expected an `AggregationRule` constructor, found `{ruleName}`"
  let citation ← readString args[5]!
  let module ← getMainModule
  modifyEnv fun env => aggregationExt.addEntry env {
    name := declName, theory := theoryOfModule module, module, source := a, target := b, rule, citation }

def registerTemporal (declName : Name) : MetaM Unit := do
  let _ ← requireDoc "temporal rule" declName
  let (a, b) ← readPairType declName ``Lemma.Temporal
  let args ← readCtorArgs declName ``Lemma.Temporal.mk 8
  let ruleName ← headName args[4]!
  let some rule := temporalRuleOfName? ruleName
    | throwError "expected a `TemporalRule` constructor, found `{ruleName}`"
  let citation ← readString args[5]!
  let module ← getMainModule
  modifyEnv fun env => temporalExt.addEntry env {
    name := declName, theory := theoryOfModule module, module, source := a, target := b, rule, citation }

initialize registerBuiltinAttribute {
  name := `aggregation
  applicationTime := .afterCompilation
  descr := "register an aggregation rule (kernel rule 3) so that propositions can route through it"
  add := fun declName _stx kind => do
    unless kind == .global do throwError "`@[aggregation]` must be global"
    MetaM.run' (registerAggregation declName)
}

initialize registerBuiltinAttribute {
  name := `temporal
  applicationTime := .afterCompilation
  descr := "register a temporal rule (kernel rule 4) so that propositions can route through it"
  add := fun declName _stx kind => do
    unless kind == .global do throwError "`@[temporal]` must be global"
    MetaM.run' (registerTemporal declName)
}

end Lemma.Meta
