import Lemma.Theories

namespace Lemma.Generated.Spreitzer2005
open Lemma.Theories

/-- Vitality: the positive feeling of having energy available (Spreitzer et al. 2005, p. 539). -/
@[construct] structure Vitality extends AffectiveState (level := .Individual) (horizon := .Weekly) where
  energy : Energy

/-- Learning: acquiring and applying knowledge and skills (Spreitzer et al. 2005, p. 538). -/
@[construct] structure Learning extends AffectiveState (level := .Individual) (horizon := .Weekly) where
  learning : Lemma.Learning

/-- Thriving: vitality and learning jointly (Spreitzer et al. 2005, p. 538). -/
@[construct] def Thriving := Vitality × Learning

/-- Agentic work behaviors promote thriving (Spreitzer et al. 2005, P1-P3). -/
@[proposition] def agentic_thriving : Proposition Thriving.AgenticBehaviors Thriving :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    evidence := .None, citation := "Spreitzer et al. 2005, Organ. Sci. 16, 537-549, P1-P3" }

/-- Decision-making discretion promotes agentic behaviors (Spreitzer et al. 2005, P4). -/
@[proposition] def discretion_agentic : Proposition Thriving.DecisionDiscretion Thriving.AgenticBehaviors :=
  { direction := .Positive, level := .Unit, horizon := .Weekly,
    evidence := .None, citation := "Spreitzer et al. 2005, Organ. Sci. 16, 537-549, P4" }

/-- Thriving promotes health (Spreitzer et al. 2005, P8). -/
@[proposition] def thriving_health : Proposition Thriving JDR.HealthComplaints :=
  { direction := .Negative, level := .Individual, horizon := .Weekly,
    evidence := .None, citation := "Spreitzer et al. 2005, Organ. Sci. 16, 537-549, P8" }

end Lemma.Generated.Spreitzer2005
