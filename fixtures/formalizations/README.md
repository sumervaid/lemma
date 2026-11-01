# Fixture formalizations

Hand-written stand-ins for the output of `lemma formalize` when no model
endpoint is available (`--offline`). Each YAML file mirrors the JSON a
model is asked to return: `declined`, `reason`, `ambiguities`, `module`.

Provenance: written by the repository author while building the pilot,
in the same format and against the same prompt a model would see. They
were written to exercise every outcome of the pipeline (accepted with
overlap warnings, accepted with convergent propositions, reduction
failure, scope failure, declined), not to estimate what a model would
produce. The `model` field records this. No file here was produced by a
language model.
