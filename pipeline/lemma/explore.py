"""Plain-language views of the compiled library.

Everything here reads the checked-in reports, so these views work without
Lean. The overlap logic restates the key from ``Lemma/Meta/Overlap.lean``.
``tests/test_explore.py`` holds the restatement to the compiler's own output.
"""

from __future__ import annotations

import json
import re
from dataclasses import dataclass
from pathlib import Path

import yaml

from .config import Paths

PART_TEMPLATES = {
    "Energy": ("En", "Energy"),
    "Attention": ("At", "Attention to {}"),
    "Identification": ("Id", "Identification with {}"),
    "Demand": ("De", "{} demand"),
    "Resource": ("Re", "{} resource"),
    "Change": ("Ch", "Change in {} resource"),
    "Affect": ("Af", "{} affect with {} activation"),
    "Learning": ("Le", "Learning"),
    "Efficacy": ("Ef", "Efficacy for {}"),
    "Motivation": ("Mo", "{} motivation"),
    "Skill": ("Sk", "Skill"),
    "Symptom": ("Sy", "{} symptoms"),
    "Performance": ("Pe", "{} performance"),
    "Intention": ("In", "{} intention"),
    "Trust": ("Tu", "Trust in {}"),
    "Expectancy": ("Ex", "{} expectancy"),
    "Behavior": ("Be", "{} behavior"),
    "Trait": ("Tr", "{}"),
}

KIND_MEANING = {
    "identity": "The two constructs are built from exactly the same parts at the same scope.",
    "subtype": "Every part of one construct also belongs to the other.",
    "partial": "The two constructs share some parts while each keeps parts of its own.",
    "none": "The two constructs share no part at the same scope.",
}

PIPELINE_LABEL = "pipeline fixture"
CURATED_LABEL = "curated"


def tail(name: str) -> str:
    return name.rsplit(".", 1)[-1]


def theory_name(name: str) -> str:
    """``Lemma.Theories.JDR.JobDemands`` becomes ``JDR.JobDemands``."""
    return ".".join(name.split(".")[-2:])


def words(identifier: str) -> str:
    return re.sub(r"(?<=[a-z])(?=[A-Z])", " ", identifier)


def sentence_case(text: str) -> str:
    return text[:1].upper() + text[1:]


def part_name(leaf: dict) -> str:
    """``Attention Work``: the part as the compiler prints the part."""
    return " ".join([tail(leaf["prim"]), *[tail(a) for a in leaf["args"]]])


def part_label(prim: str, args: list[str]) -> str:
    _, template = PART_TEMPLATES.get(prim, (prim[:2], " ".join(["{}"] * max(len(args), 1))))
    if not args:
        return template if "{}" not in template else prim
    filled = template.format(*[words(a).lower() for a in args])
    return sentence_case(filled)


def part_key(leaf: dict) -> tuple:
    """The overlap key from ``Lemma/Meta/Overlap.lean``: primitive, arguments, level, horizon."""
    return (leaf["prim"], tuple(leaf["args"]), leaf["level"], leaf["horizon"])


def overlap_kind(keys_a: set, keys_b: set) -> str:
    if not keys_a & keys_b:
        return "none"
    if keys_a == keys_b:
        return "identity"
    if keys_a < keys_b or keys_b < keys_a:
        return "subtype"
    return "partial"


def provenance(module: str) -> str:
    return PIPELINE_LABEL if module.startswith("Lemma.Generated") else CURATED_LABEL


def _plain_scope(level: str, horizon: str) -> str:
    return f"{level} / {horizon}"


class AmbiguousNameError(LookupError):
    def __init__(self, query: str, options: list[str]):
        super().__init__(query)
        self.query = query
        self.options = options


class UnknownNameError(LookupError):
    def __init__(self, query: str, suggestions: list[str]):
        super().__init__(query)
        self.query = query
        self.suggestions = suggestions


