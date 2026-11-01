# Lemma library report

Generated 2026-11-01T18:37:02+00:00 by `lemma check`. Kernel 0.1.0.

## Summary

| Quantity | Value |
|---|---|
| Theories (modules) | 21 (15 curated, 6 generated) |
| Primitives | 18 |
| Constructs (curated + generated) | 73 (53 + 20) |
| Propositions (curated + generated) | 89 (73 + 16) |
| Aggregation rules | 3 |
| Temporal rules | 4 |
| Source papers (curated sources ∪ accepted pipeline papers) | 67 |
| Overlap warnings | 164 (55 resolved by declaration, 109 unresolved) |
| Overlap warnings, curated library only | 54 (54 resolved); 110 further warnings involve accepted generated modules |
| Overlap warnings by kind | identity: 34, partial: 54, subtype: 76 |
| Overlap declarations by kind | alias_of: 1, distinct_from: 50, subtype_of: 4 |
| Scope shifts (same primitive, different scope) | 141 |
| Cross-theory contradictions (same scope and boundary) | 1 |
| Conditional disagreements (different boundary) | 1 |
| Shape disagreements (linear vs curvilinear) | 1 |
| Convergences (same claim in two or more theories) | 4 |
| Implied propositions (deduplicated) | 93 (85 untested, 7 tested, 1 contradicted, 2 with disagreeing implied directions) |
| Formalization failures (pipeline) | 3 of 9 papers |

## Constructs

| Construct | Theory | Kind | Level | Horizon | Primitive leaves |
|---|---|---|---|---|---|
| Vigor | Engagement | structure | Individual | Weekly | Energy |
| Dedication | Engagement | structure | Individual | Weekly | Identification Work |
| Absorption | Engagement | structure | Individual | Weekly | Attention Work |
| Engagement | Engagement | structure | Individual | Weekly | Attention Work, Energy, Identification Work |
| TaskPerformance | Engagement | structure | Individual | Weekly | Performance Task |
| ContextualPerformance | Engagement | structure | Individual | Weekly | Performance Contextual |
| TurnoverIntention | Engagement | structure | Individual | Weekly | Intention Turnover |
| Exhaustion | Burnout | structure | Individual | Weekly | Energy |
| Cynicism | Burnout | structure | Individual | Weekly | Identification Work |
| ReducedEfficacy | Burnout | structure | Individual | Weekly | Efficacy Work |
| Burnout | Burnout | composite | Individual | Weekly | Efficacy Work, Energy, Identification Work |
| JobDemands | JDR | structure | Individual | Weekly | Demand Cognitive, Demand Emotional, Demand Physical, Demand RoleConflict, Demand TimePressure, Demand Workload |
| JobResources | JDR | structure | Individual | Weekly | Resource Autonomy, Resource CareerSecurity, Resource Development, Resource Feedback, Resource SocialSupport |
| PersonalResources | JDR | structure | Individual | Weekly | Efficacy Work, Expectancy Positive, Identification Self |
| HealthComplaints | JDR | structure | Individual | Weekly | Symptom Psychosomatic |
| OrganizationalCommitment | JDR | structure | Individual | Weekly | Identification Organization |
| Resources | COR | structure | Individual | Weekly | Efficacy Self, Expectancy Positive, Resource Autonomy, Resource CareerSecurity, Resource Development, Resource Esteem, Resource Knowledge, Resource Object, Resource Pay, Resource SocialSupport, Resource Time |
| ResourceLoss | COR | structure | Individual | Weekly | Change Autonomy, Change CareerSecurity, Change Esteem, Change Pay, Change SocialSupport, Change Time |
| ResourceGain | COR | structure | Individual | Weekly | Change Autonomy, Change CareerSecurity, Change Esteem, Change Pay, Change SocialSupport, Change Time |
| Strain | COR | structure | Individual | Weekly | Affect Negative High, Symptom Psychosomatic |
| Effort | ERI | structure | Individual | Weekly | Demand Interruption, Demand Responsibility, Demand TimePressure, Demand Workload |
| Reward | ERI | structure | Individual | Weekly | Resource CareerSecurity, Resource Esteem, Resource Pay |
| EffortRewardImbalance | ERI | composite | Individual | Weekly | Demand Interruption, Demand Responsibility, Demand TimePressure, Demand Workload, Resource CareerSecurity, Resource Esteem, Resource Pay |
| Overcommitment | ERI | structure | Individual | Static | Attention Work, Motivation Controlled |
| Vitality | Thriving | structure | Individual | Weekly | Energy |
| LearningAtWork | Thriving | structure | Individual | Weekly | Learning |
| Thriving | Thriving | composite | Individual | Weekly | Energy, Learning |
| AgenticBehaviors | Thriving | structure | Individual | Weekly | Behavior Exploration, Behavior HeedfulRelating, Behavior TaskFocus |
| UnitAgenticBehaviors | Thriving | structure | Unit | Weekly | Behavior Exploration, Behavior HeedfulRelating, Behavior TaskFocus |
| DecisionDiscretion | Thriving | structure | Unit | Weekly | Resource Autonomy |
| InformationSharing | Thriving | structure | Unit | Weekly | Resource Information |
| TrustClimate | Thriving | structure | Unit | Weekly | Trust Team |
| Detachment | Recovery | structure | Individual | Daily | Attention Work |
| Relaxation | Recovery | structure | Individual | Daily | Affect Positive Low |
| Mastery | Recovery | structure | Individual | Daily | Learning |
| LeisureControl | Recovery | structure | Individual | Daily | Resource Autonomy |
| WeeklyDetachment | Recovery | structure | Individual | Weekly | Attention Work |
| DailyEngagement | Recovery | structure | Individual | Daily | Attention Work, Energy, Identification Work |
| Flow | Flow | structure | Individual | Momentary | Affect Positive High, Attention Work, Motivation Intrinsic |
| FlowFrequency | Flow | structure | Individual | Weekly | Affect Positive High, Attention Work, Motivation Intrinsic |
| FlowProneness | Flow | structure | Individual | Static | Affect Positive High, Attention Work, Motivation Intrinsic |
| ChallengeSkillBalance | Flow | structure | Individual | Momentary | Demand Cognitive, Skill |
| Conscientiousness | Flow | structure | Individual | Static | Trait Conscientiousness |
| HarmoniousPassion | Passion | structure | Individual | Static | Identification Work, Motivation Autonomous |
| ObsessivePassion | Passion | structure | Individual | Static | Identification Work, Motivation Controlled |
| WorkingExcessively | Workaholism | structure | Individual | Static | Behavior WorkingHours |
| WorkingCompulsively | Workaholism | structure | Individual | Static | Motivation Controlled |
| Workaholism | Workaholism | composite | Individual | Static | Behavior WorkingHours, Motivation Controlled |
| ShiromVigor | ShiromVigor | structure | Individual | Weekly | Affect Positive High, Energy |
| ChallengeDemands | ChallengeHindrance | structure | Individual | Weekly | Demand Responsibility, Demand TimePressure, Demand Workload |
| HindranceDemands | ChallengeHindrance | structure | Individual | Weekly | Demand Hassle, Demand RoleAmbiguity, Demand RoleConflict |
| TeamEngagement | Team | structure | Team | Weekly | Attention Work, Energy, Identification Work |
| TeamPerformance | Team | structure | Team | Weekly | Performance Task |
| JobDemands | BakkerDemerouti2007 | structure | Individual | Weekly | Demand Emotional, Demand RoleConflict, Demand Workload |
| JobResources | BakkerDemerouti2007 | structure | Individual | Weekly | Resource Autonomy, Resource Development, Resource Feedback, Resource SocialSupport |
| Resources | Hobfoll1989 | structure | Individual | Weekly | Efficacy Self, Resource CareerSecurity, Resource Object, Resource Pay, Resource SocialSupport, Resource Time |
| NetLoss | Hobfoll1989 | structure | Individual | Weekly | Change CareerSecurity, Change Pay, Change SocialSupport, Change Time |
| StressReaction | Hobfoll1989 | structure | Individual | Weekly | Affect Negative High, Symptom Psychosomatic |
| EmotionalExhaustion | MaslachJackson1981 | structure | Individual | Weekly | Energy |
| Depersonalization | MaslachJackson1981 | structure | Individual | Weekly | Identification Work |
| ReducedAccomplishment | MaslachJackson1981 | structure | Individual | Weekly | Efficacy Work |
| Vigor | Schaufeli2002 | structure | Individual | Weekly | Energy |
| Dedication | Schaufeli2002 | structure | Individual | Weekly | Identification Work |
| Absorption | Schaufeli2002 | structure | Individual | Weekly | Attention Work |
| WorkEngagement | Schaufeli2002 | composite | Individual | Weekly | Attention Work, Energy, Identification Work |
| Effort | Siegrist1996 | structure | Individual | Weekly | Demand Interruption, Demand Responsibility, Demand TimePressure, Demand Workload |
| Reward | Siegrist1996 | structure | Individual | Weekly | Resource CareerSecurity, Resource Esteem, Resource Pay |
| Imbalance | Siegrist1996 | composite | Individual | Weekly | Demand Interruption, Demand Responsibility, Demand TimePressure, Demand Workload, Resource CareerSecurity, Resource Esteem, Resource Pay |
| Overcommitment | Siegrist1996 | structure | Individual | Static | Attention Work, Motivation Controlled |
| CardiovascularStrain | Siegrist1996 | structure | Individual | Weekly | Affect Negative High, Symptom Cardiovascular |
| Vitality | Spreitzer2005 | structure | Individual | Weekly | Energy |
| Learning | Spreitzer2005 | structure | Individual | Weekly | Learning |
| Thriving | Spreitzer2005 | composite | Individual | Weekly | Energy, Learning |

