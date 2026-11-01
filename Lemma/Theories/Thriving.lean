import Lemma.Theories.ERI

/-!
# Thriving at work (Spreitzer, Sutcliffe, Dutton, Sonenshein & Grant 2005; Porath, Spreitzer, Gibson & Garnett 2012)

Thriving is "the psychological state in which individuals experience both
a sense of vitality and a sense of learning at work" (Spreitzer et al.
2005, p. 538). Unit contextual features (decision-making discretion, broad
information sharing, a climate of trust and respect) enable agentic work
behaviors (task focus, exploration, heedful relating), which produce
thriving, which in turn promotes development and health.

This file is the proposal's Listing 1. On compiling `Thriving`, the
compiler unfolds vitality to `Energy` at the individual level and weekly
horizon and reports the shared primitive with engagement's vigor, with
exhaustion, and with Shirom's vigor once that module is loaded.

The socially embedded model is a cross-level model. The pilot kernel
states cross-level relations at the higher level by aggregating the
lower-level construct through a registered rule (see `ARCHITECTURE.md`,
"Cross-level propositions").
-/

namespace Lemma.Theories.Thriving

/-- Vitality: "the positive feeling of having energy available" (Spreitzer
et al. 2005, p. 539; Porath et al. 2012 vitality subscale). Reads high energy. -/
@[construct] structure Vitality extends AffectiveState (level := .Individual) (horizon := .Weekly) where
  energy : Energy

/-- Learning: "the sense that one is acquiring, and can apply, knowledge and
skills" (Spreitzer et al. 2005, p. 538; Porath et al. 2012 learning subscale). -/
@[construct] structure LearningAtWork extends AffectiveState (level := .Individual) (horizon := .Weekly) where
  learning : Learning

/-- Thriving: the joint experience of vitality and learning (Spreitzer et al.
2005; Porath et al. 2012). -/
@[construct] def Thriving := Vitality × LearningAtWork

#reduce_construct Thriving

declare_overlap Vitality distinct_from Engagement.Vigor
  "Vitality is the affective energy component of thriving; Porath et al. 2012 report discriminant validity against engagement (vitality ρ with vigor below unity after correction)"
declare_overlap Vitality distinct_from Burnout.Exhaustion
  "Vitality reads high energy; exhaustion reads depletion (Porath et al. 2012 report a negative relation with burnout)"
declare_overlap Vitality distinct_from Burnout.Burnout
  "Vitality is the energy primitive of the burnout bundle read high"
declare_overlap Vitality distinct_from Engagement.Engagement
  "Vitality is a single energy primitive; engagement bundles energy with identification and attention"
declare_overlap Thriving distinct_from Engagement.Engagement
  "Thriving pairs energy with learning and drops identification and attention; Spreitzer et al. 2005 position thriving as a gauge of development rather than of involvement"
declare_overlap Thriving distinct_from Engagement.Vigor
  "Vigor is the energy half of thriving"
declare_overlap Thriving distinct_from Burnout.Exhaustion
  "Exhaustion is the energy half of thriving read low"
declare_overlap Thriving distinct_from Burnout.Burnout
  "Thriving and burnout share energy; burnout adds identification and efficacy, thriving adds learning"

/-- Agentic work behaviors: task focus, exploration and heedful relating
(Spreitzer et al. 2005, pp. 540-542). -/
@[construct] structure AgenticBehaviors extends WorkBehavior (level := .Individual) (horizon := .Weekly) where
  taskFocus : Behavior .TaskFocus
  exploration : Behavior .Exploration
  heedfulRelating : Behavior .HeedfulRelating

/-- Unit-level mean of agentic work behaviors, the aggregated form through
which the pilot states Spreitzer et al.'s unit-to-individual propositions. -/
@[construct] structure UnitAgenticBehaviors extends WorkBehavior (level := .Unit) (horizon := .Weekly) where
  taskFocus : Behavior .TaskFocus
  exploration : Behavior .Exploration
  heedfulRelating : Behavior .HeedfulRelating

