"""Write a new construct from plain answers, submit the draft, explain the compiler's reply."""

from __future__ import annotations

import re
from dataclasses import dataclass
from pathlib import Path

from .config import Paths
from .lean import LeanMessage, lake_build, lean_check_file

LEVELS = ["Individual", "Dyad", "Team", "Unit", "Organization"]
HORIZONS = ["Momentary", "Daily", "Weekly", "Monthly", "Annual", "Static"]
CATEGORIES = {
    "AffectiveState": "An affective or affective-cognitive state",
    "JobCharacteristic": "A characteristic of a job or work context",
    "Disposition": "A relatively stable disposition",
    "WorkBehavior": "A behavior or behavioral intention",
    "Outcome": "A health or performance outcome",
    "ResourceDynamic": "A change in resources over the horizon",
}


OVERLAP_WORD = {"identity": "identical", "subtype": "nested", "partial": "partial"}


def parse_catalog(primitives_source: str) -> list[dict]:
    """Read the vocabulary from ``Primitives.lean``, the one source of truth for parts."""
    enums = {
        m.group(1): re.findall(r"\|\s*(\w+)", m.group(2))
        for m in re.finditer(r"inductive (\w+)\n((?:\s*\|\s*\w+\n)+)", primitives_source)
    }
    catalog = []
    for m in re.finditer(r"@\[primitive\] structure (\w+)((?: \(\w+ : \w+\))*) extends Primitive", primitives_source):
        params = [{"name": n, "type": t, "values": enums[t]} for n, t in re.findall(r"\((\w+) : (\w+)\)", m.group(2))]
        catalog.append({"prim": m.group(1), "params": params})
    return catalog


def all_parts(catalog: list[dict]) -> list[str]:
    parts: list[str] = []
    for entry in catalog:
        combos = [[]]
        for param in entry["params"]:
            combos = [[*c, v] for c in combos for v in param["values"]]
        parts += [" ".join([entry["prim"], *c]) for c in combos]
    return parts


def to_identifier(text: str) -> str:
    """Turn ``work vitality`` into ``WorkVitality``, the form Lean expects for a construct name."""
    pieces = re.findall(r"[A-Za-z0-9]+", text)
    name = "".join(p[0].upper() + p[1:] for p in pieces)
    if not name or not name[0].isalpha():
        raise ValueError("A construct name needs at least one word starting with a letter.")
    return name


def field_name(part: str) -> str:
    pieces = part.split()
    return pieces[0][0].lower() + pieces[0][1:] + "".join(pieces[1:])


def lean_type(part: str) -> str:
    pieces = part.split()
    return " ".join([f"Lemma.{pieces[0]}", *[f".{a}" for a in pieces[1:]]])


def docstring(definition: str, citation: str) -> str:
    text = " ".join(f"{definition.strip().rstrip('.')} ({citation.strip() or 'citation to add'}).".split())
    return text.replace("-/", "- /").replace("/-", "/ -")


def render_lean(
    name: str,
    definition: str,
    citation: str,
    category: str,
    level: str,
    horizon: str,
    parts: list[str],
    generated: list[str],
) -> str:
    """Keep in step with ``renderLean`` in ``site_assets/overlap.js``. A test compares the two."""
    imports = ["import Lemma", *[f"import Lemma.Generated.{m}" for m in generated]]
    fields = [f"  {field_name(p)} : {lean_type(p)}" for p in parts]
    return "\n".join(
        [
            *imports,
            "",
            f"namespace Lemma.Drafts.{name}",
            "",
            f"/-- {docstring(definition, citation)} -/",
            f"@[construct] structure {name} extends {category} (level := .{level}) (horizon := .{horizon}) where",
            *fields,
            "",
            f"end Lemma.Drafts.{name}",
            "",
        ]
    )


@dataclass
class Explained:
    tone: str  # "problem" | "attention" | "note"
    headline: str
    detail: str
    raw: str
    line: int


def explain(message: LeanMessage) -> Explained:
    first = message.first_line
    detail_lines = [ln.strip() for ln in message.data.splitlines()[1:]]
    tone = {"error": "problem", "warning": "attention"}.get(message.severity, "note")
    m = re.match(r"shares primitives? (.+?) with (\S+)", first)
    if m:
        kind = next((ln.split(":", 1)[1].split()[0] for ln in detail_lines if ln.startswith("overlap kind:")), "")
        return Explained(
            tone,
            f"Shares {m.group(1)} with {m.group(2).rsplit('.', 1)[0]}",
            f"Overlap {OVERLAP_WORD.get(kind, kind)}. Record a decision with declare_overlap, naming the source of the distinction.",
            message.data,
            message.line,
        )
    m = re.match(r"construct `(.+)` does not reduce to primitives", first)
    if m:
        return Explained(
            tone,
            f"{m.group(1)} uses something outside the vocabulary",
            "Every field must be a registered part. Run lemma find to see the parts on offer.",
            message.data,
            message.line,
        )
    if "requires a citation docstring" in first:
        return Explained(
            tone, "A citation is missing", "Add a definition with author, year, page.", message.data, message.line
        )
    m = re.match(r"scope mismatch in `(.+?)`: (.*)", first)
    if m:
        return Explained(tone, f"The scope of {m.group(1)} does not line up", m.group(2), message.data, message.line)
    if first.startswith("contradicts "):
        return Explained(tone, "This claim disagrees with another theory", first, message.data, message.line)
    if first.startswith("shape disagreement"):
        return Explained(tone, "This claim differs in shape from another theory", first, message.data, message.line)
    if " is routed through " in first:
        return Explained(tone, "The claim connects through a registered rule", first, message.data, message.line)
    return Explained(tone, "Compiler message", first, message.data, message.line)


def library_built(root: Path) -> bool:
    return (root / ".lake" / "build" / "lib" / "Lemma.olean").exists()


def submit(paths: Paths, file: Path) -> tuple[bool, list[Explained]]:
    if not library_built(paths.root):
        print("Building the library for the first time. This takes a minute or two.")
        built = lake_build(paths.root)
        if not built.ok:
            raise RuntimeError(built.stdout[-2000:] or built.stderr[-2000:])
    result = lean_check_file(paths.root, file.resolve())
    return result.ok, [explain(m) for m in result.messages]
