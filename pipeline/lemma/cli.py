"""Command-line entry point: ``lemma <command>``.

Commands
--------
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
from pathlib import Path

from .check import load_library, run_check, write_json
from .config import LLMConfig, Paths, find_repo_root
from .distinct import DEFAULT_THRESHOLD, classify, read_csv, render
from .formalize import formalize_paper
from .lean import toolchain_available
from .llm import FixtureProvider, OpenAICompatibleProvider
from .score import load_scoring_config, render_agenda, score_library
from .verify import all_sheets, compute_precision, sample_items, write_sheet


def _paths(args: argparse.Namespace) -> Paths:
    root = Path(args.root).resolve() if args.root else find_repo_root()
    return Paths(root)


def cmd_formalize(args: argparse.Namespace) -> int:
    paths = _paths(args)
    if not toolchain_available():
        print("error: lean/lake not on PATH (set LEMMA_LEAN_BIN)", file=sys.stderr)
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
    parser = argparse.ArgumentParser(prog="lemma", description="Lemma pipeline")
    parser.add_argument("--root", help="repository root (default: auto-detect from cwd)")
    sub = parser.add_subparsers(dest="command", required=True)

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
    return int(args.func(args))


if __name__ == "__main__":  # pragma: no cover
    sys.exit(main())
