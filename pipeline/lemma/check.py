"""``lemma check``: run the compiler over the whole library and write the report.

The checks themselves run inside Lean (``#lemma_report`` in
``scripts/report.lean`` dumps the registries and every check result to
``reports/library_raw.json``). This module

1. builds the library (which includes accepted generated modules under
   ``Lemma/Generated``),
2. regenerates the import block of ``scripts/report.lean`` so that the
   report sees those modules,
3. runs the report script, and
4. enriches the raw JSON with derived views (deduplicated implied
   propositions, conditional disagreements, convergences, per-paper
   formalization outcomes, source counts) into ``reports/library.json``
   and a human-readable ``reports/library.md``.

Everything in step 4 is a pure function of the raw report and the paper
reports, so it is unit-tested without Lean.
"""

from __future__ import annotations

import json
import re
from collections import Counter, defaultdict
from datetime import UTC, datetime
from pathlib import Path

import yaml

from .config import Paths
from .formalize import load_paper_reports
from .lean import LeanResult, lake_build, lean_run_script

IMPORT_BEGIN = "-- BEGIN GENERATED IMPORTS"
IMPORT_END = "-- END GENERATED IMPORTS"


def short(name: str) -> str:
    return name.split(".")[-1]


def qualified(name: str) -> str:
    """``Lemma.Theories.JDR.JobDemands`` → ``JDR.JobDemands`` (theory-qualified short name)."""
    parts = name.split(".")
    return ".".join(parts[-2:]) if len(parts) >= 2 else name


def generated_modules(paths: Paths) -> list[str]:
    if not paths.generated.exists():
        return []
    return sorted(p.stem for p in paths.generated.glob("*.lean"))


def update_report_script(paths: Paths, modules: list[str]) -> str:
    script = paths.report_script.read_text(encoding="utf-8")
    block = "\n".join(f"import Lemma.Generated.{m}" for m in modules)
    pattern = re.compile(re.escape(IMPORT_BEGIN) + r".*?" + re.escape(IMPORT_END), re.DOTALL)
    new = f"{IMPORT_BEGIN}\n{block}\n{IMPORT_END}" if block else f"{IMPORT_BEGIN}\n{IMPORT_END}"
    updated = pattern.sub(new, script)
    paths.report_script.write_text(updated, encoding="utf-8")
    return updated


def load_sources(paths: Paths) -> list[dict]:
    src = paths.bibliography / "sources.yaml"
    if not src.exists():
        return []
    with src.open(encoding="utf-8") as fh:
        data = yaml.safe_load(fh) or {}
    return list(data.get("sources", []))


# --------------------------------------------------------------------------- #
# Enrichment (pure)
# --------------------------------------------------------------------------- #


def _key(p: dict) -> tuple:
    return (p["antecedent"], p["consequent"], p["level"], p["horizon"])


def _boundary_key(b: dict) -> str:
    kind = b.get("kind", "none")
    if kind == "moderator":
        return f"moderator:{short(b['construct'])}:{b['effect']}"
    if kind == "scope":
        return f"scope:{b.get('description', '')}"
    return "none"


def contradicts(a: str, b: str) -> bool:
    signed = {"Positive", "Negative"}
    if a in signed and b in signed and a != b:
        return True
    return (a == "Null" and b in signed) or (b == "Null" and a in signed)


def shape_disagrees(a: str, b: str) -> bool:
    return (a == "Curvilinear") != (b == "Curvilinear")


def conditional_disagreements(props: list[dict]) -> list[dict]:
    """Same pair and scope, contradicting directions, different boundary conditions."""
    out = []
    for i, p in enumerate(props):
        for q in props[i + 1 :]:
            if _key(p) != _key(q):
                continue
            if _boundary_key(p["boundary"]) == _boundary_key(q["boundary"]):
                continue
            if p["theory"] == q["theory"]:
                continue
            if contradicts(p["direction"], q["direction"]):
                out.append(
                    {
                        "a": p["name"],
                        "b": q["name"],
                        "theoryA": p["theory"],
                        "theoryB": q["theory"],
                        "antecedent": p["antecedent"],
                        "consequent": p["consequent"],
                        "level": p["level"],
                        "horizon": p["horizon"],
                        "directionA": p["direction"],
                        "directionB": q["direction"],
                        "boundaryA": _boundary_key(p["boundary"]),
                        "boundaryB": _boundary_key(q["boundary"]),
                    }
                )
    return out


