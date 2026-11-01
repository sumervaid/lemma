"""``lemma distinct``: definitional versus empirical distinctness.

Definitional distinctness is what the compiler decides: two constructs are
*identical* when they reduce to the same primitives at the same scope,
*nested* when one's primitives are a subset of the other's, *overlapping*
when they share some, and *disjoint* otherwise.

Empirical distinctness is estimated from reliability-corrected correlations
(metaBUS-style). This stub reads a CSV with columns

    construct_a, construct_b, rho, k, n, source, status, note

where ``rho`` is the corrected correlation, ``k`` the number of samples,
``n`` the total sample size, and ``status`` one of ``cited`` (checked
against the source), ``recalled`` (entered from memory, to be checked) or
``placeholder`` (illustrative). Pairs with ``|rho| >= threshold`` are
*empirically indistinguishable* (Le, Schmidt, Harter & Lauver 2010 argue
corrected correlations near .90 signal redundancy; the default threshold
of .80 is deliberately conservative and configurable).

The product is the four-way table the proposal describes, with the
"definitionally distinct yet empirically indistinguishable" cell marked.
"""

from __future__ import annotations

import csv
from dataclasses import dataclass
from pathlib import Path

from .check import short

DEFAULT_THRESHOLD = 0.80


@dataclass
class DistinctRow:
    a: str
    b: str
    rho: float | None
    k: int | None
    n: int | None
    source: str
    status: str
    note: str
    definitional: str  # identical | nested | overlapping | disjoint | unknown
    declaration: str  # distinct_from | alias_of | subtype_of | none | n/a
    empirical: str  # indistinguishable | distinct | unknown
    label: str

    def to_dict(self) -> dict:
        return self.__dict__.copy()


def _find_construct(report: dict, name: str) -> dict | None:
    for c in report["constructs"]:
        if short(c["name"]) == name or c["name"] == name:
            return c
    return None


def _definitional(report: dict, a: dict, b: dict) -> tuple[str, str]:
    if a["name"] == b["name"]:
        return "identical", "n/a"
    for o in report["overlaps"]:
        if {o["a"], o["b"]} == {a["name"], b["name"]}:
            kind = {"identity": "identical", "subtype": "nested", "partial": "overlapping"}[o["kind"]]
            decl = o["declared"]["kind"] if o.get("declared") else "none"
            return kind, decl
    # Components declared in the definition are composition, not overlap.
    if b["name"] in a.get("components", []) or a["name"] in b.get("components", []):
        return "nested", "composition"
    return "disjoint", "n/a"


def classify(report: dict, rows: list[dict], threshold: float = DEFAULT_THRESHOLD) -> list[DistinctRow]:
    out = []
    for r in rows:
        a = _find_construct(report, r["construct_a"])
        b = _find_construct(report, r["construct_b"])
        rho = float(r["rho"]) if r.get("rho") not in (None, "") else None
        k = int(r["k"]) if r.get("k") not in (None, "") else None
        n = int(r["n"]) if r.get("n") not in (None, "") else None
        if a is None or b is None:
            definitional, decl = "unknown", "n/a"
        else:
            definitional, decl = _definitional(report, a, b)
        if rho is None:
            empirical = "unknown"
        elif abs(rho) >= threshold:
            empirical = "indistinguishable"
        else:
            empirical = "distinct"
        label = _label(definitional, decl, empirical)
        out.append(
            DistinctRow(
                a=r["construct_a"],
                b=r["construct_b"],
                rho=rho,
                k=k,
                n=n,
                source=r.get("source", ""),
                status=r.get("status", "placeholder"),
                note=r.get("note", ""),
                definitional=definitional,
                declaration=decl,
                empirical=empirical,
                label=label,
            )
        )
    return out


def _label(definitional: str, decl: str, empirical: str) -> str:
    """Four-way label from the compiler's decision and the correlation.

    Definitional distinctness is the compiler's: anything other than
    ``identical`` is definitionally distinct. The scholar's declaration is
    reported alongside but does not change the label, so that a declared
    ``distinct_from`` on an identical pair stays visible as a vocabulary
    question rather than disappearing into the declaration.
    """
    if definitional == "unknown" or empirical == "unknown":
        return "insufficient data"
    def_distinct = definitional != "identical"
    if def_distinct and empirical == "indistinguishable":
        return "definitionally distinct, empirically indistinguishable"
    if def_distinct and empirical == "distinct":
        return "distinct on both counts"
    if not def_distinct and empirical == "indistinguishable":
        return "identical on both counts"
    return "definitionally identical, empirically distinct"


def read_csv(path: Path) -> list[dict]:
    with path.open(encoding="utf-8", newline="") as fh:
        return [row for row in csv.DictReader(fh) if row.get("construct_a")]


def render(rows: list[DistinctRow], threshold: float) -> str:
    lines = [
        "# Definitional versus empirical distinctness",
        "",
        f"Threshold for empirical indistinguishability: |ρ| ≥ {threshold:.2f} (reliability-corrected).",
        "",
        "Row status: `cited` = checked against the source; `recalled` = entered from memory, "
        "to be checked before use; `placeholder` = illustrative value. "
        "No row in the pilot fixture has been checked against metaBUS; see fixture provenance "
        "in the technical appendix.",
        "",
        "| A | B | ρ | k | N | Definitional | Declaration | Empirical | Label | Status | Source |",
        "|---|---|---|---|---|---|---|---|---|---|---|",
    ]
    for r in rows:
        rho = "" if r.rho is None else f"{r.rho:.2f}"
        lines.append(
            f"| {r.a} | {r.b} | {rho} | {r.k or ''} | {r.n or ''} | {r.definitional} | {r.declaration} | "
            f"{r.empirical} | {r.label} | {r.status} | {r.source} |"
        )
    lines.append("")
    return "\n".join(lines)
