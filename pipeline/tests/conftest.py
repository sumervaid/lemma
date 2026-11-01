"""Shared fixtures: a small synthetic library report in the shape `lemma check` writes."""

from __future__ import annotations

import pytest


def prop(name, theory, a, b, direction, evidence="CrossSectional", boundary=None, level="Individual", horizon="Weekly"):
    return {
        "name": f"Lemma.Theories.{theory}.{name}",
        "theory": theory,
        "module": f"Lemma.Theories.{theory}",
        "antecedent": a,
        "consequent": b,
        "direction": direction,
        "level": level,
        "horizon": horizon,
        "boundary": boundary or {"kind": "none"},
        "evidence": evidence,
        "citation": "test",
        "doc": "test",
        "scope": {"kind": "exact"},
    }


A = "Lemma.Theories.T1.Demands"
B = "Lemma.Theories.T1.Exhaustion"
C = "Lemma.Theories.T1.Performance"
D = "Lemma.Theories.T1.Resources"


@pytest.fixture
def raw_report():
    """Raw report as `#lemma_report` writes it, for a four-construct toy library."""
    props = [
        prop("demands_exhaustion", "T1", A, B, "Positive", "MetaAnalytic"),
        prop("exhaustion_performance", "T1", B, C, "Negative", "Longitudinal"),
        prop("demands_exhaustion", "T2", A, B, "Positive", "CrossSectional"),
        prop("demands_exhaustion_null", "T3", A, B, "Null", "CrossSectional"),
        prop("demands_performance_curvi", "T3", A, C, "Curvilinear", "CrossSectional"),
        prop("demands_performance", "T2", A, C, "Negative", "CrossSectional"),
        prop(
            "resources_exhaustion_mod",
            "T2",
            D,
            B,
            "Negative",
            "CrossSectional",
            boundary={"kind": "moderator", "construct": A, "effect": "Amplifies"},
        ),
        prop("resources_exhaustion_pos", "T3", D, B, "Positive", "None"),
    ]
    constructs = [
        {
            "name": n,
            "theory": "T1",
            "module": "Lemma.Theories.T1",
            "kind": "structure",
            "level": "Individual",
            "horizon": "Weekly",
            "components": [],
            "doc": "d",
            "leaves": [{"prim": p, "args": [], "path": ["f"], "via": None, "level": "Individual", "horizon": "Weekly"}],
        }
        for n, p in [
            (A, "Lemma.Demand"),
            (B, "Lemma.Energy"),
            (C, "Lemma.Performance"),
            (D, "Lemma.Resource"),
            ("Lemma.Theories.T1.Vigor", "Lemma.Energy"),
            ("Lemma.Theories.T1.Effort", "Lemma.Demand"),
        ]
    ]
    overlaps = [
        {
            "a": B,
            "b": "Lemma.Theories.T1.Vigor",
            "kind": "identity",
            "subset": None,
            "shared": [
                {
                    "key": {"prim": "Lemma.Energy", "args": [], "level": "Individual", "horizon": "Weekly"},
                    "inA": "Exhaustion.f",
                    "inB": "Vigor.f",
                }
            ],
            "sizeA": 1,
            "sizeB": 1,
            "declared": {"a": B, "b": "Lemma.Theories.T1.Vigor", "kind": "distinct_from", "reason": "r", "module": "m"},
        },
        {
            "a": A,
            "b": "Lemma.Theories.T1.Effort",
            "kind": "partial",
            "subset": None,
            "shared": [
                {
                    "key": {"prim": "Lemma.Demand", "args": [], "level": "Individual", "horizon": "Weekly"},
                    "inA": "Demands.f",
                    "inB": "Effort.f",
                }
            ],
            "sizeA": 2,
            "sizeB": 3,
            "declared": None,
        },
    ]
    contradictions = [
        {
            "a": props[0]["name"],
            "b": props[3]["name"],
            "theoryA": "T1",
            "theoryB": "T3",
            "antecedent": A,
            "consequent": B,
            "level": "Individual",
            "horizon": "Weekly",
            "directionA": "Positive",
            "directionB": "Null",
        },
        {
            "a": props[2]["name"],
            "b": props[3]["name"],
            "theoryA": "T2",
            "theoryB": "T3",
            "antecedent": A,
            "consequent": B,
            "level": "Individual",
            "horizon": "Weekly",
            "directionA": "Positive",
            "directionB": "Null",
        },
    ]
    shape = [
        {
            "a": props[5]["name"],
            "b": props[4]["name"],
            "theoryA": "T2",
            "theoryB": "T3",
            "antecedent": A,
            "consequent": C,
            "directionA": "Negative",
            "directionB": "Curvilinear",
        }
    ]
    implied = [
        {
            "antecedent": A,
            "consequent": C,
            "direction": "Negative",
            "level": "Individual",
            "horizon": "Weekly",
            "premiseA": props[0]["name"],
            "premiseB": props[1]["name"],
            "theories": ["T1"],
            "registered": props[5]["name"],
            "status": "tested",
        },
        {
            "antecedent": A,
            "consequent": C,
            "direction": "Negative",
            "level": "Individual",
            "horizon": "Weekly",
            "premiseA": props[2]["name"],
            "premiseB": props[1]["name"],
            "theories": ["T2", "T1"],
            "registered": props[5]["name"],
            "status": "tested",
        },
        {
            "antecedent": D,
            "consequent": C,
            "direction": "Negative",
            "level": "Individual",
            "horizon": "Weekly",
            "premiseA": props[7]["name"],
            "premiseB": props[1]["name"],
            "theories": ["T3", "T1"],
            "registered": None,
            "status": "untested",
        },
    ]
    return {
        "kernel_version": "0.1.0",
        "theories": ["T1", "T2", "T3"],
        "primitives": [{"name": "Lemma.Energy", "module": "m", "doc": "d"}],
        "constructs": constructs,
        "propositions": props,
        "aggregations": [],
        "temporals": [],
        "overlap_declarations": [],
        "overlaps": overlaps,
        "scope_shifts": [],
        "contradictions": contradictions,
        "shape_disagreements": shape,
        "implied": implied,
    }


@pytest.fixture
def paper_reports():
    return [
        {
            "paper_id": "p1",
            "module": "P1",
            "status": "accepted",
            "provider": "fixture",
            "model": "fx",
            "counts": {"constructs": 2, "propositions": 3},
            "overlap_warnings": [{"message": "shares primitive X with Y"}],
            "errors": [],
        },
        {
            "paper_id": "p2",
            "module": "P2",
            "status": "failed",
            "provider": "fixture",
            "model": "fx",
            "reason": "",
            "ambiguities": ["no primitive for safety"],
            "counts": {"constructs": 1, "propositions": 1},
            "overlap_warnings": [],
            "errors": [{"message": "construct `X` does not reduce to primitives\n  detail"}],
        },
        {
            "paper_id": "p3",
            "module": "P3",
            "status": "declined",
            "provider": "fixture",
            "model": "fx",
            "reason": "process theory",
            "ambiguities": [],
            "counts": {},
            "overlap_warnings": [],
            "errors": [],
        },
    ]
