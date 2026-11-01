# Verification agenda

Ranked by `lemma score`. Score = 0.4·E (evidence weakness) + 0.25·S (structural load) + 0.25·G (disagreement) + 0.1·I (implied, untested). Weights in `config/scoring.yaml`; formula in `pipeline/lemma/score.py`.

170 candidates scored: 85 registered propositions and 85 implied-untested compositions. Library: 73 constructs, 89 propositions, 21 theories.

## Combined top 25

| Rank | Score | Kind | Proposition | Direction | Scope | Theories | E | S | G | I |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.688 | implied | Passion.HarmoniousPassion → Engagement.TaskPerformance | Positive | Individual / Weekly | Passion, Burnout, Engagement, BakkerDemerouti2007 | 1.00 | 0.75 | 0.00 | 1 |
| 2 | 0.688 | implied | JDR.JobDemands → Burnout.Cynicism | Positive | Individual / Weekly | JDR, Burnout, BurnoutProcess | 1.00 | 0.75 | 0.00 | 1 |
| 3 | 0.688 | implied | JDR.JobResources → Engagement.TaskPerformance | Positive | Individual / Weekly | JDR, Engagement, BakkerDemerouti2007, Burnout | 1.00 | 0.75 | 0.00 | 1 |
| 4 | 0.625 | implied | ChallengeHindrance.ChallengeDemands → Burnout.Cynicism | Positive | Individual / Weekly | ChallengeHindrance, Burnout, BurnoutProcess | 1.00 | 0.50 | 0.00 | 1 |
| 5 | 0.625 | implied | Recovery.Detachment → Burnout.Cynicism | Negative | Individual / Weekly | Recovery, Burnout, BurnoutProcess | 1.00 | 0.50 | 0.00 | 1 |
| 6 | 0.625 | implied | ERI.EffortRewardImbalance → Burnout.Cynicism | Positive | Individual / Weekly | ERI, Burnout, BurnoutProcess | 1.00 | 0.50 | 0.00 | 1 |
| 7 | 0.625 | implied | Passion.HarmoniousPassion → Burnout.Cynicism | Negative | Individual / Weekly | Passion, Burnout, BurnoutProcess | 1.00 | 0.50 | 0.00 | 1 |
| 8 | 0.625 | implied | ChallengeHindrance.HindranceDemands → Burnout.Cynicism | Positive | Individual / Weekly | ChallengeHindrance, Burnout, BurnoutProcess | 1.00 | 0.50 | 0.00 | 1 |
| 9 | 0.625 | implied | BakkerDemerouti2007.JobDemands → Burnout.Cynicism | Positive | Individual / Weekly | BakkerDemerouti2007, Burnout, BurnoutProcess | 1.00 | 0.50 | 0.00 | 1 |
| 10 | 0.625 | implied | JDR.JobResources → Burnout.Cynicism | Negative | Individual / Weekly | JDR, Burnout, BurnoutProcess | 1.00 | 0.50 | 0.00 | 1 |
| 11 | 0.625 | implied | Passion.ObsessivePassion → Burnout.Cynicism | Positive | Individual / Weekly | Passion, Burnout, BurnoutProcess | 1.00 | 0.50 | 0.00 | 1 |
| 12 | 0.625 | implied | JDR.PersonalResources → Engagement.TaskPerformance | Positive | Individual / Weekly | JDR, Engagement, BakkerDemerouti2007 | 1.00 | 0.50 | 0.00 | 1 |
| 13 | 0.625 | implied | COR.ResourceGain → Engagement.TaskPerformance | Positive | Individual / Weekly | COR, Engagement, BakkerDemerouti2007 | 1.00 | 0.50 | 0.00 | 1 |
| 14 | 0.625 | implied | COR.ResourceLoss → Burnout.Cynicism | Positive | Individual / Weekly | COR, Burnout, BurnoutProcess | 1.00 | 0.50 | 0.00 | 1 |
| 15 | 0.625 | implied | Schaufeli2002.WorkEngagement → Burnout.Cynicism | Negative | Individual / Weekly | Schaufeli2002, Burnout, BurnoutProcess | 1.00 | 0.50 | 0.00 | 1 |
| 16 | 0.625 | implied | Workaholism.Workaholism → Burnout.Cynicism | Positive | Individual / Weekly | Workaholism, Burnout, BurnoutProcess | 1.00 | 0.50 | 0.00 | 1 |
| 17 | 0.625 | implied | Workaholism.WorkingExcessively → Engagement.TaskPerformance | Positive | Individual / Weekly | Workaholism, Engagement, BakkerDemerouti2007 | 1.00 | 0.50 | 0.00 | 1 |
| 18 | 0.624 | registered | Burnout.Cynicism → Burnout.ReducedEfficacy | Positive | Individual / Weekly | Burnout | 0.70 | 0.38 | 1.00 | 0 |
| 19 | 0.594 | implied | Thriving.AgenticBehaviors → JDR.HealthComplaints | Negative | Individual / Weekly | Thriving, Spreitzer2005 | 1.00 | 0.38 | 0.00 | 1 |
| 20 | 0.594 | implied | Burnout.Exhaustion → Burnout.ReducedEfficacy | Positive | Individual / Weekly | Burnout, BurnoutProcess | 1.00 | 0.38 | 0.00 | 1 |
| 21 | 0.594 | implied | JDR.JobDemands → JDR.HealthComplaints | Positive | Individual / Weekly | JDR, BurnoutProcess | 1.00 | 0.38 | 0.00 | 1 |
| 22 | 0.594 | implied | BakkerDemerouti2007.JobResources → Engagement.TaskPerformance | Positive | Individual / Weekly | BakkerDemerouti2007, Engagement | 1.00 | 0.38 | 0.00 | 1 |
| 23 | 0.562 | implied | ChallengeHindrance.ChallengeDemands → Engagement.ContextualPerformance | Positive | Individual / Weekly | ChallengeHindrance, Engagement | 1.00 | 0.25 | 0.00 | 1 |
| 24 | 0.562 | implied | ChallengeHindrance.ChallengeDemands → JDR.HealthComplaints | Positive | Individual / Weekly | ChallengeHindrance, JDR | 1.00 | 0.25 | 0.00 | 1 |
| 25 | 0.562 | implied | ChallengeHindrance.ChallengeDemands → JDR.JobResources | Positive | Individual / Weekly | ChallengeHindrance, JDR | 1.00 | 0.25 | 0.00 | 1 |

