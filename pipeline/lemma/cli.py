"""Command-line entry point: ``lemma <command>``.

Commands for readers
--------------------
doctor      state what works on this machine
tour        the curated findings
find        search constructs, claims and parts
show        one construct in plain language
compare     two constructs side by side
new         write a construct from plain answers, then check the draft
try         check a draft file, with the compiler's reply explained
site        build the browsable Explorer

Commands for maintainers
------------------------
formalize   paper(s) → Lemma module → compiler → reports/papers/<paper>.json
check       compiler over the whole library → reports/library.{json,md}
score       verification-priority scorer → reports/agenda.{md,json}
distinct    definitional vs empirical distinctness → reports/distinctness.{md,json}
verify      sample a review sheet, or compute precision from labelled sheets
report      check + score + distinct + precision, then refresh README numbers
"""

from __future__ import annotations

import argparse
import json
import sys
import webbrowser
from pathlib import Path

from .check import generated_modules, load_library, run_check, write_json
from .config import LLMConfig, Paths, find_repo_root
from .distinct import DEFAULT_THRESHOLD, classify, read_csv, render
from .doctor import render as render_doctor
from .doctor import run_checks
from .draft import (
    CATEGORIES,
    HORIZONS,
    LEVELS,
    all_parts,
    library_built,
    parse_catalog,
    render_lean,
    submit,
    to_identifier,
)
from .explore import (
    AmbiguousNameError,
    Library,
    UnknownNameError,
    clean_doc,
    describe_comparison,
    describe_construct,
    fill_counts,
    format_claim,
    load_curation,
    part_label,
    tail,
    theory_name,
)
from .formalize import formalize_paper
from .lean import lake_build, toolchain_available
from .llm import FixtureProvider, OpenAICompatibleProvider
from .score import load_scoring_config, render_agenda, score_library
from .site import build_site
from .verify import all_sheets, compute_precision, sample_items, write_sheet


def _paths(args: argparse.Namespace) -> Paths:
    root = Path(args.root).resolve() if args.root else find_repo_root()
    return Paths(root)


START_TEXT = """Lemma checks organizational theory the way a compiler checks code.

Explore the library
  lemma tour                     the curated findings
  lemma find energy              search constructs, claims, parts
  lemma show Thriving            one construct in plain language
  lemma compare Exhaustion Vigor two constructs side by side
  lemma site --open              the Explorer, in a browser

Check a new idea
  lemma new                      answer a few questions, receive a checked draft
  lemma try drafts/MyIdea.lean   check a draft file

Set up
  lemma doctor                   state what works on this machine

Every command, including the maintainer pipeline: lemma --help
"""


def _resolve(lib: Library, query: str):
    try:
        return lib.resolve(query)
    except AmbiguousNameError as err:
        print(f"{err.query} names several constructs. Pick one:", file=sys.stderr)
        for option in err.options:
            print(f"  {option}", file=sys.stderr)
    except UnknownNameError as err:
        print(f"No construct is named {err.query}.", file=sys.stderr)
        if err.suggestions:
            print("Closest matches:", file=sys.stderr)
            for option in err.suggestions:
                print(f"  {option}", file=sys.stderr)
        else:
            print("Search with: lemma find <word>", file=sys.stderr)
    return None


def cmd_doctor(args: argparse.Namespace) -> int:
    text, code = render_doctor(run_checks(_paths(args)))
    print(text)
    return code


def cmd_tour(args: argparse.Namespace) -> int:
    paths = _paths(args)
    lib = Library(paths)
    curation = load_curation(paths)
    print(fill_counts(curation["status"], lib.report))
    for finding in curation["findings"]:
        print(f"\n{fill_counts(finding['title'], lib.report)}")
        print(f"  {fill_counts(finding['body'], lib.report)}")
        print(f"  Caution. {finding['caution']}")
        if finding.get("compare"):
            a, b = finding["compare"]
            print(f"  See: lemma compare {a} {b}")
    return 0


def cmd_find(args: argparse.Namespace) -> int:
    lib = Library(_paths(args))
    query = " ".join(args.words)
    constructs, claims, parts = lib.find_constructs(query), lib.find_claims(query), lib.find_parts(query)
    if not (constructs or claims or parts):
        print(f"No matches for {query}. Try one broader word.")
        return 1
    if parts:
        print("Parts")
        for p in parts:
            print(f"  {tail(p['name']):18s} {clean_doc(p.get('doc', ''))[:90]}")
    if constructs:
        print(f"\nConstructs: {len(constructs)}")
        for c in constructs[: args.limit]:
            print(f"  {theory_name(c['name'])}")
    if claims:
        print(f"\nClaims: {len(claims)}")
        for p in claims[: args.limit]:
            print(f"  {format_claim(p)}")
    print("\nFor detail: lemma show <construct>")
    return 0


