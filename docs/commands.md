# Commands

## For readers

These commands read the checked-in reports. `new` and `try` also run the compiler when Lean is present.

| Command | Purpose |
|---|---|
| `lemma` | Show a short menu |
| `lemma doctor` | State what works on this machine, with next steps |
| `lemma tour` | Print the curated findings with their cautions |
| `lemma find WORDS` | Search constructs, claims and parts |
| `lemma show NAME` | Print one construct in plain language |
| `lemma compare A B` | Set two constructs side by side |
| `lemma new` | Write a construct from plain answers, then check the draft |
| `lemma try FILE` | Check a draft file, with the compiler's reply explained |
| `lemma site --open` | Build the Explorer, then open the page in a browser |

`lemma new` also takes every answer as a flag, for scripted use. Run `lemma new --help` for the list.

## For maintainers

| Command | Purpose |
|---|---|
| `lemma formalize` | Paper to module to compiler |
| `lemma check` | Compiler report at `reports/library.json` |
| `lemma score` | Verification agenda at `reports/agenda.md` |
| `lemma distinct` | Definitional against empirical distinctness |
| `lemma verify` | Review sheet, or precision from labelled sheets |
| `lemma report` | All reports, plus the README numbers |

## Make targets

| Target | Purpose |
|---|---|
| `make setup` | Run `install.sh` |
| `make install` | Install the pipeline into the active Python |
| `make build` | Compile the library |
| `make test` | Lean tests, Python tests, lint |
| `make report` | Regenerate every report |
| `make site` | Build the Explorer at `site/index.html` |

## Curating the Explorer

`config/curation.yaml` holds the findings, cautions and starting collections shown by `lemma tour` and the Explorer. Counts appear as placeholders filled from the compiler report. A test resolves every construct name in the file.
