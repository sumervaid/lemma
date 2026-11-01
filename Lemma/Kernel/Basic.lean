/-!
# Lemma kernel: basic vocabularies

This file is part of the **kernel**: the construction rules every construct
and proposition in the library must reduce to. The kernel carries zero
psychological content. The only things declared here are the index sets
along which measurement events, constructs and propositions are typed.

The kernel is versioned. A change to any file under `Lemma/Kernel/` is a
reviewed contribution and bumps `KERNEL_VERSION` (see `CHANGELOG.md`).
-/

namespace Lemma

/-- Semantic version of the kernel construction rules. -/
def KERNEL_VERSION : String := "0.1.0"

/-- Unit of analysis at which an observation is taken or a construct lives. -/
inductive Level
  | Individual
  | Dyad
  | Team
  | Unit
  | Organization
  deriving DecidableEq, Repr, Inhabited, Hashable, Ord

/-- Time horizon over which an observation or construct is indexed.
`Static` marks a trait-like quantity with no declared time index. -/
inductive Horizon
  | Momentary
  | Daily
  | Weekly
  | Monthly
  | Annual
  | Static
  deriving DecidableEq, Repr, Inhabited, Hashable, Ord

/-- Provenance of a measurement event. -/
inductive Source
  | SelfReport
  | OtherReport
  | Sensor
  | Administrative
  | Behavioral
  deriving DecidableEq, Repr, Inhabited, Hashable, Ord

/-- Sign of a typed relation between two constructs. -/
inductive Direction
  | Positive
  | Negative
  | Null
  | Curvilinear
  deriving DecidableEq, Repr, Inhabited, Hashable, Ord

/-- Strongest kind of evidence attached to a proposition at the time of
formalization. `None` marks a proposition stated without evidence, for
instance one implied by composition of two theories. -/
inductive EvidenceKind
  | Experimental
  | Longitudinal
  | CrossSectional
  | MetaAnalytic
  | Simulation
  | None
  deriving DecidableEq, Repr, Inhabited, Hashable, Ord

/-- Strict ordering of levels from the smallest unit to the largest. -/
def Level.rank : Level → Nat
  | .Individual => 0
  | .Dyad => 1
  | .Team => 2
  | .Unit => 3
  | .Organization => 4

/-- Strict ordering of horizons from the shortest to the longest, with
`Static` ranked last because a static quantity has no time index. -/
def Horizon.rank : Horizon → Nat
  | .Momentary => 0
  | .Daily => 1
  | .Weekly => 2
  | .Monthly => 3
  | .Annual => 4
  | .Static => 5

def Level.toString : Level → String
  | .Individual => "Individual"
  | .Dyad => "Dyad"
  | .Team => "Team"
  | .Unit => "Unit"
  | .Organization => "Organization"

def Horizon.toString : Horizon → String
  | .Momentary => "Momentary"
  | .Daily => "Daily"
  | .Weekly => "Weekly"
  | .Monthly => "Monthly"
  | .Annual => "Annual"
  | .Static => "Static"

def Source.toString : Source → String
  | .SelfReport => "SelfReport"
  | .OtherReport => "OtherReport"
  | .Sensor => "Sensor"
  | .Administrative => "Administrative"
  | .Behavioral => "Behavioral"

def Direction.toString : Direction → String
  | .Positive => "Positive"
  | .Negative => "Negative"
  | .Null => "Null"
  | .Curvilinear => "Curvilinear"

def EvidenceKind.toString : EvidenceKind → String
  | .Experimental => "Experimental"
  | .Longitudinal => "Longitudinal"
  | .CrossSectional => "CrossSectional"
  | .MetaAnalytic => "MetaAnalytic"
  | .Simulation => "Simulation"
  | .None => "None"

instance : ToString Level := ⟨Level.toString⟩
instance : ToString Horizon := ⟨Horizon.toString⟩
instance : ToString Source := ⟨Source.toString⟩
instance : ToString Direction := ⟨Direction.toString⟩
instance : ToString EvidenceKind := ⟨EvidenceKind.toString⟩

/-- Sign algebra used when composing propositions transitively along a
mediating path. `Positive ∘ Positive = Positive`, `Positive ∘ Negative =
Negative`. A `Null` link means the path contributes nothing, which says
nothing about the total relation, so the composition is undefined, as it
is for `Curvilinear`. -/
def Direction.compose : Direction → Direction → Option Direction
  | .Positive, .Positive => some .Positive
  | .Negative, .Negative => some .Positive
  | .Positive, .Negative => some .Negative
  | .Negative, .Positive => some .Negative
  | _, _ => none

/-- Two directions contradict when both are linear and disagree in sign,
or when one asserts a null relation and the other a signed one. -/
def Direction.contradicts : Direction → Direction → Bool
  | .Positive, .Negative | .Negative, .Positive => true
  | .Null, .Positive | .Null, .Negative | .Positive, .Null | .Negative, .Null => true
  | _, _ => false

/-- Two directions disagree in shape when exactly one is curvilinear. -/
def Direction.shapeDisagrees : Direction → Direction → Bool
  | .Curvilinear, .Curvilinear => false
  | .Curvilinear, _ | _, .Curvilinear => true
  | _, _ => false

end Lemma