@dataclass
class Comparison:
    a: dict
    b: dict
    kind: str
    shared: list[str]
    only_a: list[str]
    only_b: list[str]
    scope_shifts: list[str]
    declaration: dict | None
    claims: list[dict]
    correlation: dict | None


class Library:
    def __init__(self, paths: Paths):
        self.paths = paths
        self.report = _read_json(paths.reports / "library.json")
        self.agenda = _read_json(paths.reports / "agenda.json")
        self.distinctness = _read_json(paths.reports / "distinctness.json")
        self.constructs = self.report["constructs"]
        self.propositions = self.report["propositions"]
        self.by_name = {c["name"]: c for c in self.constructs}
        self.keys = {c["name"]: {part_key(leaf) for leaf in c["leaves"]} for c in self.constructs}

    def resolve(self, query: str) -> dict:
        """Find a construct by ``Theory.Name`` or ``Name``. A lone curated match wins over fixture copies."""
        wanted = query.strip().lower().replace(" ", "")
        exact = [c for c in self.constructs if theory_name(c["name"]).lower() == wanted or c["name"].lower() == wanted]
        if len(exact) == 1:
            return exact[0]
        matches = [c for c in self.constructs if tail(c["name"]).lower() == wanted]
        if len(matches) == 1:
            return matches[0]
        curated = [c for c in matches if provenance(c["module"]) == CURATED_LABEL]
        if len(curated) == 1:
            return curated[0]
        if matches:
            raise AmbiguousNameError(query, [theory_name(c["name"]) for c in matches])
        raise UnknownNameError(query, [theory_name(c["name"]) for c in self.find_constructs(query)[:5]])

    def find_constructs(self, query: str) -> list[dict]:
        terms = query.lower().split()
        scored = []
        for c in self.constructs:
            name = theory_name(c["name"]).lower()
            parts = " ".join(part_name(leaf).lower() for leaf in c["leaves"])
            doc = c.get("doc", "").lower()
            hay = f"{name} {parts} {doc}"
            if not all(t in hay for t in terms):
                continue
            score = sum(4 if t in name else 2 if t in parts else 1 for t in terms)
            scored.append((-score, name, c))
        return [c for _, _, c in sorted(scored, key=lambda row: row[:2])]

    def find_claims(self, query: str) -> list[dict]:
        terms = query.lower().split()
        out = []
        for p in self.propositions:
            hay = " ".join([p["name"], p["antecedent"], p["consequent"], p.get("doc", ""), p.get("citation", "")])
            if all(t in hay.lower() for t in terms):
                out.append(p)
        return out

    def find_parts(self, query: str) -> list[dict]:
        terms = query.lower().split()
        return [
            p
            for p in self.report["primitives"]
            if all(t in f"{tail(p['name'])} {p.get('doc', '')}".lower() for t in terms)
        ]

    def declaration(self, a: str, b: str) -> dict | None:
        for d in self.report["overlap_declarations"]:
            if {d["a"], d["b"]} == {a, b}:
                return d
        return None

    def claims_about(self, name: str) -> list[dict]:
        return [p for p in self.propositions if name in (p["antecedent"], p["consequent"])]

    def overlaps_of(self, name: str) -> list[dict]:
        return [o for o in self.report["overlaps"] if name in (o["a"], o["b"])]

    def compare(self, a: dict, b: dict) -> Comparison:
        keys_a, keys_b = self.keys[a["name"]], self.keys[b["name"]]
        labels = {
            part_key(leaf): part_label(tail(leaf["prim"]), [tail(x) for x in leaf["args"]])
            for leaf in [*a["leaves"], *b["leaves"]]
        }
        prims_a = {(k[0], k[1]): k for k in keys_a}
        shifts = sorted(
            labels[k] + f": {_plain_scope(prims_a[(k[0], k[1])][2], prims_a[(k[0], k[1])][3])} against {k[2]} / {k[3]}"
            for k in keys_b
            if (k[0], k[1]) in prims_a and k not in keys_a
        )
        correlation = None
        wanted = {tail(a["name"]), tail(b["name"])}
        for row in self.distinctness.get("rows", []):
            if {row["a"], row["b"]} == wanted:
                correlation = row
        return Comparison(
            a=a,
            b=b,
            kind=overlap_kind(keys_a, keys_b),
            shared=sorted(labels[k] for k in keys_a & keys_b),
            only_a=sorted(labels[k] for k in keys_a - keys_b),
            only_b=sorted(labels[k] for k in keys_b - keys_a),
            scope_shifts=shifts,
            declaration=self.declaration(a["name"], b["name"]),
            claims=[p for p in self.propositions if {p["antecedent"], p["consequent"]} == {a["name"], b["name"]}],
            correlation=correlation,
        )