## Propositions

| Proposition | Theory | Antecedent | Consequent | Direction | Scope | Boundary | Evidence |
|---|---|---|---|---|---|---|---|
| engagement_task_performance | Engagement | Engagement | TaskPerformance | Positive | Individual / Weekly | none | MetaAnalytic |
| engagement_contextual_performance | Engagement | Engagement | ContextualPerformance | Positive | Individual / Weekly | none | MetaAnalytic |
| engagement_turnover | Engagement | Engagement | TurnoverIntention | Negative | Individual / Weekly | none | MetaAnalytic |
| exhaustion_cynicism | Burnout | Exhaustion | Cynicism | Positive | Individual / Weekly | none | Longitudinal |
| cynicism_reduced_efficacy | Burnout | Cynicism | ReducedEfficacy | Positive | Individual / Weekly | none | CrossSectional |
| burnout_task_performance | Burnout | Burnout | TaskPerformance | Negative | Individual / Weekly | none | MetaAnalytic |
| exhaustion_task_performance | Burnout | Exhaustion | TaskPerformance | Negative | Individual / Weekly | none | MetaAnalytic |
| burnout_turnover | Burnout | Burnout | TurnoverIntention | Positive | Individual / Weekly | none | MetaAnalytic |
| demands_exhaustion | JDR | JobDemands | Exhaustion | Positive | Individual / Weekly | none | MetaAnalytic |
| demands_exhaustion_buffered | JDR | JobDemands | Exhaustion | Positive | Individual / Weekly | moderator:JobResources:Buffers | CrossSectional |
| exhaustion_health | JDR | Exhaustion | HealthComplaints | Positive | Individual / Weekly | none | Longitudinal |
| resources_engagement | JDR | JobResources | Engagement | Positive | Individual / Weekly | none | MetaAnalytic |
| resources_engagement_boosted | JDR | JobResources | Engagement | Positive | Individual / Weekly | moderator:JobDemands:Amplifies | CrossSectional |
| resources_exhaustion | JDR | JobResources | Exhaustion | Negative | Individual / Weekly | none | MetaAnalytic |
| demands_engagement | JDR | JobDemands | Engagement | Null | Individual / Weekly | none | CrossSectional |
| personal_resources_engagement | JDR | PersonalResources | Engagement | Positive | Individual / Weekly | none | Longitudinal |
| engagement_resources | JDR | Engagement | JobResources | Positive | Individual / Weekly | none | Longitudinal |
| engagement_commitment | JDR | Engagement | OrganizationalCommitment | Positive | Individual / Weekly | none | Longitudinal |
| demands_task_performance | JDR | JobDemands | TaskPerformance | Negative | Individual / Weekly | none | CrossSectional |
| loss_strain | COR | ResourceLoss | Strain | Positive | Individual / Weekly | none | Longitudinal |
| gain_strain | COR | ResourceGain | Strain | Negative | Individual / Weekly | none | Longitudinal |
| resources_strain | COR | Resources | Strain | Negative | Individual / Weekly | none | MetaAnalytic |
| loss_exhaustion | COR | ResourceLoss | Exhaustion | Positive | Individual / Weekly | none | MetaAnalytic |
| demands_loss | COR | JobDemands | ResourceLoss | Positive | Individual / Weekly | none | CrossSectional |
| strain_loss | COR | Strain | ResourceLoss | Positive | Individual / Weekly | none | Longitudinal |
| resources_gain | COR | Resources | ResourceGain | Positive | Individual / Weekly | none | Longitudinal |
| gain_engagement | COR | ResourceGain | Engagement | Positive | Individual / Weekly | none | Longitudinal |
| imbalance_strain | ERI | EffortRewardImbalance | Strain | Positive | Individual / Weekly | none | MetaAnalytic |
| overcommitment_strain | ERI | Overcommitment | Strain | Positive | Individual / Weekly | none | CrossSectional |
| imbalance_strain_overcommitted | ERI | EffortRewardImbalance | Strain | Positive | Individual / Weekly | moderator:Overcommitment:Amplifies | CrossSectional |
| reward_strain | ERI | Reward | Strain | Negative | Individual / Weekly | none | CrossSectional |
| effort_strain | ERI | Effort | Strain | Positive | Individual / Weekly | none | CrossSectional |
| imbalance_exhaustion | ERI | EffortRewardImbalance | Exhaustion | Positive | Individual / Weekly | none | CrossSectional |
| discretion_agentic | Thriving | DecisionDiscretion | AgenticBehaviors | Positive | Unit / Weekly | none | None |
| information_agentic | Thriving | InformationSharing | AgenticBehaviors | Positive | Unit / Weekly | none | None |
| trust_agentic | Thriving | TrustClimate | AgenticBehaviors | Positive | Unit / Weekly | none | None |
| agentic_thriving | Thriving | AgenticBehaviors | Thriving | Positive | Individual / Weekly | none | Longitudinal |
| thriving_task_performance | Thriving | Thriving | TaskPerformance | Positive | Individual / Weekly | none | MetaAnalytic |
| thriving_health | Thriving | Thriving | HealthComplaints | Negative | Individual / Weekly | none | MetaAnalytic |
| thriving_burnout | Thriving | Thriving | Burnout | Negative | Individual / Weekly | none | MetaAnalytic |
| detachment_exhaustion | Recovery | Detachment | Exhaustion | Negative | Individual / Weekly | none | Longitudinal |
| detachment_daily_engagement | Recovery | Detachment | DailyEngagement | Positive | Individual / Daily | none | Longitudinal |
| demands_engagement_detachment | Recovery | JobDemands | Engagement | Negative | Individual / Weekly | moderator:WeeklyDetachment:Buffers | Longitudinal |
| demands_health_detachment | Recovery | JobDemands | HealthComplaints | Positive | Individual / Weekly | moderator:WeeklyDetachment:Buffers | Longitudinal |
| relaxation_daily_engagement | Recovery | Relaxation | DailyEngagement | Positive | Individual / Daily | none | Longitudinal |
| balance_flow | Flow | ChallengeSkillBalance | Flow | Positive | Individual / Momentary | none | Longitudinal |
| resources_flow | Flow | JobResources | Flow | Positive | Individual / Weekly | none | CrossSectional |
| flow_task_performance_conscientious | Flow | Flow | TaskPerformance | Positive | Individual / Weekly | moderator:Conscientiousness:Amplifies | CrossSectional |
| flow_vigor_detached | Flow | Flow | Vigor | Positive | Individual / Weekly | moderator:WeeklyDetachment:Amplifies | Longitudinal |
| obsessive_exhaustion | Passion | ObsessivePassion | Exhaustion | Positive | Individual / Weekly | none | Longitudinal |
| harmonious_exhaustion | Passion | HarmoniousPassion | Exhaustion | Negative | Individual / Weekly | none | Longitudinal |
| harmonious_flow | Passion | HarmoniousPassion | FlowProneness | Positive | Individual / Static | none | CrossSectional |
| obsessive_flow | Passion | ObsessivePassion | FlowProneness | Null | Individual / Static | none | CrossSectional |
| harmonious_engagement | Passion | HarmoniousPassion | Engagement | Positive | Individual / Weekly | none | CrossSectional |
| workaholism_exhaustion | Workaholism | Workaholism | Exhaustion | Positive | Individual / Weekly | none | MetaAnalytic |
| excessive_engagement | Workaholism | WorkingExcessively | Engagement | Positive | Individual / Weekly | none | CrossSectional |
| compulsive_engagement | Workaholism | WorkingCompulsively | Engagement | Null | Individual / Weekly | none | CrossSectional |
| workaholism_health | Workaholism | Workaholism | HealthComplaints | Positive | Individual / Weekly | none | MetaAnalytic |
| vigor_health | ShiromVigor | ShiromVigor | HealthComplaints | Negative | Individual / Weekly | none | Longitudinal |
| vigor_task_performance | ShiromVigor | ShiromVigor | TaskPerformance | Positive | Individual / Weekly | none | CrossSectional |
| challenge_engagement | ChallengeHindrance | ChallengeDemands | Engagement | Positive | Individual / Weekly | none | MetaAnalytic |
| hindrance_engagement | ChallengeHindrance | HindranceDemands | Engagement | Negative | Individual / Weekly | none | MetaAnalytic |
| challenge_exhaustion | ChallengeHindrance | ChallengeDemands | Exhaustion | Positive | Individual / Weekly | none | MetaAnalytic |
| hindrance_exhaustion | ChallengeHindrance | HindranceDemands | Exhaustion | Positive | Individual / Weekly | none | MetaAnalytic |
| challenge_task_performance | ChallengeHindrance | ChallengeDemands | TaskPerformance | Positive | Individual / Weekly | none | MetaAnalytic |
| hindrance_task_performance | ChallengeHindrance | HindranceDemands | TaskPerformance | Negative | Individual / Weekly | none | MetaAnalytic |
| exhaustion_cynicism | BurnoutProcess | Exhaustion | Cynicism | Positive | Individual / Weekly | none | CrossSectional |
| cynicism_reduced_efficacy | BurnoutProcess | Cynicism | ReducedEfficacy | Null | Individual / Weekly | none | CrossSectional |
| resources_reduced_efficacy | BurnoutProcess | JobResources | ReducedEfficacy | Negative | Individual / Weekly | none | CrossSectional |
| demands_exhaustion | BurnoutProcess | JobDemands | Exhaustion | Positive | Individual / Weekly | none | CrossSectional |
| demands_task_performance | Activation | JobDemands | TaskPerformance | Curvilinear | Individual / Weekly | none | CrossSectional |
| team_engagement_performance | Team | TeamEngagement | TeamPerformance | Positive | Team / Weekly | none | CrossSectional |
| engagement_team_performance | Team | Engagement | TeamPerformance | Positive | Team / Weekly | none | CrossSectional |
| demands_exhaustion | BakkerDemerouti2007 | JobDemands | Exhaustion | Positive | Individual / Weekly | none | CrossSectional |
| resources_engagement | BakkerDemerouti2007 | JobResources | Engagement | Positive | Individual / Weekly | none | CrossSectional |
| demands_exhaustion_buffered | BakkerDemerouti2007 | JobDemands | Exhaustion | Positive | Individual / Weekly | moderator:JobResources:Buffers | CrossSectional |
| resources_engagement_boosted | BakkerDemerouti2007 | JobResources | Engagement | Positive | Individual / Weekly | moderator:JobDemands:Amplifies | CrossSectional |
| engagement_performance | BakkerDemerouti2007 | Engagement | TaskPerformance | Positive | Individual / Weekly | none | CrossSectional |
| loss_stress | Hobfoll1989 | NetLoss | StressReaction | Positive | Individual / Weekly | none | CrossSectional |
| resources_stress | Hobfoll1989 | Resources | StressReaction | Negative | Individual / Weekly | none | CrossSectional |
| stress_loss | Hobfoll1989 | StressReaction | NetLoss | Positive | Individual / Weekly | none | None |
| exhaustion_turnover | MaslachJackson1981 | EmotionalExhaustion | TurnoverIntention | Positive | Individual / Weekly | none | CrossSectional |
| engagement_exhaustion | Schaufeli2002 | WorkEngagement | Exhaustion | Negative | Individual / Weekly | none | CrossSectional |
| imbalance_strain | Siegrist1996 | Imbalance | CardiovascularStrain | Positive | Individual / Weekly | none | Longitudinal |
| overcommitment_strain | Siegrist1996 | Overcommitment | CardiovascularStrain | Positive | Individual / Weekly | none | Longitudinal |
| imbalance_strain_overcommitted | Siegrist1996 | Imbalance | CardiovascularStrain | Positive | Individual / Weekly | moderator:Overcommitment:Amplifies | Longitudinal |
| agentic_thriving | Spreitzer2005 | AgenticBehaviors | Thriving | Positive | Individual / Weekly | none | None |
| discretion_agentic | Spreitzer2005 | DecisionDiscretion | AgenticBehaviors | Positive | Unit / Weekly | none | None |
| thriving_health | Spreitzer2005 | Thriving | HealthComplaints | Negative | Individual / Weekly | none | None |