def convergences(props: list[dict]) -> list[dict]:
    """Comparable propositions asserted with the same direction by two or more theories."""
    groups: dict[tuple, list[dict]] = defaultdict(list)
    for p in props:
        groups[(*_key(p), _boundary_key(p["boundary"]), p["direction"])].append(p)
    out = []
    for key, members in groups.items():
        theories = sorted({m["theory"] for m in members})
        if len(theories) >= 2:
            out.append(
                {
                    "antecedent": key[0],
                    "consequent": key[1],
                    "level": key[2],
                    "horizon": key[3],
                    "boundary": key[4],
                    "direction": key[5],
                    "theories": theories,
                    "propositions": sorted(m["name"] for m in members),
                }
            )
    return sorted(out, key=lambda c: (c["antecedent"], c["consequent"]))


def dedupe_implied(implied: list[dict]) -> list[dict]:
    """Merge implied propositions with the same pair, scope and direction.

    Keeps every premise pair, the union of theories, and the strongest
    status (``contradicted`` > ``tested`` > ``untested``).
    """
    order = {"untested": 0, "tested": 1, "contradicted": 2}
    merged: dict[tuple, dict] = {}
    for imp in implied:
        key = (imp["antecedent"], imp["consequent"], imp["direction"], imp["level"], imp["horizon"])
        entry = merged.get(key)
        if entry is None:
            entry = {
                "antecedent": imp["antecedent"],
                "consequent": imp["consequent"],
                "direction": imp["direction"],
                "level": imp["level"],
                "horizon": imp["horizon"],
                "premises": [],
                "theories": [],
                "registered": imp.get("registered"),
                "status": imp["status"],
            }
            merged[key] = entry
        entry["premises"].append([imp["premiseA"], imp["premiseB"]])
        for t in imp.get("theories", []):
            if t not in entry["theories"]:
                entry["theories"].append(t)
        if order.get(imp["status"], 0) > order.get(entry["status"], 0):
            entry["status"] = imp["status"]
            entry["registered"] = imp.get("registered")
    out = list(merged.values())
    # Implied disagreements: the same pair implied with contradicting directions.
    by_pair: dict[tuple, list[dict]] = defaultdict(list)
    for e in out:
        by_pair[(e["antecedent"], e["consequent"], e["level"], e["horizon"])].append(e)
    for members in by_pair.values():
        dirs = {m["direction"] for m in members}
        for m in members:
            m["implied_disagreement"] = any(contradicts(m["direction"], d) for d in dirs - {m["direction"]})
    return sorted(out, key=lambda e: (e["antecedent"], e["consequent"], e["direction"]))


def summarize_formalization(paper_reports: list[dict]) -> dict:
    by_status = Counter(r["status"] for r in paper_reports)
    failures = [
        {
            "paper_id": r["paper_id"],
            "status": r["status"],
            "reason": r.get("reason", ""),
            "ambiguities": r.get("ambiguities", []),
            "errors": [e["message"].splitlines()[0] for e in r.get("errors", [])],
            "lean_path": r.get("lean_path", ""),
        }
        for r in paper_reports
        if r["status"] in {"failed", "declined"}
    ]
    accepted = [r for r in paper_reports if r["status"] == "accepted"]
    return {
        "papers": len(paper_reports),
        "accepted": by_status.get("accepted", 0),
        "failed": by_status.get("failed", 0),
        "declined": by_status.get("declined", 0),
        "failures_total": by_status.get("failed", 0) + by_status.get("declined", 0),
        "accepted_constructs": sum(r.get("counts", {}).get("constructs", 0) for r in accepted),
        "accepted_propositions": sum(r.get("counts", {}).get("propositions", 0) for r in accepted),
        "overlap_warnings_in_generated": sum(len(r.get("overlap_warnings", [])) for r in accepted),
        "providers": sorted({r.get("provider", "") for r in paper_reports}),
        "models": sorted({r.get("model", "") for r in paper_reports}),
        "failures": failures,
        "per_paper": [
            {
                "paper_id": r["paper_id"],
                "module": r.get("module", ""),
                "status": r["status"],
                "provider": r.get("provider", ""),
                "counts": r.get("counts", {}),
                "overlap_warnings": len(r.get("overlap_warnings", [])),
                "errors": len(r.get("errors", [])),
            }
            for r in paper_reports
        ],
    }


