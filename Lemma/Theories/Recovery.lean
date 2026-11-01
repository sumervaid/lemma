import Lemma.Theories.Thriving

/-!
# Recovery from work (Sonnentag & Fritz 2007; Sonnentag & Fritz 2015)

Recovery experiences during non-work time, psychological detachment,
relaxation, mastery and control, restore the resources work consumed.
Detachment, "an individual's sense of being away from the work situation"
(Etzion, Eden & Lapidot 1998, p. 579), is the most studied.

Horizons. Recovery experiences are daily constructs. The pilot connects
them to the weekly constructs of the other theories through registered
temporal rules, which Q3 reports as routing.

The compiler reports, on compiling this file, that mastery shares the
learning primitive with thriving at a different horizon (a scope shift
rather than an overlap) and that daily engagement shares all three
engagement primitives at the daily horizon.
-/

namespace Lemma.Theories.Recovery

/-- Psychological detachment from work during off-job time: mentally
disengaging from work (Sonnentag & Fritz 2007, Recovery Experience
Questionnaire). Reads low attention to work. -/
@[construct] structure Detachment extends AffectiveState (level := .Individual) (horizon := .Daily) where
  attention : Attention .Work

/-- Relaxation: low activation and positive affect during off-job time
(Sonnentag & Fritz 2007). -/
@[construct] structure Relaxation extends AffectiveState (level := .Individual) (horizon := .Daily) where
  affect : Affect .Positive .Low

/-- Mastery experiences: off-job activities that offer learning and
challenge (Sonnentag & Fritz 2007). -/
@[construct] structure Mastery extends AffectiveState (level := .Individual) (horizon := .Daily) where
  learning : Learning

/-- Control during leisure time: deciding which activity to pursue and when
(Sonnentag & Fritz 2007). -/
@[construct] structure LeisureControl extends AffectiveState (level := .Individual) (horizon := .Daily) where
  control : Resource .Autonomy

/-- Weekly mean of daily detachment, the form in which detachment enters
weekly propositions (Sonnentag, Binnewies & Mojza 2010 measure detachment
with a general-time-frame scale). -/
@[construct] structure WeeklyDetachment extends AffectiveState (level := .Individual) (horizon := .Weekly) where
  attention : Attention .Work

/-- Daily (state) work engagement (Sonnentag 2003; Bakker 2014). -/
@[construct] structure DailyEngagement extends AffectiveState (level := .Individual) (horizon := .Daily) where
  vigor : Energy
  dedication : Identification .Work
  absorption : Attention .Work

/-- Daily detachment aggregates over the week by the mean. -/
@[temporal] def detachmentWeekly : Temporal Detachment WeeklyDetachment :=
  { rule := .Mean, citation := "Sonnentag, Binnewies & Mojza 2010, J. Appl. Psychol. 95, 965-976" }

/-- Daily engagement aggregates over the week by the mean (Bakker 2014,
Eur. Psychol. 19, 227-236). -/
@[temporal] def engagementWeekly : Temporal DailyEngagement Engagement.Engagement :=
  { rule := .Mean, citation := "Bakker 2014, Eur. Psychol. 19, 227-236" }

declare_overlap WeeklyDetachment distinct_from Engagement.Absorption
  "Detachment reads low attention to work during off-job time; absorption reads high attention during work (Sonnentag & Fritz 2007)"
declare_overlap WeeklyDetachment distinct_from Engagement.Engagement
  "Weekly detachment shares only the attention primitive, read in the opposite setting"
declare_overlap DailyEngagement distinct_from Detachment
  "Daily engagement reads attention to work during work; detachment reads attention to work during off-job time (Sonnentag et al. 2008)"

/-- Lack of detachment predicts exhaustion over one year: detachment is
negatively related to exhaustion (Sonnentag, Binnewies & Mojza 2010;
Sonnentag & Fritz 2015 review). -/
@[proposition] def detachment_exhaustion : Proposition Detachment Burnout.Exhaustion :=
  { direction := .Negative, level := .Individual, horizon := .Weekly,
    evidence := .Longitudinal,
    citation := "Sonnentag, Binnewies & Mojza 2010, J. Appl. Psychol. 95, 965-976" }

/-- Evening detachment predicts next-day engagement (Sonnentag, Mojza,
Binnewies & Scholl 2008, diary study). -/
@[proposition] def detachment_daily_engagement : Proposition Detachment DailyEngagement :=
  { direction := .Positive, level := .Individual, horizon := .Daily,
    evidence := .Longitudinal,
    citation := "Sonnentag, Mojza, Binnewies & Scholl 2008, Work & Stress 22, 257-276" }

/-- Job demands are negatively related to engagement, and detachment buffers
the relation (Sonnentag, Binnewies & Mojza 2010, one-year study). Stated
with the moderator, so the compiler records a conditional disagreement,
not a contradiction, with JD-R's null main effect. -/
@[proposition] def demands_engagement_detachment : Proposition JDR.JobDemands Engagement.Engagement :=
  { direction := .Negative, level := .Individual, horizon := .Weekly,
    boundary := .moderator WeeklyDetachment .Buffers,
    evidence := .Longitudinal,
    citation := "Sonnentag, Binnewies & Mojza 2010, J. Appl. Psychol. 95, 965-976" }

/-- Job demands predict psychosomatic complaints, and detachment buffers the
relation (Sonnentag, Binnewies & Mojza 2010). -/
@[proposition] def demands_health_detachment : Proposition JDR.JobDemands JDR.HealthComplaints :=
  { direction := .Positive, level := .Individual, horizon := .Weekly,
    boundary := .moderator WeeklyDetachment .Buffers,
    evidence := .Longitudinal,
    citation := "Sonnentag, Binnewies & Mojza 2010, J. Appl. Psychol. 95, 965-976" }

/-- Relaxation during off-job time predicts next-morning vigor through
feeling recovered (Sonnentag, Binnewies & Mojza 2008; Binnewies, Sonnentag
& Mojza 2009). Stated over daily engagement. -/
@[proposition] def relaxation_daily_engagement : Proposition Relaxation DailyEngagement :=
  { direction := .Positive, level := .Individual, horizon := .Daily,
    evidence := .Longitudinal,
    citation := "Sonnentag, Binnewies & Mojza 2008, J. Appl. Psychol. 93, 674-684" }

end Lemma.Theories.Recovery
