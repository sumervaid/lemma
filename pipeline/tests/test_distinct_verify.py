"""Distinctness classification and verification precision."""

from lemma.check import enrich
from lemma.config import Paths
from lemma.distinct import classify, render
from lemma.verify import compute_precision, extract_items, write_sheet


def test_classify_labels(raw_report, paper_reports):
    report = enrich(raw_report, paper_reports, [])
    rows = [
        {
            "construct_a": "Exhaustion",
            "construct_b": "Vigor",
            "rho": "-0.9",
            "k": "3",
            "n": "100",
            "source": "s",
            "status": "placeholder",
            "note": "",
        },
        {
            "construct_a": "Demands",
            "construct_b": "Effort",
            "rho": "0.5",
            "k": "",
            "n": "",
            "source": "s",
            "status": "placeholder",
            "note": "",
        },
        {
            "construct_a": "Demands",
            "construct_b": "Nope",
            "rho": "0.5",
            "source": "s",
            "status": "placeholder",
            "note": "",
        },
        {
            "construct_a": "Demands",
            "construct_b": "Effort",
            "rho": "",
            "source": "s",
            "status": "placeholder",
            "note": "",
        },
    ]
    out = classify(report, rows, threshold=0.8)
    assert out[0].definitional == "identical" and out[0].declaration == "distinct_from"
    assert out[0].label == "definitionally distinct, empirically indistinguishable"
    assert out[1].label == "distinct on both counts"
    assert out[2].label == "insufficient data"
    assert out[3].empirical == "unknown"
    md = render(out, 0.8)
    assert "Exhaustion | Vigor" in md


def test_extract_items_and_precision(tmp_path):
    src = "/-- doc one -/\n@[construct] structure A extends X where\n  f : Energy\n\n/-- doc two -/\n@[proposition] def p : Proposition A B := {}\n"
    items = extract_items(src, "Mod", "Lemma/Generated/Mod.lean")
    assert [(i.kind, i.name) for i in items] == [("construct", "A"), ("proposition", "p")]
    assert items[0].doc == "doc one"
    paths = Paths(tmp_path)
    sheet = write_sheet(paths, items, seed=7)
    assert sheet.exists()
    p = compute_precision([sheet])
    assert p.precision is None and p.labelled == 0
    text = sheet.read_text(encoding="utf-8").replace("label: ''", "label: faithful", 1)
    sheet.write_text(text, encoding="utf-8")
    p = compute_precision([sheet])
    assert p.labelled == 1 and p.precision == 1.0


def test_precision_counts_unsure_separately(tmp_path):
    sheet = tmp_path / "sheet-1.yaml"
    sheet.write_text("items:\n- label: faithful\n- label: unfaithful\n- label: unsure\n- label: ''\n", encoding="utf-8")
    p = compute_precision([sheet])
    assert (p.faithful, p.unfaithful, p.unsure, p.labelled) == (1, 1, 1, 3)
    assert p.precision == 0.5
