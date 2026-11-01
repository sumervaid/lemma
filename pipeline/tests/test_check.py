"""Enrichment of the raw Lean report: contradictions, convergences, implied dedup, counts."""

from lemma.check import (
    IMPORT_BEGIN,
    IMPORT_END,
    conditional_disagreements,
    contradicts,
    convergences,
    dedupe_implied,
    enrich,
    render_markdown,
    shape_disagrees,
    summarize_formalization,
)


def test_direction_predicates():
    assert contradicts("Positive", "Negative")
    assert contradicts("Null", "Positive")
    assert not contradicts("Positive", "Positive")
    assert not contradicts("Curvilinear", "Positive")
    assert shape_disagrees("Curvilinear", "Positive")
    assert not shape_disagrees("Curvilinear", "Curvilinear")


def test_conditional_disagreements_require_different_boundary_and_theory(raw_report):
    cond = conditional_disagreements(raw_report["propositions"])
    pairs = {(c["theoryA"], c["theoryB"]) for c in cond}
    # T2's moderated negative vs T3's unconditional positive on Resources -> Exhaustion
    assert ("T2", "T3") in pairs
    assert all(c["boundaryA"] != c["boundaryB"] for c in cond)


def test_convergences(raw_report):
    conv = convergences(raw_report["propositions"])
    assert len(conv) == 1
    assert conv[0]["theories"] == ["T1", "T2"]
    assert conv[0]["direction"] == "Positive"


def test_dedupe_implied_merges_paths_and_flags_disagreement(raw_report):
    implied = dedupe_implied(raw_report["implied"])
    assert len(implied) == 2
    tested = next(i for i in implied if i["status"] == "tested")
    assert len(tested["premises"]) == 2
    assert set(tested["theories"]) == {"T1", "T2"}
    assert all(not i["implied_disagreement"] for i in implied)


def test_dedupe_implied_disagreement_flag():
    base = {
        "level": "Individual",
        "horizon": "Weekly",
        "premiseA": "a",
        "premiseB": "b",
        "theories": ["T"],
        "registered": None,
        "status": "untested",
    }
    implied = dedupe_implied(
        [
            {**base, "antecedent": "X", "consequent": "Y", "direction": "Positive"},
            {**base, "antecedent": "X", "consequent": "Y", "direction": "Negative"},
        ]
    )
    assert all(i["implied_disagreement"] for i in implied)


def test_summarize_formalization(paper_reports):
    f = summarize_formalization(paper_reports)
    assert f["accepted"] == 1 and f["failed"] == 1 and f["declined"] == 1
    assert f["failures_total"] == 2
    assert f["accepted_constructs"] == 2 and f["accepted_propositions"] == 3
    assert f["failures"][0]["errors"] == ["construct `X` does not reduce to primitives"]


def test_enrich_summary_counts(raw_report, paper_reports):
    sources = [{"id": "s1"}, {"id": "s2"}, {"id": "p1"}]
    report = enrich(raw_report, paper_reports, sources)
    s = report["summary"]
    assert s["constructs"] == 6
    assert s["propositions"] == 8
    assert s["overlap_warnings"] == 2
    assert s["overlap_warnings_resolved"] == 1
    assert s["overlap_warnings_by_kind"] == {"identity": 1, "partial": 1}
    assert s["contradictions_cross_theory"] == 2
    assert s["shape_disagreements"] == 1
    assert s["conditional_disagreements"] == 1
    assert s["implied"] == 2 and s["implied_untested"] == 1
    assert s["formalization_failures"] == 2
    # p1 is both a curated source and an accepted pipeline paper: counted once.
    assert s["papers_total"] == 3
    md = render_markdown(report)
    assert "## Cross-theory contradictions" in md
    assert "demands_exhaustion_null" in md


def test_import_block_markers_exist_in_script():
    from pathlib import Path

    script = Path(__file__).resolve().parents[2] / "scripts" / "report.lean"
    text = script.read_text(encoding="utf-8")
    assert IMPORT_BEGIN in text and IMPORT_END in text
