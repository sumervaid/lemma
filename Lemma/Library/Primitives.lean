import Lemma.Meta

/-!
# Library primitives

Primitives are the atomic value types every construct reduces to. They are
**library** definitions, not kernel definitions: the kernel only requires
that a construct reduce to *some* registered primitives. This file is the
pilot's choice of primitives for the employee well-being domain. The choice
is a methodological commitment and is versioned with the library.

Design rule. Primitives are concrete. Abstract categories such as "job
resources" or "job demands" are constructs, built as bundles of concrete
primitives, so that containment between categories shows up as set
inclusion over primitive leaves (the `subtype` overlap kind). A primitive's
arguments (`Identification Work` versus `Identification Organization`) are
atomic: two leaves with different arguments are different primitives.

Each primitive carries a docstring stating what the primitive measures and
where the operationalization comes from.
-/

namespace Lemma

/-- Referent of an attention, identification, efficacy or trust primitive. -/
inductive Target
  | Work
  | Team
  | Organization
  | Self
  | Leader
  | Family
  deriving DecidableEq, Repr, Inhabited

/-- Concrete kinds of job demand (Demerouti et al. 2001; Cavanaugh et al. 2000;
Siegrist 1996). -/
inductive DemandKind
  | Workload
  | TimePressure
  | Emotional
  | Cognitive
  | Physical
  | RoleConflict
  | RoleAmbiguity
  | Interruption
  | Responsibility
  | Hassle
  | Interrole
  deriving DecidableEq, Repr, Inhabited

/-- Concrete kinds of resource (Hobfoll 1989; Bakker & Demerouti 2007; Siegrist 1996). -/
inductive ResourceKind
  | Autonomy
  | SocialSupport
  | Feedback
  | Development
  | CareerSecurity
  | Pay
  | Esteem
  | Time
  | Knowledge
  | Object
  | Information
  deriving DecidableEq, Repr, Inhabited

inductive Valence
  | Positive
  | Negative
  deriving DecidableEq, Repr, Inhabited

inductive Activation
  | High
  | Low
  deriving DecidableEq, Repr, Inhabited

/-- Regulatory style of motivation (Deci & Ryan 2000; Vallerand et al. 2003). -/
inductive MotivationKind
  | Intrinsic
  | Autonomous
  | Controlled
  | Extrinsic
  deriving DecidableEq, Repr, Inhabited

inductive SymptomKind
  | Psychosomatic
  | Depressive
  | Cardiovascular
  deriving DecidableEq, Repr, Inhabited

inductive PerformanceKind
  | Task
  | Contextual
  | Creative
  deriving DecidableEq, Repr, Inhabited

inductive IntentionKind
  | Turnover
  deriving DecidableEq, Repr, Inhabited

/-- Concrete work behaviors with a behavioral or administrative source. -/
inductive BehaviorKind
  | TaskFocus
  | Exploration
  | HeedfulRelating
  | WorkingHours
  | DeliberatePractice
  deriving DecidableEq, Repr, Inhabited

/-- Felt energy: physical and emotional energy available for activity, as in
the UWES vigor items ("At my work, I feel bursting with energy", Schaufeli
et al. 2002) and the MBI exhaustion items read as depletion of the same
quantity (Maslach & Jackson 1981). Unsigned: a construct declares in its
docstring whether the construct reads high or low energy. -/
@[primitive] structure Energy extends Primitive

/-- Attentional focus on `target`: concentration and absorption in the target
(UWES absorption, Schaufeli et al. 2002; WOLF absorption, Bakker 2008;
inability to detach, Sonnentag & Fritz 2007). -/
@[primitive] structure Attention (target : Target) extends Primitive

/-- Identification with `target`: felt significance, involvement and
belonging (UWES dedication, Schaufeli et al. 2002; organizational
identification, Mael & Ashforth 1992; MBI cynicism read as withdrawal of
the same quantity, Maslach et al. 2001). -/
@[primitive] structure Identification (target : Target) extends Primitive

/-- A job demand of concrete kind `kind`: an aspect of the job requiring
sustained effort (Demerouti et al. 2001). -/
@[primitive] structure Demand (kind : DemandKind) extends Primitive

/-- A resource of concrete kind `kind`: an object, condition, personal
characteristic or energy valued in itself or as a means (Hobfoll 1989). -/
@[primitive] structure Resource (kind : ResourceKind) extends Primitive

/-- Signed change in a resource of kind `kind` over the construct's
horizon. Resource loss and resource gain (Hobfoll 1989) both read this
primitive, with opposite sign. -/
@[primitive] structure Change (kind : ResourceKind) extends Primitive

/-- Core affect located by valence and activation on the circumplex
(Russell 1980; Warr 1990). -/
@[primitive] structure Affect (valence : Valence) (activation : Activation) extends Primitive

/-- Acquisition and application of knowledge and skills (Spreitzer et al.
2005 learning; Sonnentag & Fritz 2007 mastery). -/
@[primitive] structure Learning extends Primitive

/-- Belief in one's capability with respect to `target` (Bandura 1977; MBI
professional efficacy, Maslach et al. 2001). -/
@[primitive] structure Efficacy (target : Target) extends Primitive

/-- Motivation of regulatory style `kind` (Deci & Ryan 2000). -/
@[primitive] structure Motivation (kind : MotivationKind) extends Primitive

/-- Perceived skill relative to the task at hand (Csikszentmihalyi 1990). -/
@[primitive] structure Skill extends Primitive

/-- Health symptom of kind `kind` (psychosomatic complaints, depressive
symptoms, cardiovascular markers; Siegrist 1996; Hakanen et al. 2008). -/
@[primitive] structure Symptom (kind : SymptomKind) extends Primitive

/-- Work performance of kind `kind`, ideally other-reported or
administrative (Christian et al. 2011). -/
@[primitive] structure Performance (kind : PerformanceKind) extends Primitive

/-- Behavioral intention of kind `kind` (turnover intention). -/
@[primitive] structure Intention (kind : IntentionKind) extends Primitive

/-- Trust in `target` (Mayer, Davis & Schoorman 1995). -/
@[primitive] structure Trust (target : Target) extends Primitive

/-- Generalized expectancy of `valence` outcomes (optimism, Scheier & Carver 1985). -/
@[primitive] structure Expectancy (valence : Valence) extends Primitive

/-- A concrete work behavior of kind `kind`. -/
@[primitive] structure Behavior (kind : BehaviorKind) extends Primitive

end Lemma
