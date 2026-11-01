"""Parsing of `lean --json` output and classification of compiler messages."""

from lemma.lean import LeanMessage, parse_json_messages

SAMPLE = """
{"severity":"warning","pos":{"line":13,"column":2},"fileName":"x.lean","data":"shares primitive Energy with Engagement.vigor\\n  Vitality.energy ~ Engagement.vigor : Energy at Individual / Weekly"}
not json
{"severity":"error","pos":{"line":48,"column":2},"fileName":"x.lean","data":"scope mismatch in `p`: X lives at Individual / Weekly but the proposition declares Team / Weekly"}
{"severity":"information","pos":{"line":50,"column":2},"fileName":"x.lean","data":"`q` is routed through engagementTeam"}
{"severity":"warning","pos":{"line":60,"column":2},"fileName":"x.lean","data":"contradicts demands_exhaustion (JDR): A → B is Negative here and Positive there at Individual / Weekly"}
"""


def test_parse_skips_non_json_lines():
    msgs = parse_json_messages(SAMPLE)
    assert [m.severity for m in msgs] == ["warning", "error", "information", "warning"]
    assert msgs[0].line == 13 and msgs[0].column == 2


def test_classification():
    msgs = parse_json_messages(SAMPLE)
    assert msgs[0].is_overlap_warning()
    assert not msgs[0].is_contradiction_warning()
    assert msgs[2].is_routing_note()
    assert msgs[3].is_contradiction_warning()
    assert msgs[0].first_line == "shares primitive Energy with Engagement.vigor"


def test_overlap_warning_shape_matches_listing_1():
    m = LeanMessage("warning", 1, 1, "shares primitive Energy with Engagement.vigor\n  detail")
    assert m.is_overlap_warning()
    assert m.first_line.startswith("shares primitive ")
