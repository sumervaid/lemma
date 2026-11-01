# Changelog

All notable changes to the kernel, the primitive vocabulary and the
pipeline. The kernel follows semantic versioning (`KERNEL_VERSION` in
`Lemma/Kernel/Basic.lean`).

## Kernel 0.1.0, library 0.1.0, pipeline 0.1.0 (2026-11-01)

Initial release accompanying the Stage 1 proposal.

### Kernel
- Five construction rules: `Observation`, `Construct` / `Primitive` /
  `IsConstruct`, `Aggregation`, `Temporal`, `Proposition`.
- Enumerations `Level`, `Horizon`, `Source`, `Direction`, `EvidenceKind`,
  `Boundary` with `ModerationEffect`.
- Rule constraints (`raisesLevel`, `keepsHorizon`, `lengthensHorizon`,
  `keepsLevel`) discharged by `decide`.
- Sign algebra `Direction.compose` with `Null` and `Curvilinear` undefined.
- Static embedding: a `Static` construct matches any declared horizon.

### Compiler
- Persistent registries for primitives, constructs, propositions, rules and
  overlap declarations.
- `@[primitive]`, `@[construct]` (Q1 + Q2, generates `IsConstruct`),
  `@[proposition]` (Q3 + Q4), `@[aggregation]`, `@[temporal]`.
- Commands `#reduce_construct`, `#check_overlap`, `#check_scope`,
  `#check_contradictions`, `#derive_implied`, `declare_overlap`,
  `#lemma_report`, `#lemma_stats`.
- Options `lemma.linter.overlap`, `lemma.linter.contradiction`,
  `lemma.linter.scopeRouting`.

### Vocabulary
- Eighteen primitives for the employee well-being domain (see
  `Lemma/Library/Primitives.lean`), six base categories.

### Pipeline
- `lemma formalize` (OpenAI-compatible endpoint or `--offline` fixtures),
  `lemma check`, `lemma score`, `lemma distinct`, `lemma verify`,
  `lemma report`.

### Known limitations carried into 0.2 planning
- No top-down (contextual) relation across levels.
- No subtyping among primitive arguments.
- Composition restricted to length-2 chains.
- Moderators are not scope-checked.
