Lemma is a Lean 4.15.0 project encoding organizational theory as typed definitions, built on core Lean only.

The kernel has five construction rules, namely `Observation`, `Construct`, `Aggregation`, `Temporal`, plus `Proposition`. The `@[construct]` attribute generates an `IsConstruct` instance only after the reduction check passes, so a construct failing reduction stays out of every proposition. Aggregation rules carry proof fields discharged by `decide`, requiring a strictly higher level with a matching horizon. Temporal rules carry the dual constraint.

Four checks run as metaprograms over persistent registries. Reduction unfolds a construct to registered primitives. Overlap reports constructs sharing a primitive at one scope. Scope matches a proposition against declared levels plus horizons. Composition reports contradictions across modules while deriving implied length-2 chains through a sign algebra. `#guard_msgs` tests pin the compiler messages.

I would welcome feedback on the metaprogramming approach, especially the registry design, the attribute-driven checks at elaboration time, plus the use of `decide` for rule constraints.

Repository at https://github.com/sumervaid/lemma
