"""Formalization providers.

Two providers implement the same interface:

* :class:`OpenAICompatibleProvider` calls any server speaking the OpenAI
  ``/v1/chat/completions`` protocol (Ollama, vLLM, llama.cpp, hosted
  endpoints). It uses only the standard library. Nothing is cached or
  mocked: if the endpoint is unreachable, the call raises.
* :class:`FixtureProvider` returns hand-written formalizations from
  ``fixtures/formalizations/<paper>.yaml``. It exists so that the whole
  pipeline runs end to end, deterministically, on a machine with no model.
  Every report records which provider produced each formalization.

A formalization response is a :class:`Formalization`: the Lean source of
a module (or ``None`` when the model declines), the model's stated
ambiguities, and provenance.
"""

from __future__ import annotations

import json
import re
import urllib.error
import urllib.request
from dataclasses import dataclass, field
from pathlib import Path
from typing import Protocol

import yaml

from .config import LLMConfig


@dataclass
class Formalization:
    paper_id: str
    lean: str | None
    declined: bool
    reason: str
    ambiguities: list[str] = field(default_factory=list)
    provider: str = ""
    model: str = ""
    raw: str = ""

    def to_dict(self) -> dict:
        return {
            "paper_id": self.paper_id,
            "declined": self.declined,
            "reason": self.reason,
            "ambiguities": self.ambiguities,
            "provider": self.provider,
            "model": self.model,
        }


class Provider(Protocol):
    name: str

    def formalize(self, paper_id: str, paper_text: str, prompt: str) -> Formalization: ...

    def repair(
        self, paper_id: str, previous: Formalization, errors: list[str], prompt: str
    ) -> Formalization | None: ...


_JSON_BLOCK = re.compile(r"\{.*\}", re.DOTALL)


def parse_model_output(paper_id: str, text: str) -> Formalization:
    """Extract the JSON object a model was asked to return.

    The prompt asks for ``{"declined": bool, "reason": str, "ambiguities":
    [str], "module": str}``. Models wrap JSON in fences or prose, so the
    first balanced object in the text is taken.
    """
    # Strip <think>...</think> blocks emitted by reasoning models such as Qwen3.
    text = re.sub(r"<think>.*?</think>", "", text, flags=re.DOTALL).strip()
    match = _JSON_BLOCK.search(text)
    if match is None:
        return Formalization(
            paper_id=paper_id,
            lean=None,
            declined=True,
            reason="model output contained no JSON object",
            raw=text,
        )
    try:
        obj = json.loads(match.group(0))
    except json.JSONDecodeError as exc:
        return Formalization(
            paper_id=paper_id,
            lean=None,
            declined=True,
            reason=f"model output was not valid JSON: {exc}",
            raw=text,
        )
    declined = bool(obj.get("declined", False))
    module = obj.get("module")
    if not isinstance(module, str) or not module.strip():
        module = None
        declined = True
    return Formalization(
        paper_id=paper_id,
        lean=module,
        declined=declined,
        reason=str(obj.get("reason", "")),
        ambiguities=[str(a) for a in obj.get("ambiguities", [])],
        raw=text,
    )


class OpenAICompatibleProvider:
    """Chat-completions client with no third-party dependencies."""

    name = "openai-compatible"

    def __init__(self, config: LLMConfig | None = None) -> None:
        self.config = config or LLMConfig()

    def _chat(self, messages: list[dict[str, str]]) -> str:
        url = self.config.base_url.rstrip("/") + "/chat/completions"
        body = {
            "model": self.config.model,
            "messages": messages,
            "temperature": self.config.temperature,
            "max_tokens": self.config.max_tokens,
        }
        headers = {"Content-Type": "application/json"}
        if self.config.api_key:
            headers["Authorization"] = f"Bearer {self.config.api_key}"
        req = urllib.request.Request(url, data=json.dumps(body).encode("utf-8"), headers=headers, method="POST")
        try:
            with urllib.request.urlopen(req, timeout=self.config.timeout_s) as resp:
                payload = json.loads(resp.read().decode("utf-8"))
        except urllib.error.URLError as exc:
            raise RuntimeError(
                f"could not reach model endpoint {url}: {exc}. "
                "Set LEMMA_LLM_BASE_URL / LEMMA_LLM_MODEL, or run with --offline."
            ) from exc
        try:
            return payload["choices"][0]["message"]["content"]
        except (KeyError, IndexError, TypeError) as exc:
            raise RuntimeError(f"unexpected response shape from {url}: {payload}") from exc

    def formalize(self, paper_id: str, paper_text: str, prompt: str) -> Formalization:
        text = self._chat(
            [
                {"role": "system", "content": prompt},
                {"role": "user", "content": f"PAPER ID: {paper_id}\n\n{paper_text}"},
            ]
        )
        result = parse_model_output(paper_id, text)
        result.provider = self.name
        result.model = self.config.model
        return result

    def repair(self, paper_id: str, previous: Formalization, errors: list[str], prompt: str) -> Formalization | None:
        if previous.lean is None:
            return None
        feedback = "\n".join(f"- {e}" for e in errors)
        text = self._chat(
            [
                {"role": "system", "content": prompt},
                {
                    "role": "user",
                    "content": (
                        f"PAPER ID: {paper_id}\n\nYour previous module failed to compile:\n\n"
                        f"```lean\n{previous.lean}\n```\n\nCompiler messages:\n{feedback}\n\n"
                        "Return a corrected module in the same JSON format, or decline with "
                        "a reason if the paper cannot be expressed in the kernel."
                    ),
                },
            ]
        )
        result = parse_model_output(paper_id, text)
        result.provider = self.name
        result.model = self.config.model
        return result


class FixtureProvider:
    """Hand-written formalizations standing in for a model run."""

    name = "fixture"

    def __init__(self, fixture_dir: Path) -> None:
        self.fixture_dir = fixture_dir

    def available(self) -> list[str]:
        return sorted(p.stem for p in self.fixture_dir.glob("*.yaml"))

    def formalize(self, paper_id: str, paper_text: str, prompt: str) -> Formalization:
        path = self.fixture_dir / f"{paper_id}.yaml"
        if not path.exists():
            raise FileNotFoundError(
                f"no fixture formalization for '{paper_id}' at {path}; "
                f"available: {', '.join(self.available()) or 'none'}"
            )
        with path.open(encoding="utf-8") as fh:
            data = yaml.safe_load(fh) or {}
        lean = data.get("module")
        declined = bool(data.get("declined", False)) or not lean
        return Formalization(
            paper_id=paper_id,
            lean=lean if not declined else None,
            declined=declined,
            reason=str(data.get("reason", "")),
            ambiguities=[str(a) for a in data.get("ambiguities", [])],
            provider=self.name,
            model=str(data.get("model", "hand-written fixture")),
            raw=path.read_text(encoding="utf-8"),
        )

    def repair(self, paper_id: str, previous: Formalization, errors: list[str], prompt: str) -> Formalization | None:
        # Fixtures are fixed by construction; a failing fixture documents a failure mode.
        return None