## Registered propositions, top 25

Claims a theory states. High scores mark thin evidence under structural load, or disagreement among theories.

| Rank | Score | Kind | Proposition | Direction | Scope | Theories | E | S | G | I |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.624 | registered | Burnout.Cynicism → Burnout.ReducedEfficacy | Positive | Individual / Weekly | Burnout | 0.70 | 0.38 | 1.00 | 0 |
| 2 | 0.561 | registered | Burnout.Cynicism → Burnout.ReducedEfficacy | Null | Individual / Weekly | BurnoutProcess | 0.70 | 0.12 | 1.00 | 0 |
| 3 | 0.499 | registered | Workaholism.WorkingExcessively → Engagement.Engagement | Positive | Individual / Weekly | Workaholism | 0.70 | 0.88 | 0.00 | 0 |
| 4 | 0.499 | registered | Passion.HarmoniousPassion → Engagement.Engagement | Positive | Individual / Weekly | Passion | 0.70 | 0.88 | 0.00 | 0 |
| 5 | 0.499 | registered | BakkerDemerouti2007.JobResources → Engagement.Engagement | Positive | Individual / Weekly | BakkerDemerouti2007 | 0.70 | 0.88 | 0.00 | 0 |
| 6 | 0.490 | registered | Burnout.Exhaustion → Engagement.TaskPerformance | Negative | Individual / Weekly | Burnout | 0.10 | 1.00 | 0.80 | 0 |
| 7 | 0.463 | registered | Thriving.AgenticBehaviors → Spreitzer2005.Thriving | Positive | Individual / Weekly | Spreitzer2005 | 1.00 | 0.25 | 0.00 | 0 |
| 8 | 0.463 | registered | Thriving.DecisionDiscretion → Thriving.AgenticBehaviors | Positive | Unit / Weekly | Spreitzer2005, Thriving | 1.00 | 0.25 | 0.00 | 0 |
| 9 | 0.463 | registered | Hobfoll1989.StressReaction → Hobfoll1989.NetLoss | Positive | Individual / Weekly | Hobfoll1989 | 1.00 | 0.25 | 0.00 | 0 |
| 10 | 0.463 | registered | Spreitzer2005.Thriving → JDR.HealthComplaints | Negative | Individual / Weekly | Spreitzer2005 | 1.00 | 0.25 | 0.00 | 0 |
| 11 | 0.461 | registered | JDR.JobDemands → Engagement.Engagement | Null | Individual / Weekly | JDR | 0.70 | 0.12 | 0.60 | 0 |
| 12 | 0.436 | registered | BakkerDemerouti2007.JobDemands → Burnout.Exhaustion | Positive | Individual / Weekly | BakkerDemerouti2007 | 0.70 | 0.62 | 0.00 | 0 |
| 13 | 0.436 | registered | JDR.JobDemands → Engagement.TaskPerformance | Negative | Individual / Weekly | JDR | 0.70 | 0.12 | 0.50 | 0 |
| 14 | 0.436 | registered | JDR.JobDemands → Engagement.TaskPerformance | Curvilinear | Individual / Weekly | Activation | 0.70 | 0.12 | 0.50 | 0 |
| 15 | 0.436 | registered | Schaufeli2002.WorkEngagement → Burnout.Exhaustion | Negative | Individual / Weekly | Schaufeli2002 | 0.70 | 0.62 | 0.00 | 0 |
| 16 | 0.436 | registered | ERI.EffortRewardImbalance → Burnout.Exhaustion | Positive | Individual / Weekly | ERI | 0.70 | 0.62 | 0.00 | 0 |
| 17 | 0.431 | registered | Thriving.InformationSharing → Thriving.AgenticBehaviors | Positive | Unit / Weekly | Thriving | 1.00 | 0.12 | 0.00 | 0 |
| 18 | 0.431 | registered | Thriving.TrustClimate → Thriving.AgenticBehaviors | Positive | Unit / Weekly | Thriving | 1.00 | 0.12 | 0.00 | 0 |
| 19 | 0.410 | registered | Engagement.Engagement → JDR.OrganizationalCommitment | Positive | Individual / Weekly | JDR | 0.40 | 1.00 | 0.00 | 0 |
| 20 | 0.410 | registered | Engagement.Engagement → JDR.JobResources | Positive | Individual / Weekly | JDR | 0.40 | 1.00 | 0.00 | 0 |
| 21 | 0.410 | registered | Burnout.Exhaustion → Burnout.Cynicism | Positive | Individual / Weekly | Burnout, BurnoutProcess | 0.40 | 1.00 | 0.00 | 0 |
| 22 | 0.410 | registered | Burnout.Exhaustion → JDR.HealthComplaints | Positive | Individual / Weekly | JDR | 0.40 | 1.00 | 0.00 | 0 |
| 23 | 0.410 | registered | COR.ResourceGain → Engagement.Engagement | Positive | Individual / Weekly | COR | 0.40 | 1.00 | 0.00 | 0 |
| 24 | 0.410 | registered | COR.Strain → COR.ResourceLoss | Positive | Individual / Weekly | COR | 0.40 | 1.00 | 0.00 | 0 |
| 25 | 0.396 | registered | ChallengeHindrance.ChallengeDemands → Burnout.Exhaustion | Positive | Individual / Weekly | ChallengeHindrance | 0.10 | 0.62 | 0.80 | 0 |