def cmd_show(args: argparse.Namespace) -> int:
    lib = Library(_paths(args))
    construct = _resolve(lib, " ".join(args.name))
    if construct is None:
        return 1
    print(describe_construct(lib, construct))
    return 0


def cmd_compare(args: argparse.Namespace) -> int:
    lib = Library(_paths(args))
    a, b = _resolve(lib, args.a), _resolve(lib, args.b)
    if a is None or b is None:
        return 1
    print(describe_comparison(lib.compare(a, b)))
    return 0


def _ask(prompt: str, default: str = "") -> str:
    suffix = f" [{default}]" if default else ""
    answer = input(f"{prompt}{suffix}: ").strip()
    return answer or default


def _choose(prompt: str, options: list[str], labels: dict[str, str] | None = None, default: str = "") -> str:
    print(prompt)
    for i, option in enumerate(options, start=1):
        print(f"  {i:2d}  {(labels or {}).get(option, option)}")
    while True:
        answer = _ask("Number", str(options.index(default) + 1) if default else "")
        if answer.isdigit() and 1 <= int(answer) <= len(options):
            return options[int(answer) - 1]
        print(f"Enter a number from 1 to {len(options)}.")


def _labelled_parts(parts: list[str]) -> dict[str, str]:
    return {p: part_label(p.split()[0], p.split()[1:]) for p in parts}


def _choose_parts(parts: list[str]) -> list[str]:
    labels = _labelled_parts(parts)
    print("Parts. Enter a word to search, a number to add, or a blank line to finish.")
    chosen: list[str] = []
    shown = parts
    while True:
        for i, part in enumerate(shown, start=1):
            print(f"  {i:2d}  {labels[part]}")
        answer = _ask(f"Chosen so far: {len(chosen)}")
        if not answer:
            if chosen:
                return chosen
            print("A construct needs at least one part.")
        elif answer.isdigit() and 1 <= int(answer) <= len(shown):
            pick = shown[int(answer) - 1]
            if pick not in chosen:
                chosen.append(pick)
            print(f"Added {labels[pick]}.")
            shown = parts
        else:
            shown = [p for p in parts if answer.lower() in labels[p].lower()] or parts


def _report_submission(paths: Paths, file: Path, raw: bool) -> int:
    if not toolchain_available():
        print(f"Wrote {file}.")
        print("The compiler check needs Lean. Run ./install.sh, then: lemma try " + str(file))
        return 0
    ok, messages = submit(paths, file)
    tones = {"problem": "Problem", "attention": "Attention", "note": "Note"}
    for m in messages:
        print(f"\n{tones[m.tone]}. {m.headline}")
        print(f"  {m.detail}")
        if raw:
            print(f"  Compiler text, line {m.line}: {m.raw}")
    print()
    if ok:
        attention = sum(m.tone == "attention" for m in messages)
        print(
            f"Compiled. {attention} overlap or disagreement messages call for a decision."
            if attention
            else "Compiled with nothing to resolve."
        )
    else:
        print("The draft did not compile. Each problem above names the fix.")
    return 0 if ok else 1


def cmd_new(args: argparse.Namespace) -> int:
    paths = _paths(args)
    catalog = parse_catalog((paths.root / "Lemma" / "Library" / "Primitives.lean").read_text(encoding="utf-8"))
    parts = all_parts(catalog)
    categories = list(CATEGORIES)
    name = args.name or _ask("Construct name, for example work vitality")
    try:
        identifier = to_identifier(name)
    except ValueError as err:
        print(err, file=sys.stderr)
        return 2
    definition = args.definition or _ask("One-sentence definition")
    citation = args.citation or _ask("Citation with author, year, page")
    category = args.category or _choose("Category", categories, CATEGORIES)
    level = args.level or _choose("Level of analysis", LEVELS, default="Individual")
    horizon = args.horizon or _choose("Time horizon", HORIZONS, default="Weekly")
    chosen = args.part or _choose_parts(parts)
    unknown = [p for p in chosen if p not in parts]
    if unknown:
        print(f"Unknown parts: {', '.join(unknown)}. Run lemma find <word> to list parts.", file=sys.stderr)
        return 2
    if category not in CATEGORIES or level not in LEVELS or horizon not in HORIZONS:
        print(
            f"Categories: {', '.join(categories)}. Levels: {', '.join(LEVELS)}. Horizons: {', '.join(HORIZONS)}.",
            file=sys.stderr,
        )
        return 2
    drafts = paths.root / "drafts"
    drafts.mkdir(exist_ok=True)
    file = drafts / f"{identifier}.lean"
    file.write_text(
        render_lean(identifier, definition, citation, category, level, horizon, chosen, generated_modules(paths)),
        encoding="utf-8",
    )
    print(f"\nWrote {file}")
    return _report_submission(paths, file, args.raw)


