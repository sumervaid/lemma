import Lemma.Library.Primitives

/-!
# Library base categories

Thin parents over `Construct level horizon` which name the category a
construct belongs to. They add no fields. A theory file writes

```lean
structure Engagement extends AffectiveState (level := .Individual) (horizon := .Weekly) where
  ...
```

and the compiler reads the scope from the `Construct` ancestor.
-/

namespace Lemma

/-- An affective or affective-cognitive state of a unit over a horizon. -/
structure AffectiveState (level : Level) (horizon : Horizon) extends Construct level horizon

/-- A perceived or recorded characteristic of a job or work context. -/
structure JobCharacteristic (level : Level) (horizon : Horizon) extends Construct level horizon

/-- A relatively stable disposition. Usually declared at `Horizon.Static`. -/
structure Disposition (level : Level) (horizon : Horizon) extends Construct level horizon

/-- A behavior or behavioral intention. -/
structure WorkBehavior (level : Level) (horizon : Horizon) extends Construct level horizon

/-- A health or performance outcome. -/
structure Outcome (level : Level) (horizon : Horizon) extends Construct level horizon

/-- A change in resources over the horizon. -/
structure ResourceDynamic (level : Level) (horizon : Horizon) extends Construct level horizon

end Lemma