def _read_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def clean_doc(doc: str) -> str:
    return " ".join((doc or "").split())


def load_curation(paths: Paths) -> dict:
    with (paths.config / "curation.yaml").open(encoding="utf-8") as fh:
        return yaml.safe_load(fh)


def fill_counts(text: str, report: dict) -> str:
    """Curated copy states counts through placeholders, so every count stays generated."""
    return text.format(**report["summary"], papers_pipeline_total=report["formalization"]["papers"])


def describe_construct(lib: Library, c: dict) -> str:
    lines = [
        theory_name(c["name"]),
        f"  Source of entry   {provenance(c['module'])}",
        f"  Scope             {_plain_scope(c['level'], c['horizon'])}",
        "",
        "  Definition",
        f"    {clean_doc(c.get('doc', ''))}",
        "",
        "  Built from",
    ]
    for leaf in c["leaves"]:
        lines.append(f"    {part_label(tail(leaf['prim']), [tail(a) for a in leaf['args']])}")
    overlaps = lib.overlaps_of(c["name"])
    if overlaps:
        lines += ["", f"  Shares parts with {len(overlaps)} other constructs"]
        for o in overlaps[:12]:
            other = o["b"] if o["a"] == c["name"] else o["a"]
            declared = "declared " + o["declared"]["kind"] if o.get("declared") else "undeclared"
            lines.append(f"    {theory_name(other):38s} {o['kind']:9s} {declared}")
        if len(overlaps) > 12:
            lines.append(f"    plus {len(overlaps) - 12} more")
    claims = lib.claims_about(c["name"])
    if claims:
        lines += ["", f"  Appears in {len(claims)} claims"]
        for p in claims[:12]:
            lines.append(f"    {format_claim(p)}")
        if len(claims) > 12:
            lines.append(f"    plus {len(claims) - 12} more")
    return "\n".join(lines)


def format_claim(p: dict) -> str:
    return (
        f"{tail(p['antecedent'])} → {tail(p['consequent'])}: {p['direction']}, "
        f"{p['evidence']} evidence, stated in {p['theory']}"
    )


def describe_comparison(cmp: Comparison) -> str:
    a, b = theory_name(cmp.a["name"]), theory_name(cmp.b["name"])
    lines = [f"{a} compared with {b}", f"  Result  {cmp.kind}. {KIND_MEANING[cmp.kind]}"]
    for title, items in (
        ("Shared parts", cmp.shared),
        (f"Only in {a}", cmp.only_a),
        (f"Only in {b}", cmp.only_b),
        ("Same part at a different scope", cmp.scope_shifts),
    ):
        if items:
            lines += ["", f"  {title}", *[f"    {i}" for i in items]]
    if cmp.declaration:
        lines += ["", "  Recorded decision", f"    {cmp.declaration['kind']}: {clean_doc(cmp.declaration['reason'])}"]
    if cmp.claims:
        lines += ["", "  Claims linking the pair", *[f"    {format_claim(p)}" for p in cmp.claims]]
    if cmp.correlation:
        row = cmp.correlation
        lines += [
            "",
            f"  Correlation on file  {row['rho']}",
            f"    Status {row['status']}. Placeholder and recalled values await a check against the source.",
        ]
    return "\n".join(lines)
