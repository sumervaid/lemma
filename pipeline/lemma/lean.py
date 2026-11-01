"""Run Lean and Lake, parse ``--json`` messages.

The compiler checks run inside Lean. This module only invokes the
toolchain and reads back the structured messages Lean prints with
``lean --json``.
"""

from __future__ import annotations

import json
import os
import shutil
import subprocess
from dataclasses import dataclass, field
from pathlib import Path

from .config import lean_bin_dir


@dataclass
class LeanMessage:
    severity: str  # "error" | "warning" | "information"
    line: int
    column: int
    data: str

    @property
    def first_line(self) -> str:
        return self.data.splitlines()[0] if self.data else ""

    def is_overlap_warning(self) -> bool:
        return self.severity == "warning" and self.first_line.startswith("shares primitive")

    def is_contradiction_warning(self) -> bool:
        return self.severity == "warning" and self.first_line.startswith("contradicts ")

    def is_routing_note(self) -> bool:
        return self.severity == "information" and " is routed through " in self.first_line

    def to_dict(self) -> dict:
        return {
            "severity": self.severity,
            "line": self.line,
            "column": self.column,
            "message": self.data,
        }


@dataclass
class LeanResult:
    ok: bool
    messages: list[LeanMessage] = field(default_factory=list)
    stdout: str = ""
    stderr: str = ""
    returncode: int = 0

    @property
    def errors(self) -> list[LeanMessage]:
        return [m for m in self.messages if m.severity == "error"]

    @property
    def warnings(self) -> list[LeanMessage]:
        return [m for m in self.messages if m.severity == "warning"]


def _env() -> dict[str, str]:
    env = dict(os.environ)
    bin_dir = lean_bin_dir()
    if bin_dir is not None:
        env["PATH"] = f"{bin_dir}{os.pathsep}{env.get('PATH', '')}"
    return env


def toolchain_available() -> bool:
    env = _env()
    path = env.get("PATH", "")
    return shutil.which("lake", path=path) is not None and shutil.which("lean", path=path) is not None


def parse_json_messages(stdout: str) -> list[LeanMessage]:
    """Parse one JSON object per line as printed by ``lean --json``."""
    out: list[LeanMessage] = []
    for raw in stdout.splitlines():
        raw = raw.strip()
        if not raw.startswith("{"):
            continue
        try:
            obj = json.loads(raw)
        except json.JSONDecodeError:
            continue
        pos = obj.get("pos") or {}
        out.append(
            LeanMessage(
                severity=str(obj.get("severity", "information")),
                line=int(pos.get("line", 0)),
                column=int(pos.get("column", 0)),
                data=str(obj.get("data", "")),
            )
        )
    return out


def run(cmd: list[str], cwd: Path, timeout_s: float = 1800) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        cmd,
        cwd=str(cwd),
        env=_env(),
        capture_output=True,
        text=True,
        timeout=timeout_s,
        check=False,
    )


def lake_build(root: Path, targets: list[str] | None = None) -> LeanResult:
    """``lake build [targets]`` in the repository root."""
    cmd = ["lake", "build", *(targets or [])]
    proc = run(cmd, root)
    # Lake prints Lean messages with a "warning: file:line:col: ..." prefix, not JSON.
    return LeanResult(
        ok=proc.returncode == 0,
        stdout=proc.stdout,
        stderr=proc.stderr,
        returncode=proc.returncode,
    )


def lean_check_file(root: Path, file: Path) -> LeanResult:
    """Elaborate a single file against the built library and return its messages.

    The file is not added to the library's build; this is the pipeline's
    way of submitting a candidate module to the compiler.
    """
    proc = run(["lake", "env", "lean", "--json", str(file)], root)
    messages = parse_json_messages(proc.stdout)
    ok = proc.returncode == 0 and not any(m.severity == "error" for m in messages)
    return LeanResult(ok=ok, messages=messages, stdout=proc.stdout, stderr=proc.stderr, returncode=proc.returncode)


def lean_run_script(root: Path, script: Path) -> LeanResult:
    """Run a Lean script (e.g. ``scripts/report.lean``) with ``lake env lean``."""
    proc = run(["lake", "env", "lean", "--json", str(script)], root)
    messages = parse_json_messages(proc.stdout)
    ok = proc.returncode == 0 and not any(m.severity == "error" for m in messages)
    return LeanResult(ok=ok, messages=messages, stdout=proc.stdout, stderr=proc.stderr, returncode=proc.returncode)
