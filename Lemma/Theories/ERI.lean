import Lemma.Theories.COR

/-!
# Effort-reward imbalance (Siegrist 1996; Siegrist et al. 2004)

Work is a contract of reciprocity. Strain follows when high effort spent at
work is met with low reward in money, esteem and career opportunities. A
personal pattern of excessive striving and inability to withdraw from work,
overcommitment, raises strain on its own and amplifies the effect of
imbalance.

The compiler reports, on compiling this file, that ERI's effort shares
workload and time pressure with JD-R's job demands, that ERI's reward is a
subset of COR's resource bundle, and that overcommitment shares its
controlled-motivation primitive with obsessive passion and workaholism
(`Lemma.Theories.Passion`, `Lemma.Theories.Workaholism`).
-/

namespace Lemma.Theories.ERI

/-- Extrinsic effort: demands and obligations of the job, measured by the
ERI effort scale (time pressure, interruptions, responsibility, overload;
Siegrist 1996; Siegrist et al. 2004). -/
@[construct] structure Effort extends JobCharacteristic (level := .Individual) (horizon := .Weekly) where
  workload : Demand .Workload
  timePressure : Demand .TimePressure
  interruptions : Demand .Interruption
  responsibility : Demand .Responsibility

/-- Occupational reward: money, esteem, and career opportunities including
job security (Siegrist 1996, p. 30). -/
@[construct] structure Reward extends JobCharacteristic (level := .Individual) (horizon := .Weekly) where
  money : Resource .Pay
  esteem : Resource .Esteem
  career : Resource .CareerSecurity

/-- Effort-reward imbalance: the ratio of effort to reward (Siegrist et al.
2004). Declared as the product of the two bundles; the ratio is a
measurement model over the product. -/
@[construct] def EffortRewardImbalance := Effort × Reward

/-- Overcommitment: "a set of attitudes, behaviours and emotions reflecting
excessive striving in combination with a strong desire of being approved
and esteemed", including inability to withdraw from work obligations
(Siegrist et al. 2004, p. 1486). A personal pattern, declared static. -/
@[construct] structure Overcommitment extends Disposition (level := .Individual) (horizon := .Static) where
  striving : Motivation .Controlled
  inabilityToWithdraw : Attention .Work

declare_overlap Effort distinct_from JDR.JobDemands
  "The ERI effort scale measures a subset of job demands (workload, time pressure) plus interruptions and responsibility; JD-R adds emotional, cognitive and physical demands and role conflict"
declare_overlap Reward subtype_of COR.Resources
  "Money, esteem and career security are COR conditions and energies (Hobfoll 1989); Siegrist 1996 restricts attention to rewards owed under the reciprocity contract"
declare_overlap Reward distinct_from JDR.JobResources
  "Rewards share job security with job resources and add pay and esteem; job resources add autonomy, support, feedback and development"
declare_overlap EffortRewardImbalance distinct_from JDR.JobDemands
  "Imbalance is a ratio over demands and rewards; demands alone are one factor"
declare_overlap EffortRewardImbalance distinct_from JDR.JobResources
  "Imbalance is a ratio over demands and rewards; job resources share only job security"
declare_overlap EffortRewardImbalance distinct_from COR.Resources
  "Imbalance is a ratio; COR resources are the stock"

/-- Effort-reward imbalance predicts strain and ill health (Siegrist 1996;
van Vegchel, de Jonge, Bosma & Schaufeli 2005, review of 45 studies;
Dragano et al. 2017, meta-analysis for coronary heart disease). -/
@[proposition] def imbalance_strain : Proposition EffortRewardImbalance COR.Strain :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    evidence := .MetaAnalytic,
    citation := "Siegrist 1996, J. Occup. Health Psychol. 1, 27-41; Dragano et al. 2017, Epidemiology 28, 619-626" }

/-- Overcommitment predicts strain on its own (Siegrist 1996; van Vegchel et
al. 2005). Declared static so that the consequent is routed through the
chronic-strain temporal rule below. -/
@[proposition] def overcommitment_strain : Proposition Overcommitment COR.Strain :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    evidence := .CrossSectional,
    citation := "van Vegchel, de Jonge, Bosma & Schaufeli 2005, Soc. Sci. Med. 60, 1117-1131" }

/-- Overcommitment amplifies the effect of imbalance on strain: the
interaction hypothesis (Siegrist 1996; Siegrist et al. 2004). Evidence is
mixed (van Vegchel et al. 2005). -/
@[proposition] def imbalance_strain_overcommitted : Proposition EffortRewardImbalance COR.Strain :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    boundary := .moderator Overcommitment .Amplifies,
    evidence := .CrossSectional,
    citation := "Siegrist et al. 2004, Soc. Sci. Med. 58, 1483-1499; van Vegchel et al. 2005" }

/-- Low reward predicts strain (Siegrist 1996; van Vegchel et al. 2005
report reward main effects). -/
@[proposition] def reward_strain : Proposition Reward COR.Strain :=
  { direction := .Negative, level := .Individual, horizon := .Weekly,
    evidence := .CrossSectional,
    citation := "van Vegchel et al. 2005, Soc. Sci. Med. 60, 1117-1131" }

/-- High effort predicts strain (van Vegchel et al. 2005 report effort main
effects). -/
@[proposition] def effort_strain : Proposition Effort COR.Strain :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    evidence := .CrossSectional,
    citation := "van Vegchel et al. 2005, Soc. Sci. Med. 60, 1117-1131" }

/-- Effort-reward imbalance predicts emotional exhaustion (Bakker, Killmer,
Siegrist & Schaufeli 2000, nurses). -/
@[proposition] def imbalance_exhaustion : Proposition EffortRewardImbalance Burnout.Exhaustion :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    evidence := .CrossSectional,
    citation := "Bakker, Killmer, Siegrist & Schaufeli 2000, J. Adv. Nurs. 31, 884-891" }

end Lemma.Theories.ERI
