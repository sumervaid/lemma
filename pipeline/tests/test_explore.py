"""The plain-language views, held to the compiler's own output in reports/library.json."""

from __future__ import annotations

import itertools
import json
import shutil
import subprocess
from pathlib import Path

import pytest

from lemma.check import generated_modules
from lemma.cli import main
from lemma.config import Paths
from lemma.doctor import Check, render
from lemma.draft import (
    all_parts,
    docstring,
    explain,
    library_built,
    parse_catalog,
    render_lean,
    to_identifier,
)
from lemma.explore import (
    AmbiguousNameError,
    Library,
    UnknownNameError,
    fill_counts,
    load_curation,
    overlap_kind,
    theory_name,
)
from lemma.lean import LeanMessage, lean_check_file, toolchain_available
from lemma.site import ASSETS, build_data, build_site, render_page

ROOT = Path(__file__).resolve().parents[2]
PATHS = Paths(ROOT)


@pytest.fixture(scope="module")
def lib():
    return Library(PATHS)


@pytest.fixture(scope="module")
def data():
    return build_data(PATHS)


def catalog():
    return parse_catalog((ROOT / "Lemma" / "Library" / "Primitives.lean").read_text(encoding="utf-8"))


def test_overlap_rule_matches_every_compiler_report(lib):
    reported = {frozenset((o["a"], o["b"])): o["kind"] for o in lib.report["overlaps"]}
    for a, b in itertools.combinations(lib.by_name, 2):
        kind = overlap_kind(lib.keys[a], lib.keys[b])
        pair = frozenset((a, b))
        if pair in reported:
            assert kind == reported[pair], (a, b)
        elif kind != "none":
            # The compiler skips a construct's own components by design.
            components = [*lib.by_name[a].get("components", []), *lib.by_name[b].get("components", [])]
            assert a in components or b in components, (a, b)


def test_resolve_prefers_the_lone_curated_entry(lib):
    assert theory_name(lib.resolve("Vitality")["name"]) == "Thriving.Vitality"
    assert theory_name(lib.resolve("engagement.vigor")["name"]) == "Engagement.Vigor"


def test_resolve_reports_ambiguity_and_absence(lib):
    with pytest.raises(UnknownNameError):
        lib.resolve("Zzz")
    with pytest.raises(AmbiguousNameError):
        _ambiguous(lib)


def _ambiguous(lib):
    # Two fixture entries with one short name and no curated entry would be ambiguous.
    original = lib.constructs
    twin = {**original[0], "name": "Lemma.Generated.A.Twin", "module": "Lemma.Generated.A"}
    other = {**original[0], "name": "Lemma.Generated.B.Twin", "module": "Lemma.Generated.B"}
    lib.constructs = [*original, twin, other]
    try:
        lib.resolve("Twin")
    finally:
        lib.constructs = original


def test_exhaustion_and_vigor_comparison(lib):
    cmp = lib.compare(lib.resolve("Burnout.Exhaustion"), lib.resolve("Engagement.Vigor"))
    assert cmp.kind == "identity"
    assert cmp.shared == ["Energy"]
    assert cmp.declaration["kind"] == "distinct_from"
    assert cmp.correlation["status"] == "placeholder"


def test_curation_names_resolve(lib):
    curation = load_curation(PATHS)
    views = {"disagreements", "agenda"}
    for finding in curation["findings"]:
        assert finding["caution"]
        fill_counts(finding["title"], lib.report)
        if "compare" in finding:
            for name in finding["compare"]:
                lib.resolve(name)
        else:
            assert finding["view"] in views
    for collection in curation["collections"]:
        for name in collection["constructs"]:
            assert theory_name(lib.resolve(name)["name"]) == name


def test_curated_counts_come_from_the_report(lib):
    titles = [fill_counts(f["title"], lib.report) for f in load_curation(PATHS)["findings"]]
    assert "85 implied pairs lack a direct claim in the library" in titles
    assert "3 of 9 pipeline papers were refused" in titles


def test_catalog_covers_the_vocabulary(lib):
    entries = catalog()
    assert len(entries) == lib.report["summary"]["primitives"]
    parts = set(all_parts(entries))
    used = {
        " ".join([p.split(".")[-1] for p in [leaf["prim"], *leaf["args"]]])
        for c in lib.constructs
        for leaf in c["leaves"]
    }
    assert used <= parts


def test_identifier_and_docstring_safety():
    assert to_identifier("work vitality") == "WorkVitality"
    with pytest.raises(ValueError):
        to_identifier("123")
    assert "-/" not in docstring("Ends the comment -/ early", "A /- B")
    assert docstring("A definition.", "") == "A definition (citation to add)."


@pytest.mark.parametrize(
    ("data_text", "severity", "expected"),
    [
        (
            "shares primitive Energy with Engagement.vigor\n  overlap kind: partial (1 of 2)",
            "warning",
            "Shares Energy with Engagement",
        ),
        (
            "shares primitives Energy, Learning with Thriving ∋ Vitality.energy",
            "warning",
            "Shares Energy, Learning with Thriving",
        ),
        (
            "construct `Bad` does not reduce to primitives\n  Nat at count",
            "error",
            "Bad uses something outside the vocabulary",
        ),
        ("construct `Bad` requires a citation docstring (see CONTRIBUTING.md)", "error", "A citation is missing"),
        ("scope mismatch in `p`: X lives at Team", "error", "The scope of p does not line up"),
        ("contradicts q (JDR): A → B is Negative here", "warning", "This claim disagrees with another theory"),
        ("something new", "information", "Compiler message"),
    ],
)
def test_compiler_messages_are_explained(data_text, severity, expected):
    assert explain(LeanMessage(severity, 1, 1, data_text)).headline == expected