## Implied, untested candidates, top 25

Claims no theory states but two propositions jointly imply along a mediating path. Each is a candidate for a direct test; the implied direction is a path sign, not a total effect.

| Rank | Score | Kind | Proposition | Direction | Scope | Theories | E | S | G | I |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.688 | implied | Passion.HarmoniousPassion → Engagement.TaskPerformance | Positive | Individual / Weekly | Passion, Burnout, Engagement, BakkerDemerouti2007 | 1.00 | 0.75 | 0.00 | 1 |
| 2 | 0.688 | implied | JDR.JobDemands → Burnout.Cynicism | Positive | Individual / Weekly | JDR, Burnout, BurnoutProcess | 1.00 | 0.75 | 0.00 | 1 |
| 3 | 0.688 | implied | JDR.JobResources → Engagement.TaskPerformance | Positive | Individual / Weekly | JDR, Engagement, BakkerDemerouti2007, Burnout | 1.00 | 0.75 | 0.00 | 1 |
| 4 | 0.625 | implied | ChallengeHindrance.ChallengeDemands → Burnout.Cynicism | Positive | Individual / Weekly | ChallengeHindrance, Burnout, BurnoutProcess | 1.00 | 0.50 | 0.00 | 1 |
| 5 | 0.625 | implied | Recovery.Detachment → Burnout.Cynicism | Negative | Individual / Weekly | Recovery, Burnout, BurnoutProcess | 1.00 | 0.50 | 0.00 | 1 |
| 6 | 0.625 | implied | ERI.EffortRewardImbalance → Burnout.Cynicism | Positive | Individual / Weekly | ERI, Burnout, BurnoutProcess | 1.00 | 0.50 | 0.00 | 1 |
| 7 | 0.625 | implied | Passion.HarmoniousPassion → Burnout.Cynicism | Negative | Individual / Weekly | Passion, Burnout, BurnoutProcess | 1.00 | 0.50 | 0.00 | 1 |
| 8 | 0.625 | implied | ChallengeHindrance.HindranceDemands → Burnout.Cynicism | Positive | Individual / Weekly | ChallengeHindrance, Burnout, BurnoutProcess | 1.00 | 0.50 | 0.00 | 1 |
| 9 | 0.625 | implied | BakkerDemerouti2007.JobDemands → Burnout.Cynicism | Positive | Individual / Weekly | BakkerDemerouti2007, Burnout, BurnoutProcess | 1.00 | 0.50 | 0.00 | 1 |
| 10 | 0.625 | implied | JDR.JobResources → Burnout.Cynicism | Negative | Individual / Weekly | JDR, Burnout, BurnoutProcess | 1.00 | 0.50 | 0.00 | 1 |
| 11 | 0.625 | implied | Passion.ObsessivePassion → Burnout.Cynicism | Positive | Individual / Weekly | Passion, Burnout, BurnoutProcess | 1.00 | 0.50 | 0.00 | 1 |
| 12 | 0.625 | implied | JDR.PersonalResources → Engagement.TaskPerformance | Positive | Individual / Weekly | JDR, Engagement, BakkerDemerouti2007 | 1.00 | 0.50 | 0.00 | 1 |
| 13 | 0.625 | implied | COR.ResourceGain → Engagement.TaskPerformance | Positive | Individual / Weekly | COR, Engagement, BakkerDemerouti2007 | 1.00 | 0.50 | 0.00 | 1 |
| 14 | 0.625 | implied | COR.ResourceLoss → Burnout.Cynicism | Positive | Individual / Weekly | COR, Burnout, BurnoutProcess | 1.00 | 0.50 | 0.00 | 1 |
| 15 | 0.625 | implied | Schaufeli2002.WorkEngagement → Burnout.Cynicism | Negative | Individual / Weekly | Schaufeli2002, Burnout, BurnoutProcess | 1.00 | 0.50 | 0.00 | 1 |
| 16 | 0.625 | implied | Workaholism.Workaholism → Burnout.Cynicism | Positive | Individual / Weekly | Workaholism, Burnout, BurnoutProcess | 1.00 | 0.50 | 0.00 | 1 |
| 17 | 0.625 | implied | Workaholism.WorkingExcessively → Engagement.TaskPerformance | Positive | Individual / Weekly | Workaholism, Engagement, BakkerDemerouti2007 | 1.00 | 0.50 | 0.00 | 1 |
| 18 | 0.594 | implied | Thriving.AgenticBehaviors → JDR.HealthComplaints | Negative | Individual / Weekly | Thriving, Spreitzer2005 | 1.00 | 0.38 | 0.00 | 1 |
| 19 | 0.594 | implied | Burnout.Exhaustion → Burnout.ReducedEfficacy | Positive | Individual / Weekly | Burnout, BurnoutProcess | 1.00 | 0.38 | 0.00 | 1 |
| 20 | 0.594 | implied | JDR.JobDemands → JDR.HealthComplaints | Positive | Individual / Weekly | JDR, BurnoutProcess | 1.00 | 0.38 | 0.00 | 1 |
| 21 | 0.594 | implied | BakkerDemerouti2007.JobResources → Engagement.TaskPerformance | Positive | Individual / Weekly | BakkerDemerouti2007, Engagement | 1.00 | 0.38 | 0.00 | 1 |
| 22 | 0.562 | implied | ChallengeHindrance.ChallengeDemands → Engagement.ContextualPerformance | Positive | Individual / Weekly | ChallengeHindrance, Engagement | 1.00 | 0.25 | 0.00 | 1 |
| 23 | 0.562 | implied | ChallengeHindrance.ChallengeDemands → JDR.HealthComplaints | Positive | Individual / Weekly | ChallengeHindrance, JDR | 1.00 | 0.25 | 0.00 | 1 |
| 24 | 0.562 | implied | ChallengeHindrance.ChallengeDemands → JDR.JobResources | Positive | Individual / Weekly | ChallengeHindrance, JDR | 1.00 | 0.25 | 0.00 | 1 |
| 25 | 0.562 | implied | ChallengeHindrance.ChallengeDemands → JDR.OrganizationalCommitment | Positive | Individual / Weekly | ChallengeHindrance, JDR | 1.00 | 0.25 | 0.00 | 1 |

