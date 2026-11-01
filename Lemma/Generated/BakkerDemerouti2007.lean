import Lemma.Theories

namespace Lemma.Generated.BakkerDemerouti2007
open Lemma.Theories

/-- Job demands: aspects of the job requiring sustained effort; work pressure,
emotional demands, role conflict (Bakker & Demerouti 2007, p. 312). -/
@[construct] structure JobDemands extends JobCharacteristic (level := .Individual) (horizon := .Weekly) where
  workPressure : Demand .Workload
  emotional : Demand .Emotional
  roleConflict : Demand .RoleConflict

/-- Job resources: autonomy, social support, performance feedback, development
opportunities (Bakker & Demerouti 2007, p. 312). -/
@[construct] structure JobResources extends JobCharacteristic (level := .Individual) (horizon := .Weekly) where
  autonomy : Resource .Autonomy
  support : Resource .SocialSupport
  feedback : Resource .Feedback
  development : Resource .Development

/-- Job demands predict exhaustion (Bakker & Demerouti 2007, p. 313, health impairment process). -/
@[proposition] def demands_exhaustion : Proposition JobDemands Burnout.Exhaustion :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    evidence := .CrossSectional, citation := "Bakker & Demerouti 2007, J. Manag. Psychol. 22, 309-328" }

/-- Job resources predict engagement (Bakker & Demerouti 2007, p. 313, motivational process). -/
@[proposition] def resources_engagement : Proposition JobResources Engagement.Engagement :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    evidence := .CrossSectional, citation := "Bakker & Demerouti 2007, J. Manag. Psychol. 22, 309-328" }

/-- Job resources buffer the effect of demands on exhaustion (Bakker & Demerouti 2007, p. 314). -/
@[proposition] def demands_exhaustion_buffered : Proposition JobDemands Burnout.Exhaustion :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    boundary := .moderator JobResources .Buffers,
    evidence := .CrossSectional, citation := "Bakker & Demerouti 2007, J. Manag. Psychol. 22, 309-328" }

/-- Resources matter most for engagement when demands are high (Bakker & Demerouti 2007, p. 315). -/
@[proposition] def resources_engagement_boosted : Proposition JobResources Engagement.Engagement :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    boundary := .moderator JobDemands .Amplifies,
    evidence := .CrossSectional, citation := "Bakker & Demerouti 2007, J. Manag. Psychol. 22, 309-328" }

/-- Engagement predicts in-role performance (Bakker & Demerouti 2007, p. 316). -/
@[proposition] def engagement_performance : Proposition Engagement.Engagement Engagement.TaskPerformance :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    evidence := .CrossSectional, citation := "Bakker & Demerouti 2007, J. Manag. Psychol. 22, 309-328" }

end Lemma.Generated.BakkerDemerouti2007
