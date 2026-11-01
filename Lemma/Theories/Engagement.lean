import Lemma.Library

/-!
# Work engagement (Schaufeli, Salanova, González-Romá & Bakker 2002)

Work engagement is "a positive, fulfilling, work-related state of mind
characterized by vigor, dedication, and absorption" (Schaufeli et al. 2002,
p. 74), measured with the Utrecht Work Engagement Scale (UWES).

Scope. The UWES asks about frequency of experiences at work. The pilot
declares engagement at the individual level and weekly horizon, following
the weekly diary form of the scale (Bakker & Bal 2010; Breevaart et al.
2012). Daily state engagement is a separate construct in
`Lemma.Theories.Recovery`.
-/

namespace Lemma.Theories.Engagement

/-- Vigor: "high levels of energy and mental resilience while working"
(Schaufeli et al. 2002, p. 74). UWES vigor subscale. Reads high energy. -/
@[construct] structure Vigor extends AffectiveState (level := .Individual) (horizon := .Weekly) where
  energy : Energy

/-- Dedication: "a sense of significance, enthusiasm, inspiration, pride, and
challenge" in one's work (Schaufeli et al. 2002, p. 74). UWES dedication
subscale. Reads high identification with work. -/
@[construct] structure Dedication extends AffectiveState (level := .Individual) (horizon := .Weekly) where
  identification : Identification .Work

/-- Absorption: "being fully concentrated and deeply engrossed in one's work"
(Schaufeli et al. 2002, p. 75). UWES absorption subscale. -/
@[construct] structure Absorption extends AffectiveState (level := .Individual) (horizon := .Weekly) where
  attention : Attention .Work

/-- Work engagement: the three-factor UWES state (Schaufeli et al. 2002).
Declared with its three fields typed directly by primitives, as in the
proposal's Listing 1, so that the compiler can report which field a
competing construct shares. -/
@[construct] structure Engagement extends AffectiveState (level := .Individual) (horizon := .Weekly) where
  vigor      : Energy
  dedication : Identification .Work
  absorption : Attention .Work

declare_overlap Vigor subtype_of Engagement
  "Vigor is the first UWES subscale; Schaufeli et al. 2002 report a three-factor model with correlated factors"
declare_overlap Dedication subtype_of Engagement
  "Dedication is the second UWES subscale (Schaufeli et al. 2002)"
declare_overlap Absorption subtype_of Engagement
  "Absorption is the third UWES subscale (Schaufeli et al. 2002)"

/-- In-role task performance, other-rated where possible (Christian, Garza &
Slaughter 2011). -/
@[construct] structure TaskPerformance extends Outcome (level := .Individual) (horizon := .Weekly) where
  performance : Performance .Task

/-- Contextual (extra-role, citizenship) performance (Christian et al. 2011). -/
@[construct] structure ContextualPerformance extends Outcome (level := .Individual) (horizon := .Weekly) where
  performance : Performance .Contextual

/-- Intention to leave the organization (Halbesleben 2010). -/
@[construct] structure TurnoverIntention extends WorkBehavior (level := .Individual) (horizon := .Weekly) where
  intention : Intention .Turnover

/-- Engagement predicts task performance (Christian et al. 2011,
meta-analysis, ρ = .43 with task performance). -/
@[proposition] def engagement_task_performance : Proposition Engagement TaskPerformance :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    evidence := .MetaAnalytic,
    citation := "Christian, Garza & Slaughter 2011, Personnel Psychology 64, 89-136" }

/-- Engagement predicts contextual performance (Christian et al. 2011,
ρ = .34 with contextual performance). -/
@[proposition] def engagement_contextual_performance : Proposition Engagement ContextualPerformance :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    evidence := .MetaAnalytic,
    citation := "Christian, Garza & Slaughter 2011, Personnel Psychology 64, 89-136" }

/-- Engagement is negatively related to turnover intention (Halbesleben 2010,
meta-analysis of the JD-R engagement literature). -/
@[proposition] def engagement_turnover : Proposition Engagement TurnoverIntention :=
  { direction := .Negative, level := .Individual, horizon := .Weekly,
    evidence := .MetaAnalytic,
    citation := "Halbesleben 2010, in Bakker & Leiter (eds.) Work Engagement, 102-117" }

end Lemma.Theories.Engagement
