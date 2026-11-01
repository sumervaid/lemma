import Lemma.Meta.Registry

/-!
# Q1: reduction to primitives

`reduceConstruct` unfolds a construct type to the primitive leaves it is
built from, following structure fields, parent structures and products. A
leaf is a registered primitive together with the scope (level, horizon) of
the nearest enclosing `Construct l h` parent. Any other leaf, such as a
`Float` field, an `axiom`, or a type never declared as a primitive, is a
reduction failure: the construct rests on an undefined term.

The reduction is what the `@[construct]` attribute runs before it accepts a
definition, and what `#reduce_construct` prints on demand.
-/

open Lean Meta

namespace Lemma.Meta

/-- One reason a construct failed to reduce. -/
structure ReduceFailure where
  path : List Name
  type : String
  reason : String
  deriving Inhabited, Repr, ToJson

/-- Result of reducing one construct type. -/
structure ReduceResult where
  leaves : Array PrimLeaf := #[]
  components : Array Name := #[]
  failures : Array ReduceFailure := #[]
  /-- Scope declared by a `Construct l h` parent, when the root is a structure. -/
  declaredScope : Option (Level × Horizon) := none
  kind : ConstructKind := .composite
  deriving Inhabited

/-- Maximum unfolding depth, a guard against pathological definitions. -/
def maxReduceDepth : Nat := 32

/-- The head constant of an application after weak head normalization. -/
private def headConst? (e : Expr) : MetaM (Option (Name × List Lean.Level × Array Expr)) := do
  let e ← whnf (← instantiateMVars e)
  let fn := e.getAppFn
  if fn.isConst then
    return some (fn.constName!, fn.constLevels!, e.getAppArgs)
  return none

