import Lemma.Theories.Workaholism

/-!
# Vigor (Shirom 2003; Shirom 2011)

Shirom defines vigor as an affective state of physical strength, emotional
energy and cognitive liveliness, measured with the Shirom-Melamed Vigor
Measure. Shirom (2011) argues vigor is "not the antithesis of burnout",
which the library records as a `distinct_from` declaration against
exhaustion, in competition with the opposite-poles reading of
Demerouti, Mostert & Bakker (2010).
-/

namespace Lemma.Theories.ShiromVigor

/-- Vigor (Shirom 2003): physical strength and emotional energy. The
cognitive-liveliness facet has no primitive in the pilot vocabulary and is
omitted, which the docstring records as a fidelity limitation. -/
@[construct] structure ShiromVigor extends AffectiveState (level := .Individual) (horizon := .Weekly) where
  physicalStrength : Energy
  emotionalEnergy : Affect .Positive .High

declare_overlap ShiromVigor distinct_from Engagement.Vigor
  "Shirom 2003 argues UWES vigor conflates energy with resilience and motivation; the SMVM isolates energy and adds emotional energy"
declare_overlap ShiromVigor distinct_from Burnout.Exhaustion
  "Shirom 2011 argues vigor and burnout are distinct, not opposite poles; Demerouti, Mostert & Bakker 2010 argue the reverse"
declare_overlap ShiromVigor distinct_from Thriving.Vitality
  "Vitality is the energy facet alone; Shirom's vigor adds emotional energy"
declare_overlap ShiromVigor distinct_from Engagement.Engagement
  "Shirom's vigor drops identification and attention and adds emotional energy"
declare_overlap ShiromVigor distinct_from Thriving.Thriving
  "Thriving pairs energy with learning; Shirom's vigor pairs energy with emotional energy"
declare_overlap ShiromVigor distinct_from Burnout.Burnout
  "Shared energy primitive only"
declare_overlap ShiromVigor distinct_from Flow.FlowFrequency
  "Shared positive high-activation affect only"

/-- Vigor predicts better self-rated health (Shirom 2011; Shirom, Toker,
Berliner, Shapira & Melamed 2008, longitudinal). -/
@[proposition] def vigor_health : Proposition ShiromVigor JDR.HealthComplaints :=
  { direction := .Negative, level := .Individual, horizon := .Weekly,
    evidence := .Longitudinal,
    citation := "Shirom, Toker, Berliner, Shapira & Melamed 2008, J. Occup. Health Psychol. 13, 319-333" }

/-- Vigor predicts job performance (Shirom 2011 review; Carmeli, Ben-Hador,
Waldman & Rupp 2009). -/
@[proposition] def vigor_task_performance : Proposition ShiromVigor Engagement.TaskPerformance :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    evidence := .CrossSectional,
    citation := "Carmeli, Ben-Hador, Waldman & Rupp 2009, J. Appl. Psychol. 94, 1553-1561" }

end Lemma.Theories.ShiromVigor
