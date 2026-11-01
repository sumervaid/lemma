import Lemma.Theories

namespace Lemma.Generated.BakkerVanemmerikEuwema2006
open Lemma.Theories

/-- Team-level burnout: the team mean of members' exhaustion (Bakker et al. 2006, p. 470). -/
@[construct] structure TeamBurnout extends AffectiveState (level := .Team) (horizon := .Weekly) where
  energy : Energy

/-- Team burnout crosses over to individual exhaustion (Bakker et al. 2006, Hypothesis 1).
Stated at the individual level, as in the multilevel model of the paper. -/
@[proposition] def team_burnout_crossover : Proposition TeamBurnout Burnout.Exhaustion :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    evidence := .CrossSectional, citation := "Bakker, van Emmerik & Euwema 2006, Work Occup. 33, 464-489" }

end Lemma.Generated.BakkerVanemmerikEuwema2006
