import Lemma.Theories.Flow

/-!
# The dualistic model of passion (Vallerand et al. 2003; Vallerand, Paquet, Philippe & Charest 2010)

Passion is "a strong inclination toward an activity that people like, that
they find important, and in which they invest time and energy" (Vallerand
et al. 2003, p. 757). Harmonious passion follows autonomous
internalization of the activity into identity; obsessive passion follows
controlled internalization and produces conflict and burnout.

The compiler reports that both passions share identification with work
with engagement's dedication at a different horizon (a scope shift), and
that obsessive passion shares controlled motivation with overcommitment
and with workaholism at the same static horizon.
-/

namespace Lemma.Theories.Passion

/-- Harmonious passion: autonomous internalization of work into identity
(Vallerand et al. 2003, Passion Scale, harmonious subscale). -/
@[construct] structure HarmoniousPassion extends Disposition (level := .Individual) (horizon := .Static) where
  identification : Identification .Work
  motivation : Motivation .Autonomous

/-- Obsessive passion: controlled internalization of work into identity,
with felt pressure to engage (Vallerand et al. 2003, obsessive subscale). -/
@[construct] structure ObsessivePassion extends Disposition (level := .Individual) (horizon := .Static) where
  identification : Identification .Work
  motivation : Motivation .Controlled

declare_overlap ObsessivePassion distinct_from HarmoniousPassion
  "Both passions internalize work into identity; they differ in the regulatory style of the internalization (Vallerand et al. 2003)"
declare_overlap ObsessivePassion distinct_from ERI.Overcommitment
  "Both read controlled motivation; obsessive passion adds identification with work, overcommitment adds inability to withdraw (Vallerand et al. 2010; Siegrist et al. 2004)"

/-- Obsessive passion predicts emotional exhaustion over six months
(Vallerand et al. 2010, Study 2, nurses). The static antecedent enters the
weekly proposition by the static-embedding rule. -/
@[proposition] def obsessive_exhaustion : Proposition ObsessivePassion Burnout.Exhaustion :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    evidence := .Longitudinal,
    citation := "Vallerand, Paquet, Philippe & Charest 2010, J. Pers. 78, 289-312" }

/-- Harmonious passion is negatively related to emotional exhaustion
(Vallerand et al. 2010, Studies 1 and 2). -/
@[proposition] def harmonious_exhaustion : Proposition HarmoniousPassion Burnout.Exhaustion :=
  { direction := .Negative, level := .Individual, horizon := .Weekly,
    evidence := .Longitudinal,
    citation := "Vallerand, Paquet, Philippe & Charest 2010, J. Pers. 78, 289-312" }

/-- Harmonious passion is positively related to flow (Vallerand et al.
2003, Study 1). Stated at the static horizon over flow proneness. -/
@[proposition] def harmonious_flow : Proposition HarmoniousPassion Flow.FlowProneness :=
  { direction := .Positive, level := .Individual, horizon := .Static,
    evidence := .CrossSectional,
    citation := "Vallerand et al. 2003, J. Pers. Soc. Psychol. 85, 756-767" }

/-- Obsessive passion is unrelated to flow (Vallerand et al. 2003, Study 1). -/
@[proposition] def obsessive_flow : Proposition ObsessivePassion Flow.FlowProneness :=
  { direction := .Null, level := .Individual, horizon := .Static,
    evidence := .CrossSectional,
    citation := "Vallerand et al. 2003, J. Pers. Soc. Psychol. 85, 756-767" }

/-- Harmonious passion is positively related to vigor and dedication
(Vallerand et al. 2010 report positive relations with work satisfaction;
Forest, Mageau, Sarrazin & Morin 2011 report relations with vitality).
Stated over engagement. -/
@[proposition] def harmonious_engagement : Proposition HarmoniousPassion Engagement.Engagement :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    evidence := .CrossSectional,
    citation := "Forest, Mageau, Sarrazin & Morin 2011, Can. J. Adm. Sci. 28, 27-40" }

end Lemma.Theories.Passion
