"""``lemma verify``: human verification of machine formalizations.

``lemma verify --sample N --seed S`` draws ``N`` items (constructs and
propositions) from the accepted generated modules and writes a review
sheet ``verification/sheet-<seed>.yaml`` with one entry per item and an
empty ``label`` field. A reviewer fills ``label`` with ``faithful``,
``unfaithful`` or ``unsure`` against the source paper, and ``notes``.

``lemma verify --precision`` reads every sheet under ``verification/``
and reports precision = faithful / (faithful + unfaithful) over labelled
items, with ``unsure`` excluded and reported separately. With no labels
the precision is reported as unavailable, never as a number.
"""

from __future__ import annotations

import random
import re
from dataclasses import dataclass, field
from pathlib import Path

import yaml

from .config import Paths

_DECL_RE = re.compile(
    r"(/--(?P<doc>.*?)-/\s*)?@\[(?P<attr>construct|proposition|aggregation|temporal)\]\s*"
    r"(?:structure|def)\s+(?P<name>[A-Za-z_][A-Za-z0-9_']*)",
    re.DOTALL,
)


@dataclass
class Item:
    module: str
    kind: str
    name: str
    doc: str
    source_file: str
    label: str = ""
    notes: str = ""

    def to_dict(self) -> dict:
        return self.__dict__.copy()


def extract_items(lean_source: str, module: str, source_file: str) -> list[Item]:
    items = []
    for m in _DECL_RE.finditer(lean_source):
        doc = " ".join((m.group("doc") or "").split())
        items.append(Item(module=module, kind=m.group("attr"), name=m.group("name"), doc=doc, source_file=source_file))
    return items


def sample_items(paths: Paths, n: int, seed: int) -> list[Item]:
    pool: list[Item] = []
    for path in sorted(paths.generated.glob("*.lean")):
        pool.extend(extract_items(path.read_text(encoding="utf-8"), path.stem, str(path.relative_to(paths.root))))
    rng = random.Random(seed)
    if n >= len(pool):
        return pool
    return rng.sample(pool, n)


def write_sheet(paths: Paths, items: list[Item], seed: int) -> Path:
    paths.verification.mkdir(parents=True, exist_ok=True)
    out = paths.verification / f"sheet-{seed}.yaml"
    payload = {
        "instructions": (
            "For each item, read the cited passage of the source paper and set label to "
            "'faithful' (the formal statement says what the paper says), 'unfaithful' "
            "(level, horizon, direction, fields or evidence kind misrepresent the paper) "
            "or 'unsure'. Add notes. Precision is computed by `lemma verify --precision`."
        ),
        "seed": seed,
        "items": [i.to_dict() for i in items],
    }
    out.write_text(yaml.safe_dump(payload, sort_keys=False, allow_unicode=True), encoding="utf-8")
    return out


@dataclass
class Precision:
    labelled: int = 0
    faithful: int = 0
    unfaithful: int = 0
    unsure: int = 0
    sheets: list[str] = field(default_factory=list)

    @property
    def precision(self) -> float | None:
        denom = self.faithful + self.unfaithful
        return None if denom == 0 else self.faithful / denom

    def to_dict(self) -> dict:
        return {
            "sheets": self.sheets,
            "labelled": self.labelled,
            "faithful": self.faithful,
            "unfaithful": self.unfaithful,
            "unsure": self.unsure,
            "precision": self.precision,
        }


def compute_precision(sheets: list[Path]) -> Precision:
    p = Precision()
    for sheet in sheets:
        with sheet.open(encoding="utf-8") as fh:
            data = yaml.safe_load(fh) or {}
        p.sheets.append(sheet.name)
        for item in data.get("items", []):
            label = str(item.get("label") or "").strip().lower()
            if not label:
                continue
            p.labelled += 1
            if label == "faithful":
                p.faithful += 1
            elif label == "unfaithful":
                p.unfaithful += 1
            else:
                p.unsure += 1
    return p


def all_sheets(paths: Paths) -> list[Path]:
    if not paths.verification.exists():
        return []
    return sorted(paths.verification.glob("sheet-*.yaml"))
