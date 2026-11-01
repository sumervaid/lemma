import Lemma.Library

/-!
# Test: Listing 1 of the proposal

Engagement, vitality, learning and thriving in a fresh registry (this file
imports the library's primitives only, not the pilot theories), with the
exact messages the compiler emits pinned by `#guard_msgs`.
-/

namespace LemmaTests.Listing1
open Lemma

/-- Engagement (Schaufeli et al. 2002). -/
@[construct] structure Engagement extends AffectiveState (level := .Individual) (horizon := .Weekly) where
  vigor      : Energy
  dedication : Identification .Work
  absorption : Attention .Work

/--
warning: shares primitive Energy with Engagement.vigor
  Vitality.energy ~ Engagement.vigor : Energy at Individual / Weekly
  overlap kind: subtype (every primitive of Vitality is a primitive of Engagement)
  resolve with: declare_overlap Vitality distinct_from Engagement "reason" (or alias_of / subtype_of)
-/
#guard_msgs in
/-- Vitality (Spreitzer et al. 2005). -/
@[construct] structure Vitality extends AffectiveState (level := .Individual) (horizon := .Weekly) where
  energy : Energy

/-- Learning (Spreitzer et al. 2005). -/
@[construct] structure Learning extends AffectiveState (level := .Individual) (horizon := .Weekly) where
  learning : Lemma.Learning

/--
warning: shares primitive Energy with Engagement.vigor
  Thriving ∋ Vitality.energy ~ Engagement.vigor : Energy at Individual / Weekly
  overlap kind: partial (1 of 2 primitive(s) of Thriving, 1 of 3 of Engagement)
  resolve with: declare_overlap Thriving distinct_from Engagement "reason" (or alias_of / subtype_of)
-/
#guard_msgs in
/-- Thriving (Spreitzer et al. 2005). -/
@[construct] def Thriving := Vitality × Learning

/--
info: Vitality unfolds to Energy at Individual / Weekly
Learning unfolds to Learning at Individual / Weekly
scope: Individual / Weekly (inferred)
---
warning: shares primitive Energy with Engagement.vigor
  Thriving ∋ Vitality.energy ~ Engagement.vigor : Energy at Individual / Weekly
  overlap kind: partial (1 of 2 primitive(s) of Thriving, 1 of 3 of Engagement)
  resolve with: declare_overlap Thriving distinct_from Engagement "reason" (or alias_of / subtype_of)
-/
#guard_msgs in
#reduce_construct Thriving

#guard_msgs in
declare_overlap Thriving distinct_from Engagement
  "thriving pairs energy with learning and drops identification and attention"

/--
info: overlap with Engagement (partial) declared: Thriving distinct_from Engagement (thriving pairs energy with learning and drops identification and attention)
-/
#guard_msgs in
#check_overlap Thriving

-- A second declaration for the same pair is rejected.
/-- error: overlap between `Thriving` and `Engagement` is already declared -/
#guard_msgs in
declare_overlap Thriving alias_of Engagement "duplicate"

end LemmaTests.Listing1
