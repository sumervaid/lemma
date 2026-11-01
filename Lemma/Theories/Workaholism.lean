import Lemma.Theories.Passion

/-!
# Workaholism (Schaufeli, Taris & Bakker 2008; Schaufeli, Taris & van Rhenen 2008)

Workaholism is "the tendency to work excessively hard and being obsessed
with work, which manifests itself in working compulsively" (Schaufeli,
Taris & Bakker 2008, p. 204), measured with the Dutch Work Addiction
Scale (DUWAS).

The compiler reports that working compulsively shares controlled
motivation with obsessive passion and overcommitment. Schaufeli, Taris &
van Rhenen 2008 ask whether workaholism, burnout and engagement are "three
of a kind or three different kinds"; the library records the answer at
the primitive level.
-/

namespace Lemma.Theories.Workaholism

/-- Working excessively: devoting an exceptional amount of time to work
(DUWAS WE subscale). Reads working hours. -/
@[construct] structure WorkingExcessively extends WorkBehavior (level := .Individual) (horizon := .Static) where
  hours : Behavior .WorkingHours

/-- Working compulsively: an inner compulsion to work (DUWAS WC subscale).
Reads controlled motivation. -/
@[construct] structure WorkingCompulsively extends Disposition (level := .Individual) (horizon := .Static) where
  compulsion : Motivation .Controlled

/-- Workaholism: the conjunction of working excessively and compulsively
(Schaufeli, Taris & Bakker 2008). -/
@[construct] def Workaholism := WorkingExcessively × WorkingCompulsively

declare_overlap WorkingCompulsively distinct_from Passion.ObsessivePassion
  "Working compulsively is the controlled-motivation component alone; obsessive passion adds identification with work (Vallerand et al. 2003)"
declare_overlap WorkingCompulsively distinct_from ERI.Overcommitment
  "Working compulsively is the controlled-motivation component alone; overcommitment adds inability to withdraw (Siegrist et al. 2004)"
declare_overlap Workaholism distinct_from Passion.ObsessivePassion
  "Workaholism adds working hours and drops identification"
declare_overlap Workaholism distinct_from ERI.Overcommitment
  "Workaholism adds working hours and drops inability to withdraw"

/-- Workaholism is positively related to exhaustion (Schaufeli, Taris & van
Rhenen 2008; Clark, Michel, Zhdanova, Pui & Baltes 2016, meta-analysis). -/
@[proposition] def workaholism_exhaustion : Proposition Workaholism Burnout.Exhaustion :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    evidence := .MetaAnalytic,
    citation := "Clark, Michel, Zhdanova, Pui & Baltes 2016, J. Manage. 42, 1836-1873" }

/-- Working excessively is positively related to engagement, working
compulsively is not (Schaufeli, Taris & van Rhenen 2008). Stated for the
excessive component. -/
@[proposition] def excessive_engagement : Proposition WorkingExcessively Engagement.Engagement :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    evidence := .CrossSectional,
    citation := "Schaufeli, Taris & van Rhenen 2008, Appl. Psychol. 57, 173-203" }

/-- Working compulsively is unrelated to engagement (Schaufeli, Taris & van
Rhenen 2008). -/
@[proposition] def compulsive_engagement : Proposition WorkingCompulsively Engagement.Engagement :=
  { direction := .Null, level := .Individual, horizon := .Weekly,
    evidence := .CrossSectional,
    citation := "Schaufeli, Taris & van Rhenen 2008, Appl. Psychol. 57, 173-203" }

/-- Workaholism is positively related to health complaints (Clark et al.
2016). -/
@[proposition] def workaholism_health : Proposition Workaholism JDR.HealthComplaints :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    evidence := .MetaAnalytic,
    citation := "Clark, Michel, Zhdanova, Pui & Baltes 2016, J. Manage. 42, 1836-1873" }

end Lemma.Theories.Workaholism
