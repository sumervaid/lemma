import Lemma.Meta.Reduce

/-!
# Q2: overlap detection

Two constructs overlap when they share a primitive leaf key
`(primitive, arguments, level, horizon)`. The check distinguishes

* **identity**: the two constructs have the same set of leaf keys;
* **subtype**: the leaf keys of one are a proper subset of the other's;
* **partial**: the intersection is non-empty and neither contains the other.

Shared primitives at a *different* scope (the same primitive at `Momentary`
and `Weekly`, say) are reported separately as **scope shifts**: they are
not overlaps, but they are places where a temporal or aggregation rule
should connect two definitions.

A construct is never reported as overlapping a construct it was explicitly
built from (its `components`), since that composition is declared in the
definition itself. Warnings are suppressed, and recorded as resolved, when
a `declare_overlap` declaration covers the pair.
-/

open Lean

namespace Lemma.Meta

inductive OverlapKind
  | identity
  | subtype
  | partialOverlap
  deriving Inhabited, BEq, Repr

instance : ToString OverlapKind :=
  ⟨fun | .identity => "identity" | .subtype => "subtype" | .partialOverlap => "partial"⟩

instance : ToJson OverlapKind := ⟨fun k => toJson (toString k)⟩

/-- One shared leaf between two constructs. -/
structure SharedLeaf where
  key : PrimKey
  /-- Display path in the first construct. -/
  inA : String
  /-- Display path in the second construct. -/
  inB : String
  deriving Inhabited, Repr, ToJson

/-- An overlap between construct `a` and construct `b`. -/
structure OverlapReport where
  a : Name
  b : Name
  kind : OverlapKind
  /-- For `subtype`: the construct whose leaf set is the subset. -/
  subset : Option Name
  shared : Array SharedLeaf
  sizeA : Nat
  sizeB : Nat
  declared : Option OverlapDecl
  deriving Inhabited, Repr, ToJson

/-- A primitive shared across scopes. -/
structure ScopeShift where
  a : Name
  b : Name
  prim : String
  inA : String
  scopeA : String
  inB : String
  scopeB : String
  deriving Inhabited, Repr, ToJson

private def dedupKeys (ls : Array PrimLeaf) : Array PrimKey :=
  ls.foldl (fun acc l => if acc.contains l.key then acc else acc.push l.key) #[]

private def subsetOf (xs ys : Array PrimKey) : Bool := xs.all ys.contains

/-- Compare a (possibly not yet registered) construct against one registered entry. -/
def overlapWith (env : Environment) (aName : Name) (aLeaves : Array PrimLeaf) (aComponents : Array Name)
    (b : ConstructEntry) : Option OverlapReport := Id.run do
  if aName == b.name then return none
  if aComponents.contains b.name || b.components.contains aName then return none
  let keysA := dedupKeys aLeaves
  let keysB := dedupKeys b.leaves
  let mut shared : Array SharedLeaf := #[]
  for k in keysA do
    if keysB.contains k then
      let la := aLeaves.find? (·.key == k)
      let lb := b.leaves.find? (·.key == k)
      match la, lb with
      | some la, some lb =>
        shared := shared.push { key := k, inA := la.pathDisplay aName, inB := lb.pathDisplay b.name }
      | _, _ => pure ()
  if shared.isEmpty then return none
  let aSub := subsetOf keysA keysB
  let bSub := subsetOf keysB keysA
  let (kind, subset) :=
    if aSub && bSub then (OverlapKind.identity, none)
    else if aSub then (.subtype, some aName)
    else if bSub then (.subtype, some b.name)
    else (.partialOverlap, none)
  return some {
    a := aName, b := b.name, kind, subset, shared,
    sizeA := keysA.size, sizeB := keysB.size,
    declared := findOverlapDecl? env aName b.name }

/-- Scope shifts between a construct and one registered entry. -/
def scopeShiftsWith (aName : Name) (aLeaves : Array PrimLeaf) (aComponents : Array Name)
    (b : ConstructEntry) : Array ScopeShift := Id.run do
  if aName == b.name then return #[]
  if aComponents.contains b.name || b.components.contains aName then return #[]
  let mut out : Array ScopeShift := #[]
  for la in aLeaves do
    for lb in b.leaves do
      if la.prim == lb.prim && la.args == lb.args && (la.level != lb.level || la.horizon != lb.horizon) then
        out := out.push {
          a := aName, b := b.name, prim := la.display,
          inA := la.pathDisplay aName, scopeA := s!"{la.level} / {la.horizon}",
          inB := lb.pathDisplay b.name, scopeB := s!"{lb.level} / {lb.horizon}" }
  return out

/-- All overlaps of a construct with every registered construct (other than itself). -/
def overlapsOf (env : Environment) (aName : Name) (aLeaves : Array PrimLeaf) (aComponents : Array Name) :
    Array OverlapReport :=
  (constructExt.all env).filterMap (overlapWith env aName aLeaves aComponents)

def scopeShiftsOf (env : Environment) (aName : Name) (aLeaves : Array PrimLeaf) (aComponents : Array Name) :
    Array ScopeShift :=
  (constructExt.all env).foldl (fun acc b => acc ++ scopeShiftsWith aName aLeaves aComponents b) #[]

/-- The warning text for an overlap, in the form shown in the proposal:
`shares primitive Energy with Engagement.vigor`. -/
def OverlapReport.message (r : OverlapReport) : String :=
  let prims := r.shared.map (·.key.display)
  let targets := r.shared.map (·.inB)
  let noun := if r.shared.size == 1 then "primitive" else "primitives"
  let head := s!"shares {noun} {String.intercalate ", " prims.toList} with {String.intercalate ", " targets.toList}"
  let pairs := r.shared.map fun s => s!"  {s.inA} ~ {s.inB} : {s.key.display} at {s.key.level} / {s.key.horizon}"
  let kindLine := match r.kind, r.subset with
    | .identity, _ => s!"  overlap kind: identity ({shortName r.a} and {shortName r.b} reduce to the same {r.sizeA} primitive(s))"
    | .subtype, some s =>
      let sup := if s == r.a then r.b else r.a
      s!"  overlap kind: subtype (every primitive of {shortName s} is a primitive of {shortName sup})"
    | _, _ => s!"  overlap kind: partial ({r.shared.size} of {r.sizeA} primitive(s) of {shortName r.a}, {r.shared.size} of {r.sizeB} of {shortName r.b})"
  let resolve := match r.declared with
    | some d => s!"  declared: {shortName d.a} {d.kind} {shortName d.b} ({d.reason})"
    | none => s!"  resolve with: declare_overlap {shortName r.a} distinct_from {shortName r.b} \"reason\" (or alias_of / subtype_of)"
  String.intercalate "\n" ([head] ++ pairs.toList ++ [kindLine, resolve])

end Lemma.Meta