def enrich(raw: dict, paper_reports: list[dict], sources: list[dict]) -> dict:
    props = raw.get("propositions", [])
    constructs = raw.get("constructs", [])
    overlaps = raw.get("overlaps", [])
    implied = dedupe_implied(raw.get("implied", []))
    cond = conditional_disagreements(props)
    conv = convergences(props)
    form = summarize_formalization(paper_reports)

    generated_theories = {short(r["module"]) for r in paper_reports if r["status"] == "accepted"}
    curated_constructs = [c for c in constructs if c["theory"] not in generated_theories]
    generated_constructs = [c for c in constructs if c["theory"] in generated_theories]
    curated_props = [p for p in props if p["theory"] not in generated_theories]
    generated_props = [p for p in props if p["theory"] in generated_theories]

    overlap_kinds = Counter(o["kind"] for o in overlaps)
    resolved = [o for o in overlaps if o.get("declared")]
    theory_of = {c["name"]: c["theory"] for c in constructs}
    overlaps_curated = [
        o
        for o in overlaps
        if theory_of.get(o["a"]) not in generated_theories and theory_of.get(o["b"]) not in generated_theories
    ]
    decl_kinds = Counter(o["declared"]["kind"] for o in resolved)

    source_ids = {s["id"] for s in sources}
    pipeline_ids = {r["paper_id"] for r in paper_reports}
    pipeline_accepted_ids = {r["paper_id"] for r in paper_reports if r["status"] == "accepted"}

    summary = {
        "kernel_version": raw.get("kernel_version"),
        "theories": len(raw.get("theories", [])),
        "theories_curated": len({c["theory"] for c in curated_constructs} | {p["theory"] for p in curated_props}),
        "primitives": len(raw.get("primitives", [])),
        "constructs": len(constructs),
        "constructs_curated": len(curated_constructs),
        "constructs_generated": len(generated_constructs),
        "propositions": len(props),
        "propositions_curated": len(curated_props),
        "propositions_generated": len(generated_props),
        "aggregations": len(raw.get("aggregations", [])),
        "temporals": len(raw.get("temporals", [])),
        "overlap_warnings": len(overlaps),
        "overlap_warnings_by_kind": dict(overlap_kinds),
        "overlap_warnings_curated": len(overlaps_curated),
        "overlap_warnings_curated_resolved": len([o for o in overlaps_curated if o.get("declared")]),
        "overlap_warnings_involving_generated": len(overlaps) - len(overlaps_curated),
        "overlap_warnings_resolved": len(resolved),
        "overlap_warnings_unresolved": len(overlaps) - len(resolved),
        "overlap_declarations_by_kind": dict(decl_kinds),
        "scope_shifts": len(raw.get("scope_shifts", [])),
        "contradictions": len(raw.get("contradictions", [])),
        "contradictions_cross_theory": len([c for c in raw.get("contradictions", []) if c["theoryA"] != c["theoryB"]]),
        "conditional_disagreements": len(cond),
        "shape_disagreements": len(raw.get("shape_disagreements", [])),
        "convergences": len(conv),
        "implied": len(implied),
        "implied_untested": len([i for i in implied if i["status"] == "untested"]),
        "implied_tested": len([i for i in implied if i["status"] == "tested"]),
        "implied_contradicted": len([i for i in implied if i["status"] == "contradicted"]),
        "implied_disagreements": len([i for i in implied if i.get("implied_disagreement")]),
        "formalization_failures": form["failures_total"],
        "papers_curated_sources": len(source_ids),
        "papers_pipeline": len(pipeline_ids),
        "papers_pipeline_accepted": len(pipeline_accepted_ids),
        "papers_total": len(source_ids | pipeline_accepted_ids),
    }
    return {
        "generated_at": datetime.now(UTC).isoformat(timespec="seconds"),
        "summary": summary,
        "theories": raw.get("theories", []),
        "primitives": raw.get("primitives", []),
        "constructs": constructs,
        "propositions": props,
        "aggregations": raw.get("aggregations", []),
        "temporals": raw.get("temporals", []),
        "overlap_declarations": raw.get("overlap_declarations", []),
        "overlaps": overlaps,
        "scope_shifts": raw.get("scope_shifts", []),
        "contradictions": raw.get("contradictions", []),
        "conditional_disagreements": cond,
        "shape_disagreements": raw.get("shape_disagreements", []),
        "convergences": conv,
        "implied": implied,
        "formalization": form,
        "sources": sources,
    }


# --------------------------------------------------------------------------- #
# Markdown
# --------------------------------------------------------------------------- #


def _md_table(headers: list[str], rows: list[list[str]]) -> str:
    out = ["| " + " | ".join(headers) + " |", "|" + "|".join("---" for _ in headers) + "|"]
    out.extend("| " + " | ".join(str(c) for c in r) + " |" for r in rows)
    return "\n".join(out)