def test_site_data_matches_the_report(data, lib):
    s = lib.report["summary"]
    assert len(data["constructs"]) == s["constructs"]
    assert len(data["propositions"]) == s["propositions"]
    assert len(data["overlaps"]) == s["overlap_warnings"]
    assert len(data["catalog"]) == s["primitives"]
    assert sum(1 for c in data["constructs"] if c["origin"] != "curated") == s["constructs_generated"]


def test_page_is_self_contained_and_safe(data, tmp_path):
    hostile = {**data, "status": "</script><script>alert(1)</script>"}
    page = render_page(hostile)
    assert "<script>alert(1)" not in page
    out = build_site(PATHS, tmp_path / "site" / "index.html")
    text = out.read_text(encoding="utf-8")
    assert text.startswith("<!doctype html>")
    assert "/*DATA*/" not in text and "/*APP*/" not in text


@pytest.mark.skipif(shutil.which("node") is None, reason="node is absent")
def test_browser_logic_matches_python(data, lib):
    payload = {
        "overlap": str(ASSETS / "overlap.js"),
        "constructs": [{"id": c["id"], "keys": [p["key"] for p in c["parts"]]} for c in data["constructs"]],
        "draft": {
            "name": "WorkVitality",
            "definition": "A felt sense of energy.",
            "citation": "Example 2026",
            "category": "AffectiveState",
            "level": "Individual",
            "horizon": "Weekly",
            "parts": ["Energy", "Attention Work", "Affect Negative High"],
            "generated": data["generated"],
        },
    }
    script = """
    const p = JSON.parse(require('fs').readFileSync(0, 'utf8'));
    const core = require(p.overlap);
    const kinds = {};
    for (const a of p.constructs) for (const b of p.constructs)
      if (a.id < b.id) kinds[a.id + '|' + b.id] = core.overlapKind(a.keys, b.keys);
    console.log(JSON.stringify({kinds, lean: core.renderLean(p.draft), id: core.toIdentifier('work vitality')}));
    """
    done = subprocess.run(["node", "-e", script], input=json.dumps(payload), capture_output=True, text=True, check=True)
    out = json.loads(done.stdout)
    keys = {c["id"]: {p["key"] for p in c["parts"]} for c in data["constructs"]}
    for pair, kind in out["kinds"].items():
        a, b = pair.split("|")
        assert kind == overlap_kind(keys[a], keys[b]), pair
    d = payload["draft"]
    assert out["lean"] == render_lean(
        d["name"], d["definition"], d["citation"], d["category"], d["level"], d["horizon"], d["parts"], d["generated"]
    )
    assert out["id"] == "WorkVitality"


@pytest.mark.parametrize(
    ("argv", "code", "needle"),
    [
        ([], 0, "lemma tour"),
        (["tour"], 0, "Pilot status"),
        (["find", "energy"], 0, "Parts"),
        (["find", "zzzz"], 1, "No matches"),
        (["show", "Thriving"], 0, "Built from"),
        (["show", "zzz"], 1, ""),
        (["compare", "Exhaustion", "Vigor"], 0, "identity"),
        (["compare", "Vigor", "zzz"], 1, ""),
    ],
)
def test_reader_commands(argv, code, needle, capsys):
    root = ["--root", str(ROOT)]
    assert main(root + argv) == code
    assert needle in capsys.readouterr().out


def test_doctor_separates_browsing_from_compiling():
    text, code = render(
        [Check("Python", True, "ok"), Check("Lean", False, "absent", "Run ./install.sh", required=False)]
    )
    assert code == 0
    assert "Ready for browsing" in text and "./install.sh" in text
    _, code = render([Check("Python", False, "old", "Run ./install.sh")])
    assert code == 1


def test_new_without_lean_still_writes_a_draft(tmp_path, monkeypatch, capsys):
    root = tmp_path / "repo"
    shutil.copytree(ROOT / "Lemma" / "Library", root / "Lemma" / "Library")
    (root / "Lemma" / "Generated").mkdir()
    monkeypatch.setattr("lemma.cli.toolchain_available", lambda: False)
    flags = ["--definition", "D", "--citation", "C", "--category", "Outcome", "--level", "Team", "--horizon", "Daily"]
    assert main(["--root", str(root), "new", "--name", "my idea", *flags, "--part", "Energy"]) == 0
    assert "the compiler check needs lean" in capsys.readouterr().out.lower()
    assert "(level := .Team)" in (root / "drafts" / "MyIdea.lean").read_text(encoding="utf-8")
    assert main(["--root", str(root), "new", "--name", "x", *flags, "--part", "Nonsense"]) == 2


@pytest.mark.skipif(not (toolchain_available() and library_built(ROOT)), reason="needs a compiled library")
def test_generated_draft_compiles_and_matches_the_overlap_count(lib, tmp_path):
    parts = ["Energy", "Attention Work"]
    lean = render_lean(
        "WorkVitality",
        "A definition",
        "Example",
        "AffectiveState",
        "Individual",
        "Weekly",
        parts,
        generated_modules(PATHS),
    )
    file = tmp_path / "WorkVitality.lean"
    file.write_text(lean, encoding="utf-8")
    result = lean_check_file(ROOT, file)
    assert result.ok, result.stdout
    keys = {
        (f"Lemma.{p.split()[0]}", tuple(f"Lemma.Target.{a}" for a in p.split()[1:]), "Individual", "Weekly")
        for p in parts
    }
    expected = sum(overlap_kind(keys, other) != "none" for other in lib.keys.values())
    warned = sum(m.is_overlap_warning() or m.first_line.startswith("shares primitives") for m in result.messages)
    assert warned == expected