## Rationale for the combined top entries

1. **Passion.HarmoniousPassion → Engagement.TaskPerformance (Positive)** — score 0.688
   - implied by composition and never stated (E=1.00, I=1)
   - composes propositions from Passion, Burnout, Engagement, BakkerDemerouti2007 along 3 paths (S=0.75): harmonious_exhaustion ∘ exhaustion_task_performance; harmonious_engagement ∘ engagement_task_performance; harmonious_engagement ∘ engagement_performance
2. **JDR.JobDemands → Burnout.Cynicism (Positive)** — score 0.688
   - implied by composition and never stated (E=1.00, I=1)
   - composes propositions from JDR, Burnout, BurnoutProcess along 4 paths (S=0.75): demands_exhaustion ∘ exhaustion_cynicism; demands_exhaustion ∘ exhaustion_cynicism; demands_exhaustion ∘ exhaustion_cynicism; demands_exhaustion ∘ exhaustion_cynicism
3. **JDR.JobResources → Engagement.TaskPerformance (Positive)** — score 0.688
   - implied by composition and never stated (E=1.00, I=1)
   - composes propositions from JDR, Engagement, BakkerDemerouti2007, Burnout along 3 paths (S=0.75): resources_engagement ∘ engagement_task_performance; resources_engagement ∘ engagement_performance; resources_exhaustion ∘ exhaustion_task_performance
