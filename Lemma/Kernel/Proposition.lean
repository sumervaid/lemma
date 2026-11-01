import Lemma.Kernel.Aggregation

/-!
# Kernel rule 5: propositions

A proposition is a typed relation between two registered constructs with a
declared direction, level, horizon, boundary condition and evidence kind.

The type `Proposition A B` demands `IsConstruct A` and `IsConstruct B`, so a
proposition over an unregistered construct fails to type-check. The scope
check (declared level and horizon against the scopes of `A` and `B`, with
routing through registered aggregation and temporal rules) and the
contradiction check run in the metaprogramming layer when the proposition
is registered with `@[proposition]`.
-/

namespace Lemma

/-- Effect of a moderator on the focal relation. -/
inductive ModerationEffect
  | /-- The relation weakens as the moderator rises. -/
    Buffers
  | /-- The relation strengthens as the moderator rises. -/
    Amplifies
  | /-- The relation holds only within a range of the moderator. -/
    Conditions
  deriving DecidableEq, Repr, Inhabited

/-- Boundary condition of a proposition. -/
inductive Boundary
  | /-- The relation is asserted without qualification at the declared scope. -/
    none
  | /-- A registered construct moderates the relation. -/
    moderator (M : Type) [IsConstruct M] (effect : ModerationEffect)
  | /-- The relation is restricted to a described population or setting. -/
    scope (description : String)

/-- Kernel rule 5. A typed relation from construct `A` (antecedent) to
construct `B` (consequent). -/
structure Proposition (A B : Type) [IsConstruct A] [IsConstruct B] where
  direction : Direction
  level : Level
  horizon : Horizon
  boundary : Boundary := .none
  evidence : EvidenceKind
  citation : String

def ModerationEffect.toString : ModerationEffect → String
  | .Buffers => "Buffers"
  | .Amplifies => "Amplifies"
  | .Conditions => "Conditions"

instance : ToString ModerationEffect := ⟨ModerationEffect.toString⟩

end Lemma
