import LemmaTests.TheoryA

/-!
# Test: Q4 contradiction, second theory module

Propositions here are theory `TheoryB`. A contradiction with `TheoryA`
is a warning and is recorded; a shape disagreement is informational; a
proposition with a different boundary condition is not comparable.
-/

namespace LemmaTests.TheoryB
open Lemma LemmaTests.TheoryA

/--
warning: contradicts demands_exhaustion (TheoryA): Demands → Exhaustion is Negative here and Positive there at Individual / Weekly
-/
#guard_msgs in
/-- Demands lower exhaustion. -/
@[proposition] def demands_exhaustion : Proposition Demands Exhaustion :=
  { direction := .Negative, level := .Individual, horizon := .Weekly, evidence := .CrossSectional, citation := "B" }

/--
info: shape disagreement with exhaustion_performance (TheoryA): Exhaustion → Performance is Curvilinear here and Negative there
-/
#guard_msgs in
/-- Exhaustion and performance follow an inverted U. -/
@[proposition] def exhaustion_performance : Proposition Exhaustion Performance :=
  { direction := .Curvilinear, level := .Individual, horizon := .Weekly, evidence := .CrossSectional, citation := "B" }

-- A different boundary condition makes the propositions incomparable: no message.
#guard_msgs in
/-- Resources raise exhaustion when demands are high (different direction, same moderator). -/
@[proposition] def resources_exhaustion_unmoderated : Proposition Resources Exhaustion :=
  { direction := .Positive, level := .Individual, horizon := .Weekly, evidence := .None, citation := "B" }

/--
warning: cross-theory contradiction: Demands → Exhaustion at Individual / Weekly is Positive in demands_exhaustion (TheoryA) and Negative in demands_exhaustion (TheoryB)
---
info: shape disagreement: Exhaustion → Performance is Negative in exhaustion_performance (TheoryA) and Curvilinear in exhaustion_performance (TheoryB)
-/
#guard_msgs in
#check_contradictions

-- Composition across theories: TheoryB's negative demands link with TheoryA's exhaustion link.
/--
info: implied (untested): Demands → Performance Negative at Individual / Weekly, from demands_exhaustion ∘ exhaustion_performance [TheoryA]
---
info: implied (untested): Demands → Performance Positive at Individual / Weekly, from demands_exhaustion ∘ exhaustion_performance [TheoryB, TheoryA]
---
info: implied (untested): Resources → Performance Negative at Individual / Weekly, from resources_exhaustion_unmoderated ∘ exhaustion_performance [TheoryB, TheoryA]
-/
#guard_msgs in
#derive_implied

end LemmaTests.TheoryB
