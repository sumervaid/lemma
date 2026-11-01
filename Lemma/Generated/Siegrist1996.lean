import Lemma.Theories

namespace Lemma.Generated.Siegrist1996
open Lemma.Theories

/-- Extrinsic effort: time pressure, interruptions, responsibility, overload (Siegrist 1996, p. 30). -/
@[construct] structure Effort extends JobCharacteristic (level := .Individual) (horizon := .Weekly) where
  timePressure : Demand .TimePressure
  interruptions : Demand .Interruption
  responsibility : Demand .Responsibility
  overload : Demand .Workload

/-- Reward: money, esteem, status control (Siegrist 1996, p. 30). -/
@[construct] structure Reward extends JobCharacteristic (level := .Individual) (horizon := .Weekly) where
  money : Resource .Pay
  esteem : Resource .Esteem
  statusControl : Resource .CareerSecurity

/-- Effort-reward imbalance (Siegrist 1996). -/
@[construct] def Imbalance := Effort × Reward

/-- Overcommitment: excessive striving and inability to withdraw (Siegrist 1996, p. 31). -/
@[construct] structure Overcommitment extends Disposition (level := .Individual) (horizon := .Static) where
  striving : Motivation .Controlled
  inabilityToWithdraw : Attention .Work

/-- Cardiovascular strain: negative affect and cardiovascular symptoms (Siegrist 1996). -/
@[construct] structure CardiovascularStrain extends Outcome (level := .Individual) (horizon := .Weekly) where
  affect : Affect .Negative .High
  symptoms : Symptom .Cardiovascular

/-- Imbalance raises strain and cardiovascular risk (Siegrist 1996, prospective cohorts). -/
@[proposition] def imbalance_strain : Proposition Imbalance CardiovascularStrain :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    evidence := .Longitudinal, citation := "Siegrist 1996, J. Occup. Health Psychol. 1, 27-41" }

/-- Overcommitment independently raises strain (Siegrist 1996). -/
@[proposition] def overcommitment_strain : Proposition Overcommitment CardiovascularStrain :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    evidence := .Longitudinal, citation := "Siegrist 1996, J. Occup. Health Psychol. 1, 27-41" }

/-- Overcommitment amplifies the imbalance effect (Siegrist 1996). -/
@[proposition] def imbalance_strain_overcommitted : Proposition Imbalance CardiovascularStrain :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    boundary := .moderator Overcommitment .Amplifies,
    evidence := .Longitudinal, citation := "Siegrist 1996, J. Occup. Health Psychol. 1, 27-41" }

end Lemma.Generated.Siegrist1996
