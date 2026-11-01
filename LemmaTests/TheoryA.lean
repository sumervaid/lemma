import Lemma.Library

/-!
# Test: Q4 contradiction, first theory module

The theory tag of a proposition is the last component of its module name,
so this file is theory `TheoryA` and `LemmaTests.TheoryB` is theory
`TheoryB`.
-/

namespace LemmaTests.TheoryA
open Lemma

/-- Demands. -/
@[construct] structure Demands extends JobCharacteristic (level := .Individual) (horizon := .Weekly) where
  workload : Demand .Workload

/-- Exhaustion. -/
@[construct] structure Exhaustion extends AffectiveState (level := .Individual) (horizon := .Weekly) where
  energy : Energy

/-- Performance. -/
@[construct] structure Performance extends Outcome (level := .Individual) (horizon := .Weekly) where
  performance : Lemma.Performance .Task

/-- Resources. -/
@[construct] structure Resources extends JobCharacteristic (level := .Individual) (horizon := .Weekly) where
  autonomy : Resource .Autonomy

/-- Demands raise exhaustion. -/
@[proposition] def demands_exhaustion : Proposition Demands Exhaustion :=
  { direction := .Positive, level := .Individual, horizon := .Weekly, evidence := .MetaAnalytic, citation := "A" }

/-- Exhaustion lowers performance. -/
@[proposition] def exhaustion_performance : Proposition Exhaustion Performance :=
  { direction := .Negative, level := .Individual, horizon := .Weekly, evidence := .Longitudinal, citation := "A" }

/-- Resources lower exhaustion when demands are high. -/
@[proposition] def resources_exhaustion_moderated : Proposition Resources Exhaustion :=
  { direction := .Negative, level := .Individual, horizon := .Weekly,
    boundary := .moderator Demands .Amplifies, evidence := .CrossSectional, citation := "A" }

-- A contradiction inside one theory is an error.
/--
error: `demands_exhaustion_null` (Null) contradicts `demands_exhaustion` (Positive) in the same theory `TheoryA` on Demands → Exhaustion at Individual / Weekly
-/
#guard_msgs in
/-- Demands do not raise exhaustion. -/
@[proposition] def demands_exhaustion_null : Proposition Demands Exhaustion :=
  { direction := .Null, level := .Individual, horizon := .Weekly, evidence := .None, citation := "A" }

/--
info: implied (untested): Demands → Performance Negative at Individual / Weekly, from demands_exhaustion ∘ exhaustion_performance [TheoryA]
-/
#guard_msgs in
#derive_implied

end LemmaTests.TheoryA
