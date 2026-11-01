import Lemma.Theories

namespace Lemma.Generated.Kahn1990
open Lemma.Theories

/-- Psychological meaningfulness: a felt return on investment of self (Kahn 1990, p. 703).
Not in the primitive vocabulary. -/
structure Meaningfulness where
  value : Float

/-- Psychological safety: showing the self without fear (Kahn 1990, p. 708). -/
structure Safety where
  value : Float

/-- Personal engagement: physical, cognitive and emotional expression in role (Kahn 1990, p. 694). -/
@[construct] structure PersonalEngagement extends AffectiveState (level := .Individual) (horizon := .Momentary) where
  physical : Energy
  cognitive : Attention .Work
  emotional : Identification .Work

/-- The psychological conditions of engagement (Kahn 1990, p. 705). -/
@[construct] structure PsychologicalConditions extends AffectiveState (level := .Individual) (horizon := .Momentary) where
  meaningfulness : Meaningfulness
  safety : Safety
  availability : Energy

/-- Meaningfulness, safety and availability increase engagement (Kahn 1990, p. 705). -/
@[proposition] def conditions_engagement : Proposition PsychologicalConditions PersonalEngagement :=
  { direction := .Positive, level := .Individual, horizon := .Momentary,
    evidence := .None, citation := "Kahn 1990, Acad. Manage. J. 33, 692-724" }

end Lemma.Generated.Kahn1990