def cmd_try(args: argparse.Namespace) -> int:
    file = Path(args.file)
    if not file.exists():
        print(f"No file at {file}.", file=sys.stderr)
        return 2
    return _report_submission(_paths(args), file, args.raw)


def cmd_site(args: argparse.Namespace) -> int:
    paths = _paths(args)
    out = Path(args.out) if args.out else paths.root / "site" / "index.html"
    build_site(paths, out)
    print(f"Wrote {out}")
    if args.open:
        webbrowser.open(out.resolve().as_uri())
    return 0


def cmd_formalize(args: argparse.Namespace) -> int:
    paths = _paths(args)
    if not toolchain_available():
        print("error: lean/lake not on PATH (set LEMMA_LEAN_BIN)", file=sys.stderr)
        return 2
    if not library_built(paths.root):
        # Candidates elaborate against the compiled library. On an unbuilt checkout every
        # candidate would fail to import, which would demote accepted modules to failures.
        print("Building the library first. This takes a minute or two.")
        built = lake_build(paths.root)
        if not built.ok:
            print(built.stdout[-2000:] or built.stderr[-2000:], file=sys.stderr)
            print("error: the library did not build, so no paper was formalized", file=sys.stderr)
            return 2
    raw_path = paths.reports / "library_raw.json"
    library_raw = json.loads(raw_path.read_text(encoding="utf-8")) if raw_path.exists() else None
    if args.offline:
        provider = FixtureProvider(paths.fixtures / "formalizations")
    else:
        provider = OpenAICompatibleProvider(LLMConfig())
    papers = [Path(p) for p in args.papers]
    if not papers:
        papers = sorted((paths.fixtures / "papers").glob("*.txt"))
    exit_code = 0
    for paper in papers:
        report = formalize_paper(paper, provider, paths, library_raw, max_repairs=args.max_repairs)
        print(
            f"{report.paper_id}: {report.status} ({report.provider}; "
            f"{report.counts.get('constructs', 0)} constructs, {report.counts.get('propositions', 0)} propositions, "
            f"{len(report.overlap_warnings)} overlap warnings, {len(report.errors)} errors)"
        )
        if report.status != "accepted" and args.strict:
            exit_code = 1
    return exit_code


def cmd_check(args: argparse.Namespace) -> int:
    paths = _paths(args)
    if not toolchain_available():
        print("error: lean/lake not on PATH (set LEMMA_LEAN_BIN)", file=sys.stderr)
        return 2
    report, _ = run_check(paths, build=not args.no_build)
    s = report["summary"]
    print(
        f"constructs={s['constructs']} propositions={s['propositions']} papers={s['papers_total']} "
        f"overlaps={s['overlap_warnings']} contradictions={s['contradictions_cross_theory']} "
        f"implied_untested={s['implied_untested']} formalization_failures={s['formalization_failures']}"
    )
    print(f"wrote {paths.reports / 'library.json'} and {paths.reports / 'library.md'}")
    return 0


def cmd_score(args: argparse.Namespace) -> int:
    paths = _paths(args)
    report = load_library(paths)
    cfg = load_scoring_config(Path(args.config) if args.config else paths.config / "scoring.yaml")
    items = score_library(report, cfg)
    (paths.reports / "agenda.md").write_text(render_agenda(items, cfg, report["summary"]), encoding="utf-8")
    write_json(paths.reports / "agenda.json", {"config": cfg, "items": [i.to_dict() for i in items]})
    for rank, it in enumerate(items[: args.top], start=1):
        print(f"{rank:3d} {it.score:.3f} {it.kind:10s} {it.antecedent} → {it.consequent} ({it.direction})")
    print(f"wrote {paths.reports / 'agenda.md'}")
    return 0


