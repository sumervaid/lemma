"""``lemma score``: rank typed propositions by how badly they need verification.

The score of a proposition ``p`` is

    score(p) = w_e * E(p) + w_s * S(p) + w_g * G(p) + w_i * I(p)

* ``E(p)``, evidence weakness, maps the strongest evidence kind attached to
  any comparable proposition (same pair, scope, boundary and direction) to
  ``[0, 1]`` through ``evidence_weakness`` in ``config/scoring.yaml``.
  A claim backed by a meta-analysis in one theory is not thin because a
  second theory restates it with a cross-sectional citation.
* ``S(p)``, structural load, is ``min(1, (T + D) / saturation)`` where ``T``
  is the number of theories asserting the claim and ``D`` the number of
  implied propositions that use ``p`` as a premise.
* ``G(p)``, disagreement, is the strongest disagreement ``p`` takes part in:
  a contradiction, an implied contradiction, a conditional disagreement, or
  a shape disagreement.
* ``I(p)`` is 1 for an implied-but-untested candidate and 0 otherwise.

Implied candidates are scored alongside registered propositions, with
``E = 1`` (no evidence), ``T`` the theories whose propositions compose into
the candidate, ``D = 0`` and ``G`` from implied disagreements.

All weights and tables live in ``config/scoring.yaml``; the function is
deterministic and unit-tested in ``pipeline/tests/test_score.py``.
"""

from __future__ import annotations

from collections import defaultdict
from dataclasses import dataclass, field
from pathlib import Path

import yaml

from .check import _boundary_key, qualified, short

DEFAULT_CONFIG = {
    "version": 1,
    "weights": {"evidence": 0.40, "structure": 0.25, "disagreement": 0.25, "implied": 0.10},
    "evidence_weakness": {
        "None": 1.0,
        "Simulation": 0.9,
        "CrossSectional": 0.7,
        "Longitudinal": 0.4,
        "Experimental": 0.2,
        "MetaAnalytic": 0.1,
    },
    "disagreement": {
        "contradiction": 1.0,
        "implied_contradiction": 0.8,
        "conditional": 0.6,
        "shape": 0.5,
        "none": 0.0,
    },
    "structure_saturation": 8,
    "agenda_size": 25,
}


def load_scoring_config(path: Path | None) -> dict:
    if path is None or not path.exists():
        return DEFAULT_CONFIG
    with path.open(encoding="utf-8") as fh:
        cfg = yaml.safe_load(fh) or {}
    merged = {**DEFAULT_CONFIG, **cfg}
    for key in ("weights", "evidence_weakness", "disagreement"):
        merged[key] = {**DEFAULT_CONFIG[key], **cfg.get(key, {})}
    return merged


@dataclass
class ScoredItem:
    name: str
    kind: str  # "registered" | "implied"
    antecedent: str
    consequent: str
    direction: str
    level: str
    horizon: str
    boundary: str
    theories: list[str]
    evidence: str
    evidence_weakness: float
    structure: float
    disagreement: float
    disagreement_kind: str
    implied_untested: float
    score: float
    rationale: list[str] = field(default_factory=list)
    members: list[str] = field(default_factory=list)

    def to_dict(self) -> dict:
        return self.__dict__.copy()


def _claim_key(p: dict) -> tuple:
    return (p["antecedent"], p["consequent"], p["level"], p["horizon"], _boundary_key(p["boundary"]), p["direction"])


