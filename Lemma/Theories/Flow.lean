import Lemma.Theories.Recovery

/-!
# Flow at work (Csikszentmihalyi 1990; Bakker 2008)

Flow is "a short-term peak experience at work that is characterized by
absorption, work enjoyment, and intrinsic work motivation" (Bakker 2008,
p. 400), measured with the Work-Related Flow Inventory (WOLF). Flow arises
when challenge and skill are balanced (Csikszentmihalyi 1990).

Horizons. Flow is momentary. The pilot registers a temporal rule from
momentary flow to its weekly frequency so that weekly propositions can be
stated, and a second rule to a static flow proneness used by the passion
module.

The compiler reports that weekly flow shares its absorption primitive with
engagement's absorption, the overlap Bakker 2008 discusses and attributes
to horizon.
-/

namespace Lemma.Theories.Flow

/-- Flow at work: absorption, enjoyment and intrinsic motivation during a
work episode (Bakker 2008, WOLF). -/
@[construct] structure Flow extends AffectiveState (level := .Individual) (horizon := .Momentary) where
  absorption : Attention .Work
  enjoyment : Affect .Positive .High
  intrinsicMotivation : Motivation .Intrinsic

/-- Weekly frequency of flow episodes (Bakker 2008 reports the WOLF over a
two-week frame; Demerouti et al. 2012 use daily measures). -/
@[construct] structure FlowFrequency extends AffectiveState (level := .Individual) (horizon := .Weekly) where
  absorption : Attention .Work
  enjoyment : Affect .Positive .High
  intrinsicMotivation : Motivation .Intrinsic

/-- Dispositional proneness to flow (Csikszentmihalyi 1990, autotelic
personality; Vallerand et al. 2003 use a general flow measure). -/
@[construct] structure FlowProneness extends Disposition (level := .Individual) (horizon := .Static) where
  absorption : Attention .Work
  enjoyment : Affect .Positive .High
  intrinsicMotivation : Motivation .Intrinsic

/-- Perceived balance of task challenge and skill (Csikszentmihalyi 1990). -/
@[construct] structure ChallengeSkillBalance extends JobCharacteristic (level := .Individual) (horizon := .Momentary) where
  challenge : Demand .Cognitive
  skill : Skill

/-- Conscientiousness (Costa & McCrae 1992), used as a moderator. -/
@[construct] structure Conscientiousness extends Disposition (level := .Individual) (horizon := .Static) where
  trait : Trait .Conscientiousness

/-- Momentary flow aggregates to weekly frequency by the mean. -/
@[temporal] def flowWeekly : Temporal Flow FlowFrequency :=
  { rule := .Mean, citation := "Bakker 2008, J. Vocat. Behav. 72, 400-414" }

/-- Weekly flow frequency aggregates to dispositional proneness by the mean. -/
@[temporal] def flowProneness : Temporal FlowFrequency FlowProneness :=
  { rule := .Mean, citation := "Csikszentmihalyi 1990, Flow: The Psychology of Optimal Experience" }

declare_overlap FlowFrequency distinct_from Engagement.Absorption
  "Flow absorption is a short-term peak experience; engagement absorption is a persistent state (Bakker 2008, p. 401)"
declare_overlap FlowFrequency distinct_from Engagement.Engagement
  "Flow adds enjoyment and intrinsic motivation and drops energy and identification (Bakker 2008)"
declare_overlap FlowFrequency distinct_from Recovery.WeeklyDetachment
  "Flow reads attention to work during work; detachment reads attention to work during off-job time"
declare_overlap FlowProneness distinct_from ERI.Overcommitment
  "Flow proneness reads absorption during work with enjoyment; overcommitment reads inability to withdraw attention from work with controlled striving (Siegrist et al. 2004)"

/-- Challenge-skill balance produces flow (Csikszentmihalyi 1990;
Csikszentmihalyi & LeFevre 1989, experience sampling). -/
@[proposition] def balance_flow : Proposition ChallengeSkillBalance Flow :=
  { direction := .Positive, level := .Individual, horizon := .Momentary,
    evidence := .Longitudinal,
    citation := "Csikszentmihalyi & LeFevre 1989, J. Pers. Soc. Psychol. 56, 815-822" }

/-- Job resources predict flow (Bakker 2005, music teachers; Bakker 2008,
Study 2). Stated weekly and routed through `flowWeekly`. -/
@[proposition] def resources_flow : Proposition JDR.JobResources Flow :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    evidence := .CrossSectional,
    citation := "Bakker 2005, J. Vocat. Behav. 66, 26-44; Bakker 2008, J. Vocat. Behav. 72, 400-414" }

/-- Flow predicts in-role performance for conscientious employees
(Demerouti 2006). -/
@[proposition] def flow_task_performance_conscientious : Proposition Flow Engagement.TaskPerformance :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    boundary := .moderator Conscientiousness .Amplifies,
    evidence := .CrossSectional,
    citation := "Demerouti 2006, J. Occup. Health Psychol. 11, 266-280" }

/-- Flow at work predicts energy after work when employees detach in the
evening (Demerouti, Bakker, Sonnentag & Fullagar 2012, diary study). -/
@[proposition] def flow_vigor_detached : Proposition Flow Engagement.Vigor :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    boundary := .moderator Recovery.WeeklyDetachment .Amplifies,
    evidence := .Longitudinal,
    citation := "Demerouti, Bakker, Sonnentag & Fullagar 2012, J. Organ. Behav. 33, 276-295" }

end Lemma.Theories.Flow
