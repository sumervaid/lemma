"""``lemma formalize``: paper → Lemma module → compiler → per-paper report.

Steps
-----
1. Read the paper (``.txt`` directly, ``.pdf`` through ``pypdf`` when installed).
2. Ask a provider (model endpoint or fixture) for a module in Lemma syntax.
3. Write the candidate to ``Lemma/Generated/<PaperId>.lean`` and elaborate it
   with ``lake env lean --json`` against the built library.
4. Record the outcome in ``reports/papers/<paper>.json``:

   * ``accepted``: compiled; the module stays in ``Lemma/Generated`` and
     becomes part of the default build.
   * ``failed``: did not compile; the candidate is moved to
     ``reports/failed/<PaperId>.lean`` with the compiler's errors and the
     model's stated ambiguities, so that ``lake build`` stays green and the
     failure stays visible.
   * ``declined``: the provider returned no module, with its reason.

The compiler checks (reduction, overlap, scope, contradiction) run inside
Lean when the module elaborates; this module only reads the messages back.
"""

from __future__ import annotations

import json
import re
import shutil
from dataclasses import dataclass, field
from datetime import UTC, datetime
from pathlib import Path

from .config import Paths
from .lean import LeanMessage, lean_check_file
from .llm import Formalization, Provider

PROMPT_PATH = Path(__file__).parent / "prompts" / "formalize.md"

_ATTR_RE = {
    "constructs": re.compile(r"@\[construct\]"),
    "propositions": re.compile(r"@\[proposition\]"),
    "aggregations": re.compile(r"@\[aggregation\]"),
    "temporals": re.compile(r"@\[temporal\]"),
}


def paper_id_of(path: Path) -> str:
    """``bakker_demerouti_2007.txt`` → ``bakker_demerouti_2007``."""
    return path.stem


def module_name_of(paper_id: str) -> str:
    """``bakker_demerouti_2007`` → ``BakkerDemerouti2007`` (a valid Lean identifier)."""
    parts = re.split(r"[^A-Za-z0-9]+", paper_id)
    name = "".join(p[:1].upper() + p[1:] for p in parts if p)
    if not name or name[0].isdigit():
        name = "Paper" + name
    return name


def read_paper(path: Path) -> str:
    if path.suffix.lower() == ".pdf":
        try:
            from pypdf import PdfReader
        except ImportError as exc:  # pragma: no cover - optional dependency
            raise RuntimeError("install the 'pdf' extra (pypdf) to read PDF input") from exc
        reader = PdfReader(str(path))
        return "\n".join((page.extract_text() or "") for page in reader.pages)
    return path.read_text(encoding="utf-8")


def primitives_block(library_raw: dict | None) -> str:
    """Render the primitive vocabulary for the prompt from the raw Lean report."""
    if not library_raw:
        return "(see Lemma/Library/Primitives.lean)"
    lines = []
    for prim in library_raw.get("primitives", []):
        name = prim["name"].split(".")[-1]
        doc = " ".join(str(prim.get("doc", "")).split())
        lines.append(f"- `{name}`: {doc[:160]}")
    return "\n".join(lines)


def build_prompt(library_raw: dict | None) -> str:
    template = PROMPT_PATH.read_text(encoding="utf-8")
    return template.replace("{{PRIMITIVES}}", primitives_block(library_raw))


def count_attributes(lean_source: str) -> dict[str, int]:
    return {k: len(rx.findall(lean_source)) for k, rx in _ATTR_RE.items()}


@dataclass
class PaperReport:
    paper_id: str
    module: str
    status: str  # accepted | failed | declined
    provider: str
    model: str
    reason: str = ""
    ambiguities: list[str] = field(default_factory=list)
    counts: dict[str, int] = field(default_factory=dict)
    errors: list[dict] = field(default_factory=list)
    overlap_warnings: list[dict] = field(default_factory=list)
    contradiction_warnings: list[dict] = field(default_factory=list)
    routing_notes: list[dict] = field(default_factory=list)
    other_messages: list[dict] = field(default_factory=list)
    lean_path: str = ""
    repairs: int = 0
    generated_at: str = ""

    def to_dict(self) -> dict:
        return self.__dict__.copy()


def _classify(messages: list[LeanMessage], report: PaperReport) -> None:
    for m in messages:
        d = m.to_dict()
        if m.severity == "error":
            report.errors.append(d)
        elif m.is_overlap_warning():
            report.overlap_warnings.append(d)
        elif m.is_contradiction_warning():
            report.contradiction_warnings.append(d)
        elif m.is_routing_note():
            report.routing_notes.append(d)
        else:
            report.other_messages.append(d)


def _write_candidate(paths: Paths, module: str, lean: str) -> Path:
    paths.generated.mkdir(parents=True, exist_ok=True)
    target = paths.generated / f"{module}.lean"
    target.write_text(lean.rstrip() + "\n", encoding="utf-8")
    return target


def formalize_paper(
    paper: Path,
    provider: Provider,
    paths: Paths,
    library_raw: dict | None,
    max_repairs: int = 0,
) -> PaperReport:
    paper_id = paper_id_of(paper)
    module = module_name_of(paper_id)
    text = read_paper(paper)
    prompt = build_prompt(library_raw)
    result: Formalization = provider.formalize(paper_id, text, prompt)
    report = PaperReport(
        paper_id=paper_id,
        module=module,
        status="declined",
        provider=result.provider,
        model=result.model,
        reason=result.reason,
        ambiguities=list(result.ambiguities),
        generated_at=datetime.now(UTC).isoformat(timespec="seconds"),
    )
    if result.declined or result.lean is None:
        _save_report(paths, report)
        return report

    repairs = 0
    while True:
        candidate = _write_candidate(paths, module, result.lean)
        lean_result = lean_check_file(paths.root, candidate)
        report.counts = count_attributes(result.lean)
        report.errors, report.overlap_warnings = [], []
        report.contradiction_warnings, report.routing_notes, report.other_messages = [], [], []
        _classify(lean_result.messages, report)
        if lean_result.ok:
            report.status = "accepted"
            report.lean_path = str(candidate.relative_to(paths.root))
            break
        if lean_result.returncode != 0 and not lean_result.errors:
            report.errors.append({"severity": "error", "line": 0, "column": 0, "message": lean_result.stderr.strip()})
        if repairs < max_repairs:
            repaired = provider.repair(paper_id, result, [e["message"] for e in report.errors], prompt)
            if repaired is not None and repaired.lean is not None and not repaired.declined:
                repairs += 1
                result = repaired
                report.ambiguities = list(repaired.ambiguities)
                continue
        # Failure: keep the candidate out of the default build, but keep it visible.
        failed_dir = paths.reports / "failed"
        failed_dir.mkdir(parents=True, exist_ok=True)
        dest = failed_dir / f"{module}.lean"
        shutil.move(str(candidate), str(dest))
        report.status = "failed"
        report.lean_path = str(dest.relative_to(paths.root))
        break
    report.repairs = repairs
    _save_report(paths, report)
    return report


def _save_report(paths: Paths, report: PaperReport) -> Path:
    out_dir = paths.reports / "papers"
    out_dir.mkdir(parents=True, exist_ok=True)
    out = out_dir / f"{report.paper_id}.json"
    out.write_text(json.dumps(report.to_dict(), indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    return out


def load_paper_reports(paths: Paths) -> list[dict]:
    out_dir = paths.reports / "papers"
    if not out_dir.exists():
        return []
    reports = []
    for p in sorted(out_dir.glob("*.json")):
        with p.open(encoding="utf-8") as fh:
            reports.append(json.load(fh))
    return reports