## Overlap warnings

| A | B | Kind | Shared primitives | Resolution |
|---|---|---|---|---|
| Engagement | Vigor | subtype | Engagement.vigor ~ Vigor.energy | subtype_of |
| Engagement | Dedication | subtype | Engagement.dedication ~ Dedication.identification | subtype_of |
| Engagement | Absorption | subtype | Engagement.absorption ~ Absorption.attention | subtype_of |
| Exhaustion | Vigor | identity | Exhaustion.energy ~ Vigor.energy | distinct_from |
| Exhaustion | Engagement | subtype | Exhaustion.energy ~ Engagement.vigor | distinct_from |
| Cynicism | Dedication | identity | Cynicism.identification ~ Dedication.identification | distinct_from |
| Cynicism | Engagement | subtype | Cynicism.identification ~ Engagement.dedication | distinct_from |
| Burnout | Vigor | subtype | Burnout ∋ Exhaustion.energy ~ Vigor.energy | distinct_from |
| Burnout | Dedication | subtype | Burnout ∋ Cynicism.identification ~ Dedication.identification | distinct_from |
| Burnout | Engagement | partial | Burnout ∋ Exhaustion.energy ~ Engagement.vigor, Burnout ∋ Cynicism.identification ~ Engagement.dedication | distinct_from |
| PersonalResources | ReducedEfficacy | subtype | PersonalResources.efficacy ~ ReducedEfficacy.efficacy | distinct_from |
| PersonalResources | Burnout | partial | PersonalResources.efficacy ~ Burnout ∋ ReducedEfficacy.efficacy | distinct_from |
| Resources | JobResources | partial | Resources.control ~ JobResources.autonomy, Resources.support ~ JobResources.support, Resources.security ~ JobResources.security, Resources.advancement ~ JobResources.development | distinct_from |
| Resources | PersonalResources | partial | Resources.optimism ~ PersonalResources.optimism | distinct_from |
| ResourceGain | ResourceLoss | identity | ResourceGain.control ~ ResourceLoss.control, ResourceGain.support ~ ResourceLoss.support, ResourceGain.security ~ ResourceLoss.security, ResourceGain.status ~ ResourceLoss.status, ResourceGain.time ~ ResourceLoss.time, ResourceGain.money ~ ResourceLoss.money | distinct_from |
| Strain | HealthComplaints | subtype | Strain.symptoms ~ HealthComplaints.symptoms | distinct_from |
| Effort | JobDemands | partial | Effort.workload ~ JobDemands.workload, Effort.timePressure ~ JobDemands.timePressure | distinct_from |
| Reward | JobResources | partial | Reward.career ~ JobResources.security | distinct_from |
| Reward | Resources | subtype | Reward.money ~ Resources.money, Reward.esteem ~ Resources.status, Reward.career ~ Resources.security | subtype_of |
| EffortRewardImbalance | JobDemands | partial | EffortRewardImbalance ∋ Effort.workload ~ JobDemands.workload, EffortRewardImbalance ∋ Effort.timePressure ~ JobDemands.timePressure | distinct_from |
| EffortRewardImbalance | JobResources | partial | EffortRewardImbalance ∋ Reward.career ~ JobResources.security | distinct_from |
| EffortRewardImbalance | Resources | partial | EffortRewardImbalance ∋ Reward.money ~ Resources.money, EffortRewardImbalance ∋ Reward.esteem ~ Resources.status, EffortRewardImbalance ∋ Reward.career ~ Resources.security | distinct_from |
| Vitality | Vigor | identity | Vitality.energy ~ Vigor.energy | distinct_from |
| Vitality | Engagement | subtype | Vitality.energy ~ Engagement.vigor | distinct_from |
| Vitality | Exhaustion | identity | Vitality.energy ~ Exhaustion.energy | distinct_from |
| Vitality | Burnout | subtype | Vitality.energy ~ Burnout ∋ Exhaustion.energy | distinct_from |
| Thriving | Vigor | subtype | Thriving ∋ Vitality.energy ~ Vigor.energy | distinct_from |
| Thriving | Engagement | partial | Thriving ∋ Vitality.energy ~ Engagement.vigor | distinct_from |
| Thriving | Exhaustion | subtype | Thriving ∋ Vitality.energy ~ Exhaustion.energy | distinct_from |
| Thriving | Burnout | partial | Thriving ∋ Vitality.energy ~ Burnout ∋ Exhaustion.energy | distinct_from |
| WeeklyDetachment | Absorption | identity | WeeklyDetachment.attention ~ Absorption.attention | distinct_from |
| WeeklyDetachment | Engagement | subtype | WeeklyDetachment.attention ~ Engagement.absorption | distinct_from |
| DailyEngagement | Detachment | subtype | DailyEngagement.absorption ~ Detachment.attention | distinct_from |
| FlowFrequency | Absorption | subtype | FlowFrequency.absorption ~ Absorption.attention | distinct_from |
| FlowFrequency | Engagement | partial | FlowFrequency.absorption ~ Engagement.absorption | distinct_from |
| FlowFrequency | WeeklyDetachment | subtype | FlowFrequency.absorption ~ WeeklyDetachment.attention | distinct_from |
| FlowProneness | Overcommitment | partial | FlowProneness.absorption ~ Overcommitment.inabilityToWithdraw | distinct_from |
| ObsessivePassion | Overcommitment | partial | ObsessivePassion.motivation ~ Overcommitment.striving | distinct_from |
| ObsessivePassion | HarmoniousPassion | partial | ObsessivePassion.identification ~ HarmoniousPassion.identification | distinct_from |
| WorkingCompulsively | Overcommitment | subtype | WorkingCompulsively.compulsion ~ Overcommitment.striving | distinct_from |
| WorkingCompulsively | ObsessivePassion | subtype | WorkingCompulsively.compulsion ~ ObsessivePassion.motivation | distinct_from |
| Workaholism | Overcommitment | partial | Workaholism ∋ WorkingCompulsively.compulsion ~ Overcommitment.striving | distinct_from |
| Workaholism | ObsessivePassion | partial | Workaholism ∋ WorkingCompulsively.compulsion ~ ObsessivePassion.motivation | distinct_from |
| ShiromVigor | Vigor | subtype | ShiromVigor.physicalStrength ~ Vigor.energy | distinct_from |
| ShiromVigor | Engagement | partial | ShiromVigor.physicalStrength ~ Engagement.vigor | distinct_from |
| ShiromVigor | Exhaustion | subtype | ShiromVigor.physicalStrength ~ Exhaustion.energy | distinct_from |
| ShiromVigor | Burnout | partial | ShiromVigor.physicalStrength ~ Burnout ∋ Exhaustion.energy | distinct_from |
| ShiromVigor | Vitality | subtype | ShiromVigor.physicalStrength ~ Vitality.energy | distinct_from |
| ShiromVigor | Thriving | partial | ShiromVigor.physicalStrength ~ Thriving ∋ Vitality.energy | distinct_from |
| ShiromVigor | FlowFrequency | partial | ShiromVigor.emotionalEnergy ~ FlowFrequency.enjoyment | distinct_from |
| ChallengeDemands | JobDemands | partial | ChallengeDemands.workload ~ JobDemands.workload, ChallengeDemands.timePressure ~ JobDemands.timePressure | distinct_from |
| ChallengeDemands | Effort | subtype | ChallengeDemands.workload ~ Effort.workload, ChallengeDemands.timePressure ~ Effort.timePressure, ChallengeDemands.responsibility ~ Effort.responsibility | distinct_from |
| ChallengeDemands | EffortRewardImbalance | subtype | ChallengeDemands.workload ~ EffortRewardImbalance ∋ Effort.workload, ChallengeDemands.timePressure ~ EffortRewardImbalance ∋ Effort.timePressure, ChallengeDemands.responsibility ~ EffortRewardImbalance ∋ Effort.responsibility | distinct_from |
| HindranceDemands | JobDemands | partial | HindranceDemands.roleConflict ~ JobDemands.roleConflict | distinct_from |
| JobDemands | JobDemands | subtype | JobDemands.workPressure ~ JobDemands.workload, JobDemands.emotional ~ JobDemands.emotional, JobDemands.roleConflict ~ JobDemands.roleConflict | unresolved |
| JobDemands | Effort | partial | JobDemands.workPressure ~ Effort.workload | unresolved |
| JobDemands | EffortRewardImbalance | partial | JobDemands.workPressure ~ EffortRewardImbalance ∋ Effort.workload | unresolved |
| JobDemands | ChallengeDemands | partial | JobDemands.workPressure ~ ChallengeDemands.workload | unresolved |
| JobDemands | HindranceDemands | partial | JobDemands.roleConflict ~ HindranceDemands.roleConflict | unresolved |
| JobResources | JobResources | subtype | JobResources.autonomy ~ JobResources.autonomy, JobResources.support ~ JobResources.support, JobResources.feedback ~ JobResources.feedback, JobResources.development ~ JobResources.development | unresolved |
| JobResources | Resources | partial | JobResources.autonomy ~ Resources.control, JobResources.support ~ Resources.support, JobResources.development ~ Resources.advancement | unresolved |
| Resources | JobResources | partial | Resources.conditions ~ JobResources.security, Resources.support ~ JobResources.support | unresolved |
| Resources | Resources | subtype | Resources.objects ~ Resources.objects, Resources.conditions ~ Resources.security, Resources.support ~ Resources.support, Resources.personal ~ Resources.efficacy, Resources.energies ~ Resources.time, Resources.money ~ Resources.money | unresolved |
| Resources | Reward | partial | Resources.conditions ~ Reward.career, Resources.money ~ Reward.money | unresolved |
| Resources | EffortRewardImbalance | partial | Resources.conditions ~ EffortRewardImbalance ∋ Reward.career, Resources.money ~ EffortRewardImbalance ∋ Reward.money | unresolved |
| Resources | JobResources | partial | Resources.support ~ JobResources.support | unresolved |
| NetLoss | ResourceLoss | subtype | NetLoss.conditions ~ ResourceLoss.security, NetLoss.support ~ ResourceLoss.support, NetLoss.energies ~ ResourceLoss.time, NetLoss.money ~ ResourceLoss.money | unresolved |
| NetLoss | ResourceGain | subtype | NetLoss.conditions ~ ResourceGain.security, NetLoss.support ~ ResourceGain.support, NetLoss.energies ~ ResourceGain.time, NetLoss.money ~ ResourceGain.money | unresolved |
| StressReaction | HealthComplaints | subtype | StressReaction.symptoms ~ HealthComplaints.symptoms | unresolved |
| StressReaction | Strain | identity | StressReaction.affect ~ Strain.affect, StressReaction.symptoms ~ Strain.symptoms | unresolved |
| EmotionalExhaustion | Vigor | identity | EmotionalExhaustion.energy ~ Vigor.energy | unresolved |
| EmotionalExhaustion | Engagement | subtype | EmotionalExhaustion.energy ~ Engagement.vigor | unresolved |
| EmotionalExhaustion | Exhaustion | identity | EmotionalExhaustion.energy ~ Exhaustion.energy | unresolved |
| EmotionalExhaustion | Burnout | subtype | EmotionalExhaustion.energy ~ Burnout ∋ Exhaustion.energy | unresolved |
| EmotionalExhaustion | Vitality | identity | EmotionalExhaustion.energy ~ Vitality.energy | unresolved |
| EmotionalExhaustion | Thriving | subtype | EmotionalExhaustion.energy ~ Thriving ∋ Vitality.energy | unresolved |
| EmotionalExhaustion | ShiromVigor | subtype | EmotionalExhaustion.energy ~ ShiromVigor.physicalStrength | unresolved |
| Depersonalization | Dedication | identity | Depersonalization.identification ~ Dedication.identification | unresolved |
| Depersonalization | Engagement | subtype | Depersonalization.identification ~ Engagement.dedication | unresolved |
| Depersonalization | Cynicism | identity | Depersonalization.identification ~ Cynicism.identification | unresolved |
| Depersonalization | Burnout | subtype | Depersonalization.identification ~ Burnout ∋ Cynicism.identification | unresolved |
| ReducedAccomplishment | ReducedEfficacy | identity | ReducedAccomplishment.efficacy ~ ReducedEfficacy.efficacy | unresolved |
| ReducedAccomplishment | Burnout | subtype | ReducedAccomplishment.efficacy ~ Burnout ∋ ReducedEfficacy.efficacy | unresolved |
| ReducedAccomplishment | PersonalResources | subtype | ReducedAccomplishment.efficacy ~ PersonalResources.efficacy | unresolved |
| Vigor | Vigor | identity | Vigor.energy ~ Vigor.energy | unresolved |
| Vigor | Engagement | subtype | Vigor.energy ~ Engagement.vigor | unresolved |
| Vigor | Exhaustion | identity | Vigor.energy ~ Exhaustion.energy | unresolved |
| Vigor | Burnout | subtype | Vigor.energy ~ Burnout ∋ Exhaustion.energy | unresolved |
| Vigor | Vitality | identity | Vigor.energy ~ Vitality.energy | unresolved |
| Vigor | Thriving | subtype | Vigor.energy ~ Thriving ∋ Vitality.energy | unresolved |
| Vigor | ShiromVigor | subtype | Vigor.energy ~ ShiromVigor.physicalStrength | unresolved |
| Vigor | EmotionalExhaustion | identity | Vigor.energy ~ EmotionalExhaustion.energy | unresolved |
| Dedication | Dedication | identity | Dedication.identification ~ Dedication.identification | unresolved |
| Dedication | Engagement | subtype | Dedication.identification ~ Engagement.dedication | unresolved |
| Dedication | Cynicism | identity | Dedication.identification ~ Cynicism.identification | unresolved |
| Dedication | Burnout | subtype | Dedication.identification ~ Burnout ∋ Cynicism.identification | unresolved |
| Dedication | Depersonalization | identity | Dedication.identification ~ Depersonalization.identification | unresolved |
| Absorption | Absorption | identity | Absorption.attention ~ Absorption.attention | unresolved |
| Absorption | Engagement | subtype | Absorption.attention ~ Engagement.absorption | unresolved |
| Absorption | WeeklyDetachment | identity | Absorption.attention ~ WeeklyDetachment.attention | unresolved |
| Absorption | FlowFrequency | subtype | Absorption.attention ~ FlowFrequency.absorption | unresolved |
| WorkEngagement | Vigor | subtype | WorkEngagement ∋ Vigor.energy ~ Vigor.energy | unresolved |
| WorkEngagement | Dedication | subtype | WorkEngagement ∋ Dedication.identification ~ Dedication.identification | unresolved |
| WorkEngagement | Absorption | subtype | WorkEngagement ∋ Absorption.attention ~ Absorption.attention | unresolved |
| WorkEngagement | Engagement | identity | WorkEngagement ∋ Vigor.energy ~ Engagement.vigor, WorkEngagement ∋ Dedication.identification ~ Engagement.dedication, WorkEngagement ∋ Absorption.attention ~ Engagement.absorption | alias_of |
| WorkEngagement | Exhaustion | subtype | WorkEngagement ∋ Vigor.energy ~ Exhaustion.energy | unresolved |
| WorkEngagement | Cynicism | subtype | WorkEngagement ∋ Dedication.identification ~ Cynicism.identification | unresolved |
| WorkEngagement | Burnout | partial | WorkEngagement ∋ Vigor.energy ~ Burnout ∋ Exhaustion.energy, WorkEngagement ∋ Dedication.identification ~ Burnout ∋ Cynicism.identification | unresolved |
| WorkEngagement | Vitality | subtype | WorkEngagement ∋ Vigor.energy ~ Vitality.energy | unresolved |
| WorkEngagement | Thriving | partial | WorkEngagement ∋ Vigor.energy ~ Thriving ∋ Vitality.energy | unresolved |
| WorkEngagement | WeeklyDetachment | subtype | WorkEngagement ∋ Absorption.attention ~ WeeklyDetachment.attention | unresolved |
| WorkEngagement | FlowFrequency | partial | WorkEngagement ∋ Absorption.attention ~ FlowFrequency.absorption | unresolved |
| WorkEngagement | ShiromVigor | partial | WorkEngagement ∋ Vigor.energy ~ ShiromVigor.physicalStrength | unresolved |
| WorkEngagement | EmotionalExhaustion | subtype | WorkEngagement ∋ Vigor.energy ~ EmotionalExhaustion.energy | unresolved |
| WorkEngagement | Depersonalization | subtype | WorkEngagement ∋ Dedication.identification ~ Depersonalization.identification | unresolved |
| Effort | JobDemands | partial | Effort.timePressure ~ JobDemands.timePressure, Effort.overload ~ JobDemands.workload | unresolved |
| Effort | Effort | identity | Effort.timePressure ~ Effort.timePressure, Effort.interruptions ~ Effort.interruptions, Effort.responsibility ~ Effort.responsibility, Effort.overload ~ Effort.workload | unresolved |
| Effort | EffortRewardImbalance | subtype | Effort.timePressure ~ EffortRewardImbalance ∋ Effort.timePressure, Effort.interruptions ~ EffortRewardImbalance ∋ Effort.interruptions, Effort.responsibility ~ EffortRewardImbalance ∋ Effort.responsibility, Effort.overload ~ EffortRewardImbalance ∋ Effort.workload | unresolved |
| Effort | ChallengeDemands | subtype | Effort.timePressure ~ ChallengeDemands.timePressure, Effort.responsibility ~ ChallengeDemands.responsibility, Effort.overload ~ ChallengeDemands.workload | unresolved |
| Effort | JobDemands | partial | Effort.overload ~ JobDemands.workPressure | unresolved |
| Reward | JobResources | partial | Reward.statusControl ~ JobResources.security | unresolved |
| Reward | Resources | subtype | Reward.money ~ Resources.money, Reward.esteem ~ Resources.status, Reward.statusControl ~ Resources.security | unresolved |
| Reward | Reward | identity | Reward.money ~ Reward.money, Reward.esteem ~ Reward.esteem, Reward.statusControl ~ Reward.career | unresolved |
| Reward | EffortRewardImbalance | subtype | Reward.money ~ EffortRewardImbalance ∋ Reward.money, Reward.esteem ~ EffortRewardImbalance ∋ Reward.esteem, Reward.statusControl ~ EffortRewardImbalance ∋ Reward.career | unresolved |
| Reward | Resources | partial | Reward.money ~ Resources.money, Reward.statusControl ~ Resources.conditions | unresolved |
| Imbalance | JobDemands | partial | Imbalance ∋ Effort.timePressure ~ JobDemands.timePressure, Imbalance ∋ Effort.overload ~ JobDemands.workload | unresolved |
| Imbalance | JobResources | partial | Imbalance ∋ Reward.statusControl ~ JobResources.security | unresolved |
| Imbalance | Resources | partial | Imbalance ∋ Reward.money ~ Resources.money, Imbalance ∋ Reward.esteem ~ Resources.status, Imbalance ∋ Reward.statusControl ~ Resources.security | unresolved |
| Imbalance | Effort | subtype | Imbalance ∋ Effort.timePressure ~ Effort.timePressure, Imbalance ∋ Effort.interruptions ~ Effort.interruptions, Imbalance ∋ Effort.responsibility ~ Effort.responsibility, Imbalance ∋ Effort.overload ~ Effort.workload | unresolved |
| Imbalance | Reward | subtype | Imbalance ∋ Reward.money ~ Reward.money, Imbalance ∋ Reward.esteem ~ Reward.esteem, Imbalance ∋ Reward.statusControl ~ Reward.career | unresolved |
| Imbalance | EffortRewardImbalance | identity | Imbalance ∋ Effort.timePressure ~ EffortRewardImbalance ∋ Effort.timePressure, Imbalance ∋ Effort.interruptions ~ EffortRewardImbalance ∋ Effort.interruptions, Imbalance ∋ Effort.responsibility ~ EffortRewardImbalance ∋ Effort.responsibility, Imbalance ∋ Effort.overload ~ EffortRewardImbalance ∋ Effort.workload, Imbalance ∋ Reward.money ~ EffortRewardImbalance ∋ Reward.money, Imbalance ∋ Reward.esteem ~ EffortRewardImbalance ∋ Reward.esteem, Imbalance ∋ Reward.statusControl ~ EffortRewardImbalance ∋ Reward.career | unresolved |
| Imbalance | ChallengeDemands | subtype | Imbalance ∋ Effort.timePressure ~ ChallengeDemands.timePressure, Imbalance ∋ Effort.responsibility ~ ChallengeDemands.responsibility, Imbalance ∋ Effort.overload ~ ChallengeDemands.workload | unresolved |
| Imbalance | JobDemands | partial | Imbalance ∋ Effort.overload ~ JobDemands.workPressure | unresolved |
| Imbalance | Resources | partial | Imbalance ∋ Reward.money ~ Resources.money, Imbalance ∋ Reward.statusControl ~ Resources.conditions | unresolved |
| Overcommitment | Overcommitment | identity | Overcommitment.striving ~ Overcommitment.striving, Overcommitment.inabilityToWithdraw ~ Overcommitment.inabilityToWithdraw | unresolved |
| Overcommitment | FlowProneness | partial | Overcommitment.inabilityToWithdraw ~ FlowProneness.absorption | unresolved |
| Overcommitment | ObsessivePassion | partial | Overcommitment.striving ~ ObsessivePassion.motivation | unresolved |
| Overcommitment | WorkingCompulsively | subtype | Overcommitment.striving ~ WorkingCompulsively.compulsion | unresolved |
| Overcommitment | Workaholism | partial | Overcommitment.striving ~ Workaholism ∋ WorkingCompulsively.compulsion | unresolved |
| CardiovascularStrain | Strain | partial | CardiovascularStrain.affect ~ Strain.affect | unresolved |
| CardiovascularStrain | StressReaction | partial | CardiovascularStrain.affect ~ StressReaction.affect | unresolved |
| Vitality | Vigor | identity | Vitality.energy ~ Vigor.energy | unresolved |
| Vitality | Engagement | subtype | Vitality.energy ~ Engagement.vigor | unresolved |
| Vitality | Exhaustion | identity | Vitality.energy ~ Exhaustion.energy | unresolved |
| Vitality | Burnout | subtype | Vitality.energy ~ Burnout ∋ Exhaustion.energy | unresolved |
| Vitality | Vitality | identity | Vitality.energy ~ Vitality.energy | unresolved |
| Vitality | Thriving | subtype | Vitality.energy ~ Thriving ∋ Vitality.energy | unresolved |
| Vitality | ShiromVigor | subtype | Vitality.energy ~ ShiromVigor.physicalStrength | unresolved |
| Vitality | EmotionalExhaustion | identity | Vitality.energy ~ EmotionalExhaustion.energy | unresolved |
| Vitality | Vigor | identity | Vitality.energy ~ Vigor.energy | unresolved |
| Vitality | WorkEngagement | subtype | Vitality.energy ~ WorkEngagement ∋ Vigor.energy | unresolved |
| Learning | LearningAtWork | identity | Learning.learning ~ LearningAtWork.learning | unresolved |
| Learning | Thriving | subtype | Learning.learning ~ Thriving ∋ LearningAtWork.learning | unresolved |
| Thriving | Vigor | subtype | Thriving ∋ Vitality.energy ~ Vigor.energy | unresolved |
| Thriving | Engagement | partial | Thriving ∋ Vitality.energy ~ Engagement.vigor | unresolved |
| Thriving | Exhaustion | subtype | Thriving ∋ Vitality.energy ~ Exhaustion.energy | unresolved |
| Thriving | Burnout | partial | Thriving ∋ Vitality.energy ~ Burnout ∋ Exhaustion.energy | unresolved |
| Thriving | Vitality | subtype | Thriving ∋ Vitality.energy ~ Vitality.energy | unresolved |
| Thriving | LearningAtWork | subtype | Thriving ∋ Learning.learning ~ LearningAtWork.learning | unresolved |
| Thriving | Thriving | identity | Thriving ∋ Vitality.energy ~ Thriving ∋ Vitality.energy, Thriving ∋ Learning.learning ~ Thriving ∋ LearningAtWork.learning | unresolved |
| Thriving | ShiromVigor | partial | Thriving ∋ Vitality.energy ~ ShiromVigor.physicalStrength | unresolved |
| Thriving | EmotionalExhaustion | subtype | Thriving ∋ Vitality.energy ~ EmotionalExhaustion.energy | unresolved |
| Thriving | Vigor | subtype | Thriving ∋ Vitality.energy ~ Vigor.energy | unresolved |
| Thriving | WorkEngagement | partial | Thriving ∋ Vitality.energy ~ WorkEngagement ∋ Vigor.energy | unresolved |

