import Lemma.Theories

namespace Lemma.Generated.Hobfoll1989
open Lemma.Theories

/-- Resources: objects, conditions, personal characteristics, energies (Hobfoll 1989, p. 516). -/
@[construct] structure Resources extends JobCharacteristic (level := .Individual) (horizon := .Weekly) where
  objects : Resource .Object
  conditions : Resource .CareerSecurity
  support : Resource .SocialSupport
  personal : Efficacy .Self
  energies : Resource .Time
  money : Resource .Pay

/-- Net resource loss over the horizon (Hobfoll 1989, p. 516). -/
@[construct] structure NetLoss extends ResourceDynamic (level := .Individual) (horizon := .Weekly) where
  conditions : Change .CareerSecurity
  support : Change .SocialSupport
  energies : Change .Time
  money : Change .Pay

/-- Psychological stress reaction (Hobfoll 1989, p. 516). -/
@[construct] structure StressReaction extends Outcome (level := .Individual) (horizon := .Weekly) where
  affect : Affect .Negative .High
  symptoms : Symptom .Psychosomatic

/-- Resource loss produces stress (Hobfoll 1989, p. 516). -/
@[proposition] def loss_stress : Proposition NetLoss StressReaction :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    evidence := .CrossSectional, citation := "Hobfoll 1989, Am. Psychol. 44, 513-524" }

/-- Those with more resources are less vulnerable to stress (Hobfoll 1989, p. 517). -/
@[proposition] def resources_stress : Proposition Resources StressReaction :=
  { direction := .Negative, level := .Individual, horizon := .Weekly,
    evidence := .CrossSectional, citation := "Hobfoll 1989, Am. Psychol. 44, 513-524" }

/-- Stress begets further loss: the loss spiral (Hobfoll 1989, p. 519). -/
@[proposition] def stress_loss : Proposition StressReaction NetLoss :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    evidence := .None, citation := "Hobfoll 1989, Am. Psychol. 44, 513-524" }

end Lemma.Generated.Hobfoll1989
