import Lemma.Kernel.Basic

/-!
# Kernel rule 1: observations

An `Observation` is a measurement event. It records the unit of analysis
at which the event was taken, the time index and horizon over which the
event is interpreted, the source of the reading, and the reading itself.

Nothing in this file says what was measured. Meaning is attached only by
constructs (rule 2), which are functions from observations to typed values.
-/

namespace Lemma

/-- Kernel rule 1. A single measurement event. -/
structure Observation where
  /-- Unit of analysis the reading belongs to. -/
  level : Level
  /-- Horizon over which the reading is interpreted. -/
  horizon : Horizon
  /-- Provenance of the reading. -/
  source : Source
  /-- Identifier of the unit (person, dyad, team, ...) the reading belongs to. -/
  unitId : Nat
  /-- Discrete time index in units of `horizon`. -/
  time : Nat
  /-- The raw reading. Scales are normalized to `[0, 1]` by the library. -/
  value : Float
  deriving Repr, Inhabited

/-- A bundle of observations all taken at one level and one horizon.
Constructs consume bundles, which is what fixes the scope of a construct. -/
structure ObservationBundle (level : Level) (horizon : Horizon) where
  observations : List Observation
  /-- Every observation in the bundle carries the bundle's scope. -/
  wellScoped : ∀ o ∈ observations, o.level = level ∧ o.horizon = horizon

/-- The empty bundle at any scope. -/
def ObservationBundle.empty (level : Level) (horizon : Horizon) :
    ObservationBundle level horizon :=
  ⟨[], by intro o h; cases h⟩

end Lemma