/-- Fully qualified name of an enumeration-like argument, or its printed form. -/
partial def argName (e : Expr) : MetaM String := do
  match ← headConst? e with
  | some (n, _, #[]) => return n.toString
  | some (n, _, args) =>
    let inner ← args.mapM argName
    return n.toString ++ " " ++ String.intercalate " " inner.toList
  | none => return toString (← ppExpr e)

/-- Type of field `field` of the structure instance type `e` (an application of
a structure type constant to its parameters). Dependent fields are rejected. -/
def fieldTypeOf (e : Expr) (structName field : Name) : MetaM Expr := do
  let env ← getEnv
  let some proj := getProjFnForField? env structName field
    | throwError "no projection function for field {field} of {structName}"
  let e ← whnf (← instantiateMVars e)
  let args := e.getAppArgs
  let lvls := e.getAppFn.constLevels!
  withLocalDeclD `self e fun self => do
    let t ← inferType (mkAppN (mkConst proj lvls) (args.push self))
    let t ← instantiateMVars t
    if t.containsFVar self.fvarId! then
      throwError "field {field} of {structName} is dependent, which Lemma constructs do not support"
    return t

/-- Parse `Construct l h` arguments. -/
private def scopeOfConstructArgs (args : Array Expr) : MetaM (Option (Level × Horizon)) := do
  if h : args.size = 2 then
    let l ← headConst? args[0]
    let hz ← headConst? args[1]
    match l, hz with
    | some (ln, _, _), some (hn, _, _) =>
      match levelOfName? ln, horizonOfName? hn with
      | some lv, some hr => return some (lv, hr)
      | _, _ => return none
    | _, _ => return none
  else
    return none

/-- Scope declared by a `Construct l h` ancestor of the structure type `e`,
searching parent structures depth-first. -/
partial def declaredScopeOf (e : Expr) (depth : Nat := 0) : MetaM (Option (Level × Horizon)) := do
  if depth > maxReduceDepth then return none
  let env ← getEnv
  match ← headConst? e with
  | some (n, _, args) =>
    if n == ``Lemma.Construct then
      scopeOfConstructArgs args
    else if isStructure env n then
      for f in getStructureFields env n do
        if (isSubobjectField? env n f).isSome then
          let pt ← fieldTypeOf e n f
          if let some s ← declaredScopeOf pt (depth + 1) then
            return some s
      return none
    else
      return none
  | none => return none

private structure Acc where
  leaves : Array PrimLeaf := #[]
  components : Array Name := #[]
  failures : Array ReduceFailure := #[]

private abbrev ReduceM := StateT Acc MetaM

private def fail (path : List Name) (e : Expr) (reason : String) : ReduceM Unit := do
  let s ← ppExpr e
  modify fun a => { a with failures := a.failures.push { path, type := toString s, reason } }

/-- Core traversal. `scope` is the nearest enclosing declared scope. `isRoot`
prevents a registered construct from being short-circuited to its own entry
when `#reduce_construct` is run on it after registration. -/
private partial def collect (e : Expr) (path : List Name) (via : Option Name)
    (scope : Option (Level × Horizon)) (depth : Nat) (isRoot : Bool) : ReduceM Unit := do
  if depth > maxReduceDepth then
    fail path e s!"unfolding exceeded depth {maxReduceDepth}"
    return
  let env ← getEnv
  match ← headConst? e with
  | none => fail path e "type is not an application of a constant"
  | some (n, _, args) =>
    if isPrimitive env n then
      match scope with
      | some (l, h) =>
        let argStrs ← liftM (m := MetaM) (args.toList.mapM argName)
        let leaf : PrimLeaf := { prim := n, args := argStrs, path, via, level := l, horizon := h }
        modify fun a => { a with leaves := a.leaves.push leaf }
      | none =>
        fail path e s!"primitive {shortName n} reached outside any `Construct` scope; composite definitions must be built from constructs which extend `Construct l h`"
    else if !isRoot && (findConstruct? env n).isSome then
      let some ce := findConstruct? env n | unreachable!
      modify fun a => { a with components := a.components.push n }
      for leaf in ce.leaves do
        let leaf' : PrimLeaf := { leaf with path := path ++ leaf.path, via := via <|> some n }
        modify fun a => { a with leaves := a.leaves.push leaf' }
    else if isStructure env n then
      let scope' := (← declaredScopeOf e) <|> scope
      for f in getStructureFields env n do
        let ft ← fieldTypeOf e n f
        if (isSubobjectField? env n f).isSome then
          -- A parent structure: skip the scope carrier itself, recurse into others.
          match ← headConst? ft with
          | some (``Lemma.Construct, _, _) => pure ()
          | _ => collect ft path via scope' (depth + 1) false
        else
          collect ft (path ++ [f]) via scope' (depth + 1) false
    else
      match env.find? n with
      | some (.axiomInfo _) => fail path e s!"`{n}` is an axiom: the construct rests on an undefined term"
      | some (.opaqueInfo _) => fail path e s!"`{n}` is opaque: the construct rests on an undefined term"
      | _ => fail path e s!"`{shortName n}` is neither a registered primitive, a registered construct, nor a structure"

/-- Reduce the construct type named `declName` to primitive leaves. -/
def reduceConstruct (declName : Name) : MetaM ReduceResult := do
  let env ← getEnv
  let some ci := env.find? declName
    | throwError "unknown constant {declName}"
  unless ci.levelParams.isEmpty do
    throwError "construct {declName} must not be universe polymorphic"
  let ty ← instantiateMVars ci.type
  unless (← whnf ty).isSort do
    throwError "construct {declName} must be a type, found `{← ppExpr ty}`"
  let e := mkConst declName
  let declared ← declaredScopeOf e
  let kind := if isStructure env declName then ConstructKind.structure else .composite
  let (_, acc) ← (collect e [] none declared 0 true).run {}
  return { leaves := acc.leaves, components := acc.components, failures := acc.failures,
           declaredScope := declared, kind }

/-- The scope of a reduced construct: declared for structures, inferred as
the unique scope of all leaves for composites. -/
def ReduceResult.scope? (r : ReduceResult) : Except String (Level × Horizon) :=
  match r.declaredScope with
  | some s => .ok s
  | none =>
    let scopes := r.leaves.foldl (fun (acc : List (Level × Horizon)) l =>
      if acc.contains (l.level, l.horizon) then acc else acc ++ [(l.level, l.horizon)]) []
    match scopes with
    | [s] => .ok s
    | [] => .error "no primitive leaves, so no scope can be inferred"
    | ss => .error s!"components live at different scopes ({String.intercalate ", " (ss.map fun (l, h) => s!"{l} / {h}")}); declare the composite as a structure extending `Construct l h` and route components through aggregation or temporal rules"

/-- Human-readable path of a leaf, e.g. `Thriving ∋ Vitality.energy` or `Engagement.vigor`. -/
def PrimLeaf.pathDisplay (root : Name) (l : PrimLeaf) : String :=
  let fields := l.path.filter fun n => n != `fst && n != `snd
  let fieldStr := String.intercalate "." (fields.map toString)
  match l.via with
  | some v =>
    let viaFields := (l.path.dropWhile fun n => n == `fst || n == `snd)
    let inner := String.intercalate "." ((viaFields.filter fun n => n != `fst && n != `snd).map toString)
    if inner.isEmpty then s!"{shortName root} ∋ {shortName v}" else s!"{shortName root} ∋ {shortName v}.{inner}"
  | none =>
    if fieldStr.isEmpty then shortName root else s!"{shortName root}.{fieldStr}"

end Lemma.Meta