def render_markdown(report: dict) -> str:
    s = report["summary"]
    lines = [
        "# Lemma library report",
        "",
        f"Generated {report['generated_at']} by `lemma check`. Kernel {s['kernel_version']}.",
        "",
        "## Summary",
        "",
        _md_table(
            ["Quantity", "Value"],
            [
                [
                    "Theories (modules)",
                    f"{s['theories']} ({s['theories_curated']} curated, {s['theories'] - s['theories_curated']} generated)",
                ],
                ["Primitives", s["primitives"]],
                [
                    "Constructs (curated + generated)",
                    f"{s['constructs']} ({s['constructs_curated']} + {s['constructs_generated']})",
                ],
                [
                    "Propositions (curated + generated)",
                    f"{s['propositions']} ({s['propositions_curated']} + {s['propositions_generated']})",
                ],
                ["Aggregation rules", s["aggregations"]],
                ["Temporal rules", s["temporals"]],
                ["Source papers (curated sources ∪ accepted pipeline papers)", s["papers_total"]],
                [
                    "Overlap warnings",
                    f"{s['overlap_warnings']} ({s['overlap_warnings_resolved']} resolved by declaration, {s['overlap_warnings_unresolved']} unresolved)",
                ],
                [
                    "Overlap warnings, curated library only",
                    f"{s['overlap_warnings_curated']} ({s['overlap_warnings_curated_resolved']} resolved); {s['overlap_warnings_involving_generated']} further warnings involve accepted generated modules",
                ],
                [
                    "Overlap warnings by kind",
                    ", ".join(f"{k}: {v}" for k, v in sorted(s["overlap_warnings_by_kind"].items())),
                ],
                [
                    "Overlap declarations by kind",
                    ", ".join(f"{k}: {v}" for k, v in sorted(s["overlap_declarations_by_kind"].items())),
                ],
                ["Scope shifts (same primitive, different scope)", s["scope_shifts"]],
                ["Cross-theory contradictions (same scope and boundary)", s["contradictions_cross_theory"]],
                ["Conditional disagreements (different boundary)", s["conditional_disagreements"]],
                ["Shape disagreements (linear vs curvilinear)", s["shape_disagreements"]],
                ["Convergences (same claim in two or more theories)", s["convergences"]],
                [
                    "Implied propositions (deduplicated)",
                    f"{s['implied']} ({s['implied_untested']} untested, {s['implied_tested']} tested, {s['implied_contradicted']} contradicted, {s['implied_disagreements']} with disagreeing implied directions)",
                ],
                [
                    "Formalization failures (pipeline)",
                    f"{s['formalization_failures']} of {s['papers_pipeline']} papers",
                ],
            ],
        ),
        "",
        "## Constructs",
        "",
        _md_table(
            ["Construct", "Theory", "Kind", "Level", "Horizon", "Primitive leaves"],
            [
                [
                    short(c["name"]),
                    c["theory"],
                    c["kind"],
                    c["level"],
                    c["horizon"],
                    ", ".join(sorted({_leaf_display(leaf) for leaf in c["leaves"]})),
                ]
                for c in report["constructs"]
            ],
        ),
        "",
        "## Propositions",
        "",
        _md_table(
            ["Proposition", "Theory", "Antecedent", "Consequent", "Direction", "Scope", "Boundary", "Evidence"],
            [
                [
                    short(p["name"]),
                    p["theory"],
                    short(p["antecedent"]),
                    short(p["consequent"]),
                    p["direction"],
                    f"{p['level']} / {p['horizon']}",
                    _boundary_key(p["boundary"]),
                    p["evidence"],
                ]
                for p in report["propositions"]
            ],
        ),
        "",
        "## Overlap warnings",
        "",
        _md_table(
            ["A", "B", "Kind", "Shared primitives", "Resolution"],
            [
                [
                    short(o["a"]),
                    short(o["b"]),
                    o["kind"],
                    ", ".join(f"{sh['inA']} ~ {sh['inB']}" for sh in o["shared"]),
                    (f"{o['declared']['kind']}" if o.get("declared") else "unresolved"),
                ]
                for o in report["overlaps"]
            ],
        ),
        "",
        "## Cross-theory contradictions",
        "",
    ]
    if report["contradictions"]:
        lines.append(
            _md_table(
                ["Pair", "Scope", "Theory A", "Theory B"],
                [
                    [
                        f"{short(c['antecedent'])} → {short(c['consequent'])}",
                        f"{c['level']} / {c['horizon']}",
                        f"{c['theoryA']}: {c['directionA']} ({short(c['a'])})",
                        f"{c['theoryB']}: {c['directionB']} ({short(c['b'])})",
                    ]
                    for c in report["contradictions"]
                ],
            )
        )
    else:
        lines.append("None.")
    lines += ["", "## Conditional disagreements", ""]
    if report["conditional_disagreements"]:
        lines.append(
            _md_table(
                ["Pair", "Theory A", "Theory B"],
                [
                    [
                        f"{short(c['antecedent'])} → {short(c['consequent'])}",
                        f"{c['theoryA']}: {c['directionA']} [{c['boundaryA']}]",
                        f"{c['theoryB']}: {c['directionB']} [{c['boundaryB']}]",
                    ]
                    for c in report["conditional_disagreements"]
                ],
            )
        )
    else:
        lines.append("None.")
    lines += ["", "## Shape disagreements", ""]
    if report["shape_disagreements"]:
        lines.append(
            _md_table(
                ["Pair", "Theory A", "Theory B"],
                [
                    [
                        f"{short(c['antecedent'])} → {short(c['consequent'])}",
                        f"{c['theoryA']}: {c['directionA']}",
                        f"{c['theoryB']}: {c['directionB']}",
                    ]
                    for c in report["shape_disagreements"]
                ],
            )
        )
    else:
        lines.append("None.")
    lines += ["", "## Implied propositions", ""]
    lines.append(
        _md_table(
            ["Implied", "Direction", "Status", "Theories", "Premise pairs"],
            [
                [
                    f"{short(i['antecedent'])} → {short(i['consequent'])}",
                    i["direction"] + (" (disagreeing implications)" if i.get("implied_disagreement") else ""),
                    i["status"],
                    ", ".join(i["theories"]),
                    "; ".join(f"{short(a)} ∘ {short(b)}" for a, b in i["premises"]),
                ]
                for i in report["implied"]
            ],
        )
    )
    f = report["formalization"]
    lines += [
        "",
        "## Formalization pipeline",
        "",
        f"Providers: {', '.join(f['providers']) or 'none'}. Models: {', '.join(f['models']) or 'none'}.",
        "",
        _md_table(
            ["Paper", "Module", "Status", "Constructs", "Propositions", "Overlap warnings", "Errors"],
            [
                [
                    r["paper_id"],
                    r["module"],
                    r["status"],
                    r["counts"].get("constructs", 0),
                    r["counts"].get("propositions", 0),
                    r["overlap_warnings"],
                    r["errors"],
                ]
                for r in f["per_paper"]
            ],
        ),
        "",
        "### Formalization failures",
        "",
    ]
    if f["failures"]:
        for fail in f["failures"]:
            lines.append(f"- **{fail['paper_id']}** ({fail['status']}): {fail['reason']}")
            for e in fail["errors"]:
                lines.append(f"  - compiler: `{e}`")
            for a in fail["ambiguities"]:
                lines.append(f"  - model: {a}")
    else:
        lines.append("None.")
    lines.append("")
    return "\n".join(lines)


