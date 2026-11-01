import Lemma.Theories.Engagement

/-!
# Burnout (Maslach & Jackson 1981; Maslach, Schaufeli & Leiter 2001)

Burnout is "a prolonged response to chronic emotional and interpersonal
stressors on the job, defined by the three dimensions of exhaustion,
cynicism, and inefficacy" (Maslach, Schaufeli & Leiter 2001, p. 397),
measured with the Maslach Burnout Inventory (MBI).

The compiler reports, on compiling this file, that exhaustion shares the
primitive `Energy` with engagement's vigor and that cynicism shares
`Identification Work` with dedication. This is the debate over whether
burnout and engagement are opposite poles of two continua (González-Romá,
Schaufeli, Bakker & Lloret 2006; Demerouti, Mostert & Bakker 2010) or
independent states (Schaufeli & Bakker 2004). The library records the
declaration and leaves the empirical question to `lemma distinct`.
-/

namespace Lemma.Theories.Burnout

/-- Emotional exhaustion: "feelings of being overextended and depleted of
one's emotional and physical resources" (Maslach et al. 2001, p. 399). MBI
exhaustion subscale. Reads low energy. -/
@[construct] structure Exhaustion extends AffectiveState (level := .Individual) (horizon := .Weekly) where
  energy : Energy

/-- Cynicism (depersonalization): "a negative, callous, or excessively
detached response to various aspects of the job" (Maslach et al. 2001,
p. 399). MBI cynicism subscale. Reads withdrawal of identification with work. -/
@[construct] structure Cynicism extends AffectiveState (level := .Individual) (horizon := .Weekly) where
  identification : Identification .Work

/-- Reduced professional efficacy: "feelings of incompetence and a lack of
achievement and productivity at work" (Maslach et al. 2001, p. 399). MBI
efficacy subscale, reversed. -/
@[construct] structure ReducedEfficacy extends AffectiveState (level := .Individual) (horizon := .Weekly) where
  efficacy : Efficacy .Work

/-- Burnout as the three-dimensional MBI syndrome (Maslach & Jackson 1981). -/
@[construct] def Burnout := Exhaustion × Cynicism × ReducedEfficacy

declare_overlap Exhaustion distinct_from Engagement.Vigor
  "Schaufeli & Bakker 2004 treat exhaustion and vigor as distinct states; González-Romá et al. 2006 find them opposite poles of one energy continuum. Declared distinct pending the empirical-distinctness estimate."
declare_overlap Cynicism distinct_from Engagement.Dedication
  "Schaufeli & Bakker 2004 treat cynicism and dedication as distinct; González-Romá et al. 2006 find them opposite poles of one identification continuum. Declared distinct pending the empirical-distinctness estimate."
declare_overlap Exhaustion distinct_from Engagement.Engagement
  "Exhaustion reads low energy; engagement bundles high energy with identification and attention (Schaufeli et al. 2002)"
declare_overlap Cynicism distinct_from Engagement.Engagement
  "Cynicism reads withdrawal of identification; engagement bundles identification with energy and attention (Schaufeli et al. 2002)"
declare_overlap Burnout distinct_from Engagement.Engagement
  "Burnout and engagement share the energy and identification primitives and differ on efficacy versus absorption; Schaufeli et al. 2002 report them as negatively correlated distinct states"
declare_overlap Burnout distinct_from Engagement.Vigor
  "Vigor is one primitive of the burnout bundle read with opposite sign"
declare_overlap Burnout distinct_from Engagement.Dedication
  "Dedication is one primitive of the burnout bundle read with opposite sign"

/-- Exhaustion leads to cynicism over time: the sequential model (Leiter &
Maslach 1988; Maslach et al. 2001, p. 403; Taris, Le Blanc, Schaufeli &
Schreurs 2005, longitudinal). -/
@[proposition] def exhaustion_cynicism : Proposition Exhaustion Cynicism :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    evidence := .Longitudinal,
    citation := "Leiter & Maslach 1988, J. Organ. Behav. 9, 297-308; Taris et al. 2005, Work & Stress 19, 238-255" }

/-- Cynicism leads to reduced efficacy: the third step of the sequential
model (Leiter & Maslach 1988). -/
@[proposition] def cynicism_reduced_efficacy : Proposition Cynicism ReducedEfficacy :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    evidence := .CrossSectional,
    citation := "Leiter & Maslach 1988, J. Organ. Behav. 9, 297-308" }

/-- Burnout is negatively related to in-role performance (Taris 2006,
meta-analysis; Swider & Zimmerman 2010, meta-analysis). -/
@[proposition] def burnout_task_performance : Proposition Burnout Engagement.TaskPerformance :=
  { direction := .Negative, level := .Individual, horizon := .Weekly,
    evidence := .MetaAnalytic,
    citation := "Taris 2006, Work & Stress 20, 316-334; Swider & Zimmerman 2010, J. Vocat. Behav. 76, 487-506" }

/-- Exhaustion is negatively related to in-role performance (Taris 2006). -/
@[proposition] def exhaustion_task_performance : Proposition Exhaustion Engagement.TaskPerformance :=
  { direction := .Negative, level := .Individual, horizon := .Weekly,
    evidence := .MetaAnalytic,
    citation := "Taris 2006, Work & Stress 20, 316-334" }

/-- Burnout predicts turnover intention (Swider & Zimmerman 2010; Lee &
Ashforth 1996). -/
@[proposition] def burnout_turnover : Proposition Burnout Engagement.TurnoverIntention :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    evidence := .MetaAnalytic,
    citation := "Swider & Zimmerman 2010, J. Vocat. Behav. 76, 487-506" }

end Lemma.Theories.Burnout
