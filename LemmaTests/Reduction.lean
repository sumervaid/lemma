import Lemma.Library

/-!
# Test: Q1 reduction

A construct must reduce to registered primitives. Fields of other types,
axioms and opaque constants are rejected, and the `IsConstruct` instance
is only generated for constructs that pass.
-/

namespace LemmaTests.Reduction
open Lemma

/--
error: construct `BadNat` does not reduce to primitives
  Nat at count: `Nat` is neither a registered primitive, a registered construct, a product, nor a structure extending `Construct`: the construct rests on an undefined term
-/
#guard_msgs in
/-- A construct with a raw numeric field. -/
@[construct] structure BadNat extends AffectiveState (level := .Individual) (horizon := .Weekly) where
  count : Nat

/-- An undefined term. -/
axiom Charisma : Type

/--
error: construct `BadAxiom` does not reduce to primitives
  Charisma at charisma: `LemmaTests.Reduction.Charisma` is an axiom: the construct rests on an undefined term
-/
#guard_msgs in
/-- A construct resting on an undefined term. -/
@[construct] structure BadAxiom extends AffectiveState (level := .Individual) (horizon := .Weekly) where
  charisma : Charisma

/-- A primitive used outside any `Construct` scope. -/
def Bare := Energy × Energy

/--
error: construct `Bare` does not reduce to primitives
  Energy at fst: primitive Energy reached outside any `Construct` scope; composite definitions must be built from constructs which extend `Construct l h`
  Energy at snd: primitive Energy reached outside any `Construct` scope; composite definitions must be built from constructs which extend `Construct l h`
-/
#guard_msgs in
attribute [construct] Bare

/-- error: construct `NoDoc` requires a citation docstring (see CONTRIBUTING.md) -/
#guard_msgs in
@[construct] structure NoDoc extends AffectiveState (level := .Individual) (horizon := .Weekly) where
  energy : Energy

/-- A good construct. -/
@[construct] structure Good extends AffectiveState (level := .Individual) (horizon := .Weekly) where
  energy : Energy

-- The instance exists for a registered construct ...
example : IsConstruct Good := inferInstance

-- ... and does not for a type which never passed the check.
/--
error: failed to synthesize
  IsConstruct Nat
Additional diagnostic information may be available using the `set_option diagnostics true` command.
-/
#guard_msgs in
example : IsConstruct Nat := inferInstance

-- A proposition over an unregistered type does not type-check.
/--
error: failed to synthesize
  IsConstruct BadNat
Additional diagnostic information may be available using the `set_option diagnostics true` command.
-/
#guard_msgs in
def bad : Proposition BadNat Good :=
  { direction := .Positive, level := .Individual, horizon := .Weekly, evidence := .None, citation := "" }

/-- A composite mixing scopes is rejected. -/
@[construct] structure Daily extends AffectiveState (level := .Individual) (horizon := .Daily) where
  energy : Energy

/--
error: construct `Mixed`: components live at different scopes (Individual / Weekly, Individual / Daily); declare the composite as a structure extending `Construct l h` and route components through aggregation or temporal rules
-/
#guard_msgs in
/-- Weekly times daily. -/
@[construct] def Mixed := Good × Daily

end LemmaTests.Reduction
