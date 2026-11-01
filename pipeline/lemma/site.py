"""``lemma site``: build the Explorer, one self-contained page generated from the reports."""

from __future__ import annotations

import json
from pathlib import Path

from .check import generated_modules
from .config import Paths
from .draft import CATEGORIES, HORIZONS, LEVELS, parse_catalog
from .explore import (
    PART_TEMPLATES,
    Library,
    clean_doc,
    fill_counts,
    load_curation,
    part_label,
    part_name,
    provenance,
    tail,
    theory_name,
)

ASSETS = Path(__file__).parent / "site_assets"
REPOSITORY = "https://github.com/sumervaid/lemma"


def _source_url(module: str) -> str:
    return f"{REPOSITORY}/blob/main/{module.replace('.', '/')}.lean"


def _boundary(b: dict) -> str:
    if b.get("kind") == "moderator":
        return f"{b['effect']} by {tail(b['construct'])}"
    if b.get("kind") == "scope":
        return b.get("description", "")
    return ""


def build_data(paths: Paths) -> dict:
    lib = Library(paths)
    report = lib.report
    curation = load_curation(paths)
    catalog = parse_catalog((paths.root / "Lemma" / "Library" / "Primitives.lean").read_text(encoding="utf-8"))
    docs = {tail(p["name"]): clean_doc(p.get("doc", "")) for p in report["primitives"]}

    uses: dict[str, int] = {}
    constructs = []
    for c in lib.constructs:
        parts = []
        seen = set()
        for leaf in c["leaves"]:
            name = part_name(leaf)
            key = f"{name}|{leaf['level']}|{leaf['horizon']}"
            if key in seen:
                continue
            seen.add(key)
            prim = tail(leaf["prim"])
            args = [tail(a) for a in leaf["args"]]
            parts.append(
                {
                    "key": key,
                    "part": name,
                    "prim": prim,
                    "label": part_label(prim, args),
                    "sym": PART_TEMPLATES[prim][0],
                }
            )
        for prim in {p["prim"] for p in parts}:
            uses[prim] = uses.get(prim, 0) + 1
        constructs.append(
            {
                "id": theory_name(c["name"]),
                "short": tail(c["name"]),
                "theory": c["theory"],
                "origin": provenance(c["module"]),
                "level": c["level"],
                "horizon": c["horizon"],
                "doc": clean_doc(c.get("doc", "")),
                "source": _source_url(c["module"]),
                "parts": parts,
                "components": [theory_name(x) for x in c.get("components", [])],
            }
        )

    propositions = [
        {
            "id": theory_name(p["name"]),
            "a": theory_name(p["antecedent"]),
            "b": theory_name(p["consequent"]),
            "direction": p["direction"],
            "scope": f"{p['level']} / {p['horizon']}",
            "evidence": p["evidence"],
            "theory": p["theory"],
            "origin": provenance(p["module"]),
            "citation": p.get("citation", ""),
            "doc": clean_doc(p.get("doc", "")),
            "boundary": _boundary(p.get("boundary", {})),
        }
        for p in lib.propositions
    ]
    overlaps = [
        {
            "a": theory_name(o["a"]),
            "b": theory_name(o["b"]),
            "kind": o["kind"],
            "declared": (
                {"kind": o["declared"]["kind"], "reason": clean_doc(o["declared"]["reason"])}
                if o.get("declared")
                else None
            ),
        }
        for o in report["overlaps"]
    ]
    declarations = [
        {"a": theory_name(d["a"]), "b": theory_name(d["b"]), "kind": d["kind"], "reason": clean_doc(d["reason"])}
        for d in report["overlap_declarations"]
    ]
    agenda = [
        {
            "kind": i["kind"],
            "a": i["antecedent"],
            "b": i["consequent"],
            "direction": i["direction"],
            "scope": f"{i['level']} / {i['horizon']}",
            "theories": i["theories"],
            "evidence": i["evidence"],
            "score": round(i["score"], 3),
            "why": i["rationale"],
        }
        for i in lib.agenda["items"]
    ]

    def pair(row: dict) -> dict:
        return {**row, "antecedent": theory_name(row["antecedent"]), "consequent": theory_name(row["consequent"])}

    implied_conflicts = [
        {
            "a": theory_name(i["antecedent"]),
            "b": theory_name(i["consequent"]),
            "direction": i["direction"],
            "registered": theory_name(i["registered"]) if i.get("registered") else "",
            "theories": i["theories"],
            "scope": f"{i['level']} / {i['horizon']}",
        }
        for i in report["implied"]
        if i["status"] == "contradicted"
    ]
    failures = [
        {
            "paper": f["paper_id"],
            "status": f["status"],
            "reason": clean_doc(f.get("reason", "")),
            "notes": [clean_doc(x) for x in f.get("ambiguities", [])],
            "errors": [clean_doc(x if isinstance(x, str) else x.get("message", "")) for x in f.get("errors", [])],
        }
        for f in report["formalization"]["failures"]
    ]
    catalog_out = [
        {
            **entry,
            "sym": PART_TEMPLATES[entry["prim"]][0],
            "doc": docs.get(entry["prim"], ""),
            "uses": uses.get(entry["prim"], 0),
        }
        for entry in catalog
    ]
    findings = [
        {**f, "title": fill_counts(f["title"], report), "body": fill_counts(f["body"], report)}
        for f in curation["findings"]
    ]
    return {
        "generatedAt": report["generated_at"],
        "repository": REPOSITORY,
        "summary": report["summary"],
        "status": fill_counts(curation["status"], report),
        "findings": findings,
        "collections": curation["collections"],
        "catalog": catalog_out,
        "constructs": constructs,
        "propositions": propositions,
        "overlaps": overlaps,
        "declarations": declarations,
        "contradictions": [pair(x) for x in report["contradictions"]],
        "conditional": [pair(x) for x in report["conditional_disagreements"]],
        "shape": [pair(x) for x in report["shape_disagreements"]],
        "convergences": [pair(x) for x in report["convergences"]],
        "impliedConflicts": implied_conflicts,
        "failures": failures,
        "agenda": agenda,
        "correlations": lib.distinctness.get("rows", []),
        "sources": report["sources"],
        "levels": LEVELS,
        "horizons": HORIZONS,
        "categories": CATEGORIES,
        "generated": generated_modules(paths),
    }


def _asset(name: str) -> str:
    return (ASSETS / name).read_text(encoding="utf-8")


def render_page(data: dict, fragment: bool = False) -> str:
    """``fragment`` omits the document shell, for hosts which supply their own."""
    payload = json.dumps(data, ensure_ascii=False, separators=(",", ":")).replace("<", "\\u003c")
    head = _asset("head.html").replace("/*STYLES*/", _asset("styles.css"))
    body = (
        _asset("body.html")
        .replace("/*DATA*/", payload)
        .replace("/*OVERLAP*/", _asset("overlap.js"))
        .replace("/*APP*/", _asset("app.js"))
    )
    if fragment:
        return f"{head}\n{body}\n"
    return f'<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n{head}\n</head>\n<body>\n{body}\n</body>\n</html>\n'


def build_site(paths: Paths, out: Path, fragment: bool = False) -> Path:
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(render_page(build_data(paths), fragment=fragment), encoding="utf-8")
    return out
