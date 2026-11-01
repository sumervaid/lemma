"""``lemma doctor``: state what works on this machine, with the next step for anything missing."""

from __future__ import annotations

import re
import subprocess
import sys
from dataclasses import dataclass

from .config import Paths
from .draft import library_built
from .lean import _env, toolchain_available


@dataclass
class Check:
    name: str
    ok: bool
    detail: str
    fix: str = ""
    required: bool = True


def _lean_version() -> str:
    try:
        out = subprocess.run(
            ["lean", "--version"], env=_env(), capture_output=True, text=True, timeout=120, check=False
        )
    except OSError:
        return ""
    found = re.search(r"version (\d+\.\d+\.\d+)", out.stdout)
    return found.group(1) if found else ""


def run_checks(paths: Paths) -> list[Check]:
    version = ".".join(str(n) for n in sys.version_info[:3])
    wanted = (paths.root / "lean-toolchain").read_text(encoding="utf-8").strip().rsplit(":v", 1)[-1]
    checks = [
        Check("Python 3.11 or later", sys.version_info >= (3, 11), f"found {version}", "Run ./install.sh"),
        Check(
            "Library reports",
            (paths.reports / "library.json").exists(),
            "reports/library.json",
            "Download a fresh copy of the repository.",
        ),
    ]
    has_lean = toolchain_available()
    found = _lean_version() if has_lean else ""
    checks.append(
        Check(
            f"Lean {wanted}",
            found == wanted,
            f"found {found}" if found else "absent",
            "Run ./install.sh to add the checker. Browsing commands work meanwhile.",
            required=False,
        )
    )
    checks.append(
        Check(
            "Compiled library",
            library_built(paths.root),
            ".lake/build",
            "Run make build. The first build takes a minute or two.",
            required=False,
        )
    )
    return checks


def render(checks: list[Check]) -> tuple[str, int]:
    lines = ["Lemma doctor", ""]
    for c in checks:
        lines.append(f"  {'ok ' if c.ok else 'add'}  {c.name:24s} {c.detail}")
    fixes = [c.fix for c in checks if not c.ok and c.fix]
    required_ok = all(c.ok for c in checks if c.required)
    full = all(c.ok for c in checks)
    lines.append("")
    if full:
        lines.append("Ready. Every command works. Try lemma tour, lemma site --open, or lemma new.")
    elif required_ok:
        lines.append("Ready for browsing with lemma tour, lemma find, lemma show, lemma compare, lemma site.")
    else:
        lines.append("Setup is incomplete.")
    if fixes:
        lines += ["", "Next steps", *[f"  {f}" for f in fixes]]
    return "\n".join(lines), 0 if required_ok else 1