4. **ChallengeHindrance.ChallengeDemands → Burnout.Cynicism (Positive)** — score 0.625
   - implied by composition and never stated (E=1.00, I=1)
   - composes propositions from ChallengeHindrance, Burnout, BurnoutProcess along 2 paths (S=0.50): challenge_exhaustion ∘ exhaustion_cynicism; challenge_exhaustion ∘ exhaustion_cynicism
5. **Recovery.Detachment → Burnout.Cynicism (Negative)** — score 0.625
   - implied by composition and never stated (E=1.00, I=1)
   - composes propositions from Recovery, Burnout, BurnoutProcess along 2 paths (S=0.50): detachment_exhaustion ∘ exhaustion_cynicism; detachment_exhaustion ∘ exhaustion_cynicism
6. **ERI.EffortRewardImbalance → Burnout.Cynicism (Positive)** — score 0.625
   - implied by composition and never stated (E=1.00, I=1)
   - composes propositions from ERI, Burnout, BurnoutProcess along 2 paths (S=0.50): imbalance_exhaustion ∘ exhaustion_cynicism; imbalance_exhaustion ∘ exhaustion_cynicism
7. **Passion.HarmoniousPassion → Burnout.Cynicism (Negative)** — score 0.625
   - implied by composition and never stated (E=1.00, I=1)
   - composes propositions from Passion, Burnout, BurnoutProcess along 2 paths (S=0.50): harmonious_exhaustion ∘ exhaustion_cynicism; harmonious_exhaustion ∘ exhaustion_cynicism