def cmd_distinct(args: argparse.Namespace) -> int:
    paths = _paths(args)
    report = load_library(paths)
    csv_path = Path(args.csv) if args.csv else paths.fixtures / "correlations.csv"
    rows = classify(report, read_csv(csv_path), threshold=args.threshold)
    (paths.reports / "distinctness.md").write_text(render(rows, args.threshold), encoding="utf-8")
    write_json(paths.reports / "distinctness.json", {"threshold": args.threshold, "rows": [r.to_dict() for r in rows]})
    for r in rows:
        print(f"{r.a} ~ {r.b}: {r.label} [{r.status}]")
    print(f"wrote {paths.reports / 'distinctness.md'}")
    return 0


def cmd_verify(args: argparse.Namespace) -> int:
    paths = _paths(args)
    if args.precision:
        p = compute_precision(all_sheets(paths))
        write_json(paths.reports / "precision.json", p.to_dict())
        if p.precision is None:
            print(f"precision: unavailable ({p.labelled} labelled items across {len(p.sheets)} sheets)")
        else:
            print(
                f"precision: {p.precision:.3f} ({p.faithful} faithful / {p.faithful + p.unfaithful} decided; {p.unsure} unsure)"
            )
        return 0
    items = sample_items(paths, args.sample, args.seed)
    out = write_sheet(paths, items, args.seed)
    print(f"wrote {out} with {len(items)} items")
    return 0


def _refresh_readme(paths: Paths, summary: dict, precision: dict) -> None:
    readme = paths.root / "README.md"
    if not readme.exists():
        return
    begin, end = "<!-- BEGIN GENERATED NUMBERS -->", "<!-- END GENERATED NUMBERS -->"
    text = readme.read_text(encoding="utf-8")
    if begin not in text or end not in text:
        return
    prec = (
        "not yet available (no labelled review sheets)"
        if precision.get("precision") is None
        else f"{precision['precision']:.3f}"
    )
    block = "\n".join(
        [
            begin,
            "| Quantity | Value |",
            "|---|---|",
            f"| Kernel version | {summary['kernel_version']} |",
            f"| Theories (modules) | {summary['theories']} ({summary['theories_curated']} curated, {summary['theories'] - summary['theories_curated']} accepted from the pipeline) |",
            f"| Primitives | {summary['primitives']} |",
            f"| Constructs | {summary['constructs']} ({summary['constructs_curated']} curated, {summary['constructs_generated']} accepted from the pipeline) |",
            f"| Propositions | {summary['propositions']} ({summary['propositions_curated']} curated, {summary['propositions_generated']} accepted from the pipeline) |",
            f"| Source papers | {summary['papers_total']} ({summary['papers_curated_sources']} curated sources, {summary['papers_pipeline_accepted']} accepted pipeline papers) |",
            f"| Overlap warnings | {summary['overlap_warnings']} ({summary['overlap_warnings_curated']} within the curated library, {summary['overlap_warnings_curated_resolved']} of them resolved by declaration; {summary['overlap_warnings_involving_generated']} raised against accepted pipeline modules) |",
            f"| Cross-theory contradictions | {summary['contradictions_cross_theory']} |",
            f"| Conditional disagreements | {summary['conditional_disagreements']} |",
            f"| Shape disagreements | {summary['shape_disagreements']} |",
            f"| Implied, untested propositions | {summary['implied_untested']} |",
            f"| Formalization failures | {summary['formalization_failures']} of {summary['papers_pipeline']} pipeline papers |",
            f"| Verified precision | {prec} |",
            end,
        ]
    )
    pre, rest = text.split(begin, 1)
    _, post = rest.split(end, 1)
    readme.write_text(pre + block + post, encoding="utf-8")


