import Lemma.Theories.ChallengeHindrance

/-!
# Burnout as a developmental process (Leiter 1993)

Leiter's process model keeps the sequence from exhaustion to cynicism of
Leiter & Maslach (1988) and departs from it on efficacy: diminished
professional efficacy "develops largely independently" of the other two
dimensions, from the work environment directly (Leiter 1993; discussed
in Maslach, Schaufeli & Leiter 2001, p. 403).

Compiled against `Lemma.Theories.Burnout`, the null proposition from
cynicism to reduced efficacy contradicts the sequential model's positive
one. The compiler records this as the pilot's cross-theory contradiction
inside one literature.
-/

namespace Lemma.Theories.BurnoutProcess

/-- Exhaustion leads to cynicism (Leiter 1993 retains this step of the
sequential model). -/
@[proposition] def exhaustion_cynicism : Proposition Burnout.Exhaustion Burnout.Cynicism :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    evidence := .CrossSectional,
    citation := "Leiter 1993, in Schaufeli, Maslach & Marek (eds.) Professional Burnout, 237-250" }

/-- Reduced efficacy develops in parallel with, not as a consequence of,
cynicism (Leiter 1993). -/
@[proposition] def cynicism_reduced_efficacy : Proposition Burnout.Cynicism Burnout.ReducedEfficacy :=
  { direction := .Null, level := .Individual, horizon := .Weekly,
    evidence := .CrossSectional,
    citation := "Leiter 1993, in Schaufeli, Maslach & Marek (eds.) Professional Burnout, 237-250" }

/-- Lack of job resources predicts reduced efficacy directly (Leiter 1993;
Maslach et al. 2001, p. 403). -/
@[proposition] def resources_reduced_efficacy : Proposition JDR.JobResources Burnout.ReducedEfficacy :=
  { direction := .Negative, level := .Individual, horizon := .Weekly,
    evidence := .CrossSectional,
    citation := "Leiter 1993, in Schaufeli, Maslach & Marek (eds.) Professional Burnout, 237-250" }

/-- Job demands predict exhaustion (Leiter 1993 locates the origin of
exhaustion in demands). -/
@[proposition] def demands_exhaustion : Proposition JDR.JobDemands Burnout.Exhaustion :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    evidence := .CrossSectional,
    citation := "Leiter 1993, in Schaufeli, Maslach & Marek (eds.) Professional Burnout, 237-250" }

end Lemma.Theories.BurnoutProcess
