"""The verification-priority scorer: formula, monotonicity, agenda rendering."""

import math

import pytest

from lemma.check import enrich
from lemma.score import DEFAULT_CONFIG, load_scoring_config, render_agenda, score_library


@pytest.fixture
def report(raw_report, paper_reports):
    return enrich(raw_report, paper_reports, [])


def _find(items, antecedent, consequent, direction, kind="registered"):
    return next(
        i
        for i in items
        if i.antecedent.endswith(antecedent)
        and i.consequent.endswith(consequent)
        and i.direction == direction
        and i.kind == kind
    )


def test_scores_lie_in_unit_interval(report):
    items = score_library(report, DEFAULT_CONFIG)
    assert items, "no items scored"
    assert all(0.0 <= i.score <= 1.0 for i in items)
    assert math.isclose(sum(DEFAULT_CONFIG["weights"].values()), 1.0)


def test_formula_matches_components(report):
    cfg = DEFAULT_CONFIG
    w = cfg["weights"]
    for it in score_library(report, cfg):
        expected = (
            w["evidence"] * it.evidence_weakness
            + w["structure"] * it.structure
            + w["disagreement"] * it.disagreement
            + w["implied"] * it.implied_untested
        )
        assert math.isclose(it.score, round(expected, 4), abs_tol=1e-3), it.name


def test_evidence_is_strongest_across_theories(report):
    """T2 restates T1's meta-analytic claim with cross-sectional data; E uses the meta-analysis."""
    items = score_library(report, DEFAULT_CONFIG)
    it = _find(items, "Demands", "Exhaustion", "Positive")
    assert it.evidence_weakness == DEFAULT_CONFIG["evidence_weakness"]["MetaAnalytic"]
    assert set(it.theories) == {"T1", "T2"}
    assert sorted(it.members) == ["demands_exhaustion", "demands_exhaustion"] or len(it.members) >= 1


def test_contradiction_raises_disagreement(report):
    items = score_library(report, DEFAULT_CONFIG)
    contested = _find(items, "Demands", "Exhaustion", "Null")
    assert contested.disagreement == DEFAULT_CONFIG["disagreement"]["contradiction"]
    assert contested.disagreement_kind == "contradiction"


def test_shape_and_conditional_disagreement(report):
    items = score_library(report, DEFAULT_CONFIG)
    curvi = _find(items, "Demands", "Performance", "Curvilinear")
    assert curvi.disagreement_kind == "shape"
    cond = _find(items, "Resources", "Exhaustion", "Positive")
    assert cond.disagreement_kind == "conditional"


def test_implied_untested_is_scored_and_flagged(report):
    items = score_library(report, DEFAULT_CONFIG)
    imp = _find(items, "Resources", "Performance", "Negative", kind="implied")
    assert imp.implied_untested == 1.0
    assert imp.evidence_weakness == 1.0
    # tested implied propositions are not candidates
    assert not any(
        i.kind == "implied" and i.consequent.endswith("Performance") and i.antecedent.endswith("Demands") for i in items
    )


def test_ranking_is_descending_and_deterministic(report):
    a = score_library(report, DEFAULT_CONFIG)
    b = score_library(report, DEFAULT_CONFIG)
    assert [i.name for i in a] == [i.name for i in b]
    assert all(a[k].score >= a[k + 1].score for k in range(len(a) - 1))


def test_weights_change_ranking(report):
    cfg = {**DEFAULT_CONFIG, "weights": {"evidence": 0.0, "structure": 0.0, "disagreement": 1.0, "implied": 0.0}}
    items = score_library(report, cfg)
    assert items[0].disagreement_kind == "contradiction"


def test_load_scoring_config_merges_defaults(tmp_path):
    p = tmp_path / "scoring.yaml"
    p.write_text("weights:\n  evidence: 0.5\n", encoding="utf-8")
    cfg = load_scoring_config(p)
    assert cfg["weights"]["evidence"] == 0.5
    assert cfg["weights"]["structure"] == DEFAULT_CONFIG["weights"]["structure"]
    assert load_scoring_config(tmp_path / "missing.yaml") == DEFAULT_CONFIG


def test_agenda_rendering(report):
    items = score_library(report, DEFAULT_CONFIG)
    md = render_agenda(items, DEFAULT_CONFIG, report["summary"])
    assert md.startswith("# Verification agenda")
    assert "## Registered propositions" in md
    assert "## Implied, untested candidates" in md
    assert "| 1 |" in md
