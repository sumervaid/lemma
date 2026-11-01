import Lemma.Meta.Attributes

/-!
# On-demand compiler commands

* `#reduce_construct C` prints the primitive leaves `C` unfolds to, with
  their scope, then runs the overlap check (Q1 + Q2 on demand).
* `#check_overlap C` runs the overlap check alone (Q2).
* `#check_scope p` prints the scope status of a registered proposition (Q3).
* `#check_contradictions` lists every cross-theory contradiction and shape
  disagreement in the registry (Q4).
* `#derive_implied` lists the propositions implied by length-2 composition
  and whether each is tested, untested or contradicted (Q4).
* `declare_overlap A distinct_from B "reason"` (or `alias_of`,
  `subtype_of`) records the scholar's resolution of an overlap warning.
* `#lemma_report "path.json"` writes the whole registry and every check
  result to a JSON file. The Python pipeline consumes this file.
* `#lemma_stats` prints counts.
-/

open Lean Elab Command Meta

namespace Lemma.Meta

/-- Resolve an identifier to a global constant in command context. -/
private def resolveConst (stx : Syntax) : CommandElabM Name :=
  liftTermElabM do
    let n ← realizeGlobalConstNoOverloadWithInfo stx
    return n

syntax (name := reduceConstructCmd) "#reduce_construct " ident : command

