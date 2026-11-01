import Lean
import Lemma.Kernel

/-!
# Registry: persistent environment extensions

The compiler checks need to see every construct, primitive, proposition,
aggregation rule, temporal rule and overlap declaration in the library,
across module boundaries. Each kind is stored in a
`SimplePersistentEnvExtension`, which Lean serializes into `.olean` files,
so a theory module compiled in one file is visible to checks run in
another.

Entries are plain data (names, enums, strings), which keeps them
serializable and lets the report command dump them as JSON.
-/

open Lean

namespace Lemma.Meta

/-! ## JSON instances for kernel enums -/

instance : ToJson Level := ⟨fun l => toJson l.toString⟩
instance : ToJson Horizon := ⟨fun h => toJson h.toString⟩
instance : ToJson Source := ⟨fun s => toJson s.toString⟩
instance : ToJson Direction := ⟨fun d => toJson d.toString⟩
instance : ToJson EvidenceKind := ⟨fun e => toJson e.toString⟩
instance : ToJson ModerationEffect := ⟨fun e => toJson e.toString⟩
instance : ToJson AggregationRule := ⟨fun r => toJson r.toString⟩
instance : ToJson TemporalRule := ⟨fun r => toJson r.toString⟩

/-- Parse a fully qualified constructor name of `Level`. -/
def levelOfName? : Name → Option Level
  | ``Level.Individual => some .Individual
  | ``Level.Dyad => some .Dyad
  | ``Level.Team => some .Team
  | ``Level.Unit => some .Unit
  | ``Level.Organization => some .Organization
  | _ => none

/-- Parse a fully qualified constructor name of `Horizon`. -/
def horizonOfName? : Name → Option Horizon
  | ``Horizon.Momentary => some .Momentary
  | ``Horizon.Daily => some .Daily
  | ``Horizon.Weekly => some .Weekly
  | ``Horizon.Monthly => some .Monthly
  | ``Horizon.Annual => some .Annual
  | ``Horizon.Static => some .Static
  | _ => none

def directionOfName? : Name → Option Direction
  | ``Direction.Positive => some .Positive
  | ``Direction.Negative => some .Negative
  | ``Direction.Null => some .Null
  | ``Direction.Curvilinear => some .Curvilinear
  | _ => none

def evidenceOfName? : Name → Option EvidenceKind
  | ``EvidenceKind.Experimental => some .Experimental
  | ``EvidenceKind.Longitudinal => some .Longitudinal
  | ``EvidenceKind.CrossSectional => some .CrossSectional
  | ``EvidenceKind.MetaAnalytic => some .MetaAnalytic
  | ``EvidenceKind.Simulation => some .Simulation
  | ``EvidenceKind.None => some .None
  | _ => none

def moderationOfName? : Name → Option ModerationEffect
  | ``ModerationEffect.Buffers => some .Buffers
  | ``ModerationEffect.Amplifies => some .Amplifies
  | ``ModerationEffect.Conditions => some .Conditions
  | _ => none

def aggregationRuleOfName? : Name → Option AggregationRule
  | ``AggregationRule.Mean => some .Mean
  | ``AggregationRule.Sum => some .Sum
  | ``AggregationRule.Max => some .Max
  | ``AggregationRule.Min => some .Min
  | ``AggregationRule.Dispersion => some .Dispersion
  | ``AggregationRule.DirectConsensus => some .DirectConsensus
  | ``AggregationRule.ReferentShift => some .ReferentShift
  | _ => none

def temporalRuleOfName? : Name → Option TemporalRule
  | ``TemporalRule.Mean => some .Mean
  | ``TemporalRule.Trend => some .Trend
  | ``TemporalRule.Peak => some .Peak
  | ``TemporalRule.Cumulative => some .Cumulative
  | ``TemporalRule.Lagged => some .Lagged
  | ``TemporalRule.Variability => some .Variability
  | _ => none

