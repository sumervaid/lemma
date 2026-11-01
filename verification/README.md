# Human verification

`lemma verify --sample N --seed S` writes `sheet-S.yaml` with `N` items
sampled from the accepted generated modules. A reviewer sets each item's
`label` to `faithful`, `unfaithful` or `unsure` against the source paper
and adds `notes`. `lemma verify --precision` computes

    precision = faithful / (faithful + unfaithful)

over labelled items, reporting `unsure` separately and writing
`reports/precision.json`. With no labels the precision is reported as
unavailable. The pilot ships an unlabelled sheet: no precision estimate
exists yet, and the README says so.
