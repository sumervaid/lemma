"""Model-output parsing, module naming and attribute counting (no Lean, no network)."""

from pathlib import Path

from lemma.formalize import count_attributes, module_name_of, paper_id_of
from lemma.llm import FixtureProvider, parse_model_output


def test_module_name():
    assert module_name_of("bakker_demerouti_2007") == "BakkerDemerouti2007"
    assert module_name_of("2007-paper") == "Paper2007Paper"
    assert paper_id_of(Path("/x/y/spreitzer_2005.txt")) == "spreitzer_2005"


def test_parse_model_output_with_fences_and_think_block():
    text = '<think>reasoning</think>Here you go:\n```json\n{"declined": false, "reason": "", "ambiguities": ["a"], "module": "import Lemma.Theories"}\n```'
    f = parse_model_output("p", text)
    assert not f.declined and f.lean == "import Lemma.Theories" and f.ambiguities == ["a"]


def test_parse_model_output_declines_on_garbage():
    f = parse_model_output("p", "no json here")
    assert f.declined and f.lean is None


def test_parse_model_output_missing_module_is_declined():
    f = parse_model_output("p", '{"declined": false, "reason": "x"}')
    assert f.declined


def test_count_attributes():
    src = "@[construct] structure A\n@[construct] def B\n@[proposition] def p\n@[aggregation] def q"
    assert count_attributes(src) == {"constructs": 2, "propositions": 1, "aggregations": 1, "temporals": 0}


def test_fixture_provider_reads_yaml(tmp_path):
    (tmp_path / "x.yaml").write_text(
        "declined: false\nmodule: |\n  import Lemma.Theories\nambiguities: [q]\n", encoding="utf-8"
    )
    (tmp_path / "y.yaml").write_text("declined: true\nreason: nope\n", encoding="utf-8")
    prov = FixtureProvider(tmp_path)
    assert prov.available() == ["x", "y"]
    fx = prov.formalize("x", "", "")
    assert fx.lean.strip() == "import Lemma.Theories" and fx.provider == "fixture"
    fy = prov.formalize("y", "", "")
    assert fy.declined and fy.reason == "nope"
    assert prov.repair("x", fx, ["err"], "") is None


def test_repo_fixtures_are_consistent():
    root = Path(__file__).resolve().parents[2]
    papers = {p.stem for p in (root / "fixtures" / "papers").glob("*.txt")}
    forms = {p.stem for p in (root / "fixtures" / "formalizations").glob("*.yaml")}
    assert papers == forms, f"papers without fixtures: {papers ^ forms}"