## Cross-theory contradictions

| Pair | Scope | Theory A | Theory B |
|---|---|---|---|
| Cynicism → ReducedEfficacy | Individual / Weekly | Burnout: Positive (cynicism_reduced_efficacy) | BurnoutProcess: Null (cynicism_reduced_efficacy) |

## Conditional disagreements

| Pair | Theory A | Theory B |
|---|---|---|
| JobDemands → Engagement | JDR: Null [none] | Recovery: Negative [moderator:WeeklyDetachment:Buffers] |

## Shape disagreements

| Pair | Theory A | Theory B |
|---|---|---|
| JobDemands → TaskPerformance | JDR: Negative | Activation: Curvilinear |

## Implied propositions

| Implied | Direction | Status | Theories | Premise pairs |
|---|---|---|---|---|
| JobDemands → Cynicism | Positive | untested | BakkerDemerouti2007, Burnout, BurnoutProcess | demands_exhaustion ∘ exhaustion_cynicism; demands_exhaustion ∘ exhaustion_cynicism |
| JobDemands → TaskPerformance | Negative | untested | BakkerDemerouti2007, Burnout | demands_exhaustion ∘ exhaustion_task_performance |
| JobDemands → HealthComplaints | Positive | untested | BakkerDemerouti2007, JDR | demands_exhaustion ∘ exhaustion_health |
| JobResources → ContextualPerformance | Positive | untested | BakkerDemerouti2007, Engagement | resources_engagement ∘ engagement_contextual_performance |
| JobResources → TaskPerformance | Positive | untested | BakkerDemerouti2007, Engagement | resources_engagement ∘ engagement_task_performance; resources_engagement ∘ engagement_performance |
| JobResources → TurnoverIntention | Negative | untested | BakkerDemerouti2007, Engagement | resources_engagement ∘ engagement_turnover |
| JobResources → JobResources | Positive | untested | BakkerDemerouti2007, JDR | resources_engagement ∘ engagement_resources |
| JobResources → OrganizationalCommitment | Positive | untested | BakkerDemerouti2007, JDR | resources_engagement ∘ engagement_commitment |
| Resources → NetLoss | Negative | untested | Hobfoll1989 | resources_stress ∘ stress_loss |
| WorkEngagement → Cynicism | Negative | untested | Schaufeli2002, Burnout, BurnoutProcess | engagement_exhaustion ∘ exhaustion_cynicism; engagement_exhaustion ∘ exhaustion_cynicism |
| WorkEngagement → TaskPerformance | Positive | untested | Schaufeli2002, Burnout | engagement_exhaustion ∘ exhaustion_task_performance |
| WorkEngagement → HealthComplaints | Negative | untested | Schaufeli2002, JDR | engagement_exhaustion ∘ exhaustion_health |
| Exhaustion → ReducedEfficacy | Positive | untested | Burnout, BurnoutProcess | exhaustion_cynicism ∘ cynicism_reduced_efficacy; exhaustion_cynicism ∘ cynicism_reduced_efficacy |
| ResourceGain → ResourceLoss | Negative | untested | COR | gain_strain ∘ strain_loss |
| ResourceGain → ContextualPerformance | Positive | untested | COR, Engagement | gain_engagement ∘ engagement_contextual_performance |
| ResourceGain → TaskPerformance | Positive | untested | COR, Engagement, BakkerDemerouti2007 | gain_engagement ∘ engagement_task_performance; gain_engagement ∘ engagement_performance |
| ResourceGain → TurnoverIntention | Negative | untested | COR, Engagement | gain_engagement ∘ engagement_turnover |
| ResourceGain → JobResources | Positive | untested | COR, JDR | gain_engagement ∘ engagement_resources |
| ResourceGain → OrganizationalCommitment | Positive | untested | COR, JDR | gain_engagement ∘ engagement_commitment |
| ResourceLoss → Cynicism | Positive | untested | COR, Burnout, BurnoutProcess | loss_exhaustion ∘ exhaustion_cynicism; loss_exhaustion ∘ exhaustion_cynicism |
| ResourceLoss → TaskPerformance | Negative | untested | COR, Burnout | loss_exhaustion ∘ exhaustion_task_performance |
| ResourceLoss → HealthComplaints | Positive | untested | COR, JDR | loss_exhaustion ∘ exhaustion_health |
| Resources → ResourceLoss | Negative | untested | COR | resources_strain ∘ strain_loss |
| Resources → Strain | Negative | tested | COR | resources_gain ∘ gain_strain |
| Resources → Engagement | Positive | untested | COR | resources_gain ∘ gain_engagement |
| Strain → Exhaustion | Positive | untested | COR | strain_loss ∘ loss_exhaustion |
| ChallengeDemands → Cynicism | Positive | untested | ChallengeHindrance, Burnout, BurnoutProcess | challenge_exhaustion ∘ exhaustion_cynicism; challenge_exhaustion ∘ exhaustion_cynicism |
| ChallengeDemands → ContextualPerformance | Positive | untested | ChallengeHindrance, Engagement | challenge_engagement ∘ engagement_contextual_performance |
| ChallengeDemands → TaskPerformance | Negative (disagreeing implications) | contradicted | ChallengeHindrance, Burnout | challenge_exhaustion ∘ exhaustion_task_performance |
| ChallengeDemands → TaskPerformance | Positive (disagreeing implications) | tested | ChallengeHindrance, Engagement, BakkerDemerouti2007 | challenge_engagement ∘ engagement_task_performance; challenge_engagement ∘ engagement_performance |
| ChallengeDemands → TurnoverIntention | Negative | untested | ChallengeHindrance, Engagement | challenge_engagement ∘ engagement_turnover |
| ChallengeDemands → HealthComplaints | Positive | untested | ChallengeHindrance, JDR | challenge_exhaustion ∘ exhaustion_health |
| ChallengeDemands → JobResources | Positive | untested | ChallengeHindrance, JDR | challenge_engagement ∘ engagement_resources |
| ChallengeDemands → OrganizationalCommitment | Positive | untested | ChallengeHindrance, JDR | challenge_engagement ∘ engagement_commitment |
| HindranceDemands → Cynicism | Positive | untested | ChallengeHindrance, Burnout, BurnoutProcess | hindrance_exhaustion ∘ exhaustion_cynicism; hindrance_exhaustion ∘ exhaustion_cynicism |
| HindranceDemands → ContextualPerformance | Negative | untested | ChallengeHindrance, Engagement | hindrance_engagement ∘ engagement_contextual_performance |
| HindranceDemands → TaskPerformance | Negative | tested | ChallengeHindrance, Engagement, BakkerDemerouti2007, Burnout | hindrance_engagement ∘ engagement_task_performance; hindrance_engagement ∘ engagement_performance; hindrance_exhaustion ∘ exhaustion_task_performance |
| HindranceDemands → TurnoverIntention | Positive | untested | ChallengeHindrance, Engagement | hindrance_engagement ∘ engagement_turnover |
| HindranceDemands → HealthComplaints | Positive | untested | ChallengeHindrance, JDR | hindrance_exhaustion ∘ exhaustion_health |
| HindranceDemands → JobResources | Negative | untested | ChallengeHindrance, JDR | hindrance_engagement ∘ engagement_resources |
| HindranceDemands → OrganizationalCommitment | Negative | untested | ChallengeHindrance, JDR | hindrance_engagement ∘ engagement_commitment |
| Effort → ResourceLoss | Positive | untested | ERI, COR | effort_strain ∘ strain_loss |
| EffortRewardImbalance → Cynicism | Positive | untested | ERI, Burnout, BurnoutProcess | imbalance_exhaustion ∘ exhaustion_cynicism; imbalance_exhaustion ∘ exhaustion_cynicism |
| EffortRewardImbalance → ResourceLoss | Positive | untested | ERI, COR | imbalance_strain ∘ strain_loss |
| EffortRewardImbalance → TaskPerformance | Negative | untested | ERI, Burnout | imbalance_exhaustion ∘ exhaustion_task_performance |
| EffortRewardImbalance → HealthComplaints | Positive | untested | ERI, JDR | imbalance_exhaustion ∘ exhaustion_health |
| Overcommitment → ResourceLoss | Positive | untested | ERI, COR | overcommitment_strain ∘ strain_loss |
| Reward → ResourceLoss | Negative | untested | ERI, COR | reward_strain ∘ strain_loss |
| Engagement → Exhaustion | Negative | untested | JDR | engagement_resources ∘ resources_exhaustion |
| Engagement → ReducedEfficacy | Negative | untested | JDR, BurnoutProcess | engagement_resources ∘ resources_reduced_efficacy |
| Engagement → Flow | Positive | untested | JDR, Flow | engagement_resources ∘ resources_flow |
| JobDemands → Cynicism | Positive | untested | JDR, Burnout, BurnoutProcess | demands_exhaustion ∘ exhaustion_cynicism; demands_exhaustion ∘ exhaustion_cynicism; demands_exhaustion ∘ exhaustion_cynicism; demands_exhaustion ∘ exhaustion_cynicism |
| JobDemands → Exhaustion | Positive | tested | COR | demands_loss ∘ loss_exhaustion |
| JobDemands → Strain | Positive | untested | COR | demands_loss ∘ loss_strain |
| JobDemands → TaskPerformance | Negative | tested | JDR, Burnout, BurnoutProcess | demands_exhaustion ∘ exhaustion_task_performance; demands_exhaustion ∘ exhaustion_task_performance |
| JobDemands → HealthComplaints | Positive | untested | JDR, BurnoutProcess | demands_exhaustion ∘ exhaustion_health; demands_exhaustion ∘ exhaustion_health |
| JobResources → Cynicism | Negative | untested | JDR, Burnout, BurnoutProcess | resources_exhaustion ∘ exhaustion_cynicism; resources_exhaustion ∘ exhaustion_cynicism |
| JobResources → ContextualPerformance | Positive | untested | JDR, Engagement | resources_engagement ∘ engagement_contextual_performance |
| JobResources → TaskPerformance | Positive | untested | JDR, Engagement, BakkerDemerouti2007, Burnout | resources_engagement ∘ engagement_task_performance; resources_engagement ∘ engagement_performance; resources_exhaustion ∘ exhaustion_task_performance |
| JobResources → TurnoverIntention | Negative | untested | JDR, Engagement | resources_engagement ∘ engagement_turnover |
| JobResources → HealthComplaints | Negative | untested | JDR | resources_exhaustion ∘ exhaustion_health |
| JobResources → OrganizationalCommitment | Positive | untested | JDR | resources_engagement ∘ engagement_commitment |
| PersonalResources → ContextualPerformance | Positive | untested | JDR, Engagement | personal_resources_engagement ∘ engagement_contextual_performance |
| PersonalResources → TaskPerformance | Positive | untested | JDR, Engagement, BakkerDemerouti2007 | personal_resources_engagement ∘ engagement_task_performance; personal_resources_engagement ∘ engagement_performance |
| PersonalResources → TurnoverIntention | Negative | untested | JDR, Engagement | personal_resources_engagement ∘ engagement_turnover |
| PersonalResources → JobResources | Positive | untested | JDR | personal_resources_engagement ∘ engagement_resources |
| PersonalResources → OrganizationalCommitment | Positive | untested | JDR | personal_resources_engagement ∘ engagement_commitment |
| HarmoniousPassion → Cynicism | Negative | untested | Passion, Burnout, BurnoutProcess | harmonious_exhaustion ∘ exhaustion_cynicism; harmonious_exhaustion ∘ exhaustion_cynicism |
| HarmoniousPassion → ContextualPerformance | Positive | untested | Passion, Engagement | harmonious_engagement ∘ engagement_contextual_performance |
| HarmoniousPassion → TaskPerformance | Positive | untested | Passion, Burnout, Engagement, BakkerDemerouti2007 | harmonious_exhaustion ∘ exhaustion_task_performance; harmonious_engagement ∘ engagement_task_performance; harmonious_engagement ∘ engagement_performance |
| HarmoniousPassion → TurnoverIntention | Negative | untested | Passion, Engagement | harmonious_engagement ∘ engagement_turnover |
| HarmoniousPassion → HealthComplaints | Negative | untested | Passion, JDR | harmonious_exhaustion ∘ exhaustion_health |
| HarmoniousPassion → JobResources | Positive | untested | Passion, JDR | harmonious_engagement ∘ engagement_resources |
| HarmoniousPassion → OrganizationalCommitment | Positive | untested | Passion, JDR | harmonious_engagement ∘ engagement_commitment |
| ObsessivePassion → Cynicism | Positive | untested | Passion, Burnout, BurnoutProcess | obsessive_exhaustion ∘ exhaustion_cynicism; obsessive_exhaustion ∘ exhaustion_cynicism |
| ObsessivePassion → TaskPerformance | Negative | untested | Passion, Burnout | obsessive_exhaustion ∘ exhaustion_task_performance |
| ObsessivePassion → HealthComplaints | Positive | untested | Passion, JDR | obsessive_exhaustion ∘ exhaustion_health |
| Detachment → Cynicism | Negative | untested | Recovery, Burnout, BurnoutProcess | detachment_exhaustion ∘ exhaustion_cynicism; detachment_exhaustion ∘ exhaustion_cynicism |
| Detachment → TaskPerformance | Positive | untested | Recovery, Burnout | detachment_exhaustion ∘ exhaustion_task_performance |
| Detachment → HealthComplaints | Negative | untested | Recovery, JDR | detachment_exhaustion ∘ exhaustion_health |
| AgenticBehaviors → Burnout | Negative | untested | Thriving | agentic_thriving ∘ thriving_burnout |
| AgenticBehaviors → TaskPerformance | Positive | untested | Thriving | agentic_thriving ∘ thriving_task_performance |
| AgenticBehaviors → HealthComplaints | Negative | untested | Thriving, Spreitzer2005 | agentic_thriving ∘ thriving_health; agentic_thriving ∘ thriving_health |
| Thriving → TaskPerformance | Positive | tested | Thriving, Burnout | thriving_burnout ∘ burnout_task_performance |
| Thriving → TurnoverIntention | Negative | untested | Thriving, Burnout | thriving_burnout ∘ burnout_turnover |
| Workaholism → Cynicism | Positive | untested | Workaholism, Burnout, BurnoutProcess | workaholism_exhaustion ∘ exhaustion_cynicism; workaholism_exhaustion ∘ exhaustion_cynicism |
| Workaholism → TaskPerformance | Negative | untested | Workaholism, Burnout | workaholism_exhaustion ∘ exhaustion_task_performance |
| Workaholism → HealthComplaints | Positive | tested | Workaholism, JDR | workaholism_exhaustion ∘ exhaustion_health |
| WorkingExcessively → ContextualPerformance | Positive | untested | Workaholism, Engagement | excessive_engagement ∘ engagement_contextual_performance |
| WorkingExcessively → TaskPerformance | Positive | untested | Workaholism, Engagement, BakkerDemerouti2007 | excessive_engagement ∘ engagement_task_performance; excessive_engagement ∘ engagement_performance |
| WorkingExcessively → TurnoverIntention | Negative | untested | Workaholism, Engagement | excessive_engagement ∘ engagement_turnover |
| WorkingExcessively → JobResources | Positive | untested | Workaholism, JDR | excessive_engagement ∘ engagement_resources |
| WorkingExcessively → OrganizationalCommitment | Positive | untested | Workaholism, JDR | excessive_engagement ∘ engagement_commitment |

