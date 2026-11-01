import Lemma.Theories.Activation

/-!
# Team-level engagement and performance (Bakker, van Emmerik & Euwema 2006; Costa, Passos & Bakker 2014; Torrente, Salanova, Llorens & Schaufeli 2012)

Engagement crosses over within teams and aggregates to a team-level
state. The pilot registers the aggregation rules from individual
engagement and performance to the team and states the team-level
proposition over the aggregates.
-/

namespace Lemma.Theories.Team

/-- Team work engagement: a shared positive state of the team (Costa, Passos
& Bakker 2014), with the same three facets at the team level. -/
@[construct] structure TeamEngagement extends AffectiveState (level := .Team) (horizon := .Weekly) where
  vigor : Energy
  dedication : Identification .Work
  absorption : Attention .Work

/-- Team task performance (Torrente et al. 2012, supervisor-rated). -/
@[construct] structure TeamPerformance extends Outcome (level := .Team) (horizon := .Weekly) where
  performance : Performance .Task

/-- Individual engagement aggregates to the team by referent-shift
consensus (Costa, Passos & Bakker 2014); Bakker et al. 2006 use the mean. -/
@[aggregation] def engagementTeam : Aggregation Engagement.Engagement TeamEngagement :=
  { rule := .ReferentShift, citation := "Costa, Passos & Bakker 2014, Eur. J. Work Organ. Psychol. 23, 414-429" }

/-- Individual task performance aggregates to the team by the mean. -/
@[aggregation] def performanceTeam : Aggregation Engagement.TaskPerformance TeamPerformance :=
  { rule := .Mean, citation := "Torrente, Salanova, Llorens & Schaufeli 2012, Psicothema 24, 106-112" }

/-- Team engagement predicts team performance (Torrente et al. 2012). -/
@[proposition] def team_engagement_performance : Proposition TeamEngagement TeamPerformance :=
  { direction := .Positive, level := .Team, horizon := .Weekly,
    evidence := .CrossSectional,
    citation := "Torrente, Salanova, Llorens & Schaufeli 2012, Psicothema 24, 106-112" }

/-- Team-level engagement relates to individual engagement through
crossover (Bakker, van Emmerik & Euwema 2006). Stated at the team level
over the aggregate, routed through `engagementTeam`. -/
@[proposition] def engagement_team_performance : Proposition Engagement.Engagement TeamPerformance :=
  { direction := .Positive, level := .Team, horizon := .Weekly,
    evidence := .CrossSectional,
    citation := "Bakker, van Emmerik & Euwema 2006, Work Occup. 33, 464-489" }

end Lemma.Theories.Team
