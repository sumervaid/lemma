# Getting started

Lemma needs no programming background. Pick the route with the least setup for the task at hand.

## Browse in a web browser

Open the [Lemma Explorer](https://sumervaid.github.io/lemma/). Nothing needs installing.

1. Select a tile in the table of parts to list every construct built on that part.
2. Open **Compare** to set two constructs side by side.
3. Open **Draft a construct** to describe an idea. The page lists every construct already using the same parts.
4. Open **Agenda** to see where a new study would teach the library the most.

Tables on the Constructs, Claims and Agenda pages download as CSV files for Excel or R.

## Run the compiler in a cloud workspace

A free GitHub account is enough, and this route also suits Windows.

1. Open [a new Codespace](https://codespaces.new/sumervaid/lemma), then select **Create codespace**.
2. Wait for setup to finish. The first start takes a few minutes.
3. In the terminal at the bottom of the window, type `lemma tour`.

## Install on a laptop

On macOS or Linux, open the Terminal app, paste this line, then press Return.

```bash
curl -fsSL https://raw.githubusercontent.com/sumervaid/lemma/main/install.sh | bash
```

The script places Lemma in a folder named `lemma` in the home directory, along with the Python and Lean versions the project needs. The download is about 250 MB. To skip Lean for browsing alone, add `-s -- --browse-only` after `bash`.

Run `lemma doctor` at any time to see what works on the machine.

## First ten minutes

```bash
lemma tour                       # the curated findings
lemma find trust                 # search constructs, claims, parts
lemma show Thriving              # one construct in plain language
lemma compare Exhaustion Vigor   # two constructs side by side
lemma new                        # answer a few questions, receive a checked draft
```

`lemma new` asks for a name, a definition, a citation, a category, a scope, then the parts. The draft lands in the `drafts` folder, and the compiler replies in plain language.

## Next steps

- [Reading the results](reading-results.md) explains each output.
- [Glossary](glossary.md) defines every term.
- [Commands](commands.md) lists every command.
- [Discussions](https://github.com/sumervaid/lemma/discussions) take proposals for a construct or a theory, with no code required.

## When something goes wrong

| Message | Fix |
|---|---|
| `lemma: command not found` | Close the terminal, open a new one, then try again. Otherwise add `export PATH="$HOME/.local/bin:$PATH"` to the shell profile. |
| `Compiled library` shows `add` in `lemma doctor` | Run `make build` inside the Lemma folder. |
| `Lean` shows `add` in `lemma doctor` | Run `./install.sh` inside the Lemma folder. |
| Setup stops partway | Run the same line again. Finished steps are skipped. The log is at `.lake/install.log`. |
