import Lemma.Theories

namespace Lemma.Generated.Schaufeli2002
open Lemma.Theories

/-- Vigor: energy and mental resilience while working (Schaufeli et al. 2002, p. 74). -/
@[construct] structure Vigor extends AffectiveState (level := .Individual) (horizon := .Weekly) where
  energy : Energy

/-- Dedication: significance, enthusiasm, inspiration, pride, challenge (Schaufeli et al. 2002, p. 74). -/
@[construct] structure Dedication extends AffectiveState (level := .Individual) (horizon := .Weekly) where
  identification : Identification .Work

/-- Absorption: full concentration and engrossment in work (Schaufeli et al. 2002, p. 75). -/
@[construct] structure Absorption extends AffectiveState (level := .Individual) (horizon := .Weekly) where
  attention : Attention .Work

/-- Work engagement as the three correlated factors (Schaufeli et al. 2002). -/
@[construct] def WorkEngagement := Vigor × Dedication × Absorption

declare_overlap WorkEngagement alias_of Engagement.Engagement
  "The same three UWES factors as the library's engagement; the generated module restates the library definition"

/-- Engagement is negatively related to exhaustion (Schaufeli et al. 2002, two-factor model). -/
@[proposition] def engagement_exhaustion : Proposition WorkEngagement Burnout.Exhaustion :=
  { direction := .Negative, level := .Individual, horizon := .Weekly,
    evidence := .CrossSectional, citation := "Schaufeli et al. 2002, J. Happiness Stud. 3, 71-92" }

end Lemma.Generated.Schaufeli2002
