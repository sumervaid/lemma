import Lemma.Meta.Registry

/-!
# Q3: scope checking

A proposition declares a level and a horizon. Each of its two constructs
must live at that scope, or be routed to it through registered rules:

* an `@[aggregation]` rule from the construct to a registered construct at
  the declared level (same horizon), and / or
* an `@[temporal]` rule from the construct (or from the aggregation target)
  to a registered construct at the declared horizon (same level).

A construct declared at `Horizon.Static` is a constant function of time
and so embeds into every horizon at its own level (the *static embedding*
rule): a trait may enter a weekly proposition without a temporal rule.

Routing is decidable by finite search over the registry. A proposition
whose constructs cannot be routed is rejected by `@[proposition]`.
-/

open Lean

namespace Lemma.Meta

/-- Outcome of routing one construct to a target scope. -/
inductive RouteResult
  | exact
  | routed (rules : List Name) (finalConstruct : Name)
  | failed (reason : String)
  deriving Inhabited, Repr

/-- Horizon match: equal, or the construct is static (static embedding). -/
def horizonMatches (constructHorizon declared : Horizon) : Bool :=
  constructHorizon == declared || constructHorizon == .Static

/-- Route construct `c` to scope `(level, horizon)` through registered rules. -/
def routeConstruct (env : Environment) (c : Name) (level : Level) (horizon : Horizon) : RouteResult :=
  match findConstruct? env c with
  | none => .failed s!"{shortName c} is not a registered construct"
  | some ce =>
    if ce.level == level && horizonMatches ce.horizon horizon then .exact
    else
      -- level step
      let levelCandidates : List (Name × List Name) :=
        if ce.level == level then [(c, [])]
        else
          (aggregationExt.all env).toList.filterMap fun a =>
            if a.source == c then
              match findConstruct? env a.target with
              | some t => if t.level == level then some (a.target, [a.name]) else none
              | none => none
            else none
      -- horizon step
      let full : List (Name × List Name) :=
        levelCandidates.flatMap fun (n, rules) =>
          match findConstruct? env n with
          | some t =>
            if horizonMatches t.horizon horizon then [(n, rules)]
            else
              (temporalExt.all env).toList.filterMap fun tr =>
                if tr.source == n then
                  match findConstruct? env tr.target with
                  | some t' => if horizonMatches t'.horizon horizon then some (tr.target, rules ++ [tr.name]) else none
                  | none => none
                else none
          | none => []
      match full with
      | (n, rules) :: _ => .routed rules n
      | [] =>
        let need := if ce.level != level && ce.horizon != horizon then
            s!"an Aggregation from {shortName c} to a {level}-level construct and a Temporal rule to the {horizon} horizon"
          else if ce.level != level then
            s!"an Aggregation from {shortName c} to a {level}-level construct"
          else
            s!"a Temporal rule from {shortName c} to the {horizon} horizon"
        .failed s!"{shortName c} lives at {ce.level} / {ce.horizon} but the proposition declares {level} / {horizon}; no registered rule bridges the gap (needs {need})"

/-- Combine the routes of the antecedent and consequent into a scope status. -/
def scopeStatus (env : Environment) (a b : Name) (level : Level) (horizon : Horizon) :
    Except String ScopeStatus :=
  match routeConstruct env a level horizon, routeConstruct env b level horizon with
  | .failed r, _ => .error r
  | _, .failed r => .error r
  | .exact, .exact => .ok .exact
  | .exact, .routed rs _ => .ok (.routed rs)
  | .routed rs _, .exact => .ok (.routed rs)
  | .routed rs _, .routed rs' _ => .ok (.routed (rs ++ rs'))

end Lemma.Meta
