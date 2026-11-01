import Lemma.Kernel.Construct

/-!
# Kernel rules 3 and 4: aggregation and temporal rules

Rule 3. An aggregation rule maps a construct across levels. Rule 4. A
temporal rule maps a construct across horizons. Both are explicit library
objects. The kernel enforces, with decidable proof obligations discharged
by `decide`, that an aggregation strictly raises the level while keeping
the horizon, and that a temporal rule strictly lengthens the horizon while
keeping the level. A rule which violates either constraint fails to
type-check.

The metaprogramming layer registers each rule (`@[aggregation]`,
`@[temporal]`) so that the scope check on propositions (`Lemma.Meta.Scope`)
can route a construct through a declared rule. A proposition whose
constructs live at a scope other than the declared one, with no registered
rule bridging the gap, is rejected.
-/

namespace Lemma

/-- How individual-level values combine into a higher-level value
(Chan 1998 composition models; Kozlowski & Klein 2000). -/
inductive AggregationRule
  | /-- Arithmetic mean of lower-level values (additive composition). -/
    Mean
  | /-- Sum of lower-level values. -/
    Sum
  | /-- Maximum of lower-level values. -/
    Max
  | /-- Minimum of lower-level values. -/
    Min
  | /-- Within-unit dispersion (a dispersion model). -/
    Dispersion
  | /-- Mean justified by within-unit agreement (direct consensus). -/
    DirectConsensus
  | /-- Mean of items whose referent is the unit (referent-shift consensus). -/
    ReferentShift
  deriving DecidableEq, Repr, Inhabited

/-- How shorter-horizon values combine into a longer-horizon value. -/
inductive TemporalRule
  | /-- Mean over the longer window. -/
    Mean
  | /-- Linear trend over the longer window. -/
    Trend
  | /-- Peak value over the longer window. -/
    Peak
  | /-- Accumulated (summed) value over the longer window. -/
    Cumulative
  | /-- Value lagged by one period of the shorter horizon. -/
    Lagged
  | /-- Within-window variability. -/
    Variability
  deriving DecidableEq, Repr, Inhabited

/-- Kernel rule 3. An explicit mapping of construct `A` to construct `B` at a
strictly higher level and the same horizon. -/
structure Aggregation (A B : Type) [IsConstruct A] [IsConstruct B] where
  rule : AggregationRule
  citation : String
  /-- Aggregation strictly raises the level. Discharged by `decide`. -/
  raisesLevel : (Construct.levelOf A).rank < (Construct.levelOf B).rank := by decide
  /-- Aggregation keeps the horizon. Discharged by `decide`. -/
  keepsHorizon : Construct.horizonOf A = Construct.horizonOf B := by decide

/-- Kernel rule 4. An explicit mapping of construct `A` to construct `B` at a
strictly longer horizon and the same level. -/
structure Temporal (A B : Type) [IsConstruct A] [IsConstruct B] where
  rule : TemporalRule
  citation : String
  /-- A temporal rule strictly lengthens the horizon. Discharged by `decide`. -/
  lengthensHorizon : (Construct.horizonOf A).rank < (Construct.horizonOf B).rank := by decide
  /-- A temporal rule keeps the level. Discharged by `decide`. -/
  keepsLevel : Construct.levelOf A = Construct.levelOf B := by decide

def AggregationRule.toString : AggregationRule → String
  | .Mean => "Mean"
  | .Sum => "Sum"
  | .Max => "Max"
  | .Min => "Min"
  | .Dispersion => "Dispersion"
  | .DirectConsensus => "DirectConsensus"
  | .ReferentShift => "ReferentShift"

def TemporalRule.toString : TemporalRule → String
  | .Mean => "Mean"
  | .Trend => "Trend"
  | .Peak => "Peak"
  | .Cumulative => "Cumulative"
  | .Lagged => "Lagged"
  | .Variability => "Variability"

instance : ToString AggregationRule := ⟨AggregationRule.toString⟩
instance : ToString TemporalRule := ⟨TemporalRule.toString⟩

end Lemma