def score_library(report: dict, cfg: dict) -> list[ScoredItem]:
    w = cfg["weights"]
    ew = cfg["evidence_weakness"]
    gw = cfg["disagreement"]
    sat = float(cfg["structure_saturation"])

    props: list[dict] = report["propositions"]
    implied: list[dict] = report.get("implied", [])

    # Theories asserting each claim, strongest evidence per claim.
    claim_theories: dict[tuple, set[str]] = defaultdict(set)
    claim_best_evidence: dict[tuple, float] = {}
    for p in props:
        k = _claim_key(p)
        claim_theories[k].add(p["theory"])
        weakness = float(ew.get(p["evidence"], 1.0))
        claim_best_evidence[k] = min(claim_best_evidence.get(k, 1.0), weakness)

    # Dependents: implied propositions using p as a premise.
    dependents: dict[str, int] = defaultdict(int)
    for imp in implied:
        for a, b in imp.get("premises", []):
            dependents[a] += 1
            dependents[b] += 1

    # Disagreement participation.
    disagreement_of: dict[str, tuple[float, str]] = {}

    def mark(name: str, kind: str) -> None:
        value = float(gw.get(kind, 0.0))
        if value > disagreement_of.get(name, (0.0, "none"))[0]:
            disagreement_of[name] = (value, kind)

    for c in report.get("contradictions", []):
        if c["theoryA"] != c["theoryB"]:
            mark(c["a"], "contradiction")
            mark(c["b"], "contradiction")
    for c in report.get("conditional_disagreements", []):
        mark(c["a"], "conditional")
        mark(c["b"], "conditional")
    for c in report.get("shape_disagreements", []):
        mark(c["a"], "shape")
        mark(c["b"], "shape")
    for imp in implied:
        if imp["status"] == "contradicted" and imp.get("registered"):
            mark(imp["registered"], "implied_contradiction")
            for a, b in imp.get("premises", []):
                mark(a, "implied_contradiction")
                mark(b, "implied_contradiction")

    items: list[ScoredItem] = []
    for p in props:
        k = _claim_key(p)
        theories = sorted(claim_theories[k])
        e = claim_best_evidence[k]
        t = len(theories)
        d = dependents.get(p["name"], 0)
        s = min(1.0, (t + d) / sat)
        g, gk = disagreement_of.get(p["name"], (0.0, "none"))
        score = w["evidence"] * e + w["structure"] * s + w["disagreement"] * g
        rationale = [
            f"strongest evidence for the claim: {_best_evidence_label(props, k, ew)} (E={e:.2f})",
            f"{t} theor{'y' if t == 1 else 'ies'} assert it, {d} implied proposition{'s' if d != 1 else ''} depend on it (S={s:.2f})",
        ]
        if gk != "none":
            rationale.append(f"disagreement: {gk} (G={g:.2f})")
        items.append(
            ScoredItem(
                name=short(p["name"]),
                kind="registered",
                antecedent=qualified(p["antecedent"]),
                consequent=qualified(p["consequent"]),
                direction=p["direction"],
                level=p["level"],
                horizon=p["horizon"],
                boundary=_boundary_key(p["boundary"]),
                theories=theories,
                evidence=p["evidence"],
                evidence_weakness=round(e, 4),
                structure=round(s, 4),
                disagreement=round(g, 4),
                disagreement_kind=gk,
                implied_untested=0.0,
                score=round(score, 4),
                rationale=rationale,
                members=[short(p["name"])],
            )
        )

    # One agenda entry per claim: comparable propositions from several theories
    # (same pair, scope, boundary and direction) collapse into the highest-scoring one.
    by_claim: dict[tuple, ScoredItem] = {}
    for it in items:
        key = (it.antecedent, it.consequent, it.level, it.horizon, it.boundary, it.direction)
        if key not in by_claim or it.score > by_claim[key].score:
            prev = by_claim.get(key)
            if prev is not None:
                it.members = sorted(set(it.members) | set(prev.members))
            by_claim[key] = it
        else:
            by_claim[key].members = sorted(set(by_claim[key].members) | set(it.members))
    items = list(by_claim.values())

    for imp in implied:
        if imp["status"] != "untested":
            continue
        t = len(imp.get("theories", []))
        paths = len(imp.get("premises", []))
        # Structural load of a candidate: how many theories it joins and how many
        # independent mediating paths imply it.
        s = min(1.0, (t - 1 + paths) / sat)
        g, gk = (
            (float(gw["implied_contradiction"]), "implied_disagreement")
            if imp.get("implied_disagreement")
            else (0.0, "none")
        )
        score = w["evidence"] * 1.0 + w["structure"] * s + w["disagreement"] * g + w["implied"] * 1.0
        premises = "; ".join(f"{short(a)} ∘ {short(b)}" for a, b in imp.get("premises", []))
        rationale = [
            "implied by composition and never stated (E=1.00, I=1)",
            f"composes propositions from {', '.join(imp.get('theories', []))} along {paths} path{'s' if paths != 1 else ''} (S={s:.2f}): {premises}",
        ]
        if gk != "none":
            rationale.append(f"disagreement: another composition implies the opposite direction (G={g:.2f})")
        items.append(
            ScoredItem(
                name=f"implied:{short(imp['antecedent'])}->{short(imp['consequent'])}:{imp['direction']}",
                kind="implied",
                antecedent=qualified(imp["antecedent"]),
                consequent=qualified(imp["consequent"]),
                direction=imp["direction"],
                level=imp["level"],
                horizon=imp["horizon"],
                boundary="none",
                theories=list(imp.get("theories", [])),
                evidence="None",
                evidence_weakness=1.0,
                structure=round(s, 4),
                disagreement=round(g, 4),
                disagreement_kind=gk,
                implied_untested=1.0,
                score=round(score, 4),
                rationale=rationale,
            )
        )

    items.sort(key=lambda i: (-i.score, i.name))
    return items


