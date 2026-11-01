import Lemma.Theories.ShiromVigor

/-!
# The challenge-hindrance framework (Cavanaugh, Boswell, Roehling & Boudreau 2000; LePine, Podsakoff & LePine 2005; Crawford, LePine & Rich 2010)

Demands divide into challenges, which promote growth and achievement, and
hindrances, which thwart it. Both produce strain; challenges raise
engagement and performance, hindrances lower them.

The compiler reports that challenge demands share workload and time
pressure with JD-R's job demands and with ERI's effort, and that
hindrance demands share role conflict with job demands. The framework's
claim that demands are not of one kind becomes, in the library, a
`subtype`/`partial` overlap against the undifferentiated bundle.
-/

namespace Lemma.Theories.ChallengeHindrance

/-- Challenge demands: workload, time pressure and responsibility
(Cavanaugh et al. 2000; Crawford et al. 2010). -/
@[construct] structure ChallengeDemands extends JobCharacteristic (level := .Individual) (horizon := .Weekly) where
  workload : Demand .Workload
  timePressure : Demand .TimePressure
  responsibility : Demand .Responsibility

/-- Hindrance demands: role conflict, role ambiguity and administrative
hassles (Cavanaugh et al. 2000; Crawford et al. 2010). -/
@[construct] structure HindranceDemands extends JobCharacteristic (level := .Individual) (horizon := .Weekly) where
  roleConflict : Demand .RoleConflict
  roleAmbiguity : Demand .RoleAmbiguity
  hassles : Demand .Hassle

declare_overlap ChallengeDemands distinct_from JDR.JobDemands
  "Challenge demands are the subset of job demands appraised as promoting growth (Cavanaugh et al. 2000); the pilot's job-demands bundle omits responsibility"
declare_overlap ChallengeDemands distinct_from ERI.Effort
  "The ERI effort scale and the challenge-demand measures share workload, time pressure and responsibility; effort adds interruptions"
declare_overlap ChallengeDemands distinct_from ERI.EffortRewardImbalance
  "Imbalance is a ratio of effort to reward; challenge demands are the effort side alone"
declare_overlap HindranceDemands distinct_from JDR.JobDemands
  "Hindrance demands are the subset of job demands appraised as thwarting growth; the pilot's job-demands bundle shares role conflict"

/-- Challenge demands are positively related to engagement (Crawford, LePine
& Rich 2010, meta-analysis, ρ = .21). -/
@[proposition] def challenge_engagement : Proposition ChallengeDemands Engagement.Engagement :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    evidence := .MetaAnalytic,
    citation := "Crawford, LePine & Rich 2010, J. Appl. Psychol. 95, 834-848" }

/-- Hindrance demands are negatively related to engagement (Crawford et al.
2010, ρ = -.19). -/
@[proposition] def hindrance_engagement : Proposition HindranceDemands Engagement.Engagement :=
  { direction := .Negative, level := .Individual, horizon := .Weekly,
    evidence := .MetaAnalytic,
    citation := "Crawford, LePine & Rich 2010, J. Appl. Psychol. 95, 834-848" }

/-- Challenge demands are positively related to burnout (Crawford et al.
2010). Stated over exhaustion. -/
@[proposition] def challenge_exhaustion : Proposition ChallengeDemands Burnout.Exhaustion :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    evidence := .MetaAnalytic,
    citation := "Crawford, LePine & Rich 2010, J. Appl. Psychol. 95, 834-848" }

/-- Hindrance demands are positively related to burnout (Crawford et al.
2010). Stated over exhaustion. -/
@[proposition] def hindrance_exhaustion : Proposition HindranceDemands Burnout.Exhaustion :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    evidence := .MetaAnalytic,
    citation := "Crawford, LePine & Rich 2010, J. Appl. Psychol. 95, 834-848" }

/-- Challenge stressors are positively related to performance (LePine,
Podsakoff & LePine 2005, meta-analysis). -/
@[proposition] def challenge_task_performance : Proposition ChallengeDemands Engagement.TaskPerformance :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    evidence := .MetaAnalytic,
    citation := "LePine, Podsakoff & LePine 2005, Acad. Manage. J. 48, 764-775" }

/-- Hindrance stressors are negatively related to performance (LePine et al.
2005). -/
@[proposition] def hindrance_task_performance : Proposition HindranceDemands Engagement.TaskPerformance :=
  { direction := .Negative, level := .Individual, horizon := .Weekly,
    evidence := .MetaAnalytic,
    citation := "LePine, Podsakoff & LePine 2005, Acad. Manage. J. 48, 764-775" }

end Lemma.Theories.ChallengeHindrance
