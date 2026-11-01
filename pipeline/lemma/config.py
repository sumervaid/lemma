"""Paths and environment for the pipeline.

Everything is resolved relative to the repository root so that the CLI
works from any working directory. No network access happens unless
``lemma formalize`` is run without ``--offline``.
"""

from __future__ import annotations

import os
from dataclasses import dataclass, field
from pathlib import Path


def find_repo_root(start: Path | None = None) -> Path:
    """Walk up from ``start`` until a directory containing ``lakefile.lean`` is found."""
    here = (start or Path.cwd()).resolve()
    for candidate in (here, *here.parents):
        if (candidate / "lakefile.lean").exists():
            return candidate
    # Fall back to the package's own location (pipeline/lemma -> repo root).
    return Path(__file__).resolve().parents[2]


@dataclass
class Paths:
    root: Path
    generated: Path = field(init=False)
    reports: Path = field(init=False)
    fixtures: Path = field(init=False)
    verification: Path = field(init=False)
    config: Path = field(init=False)
    bibliography: Path = field(init=False)
    report_script: Path = field(init=False)

    def __post_init__(self) -> None:
        self.generated = self.root / "Lemma" / "Generated"
        self.reports = self.root / "reports"
        self.fixtures = self.root / "fixtures"
        self.verification = self.root / "verification"
        self.config = self.root / "config"
        self.bibliography = self.root / "bibliography"
        self.report_script = self.root / "scripts" / "report.lean"


@dataclass
class LLMConfig:
    """Connection settings for any OpenAI-compatible chat endpoint.

    Defaults point at a local Ollama server. vLLM, llama.cpp's server and
    hosted endpoints all speak the same ``/chat/completions`` protocol.
    """

    base_url: str = os.environ.get("LEMMA_LLM_BASE_URL", "http://localhost:11434/v1")
    model: str = os.environ.get("LEMMA_LLM_MODEL", "qwen3:32b")
    api_key: str = os.environ.get("LEMMA_LLM_API_KEY", "")
    timeout_s: float = float(os.environ.get("LEMMA_LLM_TIMEOUT", "600"))
    temperature: float = float(os.environ.get("LEMMA_LLM_TEMPERATURE", "0.0"))
    max_tokens: int = int(os.environ.get("LEMMA_LLM_MAX_TOKENS", "4096"))


def lean_bin_dir() -> Path | None:
    """Directory holding ``lean`` and ``lake`` if ``LEMMA_LEAN_BIN`` is set."""
    value = os.environ.get("LEMMA_LEAN_BIN")
    return Path(value) if value else None
