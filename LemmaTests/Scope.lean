import Lemma.Library

/-!
# Test: Q3 scope, aggregation and temporal rules

A proposition's constructs must live at its declared scope or be routed
through registered rules. The kernel rejects rules which lower a level or
shorten a horizon by `decide`. Static constructs embed into every horizon.
-/

namespace LemmaTests.Scope
open Lemma

/-- Individual weekly demands. -/
@[construct] structure Demands extends JobCharacteristic (level := .Individual) (horizon := .Weekly) where
  workload : Demand .Workload

/-- Individual weekly exhaustion. -/
@[construct] structure Exhaustion extends AffectiveState (level := .Individual) (horizon := .Weekly) where
  energy : Energy

/-- Team weekly exhaustion. -/
@[construct] structure TeamExhaustion extends AffectiveState (level := .Team) (horizon := .Weekly) where
  energy : Energy

/-- Daily exhaustion. -/
@[construct] structure DailyExhaustion extends AffectiveState (level := .Individual) (horizon := .Daily) where
  energy : Energy

/-- A trait. -/
@[construct] structure Neuroticism extends Disposition (level := .Individual) (horizon := .Static) where
  trait : Trait .Neuroticism

-- An exact-scope proposition registers silently.
#guard_msgs in
/-- Demands predict exhaustion. -/
@[proposition] def demands_exhaustion : Proposition Demands Exhaustion :=
  { direction := .Positive, level := .Individual, horizon := .Weekly, evidence := .None, citation := "test" }

-- A team-level proposition over individual constructs with no aggregation rule is rejected.
/--
error: scope mismatch in `demands_exhaustion_team`: Demands lives at Individual / Weekly but the proposition declares Team / Weekly; no registered rule bridges the gap (needs an Aggregation from Demands to a Team-level construct)
-/
#guard_msgs in
/-- Demands predict exhaustion at the team level. -/
@[proposition] def demands_exhaustion_team : Proposition Demands Exhaustion :=
  { direction := .Positive, level := .Team, horizon := .Weekly, evidence := .None, citation := "test" }

-- An aggregation which lowers the level fails to type-check.
/--
error: could not synthesize default value for field 'raisesLevel' of 'Lemma.Aggregation' using tactics
---
error: tactic 'decide' proved that the proposition
  (Construct.levelOf TeamExhaustion).rank < (Construct.levelOf Exhaustion).rank
is false
-/
#guard_msgs in
/-- Wrong direction. -/
@[aggregation] def lowering : Aggregation TeamExhaustion Exhaustion :=
  { rule := .Mean, citation := "test" }

-- A temporal rule which shortens the horizon fails to type-check.
/--
error: could not synthesize default value for field 'lengthensHorizon' of 'Lemma.Temporal' using tactics
---
error: tactic 'decide' proved that the proposition
  (Construct.horizonOf Exhaustion).rank < (Construct.horizonOf DailyExhaustion).rank
is false
-/
#guard_msgs in
/-- Wrong direction. -/
@[temporal] def shortening : Temporal Exhaustion DailyExhaustion :=
  { rule := .Mean, citation := "test" }

/-- Exhaustion aggregates to the team by the mean. -/
@[aggregation] def exhaustionTeam : Aggregation Exhaustion TeamExhaustion :=
  { rule := .Mean, citation := "test" }

/-- Daily exhaustion aggregates to the week by the mean. -/
@[temporal] def exhaustionWeekly : Temporal DailyExhaustion Exhaustion :=
  { rule := .Mean, citation := "test" }

-- With the rule registered, the consequent is routed and the antecedent still fails.
/--
error: scope mismatch in `demands_exhaustion_team2`: Demands lives at Individual / Weekly but the proposition declares Team / Weekly; no registered rule bridges the gap (needs an Aggregation from Demands to a Team-level construct)
-/
#guard_msgs in
/-- Demands predict exhaustion at the team level. -/
@[proposition] def demands_exhaustion_team2 : Proposition Demands Exhaustion :=
  { direction := .Positive, level := .Team, horizon := .Weekly, evidence := .None, citation := "test" }

-- A proposition over a team construct and a routed individual construct is accepted with a note.
/-- info: `team_exhaustion_exhaustion` is routed through exhaustionTeam -/
#guard_msgs in
/-- Team exhaustion crosses over to the individual, stated at the team level. -/
@[proposition] def team_exhaustion_exhaustion : Proposition TeamExhaustion Exhaustion :=
  { direction := .Positive, level := .Team, horizon := .Weekly, evidence := .None, citation := "test" }

-- Daily to weekly routing through a temporal rule.
/-- info: `daily_demands` is routed through exhaustionWeekly -/
#guard_msgs in
/-- Daily exhaustion follows demands, stated weekly. -/
@[proposition] def daily_demands : Proposition Demands DailyExhaustion :=
  { direction := .Positive, level := .Individual, horizon := .Weekly, evidence := .None, citation := "test" }

-- A static trait enters a weekly proposition by the static-embedding rule.
#guard_msgs in
/-- Neuroticism predicts exhaustion. -/
@[proposition] def neuroticism_exhaustion : Proposition Neuroticism Exhaustion :=
  { direction := .Positive, level := .Individual, horizon := .Weekly, evidence := .None, citation := "test" }

/-- info: team_exhaustion_exhaustion: TeamExhaustion → Exhaustion at Team / Weekly, routed through exhaustionTeam -/
#guard_msgs in
#check_scope team_exhaustion_exhaustion

end LemmaTests.Scope