/-! ## Entry types -/

/-- A primitive leaf reached by unfolding a construct. The key for overlap
detection is `(prim, args, level, horizon)`. -/
structure PrimLeaf where
  /-- Fully qualified name of the primitive type. -/
  prim : Name
  /-- Fully qualified names (or pretty-printed forms) of the primitive's arguments. -/
  args : List String
  /-- Field path from the root construct to the leaf, for example `[vigor]`. -/
  path : List Name
  /-- Registered construct through which the leaf was reached, if any. -/
  via : Option Name
  level : Level
  horizon : Horizon
  deriving Inhabited, BEq, Repr, ToJson

/-- Overlap key: the identity of a leaf up to its path. -/
structure PrimKey where
  prim : Name
  args : List String
  level : Level
  horizon : Horizon
  deriving Inhabited, BEq, Repr, Hashable, ToJson

def PrimLeaf.key (l : PrimLeaf) : PrimKey :=
  { prim := l.prim, args := l.args, level := l.level, horizon := l.horizon }

/-- Short display name of a primitive with its arguments, e.g. `Identification Work`. -/
def PrimKey.display (k : PrimKey) : String :=
  let base := k.prim.components.getLast?.map toString |>.getD k.prim.toString
  let args := k.args.map fun a =>
    (a.splitOn ".").getLast?.getD a
  String.intercalate " " (base :: args)

def PrimLeaf.display (l : PrimLeaf) : String := l.key.display

/-- How a construct was declared. -/
inductive ConstructKind
  | /-- A `structure` extending `Construct l h`. -/
    structure
  | /-- A `def` unfolding to registered constructs and products of them. -/
    composite
  deriving Inhabited, BEq, Repr

instance : ToJson ConstructKind :=
  ⟨fun | .structure => "structure" | .composite => "composite"⟩

/-- A registered construct. -/
structure ConstructEntry where
  name : Name
  /-- Theory module the construct was declared in (last component of the module name). -/
  theory : Name
  /-- Full module name. -/
  module : Name
  kind : ConstructKind
  level : Level
  horizon : Horizon
  /-- Primitive leaves after full reduction. -/
  leaves : Array PrimLeaf
  /-- Registered constructs the construct is explicitly built from. -/
  components : Array Name
  /-- Docstring (the citation docstring required by `CONTRIBUTING.md`). -/
  doc : String
  deriving Inhabited, Repr, ToJson

/-- A registered primitive type. -/
structure PrimitiveEntry where
  name : Name
  module : Name
  doc : String
  deriving Inhabited, Repr, ToJson

/-- Serializable boundary condition. -/
inductive BoundaryEntry
  | none
  | moderator (construct : Name) (effect : ModerationEffect)
  | scope (description : String)
  deriving Inhabited, BEq, Repr

instance : ToJson BoundaryEntry :=
  ⟨fun
    | .none => Json.mkObj [("kind", "none")]
    | .moderator c e => Json.mkObj [("kind", "moderator"), ("construct", toJson c), ("effect", toJson e)]
    | .scope d => Json.mkObj [("kind", "scope"), ("description", toJson d)]⟩

/-- Result of the scope check on a proposition. -/
inductive ScopeStatus
  | /-- Both constructs live at the declared scope. -/
    exact
  | /-- At least one construct is routed through a registered aggregation or temporal rule. -/
    routed (rules : List Name)
  deriving Inhabited, BEq, Repr

instance : ToJson ScopeStatus :=
  ⟨fun
    | .exact => Json.mkObj [("kind", "exact")]
    | .routed rs => Json.mkObj [("kind", "routed"), ("rules", toJson rs)]⟩

/-- A registered proposition. -/
structure PropositionEntry where
  name : Name
  theory : Name
  module : Name
  antecedent : Name
  consequent : Name
  direction : Direction
  level : Level
  horizon : Horizon
  boundary : BoundaryEntry
  evidence : EvidenceKind
  citation : String
  doc : String
  scope : ScopeStatus
  deriving Inhabited, Repr, ToJson

