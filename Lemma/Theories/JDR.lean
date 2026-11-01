import Lemma.Theories.Burnout

/-!
# Job demands-resources theory (Demerouti, Bakker, Nachreiner & Schaufeli 2001; Bakker & Demerouti 2007)

Every job has demands and resources. Demands drive a health-impairment
process ending in exhaustion; resources drive a motivational process ending
in engagement; resources buffer the effect of demands, and resources matter
most when demands are high (Bakker & Demerouti 2007, pp. 312-316).

Design note. Job demands and job resources are **bundles** of concrete
primitives (workload, emotional demands, ...; autonomy, support, ...). The
compiler can then recognise that another theory's "effort" or "reward"
is a subset of the same bundle (`subtype` overlap) rather than an
unrelated term.
-/

namespace Lemma.Theories.JDR

/-- Job demands: "those physical, psychological, social, or organizational
aspects of the job that require sustained physical and/or psychological
(cognitive and emotional) effort" (Bakker & Demerouti 2007, p. 312).
Bundle of the demand kinds listed in Demerouti et al. 2001 (work overload,
time pressure, emotional demands, physical demands) and Bakker & Demerouti
2007 (role conflict, cognitive demands). -/
@[construct] structure JobDemands extends JobCharacteristic (level := .Individual) (horizon := .Weekly) where
  workload : Demand .Workload
  timePressure : Demand .TimePressure
  emotional : Demand .Emotional
  cognitive : Demand .Cognitive
  physical : Demand .Physical
  roleConflict : Demand .RoleConflict

/-- Job resources: "those physical, psychological, social, or organizational
aspects of the job that are functional in achieving work goals, reduce job
demands, or stimulate personal growth, learning, and development" (Bakker &
Demerouti 2007, p. 312). Bundle of autonomy, social support, performance
feedback, development opportunities and job security (Demerouti et al.
2001; Bakker & Demerouti 2007). -/
@[construct] structure JobResources extends JobCharacteristic (level := .Individual) (horizon := .Weekly) where
  autonomy : Resource .Autonomy
  support : Resource .SocialSupport
  feedback : Resource .Feedback
  development : Resource .Development
  security : Resource .CareerSecurity

/-- Personal resources: self-efficacy, organization-based self-esteem and
optimism (Xanthopoulou, Bakker, Demerouti & Schaufeli 2007). -/
@[construct] structure PersonalResources extends Disposition (level := .Individual) (horizon := .Weekly) where
  efficacy : Efficacy .Work
  selfEsteem : Identification .Self
  optimism : Expectancy .Positive

/-- Psychosomatic health complaints (Hakanen, Bakker & Schaufeli 2006;
Hakanen, Schaufeli & Ahola 2008). -/
@[construct] structure HealthComplaints extends Outcome (level := .Individual) (horizon := .Weekly) where
  symptoms : Symptom .Psychosomatic

/-- Affective organizational commitment: identification with and involvement
in the organization (Meyer & Allen 1991), as used in Hakanen et al. 2008. -/
@[construct] structure OrganizationalCommitment extends AffectiveState (level := .Individual) (horizon := .Weekly) where
  identification : Identification .Organization

declare_overlap PersonalResources distinct_from Burnout.ReducedEfficacy
  "Reduced efficacy is the MBI outcome dimension read low; personal resources read efficacy high as an antecedent (Xanthopoulou et al. 2007)"
declare_overlap PersonalResources distinct_from Burnout.Burnout
  "Shared efficacy primitive only, read with opposite sign"

/-! ## Health-impairment process -/

/-- Job demands predict exhaustion (Demerouti et al. 2001; Alarcon 2011,
meta-analysis; Lesener, Gusy & Wolter 2019, meta-analysis of longitudinal
studies). -/
@[proposition] def demands_exhaustion : Proposition JobDemands Burnout.Exhaustion :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    evidence := .MetaAnalytic,
    citation := "Alarcon 2011, J. Vocat. Behav. 79, 549-562; Lesener, Gusy & Wolter 2019, Work & Stress 33, 76-103" }

/-- Job demands predict exhaustion less strongly when job resources are high:
the buffer hypothesis (Bakker, Demerouti & Euwema 2005; Bakker & Demerouti
2007, p. 314). -/
@[proposition] def demands_exhaustion_buffered : Proposition JobDemands Burnout.Exhaustion :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    boundary := .moderator JobResources .Buffers,
    evidence := .CrossSectional,
    citation := "Bakker, Demerouti & Euwema 2005, J. Occup. Health Psychol. 10, 170-180" }