def _leaf_display(leaf: dict) -> str:
    base = short(leaf["prim"])
    args = [short(a) for a in leaf.get("args", [])]
    return " ".join([base, *args])


# --------------------------------------------------------------------------- #
# Driver
# --------------------------------------------------------------------------- #


def run_check(paths: Paths, build: bool = True) -> tuple[dict, LeanResult | None]:
    modules = generated_modules(paths)
    update_report_script(paths, modules)
    build_result: LeanResult | None = None
    if build:
        build_result = lake_build(paths.root)
        if not build_result.ok:
            raise RuntimeError("lake build failed:\n" + build_result.stdout[-4000:] + build_result.stderr[-2000:])
    paths.reports.mkdir(parents=True, exist_ok=True)
    result = lean_run_script(paths.root, paths.report_script)
    if not result.ok:
        raise RuntimeError("report script failed:\n" + result.stdout[-4000:] + result.stderr[-2000:])
    raw_path = paths.reports / "library_raw.json"
    with raw_path.open(encoding="utf-8") as fh:
        raw = json.load(fh)
    report = enrich(raw, load_paper_reports(paths), load_sources(paths))
    (paths.reports / "library.json").write_text(
        json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
    )
    (paths.reports / "library.md").write_text(render_markdown(report), encoding="utf-8")
    return report, build_result


def load_library(paths: Paths) -> dict:
    path = paths.reports / "library.json"
    if not path.exists():
        raise FileNotFoundError(f"{path} not found; run `lemma check` first")
    with path.open(encoding="utf-8") as fh:
        return json.load(fh)


def write_json(path: Path, data: dict) -> None:
    path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