/-- A registered aggregation rule. -/
structure AggregationEntry where
  name : Name
  theory : Name
  module : Name
  source : Name
  target : Name
  rule : AggregationRule
  citation : String
  deriving Inhabited, Repr, ToJson

/-- A registered temporal rule. -/
structure TemporalEntry where
  name : Name
  theory : Name
  module : Name
  source : Name
  target : Name
  rule : TemporalRule
  citation : String
  deriving Inhabited, Repr, ToJson

/-- The scholar's resolution of an overlap warning. -/
inductive OverlapDeclKind
  | distinct_from
  | alias_of
  | subtype_of
  deriving Inhabited, BEq, Repr

instance : ToJson OverlapDeclKind :=
  ⟨fun
    | .distinct_from => "distinct_from"
    | .alias_of => "alias_of"
    | .subtype_of => "subtype_of"⟩

instance : ToString OverlapDeclKind :=
  ⟨fun
    | .distinct_from => "distinct_from"
    | .alias_of => "alias_of"
    | .subtype_of => "subtype_of"⟩

/-- A registered overlap declaration (`declare_overlap A distinct_from B "reason"`). -/
structure OverlapDecl where
  a : Name
  b : Name
  kind : OverlapDeclKind
  reason : String
  module : Name
  deriving Inhabited, Repr, ToJson

/-! ## Extensions -/

/-- Generic registry extension: a list of entries in declaration order. -/
abbrev RegistryExt (α : Type) := SimplePersistentEnvExtension α (Array α)

private def mkRegistryExt (α : Type) [Inhabited α] (name : Name) : IO (RegistryExt α) :=
  registerSimplePersistentEnvExtension {
    name := name
    addEntryFn := fun s e => s.push e
    addImportedFn := fun imported => imported.foldl (fun acc arr => acc ++ arr) #[]
  }

initialize primitiveExt : RegistryExt PrimitiveEntry ← mkRegistryExt _ `Lemma.primitiveExt
initialize constructExt : RegistryExt ConstructEntry ← mkRegistryExt _ `Lemma.constructExt
initialize propositionExt : RegistryExt PropositionEntry ← mkRegistryExt _ `Lemma.propositionExt
initialize aggregationExt : RegistryExt AggregationEntry ← mkRegistryExt _ `Lemma.aggregationExt
initialize temporalExt : RegistryExt TemporalEntry ← mkRegistryExt _ `Lemma.temporalExt
initialize overlapDeclExt : RegistryExt OverlapDecl ← mkRegistryExt _ `Lemma.overlapDeclExt

/-! ## Queries -/

/-- All entries of an extension, imported ones first, then the current module's. -/
def RegistryExt.all {α : Type} [Inhabited α] (ext : RegistryExt α) (env : Environment) : Array α :=
  ext.getState env

def isPrimitive (env : Environment) (n : Name) : Bool :=
  (primitiveExt.all env).any (·.name == n)

def findConstruct? (env : Environment) (n : Name) : Option ConstructEntry :=
  (constructExt.all env).find? (·.name == n)

def isConstruct (env : Environment) (n : Name) : Bool :=
  (findConstruct? env n).isSome

def findOverlapDecl? (env : Environment) (a b : Name) : Option OverlapDecl :=
  (overlapDeclExt.all env).find? fun d => (d.a == a && d.b == b) || (d.a == b && d.b == a)

/-- Short display name of a construct: the last component of its full name. -/
def shortName (n : Name) : String :=
  match n.components.getLast? with
  | some c => toString c
  | none => toString n

/-- Theory tag of the current module: the last component of the module name
(`Lemma.Theories.JDR` ↦ `JDR`). -/
def theoryOfModule (m : Name) : Name :=
  match m.components.getLast? with
  | some c => c
  | none => m

end Lemma.Meta
