import Lemma.Theories.BurnoutProcess

/-!
# Activation theory applied to job demands (Gardner 1986; Janssen 2001)

Activation theory predicts an inverted-U relation between stimulation and
performance. Janssen (2001) applies it to job demands and finds
curvilinear relations between demands and both satisfaction and
performance, moderated by fairness perceptions.

Compiled against `Lemma.Theories.JDR`, the curvilinear proposition from
job demands to task performance is a shape disagreement with JD-R's
negative one.
-/

namespace Lemma.Theories.Activation

/-- Job demands relate to in-role performance in an inverted-U shape
(Janssen 2001, Hypothesis 1; Gardner 1986). -/
@[proposition] def demands_task_performance : Proposition JDR.JobDemands Engagement.TaskPerformance :=
  { direction := .Curvilinear, level := .Individual, horizon := .Weekly,
    evidence := .CrossSectional,
    citation := "Janssen 2001, Acad. Manage. J. 44, 1039-1050; Gardner 1986, Acad. Manage. Rev. 11, 411-418" }

end Lemma.Theories.Activation