def _best_evidence_label(props: list[dict], key: tuple, ew: dict) -> str:
    best = None
    for p in props:
        if _claim_key(p) == key:
            weakness = float(ew.get(p["evidence"], 1.0))
            if best is None or weakness < best[0]:
                best = (weakness, p["evidence"], p["theory"])
    return f"{best[1]} ({best[2]})" if best else "None"


def _table(items: list[ScoredItem], start_rank: int = 1) -> list[str]:
    lines = [
        "| Rank | Score | Kind | Proposition | Direction | Scope | Theories | E | S | G | I |",
        "|---|---|---|---|---|---|---|---|---|---|---|",
    ]
    for rank, it in enumerate(items, start=start_rank):
        label = f"{it.antecedent} → {it.consequent}"
        if it.boundary != "none":
            label += f" [{it.boundary}]"
        lines.append(
            f"| {rank} | {it.score:.3f} | {it.kind} | {label} | {it.direction} | {it.level} / {it.horizon} | "
            f"{', '.join(it.theories)} | {it.evidence_weakness:.2f} | {it.structure:.2f} | "
            f"{it.disagreement:.2f} | {it.implied_untested:.0f} |"
        )
    return lines


def render_agenda(items: list[ScoredItem], cfg: dict, summary: dict) -> str:
    n = int(cfg.get("agenda_size", 25))
    w = cfg["weights"]
    registered = [i for i in items if i.kind == "registered"]
    implied = [i for i in items if i.kind == "implied"]
    lines = [
        "# Verification agenda",
        "",
        "Ranked by `lemma score`. Score = "
        f"{w['evidence']}·E (evidence weakness) + {w['structure']}·S (structural load) + "
        f"{w['disagreement']}·G (disagreement) + {w['implied']}·I (implied, untested). "
        "Weights in `config/scoring.yaml`; formula in `pipeline/lemma/score.py`.",
        "",
        f"{len(items)} candidates scored: {len(registered)} registered propositions "
        f"and {len(implied)} implied-untested compositions. "
        f"Library: {summary.get('constructs')} constructs, {summary.get('propositions')} propositions, "
        f"{summary.get('theories')} theories.",
        "",
        f"## Combined top {min(n, len(items))}",
        "",
        *_table(items[:n]),
        "",
        f"## Registered propositions, top {min(n, len(registered))}",
        "",
        "Claims a theory states. High scores mark thin evidence under structural load, or disagreement among theories.",
        "",
        *_table(registered[:n]),
        "",
        f"## Implied, untested candidates, top {min(n, len(implied))}",
        "",
        "Claims no theory states but two propositions jointly imply along a mediating path. "
        "Each is a candidate for a direct test; the implied direction is a path sign, not a total effect.",
        "",
        *_table(implied[:n]),
        "",
        "## Rationale for the combined top entries",
        "",
    ]
    for rank, it in enumerate(items[:n], start=1):
        label = f"{it.antecedent} → {it.consequent} ({it.direction})"
        lines.append(f"{rank}. **{label}** — score {it.score:.3f}")
        for r in it.rationale:
            lines.append(f"   - {r}")
    lines += [
        "",
        "## Reading the agenda",
        "",
        "- A high **E** means the strongest evidence attached to the claim, across every theory stating it, is thin.",
        "- A high **S** means many theories assert the claim or build on it, so a test moves more of the library.",
        "- A high **G** means theories disagree about the claim, so a test settles a dispute rather than confirms a consensus.",
        "- **I** marks a claim no theory states but two propositions jointly imply.",
        "",
        "The agenda allocates attention. It says nothing about which direction is true.",
        "",
    ]
    return "\n".join(lines)
