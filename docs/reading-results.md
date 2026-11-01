# Reading the results

Every output answers a question about definitions and claims. None of them settles an empirical question.

## Where each entry comes from

| Label | Meaning |
|---|---|
| Curated | The author wrote the entry from the cited source. Fidelity to the source is itself a verification task. |
| Pipeline fixture | The entry comes from a hand-written file standing in for model output. No model produced any entry in this release. |

## Overlap

Two constructs overlap when they share a part at the same level and horizon.

| Result | Meaning |
|---|---|
| Identical | Both use exactly the same parts. |
| Nested | Every part of one also belongs to the other. |
| Partial | They share some parts while each keeps parts of its own. |

An overlap asks for a decision. A scholar records the pair as distinct, an alias, or a subtype, with a reason. A compiler result of identical can sit beside a recorded distinction, because parts carry no sign. Exhaustion reads low energy while vigor reads high energy.

The result follows from the parts assigned to each definition, so a contested assignment makes for a contested overlap.

## Disagreements

| Result | Meaning |
|---|---|
| Direct contradiction | Two theories state opposing directions for one pair at one scope under one boundary condition. |
| Implied against direct | Chaining two claims implies a sign which a direct claim contradicts. |
| Conditional disagreement | Opposing directions appear under different boundary conditions. |
| Shape disagreement | One theory states a straight relation while another states a curve. |

## Implied pairs

Chaining `A → B` with `B → C` implies a relation from `A` to `C`. The reports mark a pair as `untested` when the library holds no direct claim on the pair.

This label describes the library alone. The wider literature may hold many tests of the same pair, and a scan of that literature comes before any new study. An implied sign also describes one mediating path, separate from any total effect.

## Agenda

The scorer ranks candidates for attention.

```
score = 0.40 evidence weakness + 0.25 structural load + 0.25 disagreement + 0.10 implied
```

A high score marks a candidate for a closer look. The score says nothing about whether the claim holds. Weights live in `config/scoring.yaml`.

## Correlations

Each row in `fixtures/correlations.csv` carries a status. Placeholder values are illustrative. Recalled values were entered from memory. Neither should be cited until checked against the source.
