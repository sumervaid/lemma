import Lemma.Theories.JDR

/-!
# Conservation of resources theory (Hobfoll 1989; Hobfoll 2001; Hobfoll, Halbesleben, Neveu & Westman 2018)

People strive to obtain, retain, protect and foster resources. Stress
follows actual or threatened resource loss, or failure to gain after
investment. Loss is disproportionately more salient than gain (Principle
1), people invest resources to protect against loss (Principle 2), and
loss and gain produce spirals (Corollaries 2 and 3).

The compiler reports, on compiling this file, that COR's resource bundle
overlaps job resources (JD-R), that resource loss and resource gain reduce
to the same signed-change primitives, and that strain contains JD-R's
health complaints.
-/

namespace Lemma.Theories.COR

/-- Resources: "those objects, personal characteristics, conditions, or
energies that are valued by the individual or that serve as a means for
attainment of these objects, personal characteristics, conditions, or
energies" (Hobfoll 1989, p. 516). Bundle of concrete conditions (control,
support, security, status, advancement), energies (time, money, knowledge),
objects, and personal characteristics (self-efficacy, optimism). -/
@[construct] structure Resources extends JobCharacteristic (level := .Individual) (horizon := .Weekly) where
  control : Resource .Autonomy
  support : Resource .SocialSupport
  security : Resource .CareerSecurity
  status : Resource .Esteem
  advancement : Resource .Development
  time : Resource .Time
  money : Resource .Pay
  knowledge : Resource .Knowledge
  objects : Resource .Object
  efficacy : Efficacy .Self
  optimism : Expectancy .Positive

/-- Resource loss: actual decline in valued resources over the horizon
(Hobfoll 1989, Principle 1). Reads negative change. -/
@[construct] structure ResourceLoss extends ResourceDynamic (level := .Individual) (horizon := .Weekly) where
  control : Change .Autonomy
  support : Change .SocialSupport
  security : Change .CareerSecurity
  status : Change .Esteem
  time : Change .Time
  money : Change .Pay

/-- Resource gain: increase in valued resources over the horizon following
investment (Hobfoll 1989, Principle 2; Hobfoll 2001, Corollary 3). Reads
positive change. -/
@[construct] structure ResourceGain extends ResourceDynamic (level := .Individual) (horizon := .Weekly) where
  control : Change .Autonomy
  support : Change .SocialSupport
  security : Change .CareerSecurity
  status : Change .Esteem
  time : Change .Time
  money : Change .Pay

/-- Psychological strain: negative high-activation affect together with
psychosomatic symptoms (Hobfoll 1989; Hobfoll et al. 2018). -/
@[construct] structure Strain extends Outcome (level := .Individual) (horizon := .Weekly) where
  affect : Affect .Negative .High
  symptoms : Symptom .Psychosomatic

declare_overlap Resources distinct_from JDR.JobResources
  "Job resources are the subset of COR resources located in the job (Bakker & Demerouti 2007 cite Hobfoll 1989); COR adds energies, objects and personal characteristics"
declare_overlap Resources distinct_from JDR.PersonalResources
  "Personal characteristics are one COR resource category (Hobfoll 1989); JD-R treats them as a separate antecedent (Xanthopoulou et al. 2007)"
declare_overlap ResourceGain distinct_from ResourceLoss
  "Loss and gain read the same signed-change primitive with opposite sign; the primacy-of-loss principle (Hobfoll 1989) asserts asymmetric effects, which the propositions below record"
declare_overlap Strain distinct_from JDR.HealthComplaints
  "Health complaints are the symptom component of strain without the affective component"

/-- Resource loss produces strain (Hobfoll 1989, Principle 1; Hobfoll 2001;
Hobfoll et al. 2018 review the longitudinal evidence). -/
@[proposition] def loss_strain : Proposition ResourceLoss Strain :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    evidence := .Longitudinal,
    citation := "Hobfoll 1989, Am. Psychol. 44, 513-524; Hobfoll et al. 2018, Annu. Rev. Organ. Psychol. Organ. Behav. 5, 103-128" }

/-- Resource gain reduces strain, with a smaller effect than loss (Hobfoll
2001, primacy of loss). -/
@[proposition] def gain_strain : Proposition ResourceGain Strain :=
  { direction := .Negative, level := .Individual, horizon := .Weekly,
    evidence := .Longitudinal,
    citation := "Hobfoll 2001, Appl. Psychol. 50, 337-421" }

/-- Those with greater resources are less vulnerable to strain (Hobfoll
1989; Halbesleben 2006, meta-analysis of social support and burnout). -/
@[proposition] def resources_strain : Proposition Resources Strain :=
  { direction := .Negative, level := .Individual, horizon := .Weekly,
    evidence := .MetaAnalytic,
    citation := "Hobfoll 1989, Am. Psychol. 44, 513-524; Halbesleben 2006, J. Appl. Psychol. 91, 1134-1145" }

/-- Resource loss produces emotional exhaustion: COR applied to burnout
(Hobfoll & Freedy 1993; Lee & Ashforth 1996, meta-analysis). -/
@[proposition] def loss_exhaustion : Proposition ResourceLoss Burnout.Exhaustion :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    evidence := .MetaAnalytic,
    citation := "Hobfoll & Freedy 1993, in Schaufeli, Maslach & Marek (eds.) Professional Burnout; Lee & Ashforth 1996, J. Appl. Psychol. 81, 123-133" }

/-- Job demands deplete resources (Hobfoll & Freedy 1993; Hobfoll et al.
2018, p. 108: demands lead to resource loss). -/
@[proposition] def demands_loss : Proposition JDR.JobDemands ResourceLoss :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    evidence := .CrossSectional,
    citation := "Hobfoll & Freedy 1993; Hobfoll et al. 2018, Annu. Rev. Organ. Psychol. Organ. Behav. 5, 103-128" }

/-- Strain produces further resource loss: the loss spiral (Hobfoll 2001,
Corollary 2; Demerouti, Bakker & Bulters 2004, three-wave study). -/
@[proposition] def strain_loss : Proposition Strain ResourceLoss :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    evidence := .Longitudinal,
    citation := "Hobfoll 2001, Appl. Psychol. 50, 337-421; Demerouti, Bakker & Bulters 2004, J. Vocat. Behav. 64, 131-149" }

/-- Those with resources are better positioned to gain: the gain spiral
(Hobfoll 2001, Corollary 3). -/
@[proposition] def resources_gain : Proposition Resources ResourceGain :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    evidence := .Longitudinal,
    citation := "Hobfoll 2001, Appl. Psychol. 50, 337-421" }

/-- Resource gain produces engagement: engagement is a resource-gain process
(Hobfoll et al. 2018; Xanthopoulou et al. 2009). -/
@[proposition] def gain_engagement : Proposition ResourceGain Engagement.Engagement :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    evidence := .Longitudinal,
    citation := "Hobfoll et al. 2018, Annu. Rev. Organ. Psychol. Organ. Behav. 5, 103-128; Xanthopoulou et al. 2009, J. Vocat. Behav. 74, 235-244" }

end Lemma.Theories.COR