/-- Agentic behaviors aggregate to the unit by the mean (additive
composition; Chan 1998). The pilot's representation of the cross-level
link in Spreitzer et al. 2005. -/
@[aggregation] def agenticUnitMean : Aggregation AgenticBehaviors UnitAgenticBehaviors :=
  { rule := .Mean, citation := "Chan 1998, J. Appl. Psychol. 83, 234-246; Spreitzer et al. 2005" }

/-- Decision-making discretion in the unit (Spreitzer et al. 2005, p. 542). -/
@[construct] structure DecisionDiscretion extends JobCharacteristic (level := .Unit) (horizon := .Weekly) where
  autonomy : Resource .Autonomy

/-- Broad information sharing in the unit (Spreitzer et al. 2005, p. 543). -/
@[construct] structure InformationSharing extends JobCharacteristic (level := .Unit) (horizon := .Weekly) where
  information : Resource .Information

/-- Climate of trust and respect in the unit (Spreitzer et al. 2005, p. 543). -/
@[construct] structure TrustClimate extends JobCharacteristic (level := .Unit) (horizon := .Weekly) where
  trust : Trust .Team

/-- Decision-making discretion enables agentic behaviors (Spreitzer et al.
2005, Proposition 4). Stated at the unit level over the aggregated
behaviors. -/
@[proposition] def discretion_agentic : Proposition DecisionDiscretion AgenticBehaviors :=
  { direction := .Positive, level := .Unit, horizon := .Weekly,
    evidence := .None,
    citation := "Spreitzer et al. 2005, Organ. Sci. 16, 537-549, Proposition 4" }

/-- Broad information sharing enables agentic behaviors (Spreitzer et al.
2005, Proposition 5). -/
@[proposition] def information_agentic : Proposition InformationSharing AgenticBehaviors :=
  { direction := .Positive, level := .Unit, horizon := .Weekly,
    evidence := .None,
    citation := "Spreitzer et al. 2005, Organ. Sci. 16, 537-549, Proposition 5" }

/-- A climate of trust and respect enables agentic behaviors (Spreitzer et
al. 2005, Proposition 6). -/
@[proposition] def trust_agentic : Proposition TrustClimate AgenticBehaviors :=
  { direction := .Positive, level := .Unit, horizon := .Weekly,
    evidence := .None,
    citation := "Spreitzer et al. 2005, Organ. Sci. 16, 537-549, Proposition 6" }

/-- Agentic behaviors produce thriving (Spreitzer et al. 2005, Propositions
1-3; Niessen, Sonnentag & Sach 2012, diary study of task focus and
exploration). -/
@[proposition] def agentic_thriving : Proposition AgenticBehaviors Thriving :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    evidence := .Longitudinal,
    citation := "Spreitzer et al. 2005; Niessen, Sonnentag & Sach 2012, J. Organ. Behav. 33, 468-487" }

/-- Thriving is positively related to job performance (Porath et al. 2012,
supervisor ratings; Kleine, Rudolph & Zacher 2019, meta-analysis). -/
@[proposition] def thriving_task_performance : Proposition Thriving Engagement.TaskPerformance :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    evidence := .MetaAnalytic,
    citation := "Porath, Spreitzer, Gibson & Garnett 2012, J. Organ. Behav. 33, 250-275; Kleine, Rudolph & Zacher 2019, J. Organ. Behav. 40, 973-999" }

/-- Thriving is negatively related to health complaints (Spreitzer et al.
2005, Proposition 8; Porath et al. 2012; Kleine et al. 2019). -/
@[proposition] def thriving_health : Proposition Thriving JDR.HealthComplaints :=
  { direction := .Negative, level := .Individual, horizon := .Weekly,
    evidence := .MetaAnalytic,
    citation := "Kleine, Rudolph & Zacher 2019, J. Organ. Behav. 40, 973-999" }

/-- Thriving is negatively related to burnout (Porath et al. 2012; Kleine et
al. 2019). -/
@[proposition] def thriving_burnout : Proposition Thriving Burnout.Burnout :=
  { direction := .Negative, level := .Individual, horizon := .Weekly,
    evidence := .MetaAnalytic,
    citation := "Porath et al. 2012, J. Organ. Behav. 33, 250-275; Kleine, Rudolph & Zacher 2019" }

end Lemma.Theories.Thriving