8. **ChallengeHindrance.HindranceDemands → Burnout.Cynicism (Positive)** — score 0.625
   - implied by composition and never stated (E=1.00, I=1)
   - composes propositions from ChallengeHindrance, Burnout, BurnoutProcess along 2 paths (S=0.50): hindrance_exhaustion ∘ exhaustion_cynicism; hindrance_exhaustion ∘ exhaustion_cynicism
9. **BakkerDemerouti2007.JobDemands → Burnout.Cynicism (Positive)** — score 0.625
   - implied by composition and never stated (E=1.00, I=1)
   - composes propositions from BakkerDemerouti2007, Burnout, BurnoutProcess along 2 paths (S=0.50): demands_exhaustion ∘ exhaustion_cynicism; demands_exhaustion ∘ exhaustion_cynicism
10. **JDR.JobResources → Burnout.Cynicism (Negative)** — score 0.625
   - implied by composition and never stated (E=1.00, I=1)
   - composes propositions from JDR, Burnout, BurnoutProcess along 2 paths (S=0.50): resources_exhaustion ∘ exhaustion_cynicism; resources_exhaustion ∘ exhaustion_cynicism
11. **Passion.ObsessivePassion → Burnout.Cynicism (Positive)** — score 0.625
   - implied by composition and never stated (E=1.00, I=1)
   - composes propositions from Passion, Burnout, BurnoutProcess along 2 paths (S=0.50): obsessive_exhaustion ∘ exhaustion_cynicism; obsessive_exhaustion ∘ exhaustion_cynicism
12. **JDR.PersonalResources → Engagement.TaskPerformance (Positive)** — score 0.625
   - implied by composition and never stated (E=1.00, I=1)
   - composes propositions from JDR, Engagement, BakkerDemerouti2007 along 2 paths (S=0.50): personal_resources_engagement ∘ engagement_task_performance; personal_resources_engagement ∘ engagement_performance
13. **COR.ResourceGain → Engagement.TaskPerformance (Positive)** — score 0.625
   - implied by composition and never stated (E=1.00, I=1)
   - composes propositions from COR, Engagement, BakkerDemerouti2007 along 2 paths (S=0.50): gain_engagement ∘ engagement_task_performance; gain_engagement ∘ engagement_performance
14. **COR.ResourceLoss → Burnout.Cynicism (Positive)** — score 0.625
   - implied by composition and never stated (E=1.00, I=1)
   - composes propositions from COR, Burnout, BurnoutProcess along 2 paths (S=0.50): loss_exhaustion ∘ exhaustion_cynicism; loss_exhaustion ∘ exhaustion_cynicism
15. **Schaufeli2002.WorkEngagement → Burnout.Cynicism (Negative)** — score 0.625
   - implied by composition and never stated (E=1.00, I=1)
   - composes propositions from Schaufeli2002, Burnout, BurnoutProcess along 2 paths (S=0.50): engagement_exhaustion ∘ exhaustion_cynicism; engagement_exhaustion ∘ exhaustion_cynicism