/-- Exhaustion predicts health complaints (Hakanen, Schaufeli & Ahola 2008,
three-year cross-lagged study; health-impairment process). -/
@[proposition] def exhaustion_health : Proposition Burnout.Exhaustion HealthComplaints :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    evidence := .Longitudinal,
    citation := "Hakanen, Schaufeli & Ahola 2008, Work & Stress 22, 224-241" }

/-! ## Motivational process -/

/-- Job resources predict engagement (Schaufeli & Bakker 2004; Christian et
al. 2011; Halbesleben 2010, meta-analyses). -/
@[proposition] def resources_engagement : Proposition JobResources Engagement.Engagement :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    evidence := .MetaAnalytic,
    citation := "Halbesleben 2010; Christian, Garza & Slaughter 2011, Personnel Psychology 64, 89-136" }

/-- Job resources predict engagement more strongly when job demands are high:
the boost hypothesis (Bakker, Hakanen, Demerouti & Xanthopoulou 2007). -/
@[proposition] def resources_engagement_boosted : Proposition JobResources Engagement.Engagement :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    boundary := .moderator JobDemands .Amplifies,
    evidence := .CrossSectional,
    citation := "Bakker, Hakanen, Demerouti & Xanthopoulou 2007, J. Educ. Psychol. 99, 274-284" }

/-- Lack of job resources predicts exhaustion: resources are negatively
related to burnout (Schaufeli & Bakker 2004; Lee & Ashforth 1996,
meta-analysis; Alarcon 2011). -/
@[proposition] def resources_exhaustion : Proposition JobResources Burnout.Exhaustion :=
  { direction := .Negative, level := .Individual, horizon := .Weekly,
    evidence := .MetaAnalytic,
    citation := "Lee & Ashforth 1996, J. Appl. Psychol. 81, 123-133; Alarcon 2011, J. Vocat. Behav. 79, 549-562" }

/-- Job demands are unrelated to engagement in the dual-process model:
"engagement is exclusively predicted by available job resources" (Schaufeli
& Bakker 2004, abstract; four-sample structural model). -/
@[proposition] def demands_engagement : Proposition JobDemands Engagement.Engagement :=
  { direction := .Null, level := .Individual, horizon := .Weekly,
    evidence := .CrossSectional,
    citation := "Schaufeli & Bakker 2004, J. Organ. Behav. 25, 293-315" }

/-- Personal resources predict engagement (Xanthopoulou et al. 2007;
Xanthopoulou, Bakker, Demerouti & Schaufeli 2009, two-wave study). -/
@[proposition] def personal_resources_engagement : Proposition PersonalResources Engagement.Engagement :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    evidence := .Longitudinal,
    citation := "Xanthopoulou, Bakker, Demerouti & Schaufeli 2009, J. Vocat. Behav. 74, 235-244" }

/-- Engagement predicts job resources over time: the gain cycle (Xanthopoulou
et al. 2009; Hakanen, Perhoniemi & Toppinen-Tanner 2008). -/
@[proposition] def engagement_resources : Proposition Engagement.Engagement JobResources :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    evidence := .Longitudinal,
    citation := "Xanthopoulou et al. 2009, J. Vocat. Behav. 74, 235-244; Hakanen, Perhoniemi & Toppinen-Tanner 2008, J. Vocat. Behav. 73, 78-91" }

/-- Engagement predicts organizational commitment (Hakanen, Schaufeli & Ahola
2008, three-year cross-lagged study). -/
@[proposition] def engagement_commitment : Proposition Engagement.Engagement OrganizationalCommitment :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    evidence := .Longitudinal,
    citation := "Hakanen, Schaufeli & Ahola 2008, Work & Stress 22, 224-241" }

/-- Job demands are negatively related to in-role performance through
exhaustion (Bakker, Demerouti & Verbeke 2004). -/
@[proposition] def demands_task_performance : Proposition JobDemands Engagement.TaskPerformance :=
  { direction := .Negative, level := .Individual, horizon := .Weekly,
    evidence := .CrossSectional,
    citation := "Bakker, Demerouti & Verbeke 2004, Hum. Resour. Manage. 43, 83-104" }

end Lemma.Theories.JDR