## Formalization pipeline

Providers: fixture. Models: hand-written fixture (no model run).

| Paper | Module | Status | Constructs | Propositions | Overlap warnings | Errors |
|---|---|---|---|---|---|---|
| bakker_demerouti_2007 | BakkerDemerouti2007 | accepted | 2 | 5 | 7 | 0 |
| bakker_vanemmerik_euwema_2006 | BakkerVanemmerikEuwema2006 | failed | 1 | 1 | 1 | 1 |
| hobfoll_1989 | Hobfoll1989 | accepted | 3 | 3 | 8 | 0 |
| kahn_1990 | Kahn1990 | failed | 2 | 1 | 1 | 3 |
| maslach_jackson_1981 | MaslachJackson1981 | accepted | 3 | 1 | 14 | 0 |
| schaufeli_2002 | Schaufeli2002 | accepted | 4 | 1 | 27 | 0 |
| siegrist_1996 | Siegrist1996 | accepted | 5 | 3 | 21 | 0 |
| spreitzer_2005 | Spreitzer2005 | accepted | 3 | 3 | 17 | 0 |
| weick_1995 | Weick1995 | declined | 0 | 0 | 0 | 0 |

### Formalization failures

- **bakker_vanemmerik_euwema_2006** (failed): 
  - compiler: `scope mismatch in `team_burnout_crossover`: TeamBurnout lives at Team / Weekly but the proposition declares Individual / Weekly; no registered rule bridges the gap (needs an Aggregation from TeamBurnout to a Individual-level construct)`
  - model: The crossover propositions are top-down: a team-level mean predicts an individual-level outcome. The kernel's scope check requires both constructs at the declared level and has no rule which lowers a level, so the proposition as stated at the individual level is expected to be rejected.
- **kahn_1990** (failed): 
  - compiler: `construct `PsychologicalConditions` does not reduce to primitives`
  - compiler: `failed to synthesize`
  - compiler: ``conditions_engagement` must have type `Lemma.Proposition A B`, found `sorry``
  - model: Kahn's three psychological conditions (meaningfulness, safety, availability) have no primitive in the pilot vocabulary; the module declares them as new types, which the compiler is expected to reject at the reduction check.
  - model: Personal engagement is defined across physical, cognitive and emotional expression in a role episode; Momentary chosen.
  - model: The studies are ethnographic; evidence declared None.
- **weick_1995** (declined): Sensemaking is defined as an ongoing process with seven properties, not as a quantity read from observations of a unit at a horizon. The book states no directional relation between measured constructs. No kernel-conformant construct or proposition can be written without inventing a measurement model the text does not supply.
  - model: A measurement-model reading (for example, frequency of sensemaking episodes) would be an addition by the formalizer, not a formalization of the source.