16. **Workaholism.Workaholism → Burnout.Cynicism (Positive)** — score 0.625
   - implied by composition and never stated (E=1.00, I=1)
   - composes propositions from Workaholism, Burnout, BurnoutProcess along 2 paths (S=0.50): workaholism_exhaustion ∘ exhaustion_cynicism; workaholism_exhaustion ∘ exhaustion_cynicism
17. **Workaholism.WorkingExcessively → Engagement.TaskPerformance (Positive)** — score 0.625
   - implied by composition and never stated (E=1.00, I=1)
   - composes propositions from Workaholism, Engagement, BakkerDemerouti2007 along 2 paths (S=0.50): excessive_engagement ∘ engagement_task_performance; excessive_engagement ∘ engagement_performance
18. **Burnout.Cynicism → Burnout.ReducedEfficacy (Positive)** — score 0.624
   - strongest evidence for the claim: CrossSectional (Burnout) (E=0.70)
   - 1 theory assert it, 2 implied propositions depend on it (S=0.38)
   - disagreement: contradiction (G=1.00)
19. **Thriving.AgenticBehaviors → JDR.HealthComplaints (Negative)** — score 0.594
   - implied by composition and never stated (E=1.00, I=1)
   - composes propositions from Thriving, Spreitzer2005 along 2 paths (S=0.38): agentic_thriving ∘ thriving_health; agentic_thriving ∘ thriving_health
20. **Burnout.Exhaustion → Burnout.ReducedEfficacy (Positive)** — score 0.594
   - implied by composition and never stated (E=1.00, I=1)
   - composes propositions from Burnout, BurnoutProcess along 2 paths (S=0.38): exhaustion_cynicism ∘ cynicism_reduced_efficacy; exhaustion_cynicism ∘ cynicism_reduced_efficacy
21. **JDR.JobDemands → JDR.HealthComplaints (Positive)** — score 0.594
   - implied by composition and never stated (E=1.00, I=1)
   - composes propositions from JDR, BurnoutProcess along 2 paths (S=0.38): demands_exhaustion ∘ exhaustion_health; demands_exhaustion ∘ exhaustion_health
22. **BakkerDemerouti2007.JobResources → Engagement.TaskPerformance (Positive)** — score 0.594
   - implied by composition and never stated (E=1.00, I=1)
   - composes propositions from BakkerDemerouti2007, Engagement along 2 paths (S=0.38): resources_engagement ∘ engagement_task_performance; resources_engagement ∘ engagement_performance
23. **ChallengeHindrance.ChallengeDemands → Engagement.ContextualPerformance (Positive)** — score 0.562
   - implied by composition and never stated (E=1.00, I=1)
   - composes propositions from ChallengeHindrance, Engagement along 1 path (S=0.25): challenge_engagement ∘ engagement_contextual_performance
24. **ChallengeHindrance.ChallengeDemands → JDR.HealthComplaints (Positive)** — score 0.562
   - implied by composition and never stated (E=1.00, I=1)
   - composes propositions from ChallengeHindrance, JDR along 1 path (S=0.25): challenge_exhaustion ∘ exhaustion_health
25. **ChallengeHindrance.ChallengeDemands → JDR.JobResources (Positive)** — score 0.562
   - implied by composition and never stated (E=1.00, I=1)
   - composes propositions from ChallengeHindrance, JDR along 1 path (S=0.25): challenge_engagement ∘ engagement_resources

## Reading the agenda

- A high **E** means the strongest evidence attached to the claim, across every theory stating it, is thin.
- A high **S** means many theories assert the claim or build on it, so a test moves more of the library.
- A high **G** means theories disagree about the claim, so a test settles a dispute rather than confirms a consensus.
- **I** marks a claim no theory states but two propositions jointly imply.

The agenda allocates attention. It says nothing about which direction is true.
