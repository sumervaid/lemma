# Contributing to Lemma

Modeled on the Mathlib contribution guidelines: small, reviewed additions
to a shared library, with conventions enforced by the compiler where the
compiler can, and by review where it cannot.

## What a contribution is

- **A theory module** under `Lemma/Theories/<Theory>.lean`: the constructs a
  theory defines, the propositions it states, the aggregation and temporal
  rules it relies on, and the overlap declarations the compiler asks for.
- **A primitive** in `Lemma/Library/Primitives.lean`: a new atomic value
  type. Rare, reviewed as a vocabulary change, logged in `CHANGELOG.md`.
- **A kernel change** under `Lemma/Kernel/`: a change to the construction
  rules. Rarer still. Bumps `KERNEL_VERSION`.
- **A generated module** under `Lemma/Generated/`: pipeline output. Only
  modules that compile are kept; they are reviewed like theory modules
  before being promoted into `Lemma/Theories/`.

## Naming

- Modules: one theory per file, `UpperCamelCase`, named after the theory or
  its originating authors (`JDR`, `COR`, `ERI`, `ShiromVigor`,
  `ChallengeHindrance`). The last component of the module name is the
  theory tag the compiler attaches to every entry.
- Constructs: `UpperCamelCase` nouns (`JobDemands`, `ResourceLoss`).
  Disambiguate across theories by namespace, not by suffix: `COR.Resources`
  and `JDR.JobResources` are different constructs.
- Propositions: `snake_case`, `antecedent_consequent`, with a suffix for a
  boundary condition (`demands_exhaustion`, `demands_exhaustion_buffered`).
- Rules: `camelCase`, `constructTarget` (`engagementTeam`, `flowWeekly`).
- Fields: `camelCase`, named after the paper's own facet names (`vigor`,
  `timePressure`).

## Rules the compiler enforces

1. Every construct extends a base category at an explicit level and
   horizon, or is a product of registered constructs at one scope.
2. Every field of a construct is a registered primitive. Anything else is a
   reduction failure.
3. Every construct, proposition and rule carries a docstring. The
   attributes reject a definition without one.
4. A proposition's level and horizon match both constructs or route through
   registered rules.
5. A contradiction inside one theory is an error.

## Rules review enforces

1. **One construct per definition.** No construct bundles two papers'
   definitions.
2. **Citation docstrings.** The docstring quotes or closely paraphrases the
   source definition and gives author, year and page. Propositions cite the
   evidence their `evidence` field claims: `MetaAnalytic` cites a
   meta-analysis, `Longitudinal` a multi-wave study, `Experimental` an
   experiment. `None` is for stated-but-untested propositions and must say
   so.
3. **Overlap declarations.** Every overlap warning the compiler emits on a
   new construct is answered by `declare_overlap A distinct_from | alias_of
   | subtype_of B "reason"` in the same module, with a reason that names
   the source of the distinction. `alias_of` is for identity overlaps where
   the new construct restates an existing one. `subtype_of` is for
   leaf-set inclusion the literature treats as a facet relation (UWES
   subscales inside engagement). `distinct_from` is for everything else and
   must say what distinguishes the pair.
4. **Polarity in the docstring.** Primitives are unsigned. A construct that
   reads a primitive low (exhaustion reads low energy) says so.
5. **Scope choices are explicit.** A construct's horizon is a modeling
   choice. The docstring states the basis (scale time frame, diary design,
   trait framing).
6. **Fidelity limitations are declared.** When the pilot vocabulary lacks a
   primitive a facet needs, the docstring records the omitted facet rather
   than substituting a near match silently.

## Review checklist

- [ ] `lake build` passes; new warnings are overlap warnings only, each
      answered by a declaration.
- [ ] Every new definition has a citation docstring with author, year, page.
- [ ] Evidence kinds match the cited designs.
- [ ] Level and horizon are stated with a basis.
- [ ] Reads of a primitive's low pole are stated.
- [ ] Omitted facets are stated.
- [ ] `bibliography/sources.yaml` lists every new primary source.
- [ ] A `#guard_msgs` test in `LemmaTests/` pins any new compiler message.
- [ ] `make test` is green: Lean tests, pytest, ruff.
- [ ] `make report` was run and `reports/` committed, so the numbers in the
      README reflect the change.

## Commit messages

Imperative subject line under 72 characters, a body explaining why. Changes
to the kernel or the vocabulary start the subject with `kernel:` or
`vocab:` and add a `CHANGELOG.md` entry.
