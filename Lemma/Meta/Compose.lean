import Lemma.Meta.Registry

/-!
# Q4: composition and contradiction

Two propositions are **comparable** when they relate the same antecedent
to the same consequent at the same level, horizon and boundary condition.

* Comparable propositions with contradicting directions (`Positive` vs
  `Negative`, or `Null` vs a signed direction) are a **contradiction**.
  Across theories, the compiler records the contradiction and warns.
  Within one theory, the compiler rejects the second proposition.
* Comparable propositions where exactly one is `Curvilinear` are a
  **shape disagreement**, recorded separately.
* Comparable propositions with the same direction from different theories
  are **convergent**: several theories depend on one claim.

**Implied propositions.** Two unconditional propositions `A → B` and
`B → C` at the same scope compose, by the sign algebra
`Direction.compose`, into a candidate `A → C`. A candidate is **tested**
when a registered proposition states the same pair at the same scope,
**untested** otherwise, and **contradicted** when the registered
proposition disagrees in direction. Composition is restricted to length-2
chains. Longer chains are the transitive closure of these and add nothing
the scorer needs at pilot scale.
-/

open Lean

namespace Lemma.Meta

/-- Comparable: same ordered pair of constructs, same scope, same boundary. -/
def comparable (p q : PropositionEntry) : Bool :=
  p.antecedent == q.antecedent && p.consequent == q.consequent &&
  p.level == q.level && p.horizon == q.horizon && p.boundary == q.boundary

structure Contradiction where
  a : Name
  b : Name
  theoryA : Name
  theoryB : Name
  antecedent : Name
  consequent : Name
  level : Level
  horizon : Horizon
  directionA : Direction
  directionB : Direction
  deriving Inhabited, Repr, ToJson

structure ShapeDisagreement where
  a : Name
  b : Name
  theoryA : Name
  theoryB : Name
  antecedent : Name
  consequent : Name
  directionA : Direction
  directionB : Direction
  deriving Inhabited, Repr, ToJson

/-- A proposition implied by composing two registered propositions. -/
structure ImpliedProposition where
  antecedent : Name
  consequent : Name
  direction : Direction
  level : Level
  horizon : Horizon
  premiseA : Name
  premiseB : Name
  theories : List Name
  /-- Registered proposition stating the same pair at the same scope, if any. -/
  registered : Option Name
  /-- `untested`, `tested`, or `contradicted`. -/
  status : String
  deriving Inhabited, Repr, ToJson

/-- Pairs of comparable registered propositions with contradicting directions. -/
def contradictions (props : Array PropositionEntry) : Array Contradiction := Id.run do
  let mut out := #[]
  for i in [0:props.size] do
    for j in [i+1:props.size] do
      let p := props[i]!
      let q := props[j]!
      if comparable p q && p.direction.contradicts q.direction then
        out := out.push {
          a := p.name, b := q.name, theoryA := p.theory, theoryB := q.theory,
          antecedent := p.antecedent, consequent := p.consequent, level := p.level,
          horizon := p.horizon, directionA := p.direction, directionB := q.direction }
  return out

def shapeDisagreements (props : Array PropositionEntry) : Array ShapeDisagreement := Id.run do
  let mut out := #[]
  for i in [0:props.size] do
    for j in [i+1:props.size] do
      let p := props[i]!
      let q := props[j]!
      if comparable p q && p.direction.shapeDisagrees q.direction then
        out := out.push {
          a := p.name, b := q.name, theoryA := p.theory, theoryB := q.theory,
          antecedent := p.antecedent, consequent := p.consequent,
          directionA := p.direction, directionB := q.direction }
  return out

/-- Contradictions of a candidate proposition against the registry, used at
registration time by `@[proposition]`. -/
def contradictionsOf (p : PropositionEntry) (props : Array PropositionEntry) : Array PropositionEntry :=
  props.filter fun q => q.name != p.name && comparable p q && p.direction.contradicts q.direction

/-- Derive implied propositions from all unconditional length-2 chains. -/
def impliedPropositions (props : Array PropositionEntry) : Array ImpliedProposition := Id.run do
  let mut out : Array ImpliedProposition := #[]
  let unconditional := props.filter fun p => p.boundary == .none
  for p in unconditional do
    for q in unconditional do
      if p.consequent == q.antecedent && p.level == q.level && p.horizon == q.horizon
          && p.antecedent != q.consequent then
        match p.direction.compose q.direction with
        | none => pure ()
        | some d =>
          let reg := props.find? fun r =>
            r.antecedent == p.antecedent && r.consequent == q.consequent &&
            r.level == p.level && r.horizon == p.horizon && r.boundary == .none
          let status := match reg with
            | none => "untested"
            | some r => if r.direction.contradicts d then "contradicted" else "tested"
          let theories := if p.theory == q.theory then [p.theory] else [p.theory, q.theory]
          out := out.push {
            antecedent := p.antecedent, consequent := q.consequent, direction := d,
            level := p.level, horizon := p.horizon, premiseA := p.name, premiseB := q.name,
            theories, registered := reg.map (·.name), status }
  return out

end Lemma.Meta