@[command_elab reduceConstructCmd] def elabReduceConstruct : CommandElab
  | `(#reduce_construct $c:ident) => do
    let n ← resolveConst c
    liftTermElabM do
      let r ← reduceConstruct n
      let mut lines : Array String := #[]
      for leaf in r.leaves do
        let viaStr := match leaf.via with
          | some v => s!"{shortName v} unfolds to"
          | none => s!"{shortName n}.{String.intercalate "." (leaf.path.map toString)} is"
        lines := lines.push s!"{viaStr} {leaf.display} at {leaf.level} / {leaf.horizon}"
      for f in r.failures do
        lines := lines.push s!"FAIL {f.type}: {f.reason}"
      let scopeLine := match r.scope? with
        | .ok (l, h) => s!"scope: {l} / {h}{if r.declaredScope.isSome then " (declared)" else " (inferred)"}"
        | .error e => s!"scope: undetermined ({e})"
      logInfo (String.intercalate "\n" (lines.toList ++ [scopeLine]))
      let _ ← warnOverlaps n r.leaves r.components
  | _ => throwUnsupportedSyntax

syntax (name := checkOverlapCmd) "#check_overlap " ident : command

@[command_elab checkOverlapCmd] def elabCheckOverlap : CommandElab
  | `(#check_overlap $c:ident) => do
    let n ← resolveConst c
    liftTermElabM do
      let env ← getEnv
      let some ce := findConstruct? env n
        | throwError "`{shortName n}` is not a registered construct; tag it with `@[construct]` first"
      let reports ← warnOverlaps n ce.leaves ce.components
      for r in reports do
        if let some d := r.declared then
          logInfo s!"overlap with {shortName r.b} ({r.kind}) declared: {shortName d.a} {d.kind} {shortName d.b} ({d.reason})"
      let shifts := scopeShiftsOf env n ce.leaves ce.components
      for s in shifts do
        logInfo s!"scope shift: {s.inA} ({s.scopeA}) and {s.inB} ({s.scopeB}) share primitive {s.prim} at different scopes; connect them with a temporal or aggregation rule"
      if reports.isEmpty && shifts.isEmpty then
        logInfo s!"{shortName n}: no overlap with any registered construct"
  | _ => throwUnsupportedSyntax

syntax (name := checkScopeCmd) "#check_scope " ident : command

@[command_elab checkScopeCmd] def elabCheckScope : CommandElab
  | `(#check_scope $p:ident) => do
    let n ← resolveConst p
    liftTermElabM do
      let env ← getEnv
      let some pe := (propositionExt.all env).find? (·.name == n)
        | throwError "`{shortName n}` is not a registered proposition"
      match pe.scope with
      | .exact => logInfo s!"{shortName n}: {shortName pe.antecedent} → {shortName pe.consequent} at {pe.level} / {pe.horizon}, both constructs at the declared scope"
      | .routed rs => logInfo s!"{shortName n}: {shortName pe.antecedent} → {shortName pe.consequent} at {pe.level} / {pe.horizon}, routed through {String.intercalate ", " (rs.map shortName)}"
  | _ => throwUnsupportedSyntax

syntax (name := checkContradictionsCmd) "#check_contradictions" : command

@[command_elab checkContradictionsCmd] def elabCheckContradictions : CommandElab
  | `(#check_contradictions) => liftTermElabM do
    let props := propositionExt.all (← getEnv)
    let cs := contradictions props
    let ss := shapeDisagreements props
    for c in cs do
      let kind := if c.theoryA == c.theoryB then "within-theory" else "cross-theory"
      logWarning s!"{kind} contradiction: {shortName c.antecedent} → {shortName c.consequent} at {c.level} / {c.horizon} is {c.directionA} in {shortName c.a} ({c.theoryA}) and {c.directionB} in {shortName c.b} ({c.theoryB})"
    for s in ss do
      logInfo s!"shape disagreement: {shortName s.antecedent} → {shortName s.consequent} is {s.directionA} in {shortName s.a} ({s.theoryA}) and {s.directionB} in {shortName s.b} ({s.theoryB})"
    if cs.isEmpty && ss.isEmpty then
      logInfo "no contradictions among registered propositions"
  | _ => throwUnsupportedSyntax

syntax (name := deriveImpliedCmd) "#derive_implied" : command

@[command_elab deriveImpliedCmd] def elabDeriveImplied : CommandElab
  | `(#derive_implied) => liftTermElabM do
    let props := propositionExt.all (← getEnv)
    let imps := impliedPropositions props
    if imps.isEmpty then
      logInfo "no implied propositions"
    for i in imps do
      logInfo s!"implied ({i.status}): {shortName i.antecedent} → {shortName i.consequent} {i.direction} at {i.level} / {i.horizon}, from {shortName i.premiseA} ∘ {shortName i.premiseB} [{String.intercalate ", " (i.theories.map toString)}]"
  | _ => throwUnsupportedSyntax

syntax overlapDeclKind := "distinct_from" <|> "alias_of" <|> "subtype_of"
syntax (name := declareOverlapCmd) "declare_overlap " ident overlapDeclKind ident str : command

@[command_elab declareOverlapCmd] def elabDeclareOverlap : CommandElab
  | `(declare_overlap $a:ident $k:overlapDeclKind $b:ident $reason:str) => do
    let an ← resolveConst a
    let bn ← resolveConst b
    let kind : OverlapDeclKind ← match k with
      | `(overlapDeclKind| distinct_from) => pure .distinct_from
      | `(overlapDeclKind| alias_of) => pure .alias_of
      | `(overlapDeclKind| subtype_of) => pure .subtype_of
      | _ => throwUnsupportedSyntax
    let reasonStr := reason.getString
    liftTermElabM do
      let env ← getEnv
      let some ce := findConstruct? env an
        | throwError "`{shortName an}` is not a registered construct"
      unless isConstruct env bn do
        throwError "`{shortName bn}` is not a registered construct"
      if reasonStr.trim.isEmpty then
        throwError "an overlap declaration requires a non-empty reason"
      if (findOverlapDecl? env an bn).isSome then
        throwError "overlap between `{shortName an}` and `{shortName bn}` is already declared"
      let reports := overlapsOf env an ce.leaves ce.components
      let some r := reports.find? (·.b == bn)
        | logWarning s!"`{shortName an}` and `{shortName bn}` share no primitive at a common scope; the declaration is recorded but resolves nothing"
          modifyEnv fun env => overlapDeclExt.addEntry env { a := an, b := bn, kind, reason := reasonStr, module := env.mainModule }
          return
      match kind, r.kind with
      | .alias_of, .identity => pure ()
      | .alias_of, k => logWarning s!"`alias_of` declared, but the overlap kind is {k}: {shortName an} and {shortName bn} do not reduce to the same primitives"
      | .subtype_of, .subtype => pure ()
      | .subtype_of, k => logWarning s!"`subtype_of` declared, but the overlap kind is {k}"
      | .distinct_from, .identity => logInfo s!"`distinct_from` declared for an identity overlap: {shortName an} and {shortName bn} reduce to the same primitives at the same scope; the reason should state what distinguishes them"
      | .distinct_from, _ => pure ()
      modifyEnv fun env => overlapDeclExt.addEntry env { a := an, b := bn, kind, reason := reasonStr, module := env.mainModule }
  | _ => throwUnsupportedSyntax

/-! ## Report -/

/-- The full registry plus every check result, as JSON. -/
def buildReport : CoreM Json := do
  let env ← getEnv
  let constructs := constructExt.all env
  let props := propositionExt.all env
  let mut overlaps : Array OverlapReport := #[]
  let mut shifts : Array ScopeShift := #[]
  -- Each unordered pair once: compare construct i against entries j < i.
  for i in [0:constructs.size] do
    let c := constructs[i]!
    for j in [0:i] do
      let d := constructs[j]!
      if let some r := overlapWith env c.name c.leaves c.components d then
        overlaps := overlaps.push r
      shifts := shifts ++ scopeShiftsWith c.name c.leaves c.components d
  let theories := constructs.foldl (fun (acc : Array Name) c => if acc.contains c.theory then acc else acc.push c.theory) #[]
  let theories := props.foldl (fun acc p => if acc.contains p.theory then acc else acc.push p.theory) theories
  return Json.mkObj [
    ("kernel_version", toJson KERNEL_VERSION),
    ("theories", toJson theories),
    ("primitives", toJson (primitiveExt.all env)),
    ("constructs", toJson constructs),
    ("propositions", toJson props),
    ("aggregations", toJson (aggregationExt.all env)),
    ("temporals", toJson (temporalExt.all env)),
    ("overlap_declarations", toJson (overlapDeclExt.all env)),
    ("overlaps", toJson overlaps),
    ("scope_shifts", toJson shifts),
    ("contradictions", toJson (contradictions props)),
    ("shape_disagreements", toJson (shapeDisagreements props)),
    ("implied", toJson (impliedPropositions props))
  ]

syntax (name := lemmaReportCmd) "#lemma_report " str : command

@[command_elab lemmaReportCmd] def elabLemmaReport : CommandElab
  | `(#lemma_report $path:str) => liftTermElabM do
    let j ← buildReport
    let p := path.getString
    IO.FS.writeFile p (j.pretty 2)
    logInfo s!"wrote {p}"
  | _ => throwUnsupportedSyntax

syntax (name := lemmaStatsCmd) "#lemma_stats" : command

@[command_elab lemmaStatsCmd] def elabLemmaStats : CommandElab
  | `(#lemma_stats) => liftTermElabM do
    let env ← getEnv
    let constructs := constructExt.all env
    let props := propositionExt.all env
    let mut nOverlaps := 0
    let mut nUnresolved := 0
    for i in [0:constructs.size] do
      for j in [0:i] do
        if let some r := overlapWith env constructs[i]!.name constructs[i]!.leaves constructs[i]!.components constructs[j]! then
          nOverlaps := nOverlaps + 1
          if r.declared.isNone then nUnresolved := nUnresolved + 1
    let imps := impliedPropositions props
    logInfo s!"kernel {KERNEL_VERSION}: {(primitiveExt.all env).size} primitives, {constructs.size} constructs, {props.size} propositions, {(aggregationExt.all env).size} aggregation rules, {(temporalExt.all env).size} temporal rules, {nOverlaps} overlaps ({nUnresolved} unresolved), {(contradictions props).size} contradictions, {(imps.filter (·.status == "untested")).size} implied untested"
  | _ => throwUnsupportedSyntax

end Lemma.Meta