def cmd_report(args: argparse.Namespace) -> int:
    paths = _paths(args)
    if not toolchain_available():
        print("error: lean/lake not on PATH (set LEMMA_LEAN_BIN)", file=sys.stderr)
        return 2
    report, _ = run_check(paths, build=not args.no_build)
    cfg = load_scoring_config(paths.config / "scoring.yaml")
    items = score_library(report, cfg)
    (paths.reports / "agenda.md").write_text(render_agenda(items, cfg, report["summary"]), encoding="utf-8")
    write_json(paths.reports / "agenda.json", {"config": cfg, "items": [i.to_dict() for i in items]})
    csv_path = paths.fixtures / "correlations.csv"
    if csv_path.exists():
        rows = classify(report, read_csv(csv_path), threshold=DEFAULT_THRESHOLD)
        (paths.reports / "distinctness.md").write_text(render(rows, DEFAULT_THRESHOLD), encoding="utf-8")
        write_json(
            paths.reports / "distinctness.json", {"threshold": DEFAULT_THRESHOLD, "rows": [r.to_dict() for r in rows]}
        )
    precision = compute_precision(all_sheets(paths)).to_dict()
    write_json(paths.reports / "precision.json", precision)
    _refresh_readme(paths, report["summary"], precision)
    s = report["summary"]
    print(
        json.dumps(
            {
                k: s[k]
                for k in (
                    "constructs",
                    "propositions",
                    "papers_total",
                    "overlap_warnings",
                    "contradictions_cross_theory",
                    "conditional_disagreements",
                    "shape_disagreements",
                    "implied_untested",
                    "formalization_failures",
                )
            },
            indent=2,
        )
    )
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="lemma", description="Check organizational theory with a compiler.")
    parser.add_argument("--root", help="repository root (default: auto-detect from cwd)")
    sub = parser.add_subparsers(dest="command")

    p = sub.add_parser("doctor", help="state what works on this machine")
    p.set_defaults(func=cmd_doctor)

    p = sub.add_parser("tour", help="the curated findings")
    p.set_defaults(func=cmd_tour)

    p = sub.add_parser("find", help="search constructs, claims and parts")
    p.add_argument("words", nargs="+")
    p.add_argument("--limit", type=int, default=15)
    p.set_defaults(func=cmd_find)

    p = sub.add_parser("show", help="one construct in plain language")
    p.add_argument("name", nargs="+")
    p.set_defaults(func=cmd_show)

    p = sub.add_parser("compare", help="two constructs side by side")
    p.add_argument("a")
    p.add_argument("b")
    p.set_defaults(func=cmd_compare)

    p = sub.add_parser("new", help="write a construct from plain answers, then check the draft")
    p.add_argument("--name")
    p.add_argument("--definition")
    p.add_argument("--citation")
    p.add_argument("--category", help=", ".join(CATEGORIES))
    p.add_argument("--level", help=", ".join(LEVELS))
    p.add_argument("--horizon", help=", ".join(HORIZONS))
    p.add_argument("--part", action="append", help="repeatable, for example --part Energy --part 'Attention Work'")
    p.add_argument("--raw", action="store_true", help="also print the compiler's own text")
    p.set_defaults(func=cmd_new)

    p = sub.add_parser("try", help="check a draft file, with the compiler's reply explained")
    p.add_argument("file")
    p.add_argument("--raw", action="store_true", help="also print the compiler's own text")
    p.set_defaults(func=cmd_try)

    p = sub.add_parser("site", help="build the browsable Explorer")
    p.add_argument("--out", help="output file (default: site/index.html)")
    p.add_argument("--open", action="store_true", help="open the Explorer in a browser")
    p.set_defaults(func=cmd_site)

    p = sub.add_parser("formalize", help="formalize papers into Lemma modules")
    p.add_argument("papers", nargs="*", help=".txt or .pdf files (default: fixtures/papers/*.txt)")
    p.add_argument("--offline", action="store_true", help="use fixture formalizations instead of a model")
    p.add_argument("--max-repairs", type=int, default=0, help="repair rounds with the model after compile errors")
    p.add_argument("--strict", action="store_true", help="exit 1 if any paper is not accepted")
    p.set_defaults(func=cmd_formalize)

    p = sub.add_parser("check", help="run the compiler over the library and write reports")
    p.add_argument("--no-build", action="store_true", help="skip `lake build` (library already built)")
    p.set_defaults(func=cmd_check)

    p = sub.add_parser("score", help="rank propositions by verification priority")
    p.add_argument("--config", help="scoring config (default: config/scoring.yaml)")
    p.add_argument("--top", type=int, default=15)
    p.set_defaults(func=cmd_score)

    p = sub.add_parser("distinct", help="definitional vs empirical distinctness")
    p.add_argument("--csv", help="correlations CSV (default: fixtures/correlations.csv)")
    p.add_argument("--threshold", type=float, default=DEFAULT_THRESHOLD)
    p.set_defaults(func=cmd_distinct)

    p = sub.add_parser("verify", help="sample a review sheet or compute precision")
    p.add_argument("--sample", type=int, default=20)
    p.add_argument("--seed", type=int, default=1)
    p.add_argument("--precision", action="store_true")
    p.set_defaults(func=cmd_verify)

    p = sub.add_parser("report", help="check + score + distinct + precision, refresh README numbers")
    p.add_argument("--no-build", action="store_true")
    p.set_defaults(func=cmd_report)
    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    if not args.command:
        print(START_TEXT)
        return 0
    return int(args.func(args))


if __name__ == "__main__":  # pragma: no cover
    sys.exit(main())
