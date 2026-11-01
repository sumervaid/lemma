# Lemma: build, test, report.
#
# Lean toolchain: `lean` and `lake` on PATH, or LEMMA_LEAN_BIN pointing at the
# bin directory of a Lean 4.15.0 install. Python >= 3.11 with the pipeline
# installed (`make install`).

LEMMA_LEAN_BIN ?=
ifneq ($(LEMMA_LEAN_BIN),)
export PATH := $(LEMMA_LEAN_BIN):$(PATH)
endif

PY ?= python3
LEMMA ?= $(PY) -m lemma.cli

.PHONY: help setup doctor tour site install build test test-lean test-python lint format formalize check score distinct verify report clean

help:
	@echo "make setup      one-step setup: Python environment, Lean, compiled library"
	@echo "make doctor     state what works on this machine"
	@echo "make tour       the curated findings"
	@echo "make site       build the Explorer at site/index.html"
	@echo "make install    install the Python pipeline (editable) and dev tools"
	@echo "make build      lake build (kernel, library, theories, accepted generated modules)"
	@echo "make test       lake build LemmaTests (#guard_msgs) + pytest + ruff"
	@echo "make formalize  run the offline formalization pipeline over fixtures/papers"
	@echo "make check      compiler report -> reports/library.{json,md}"
	@echo "make score      verification agenda -> reports/agenda.md"
	@echo "make distinct   definitional vs empirical distinctness -> reports/distinctness.md"
	@echo "make verify     write a review sheet for human verification"
	@echo "make report     formalize + check + score + distinct + precision; refreshes README numbers"

setup:
	./install.sh

doctor:
	cd pipeline && $(LEMMA) --root .. doctor

tour:
	cd pipeline && $(LEMMA) --root .. tour

site:
	cd pipeline && $(LEMMA) --root .. site

install:
	$(PY) -m pip install -e pipeline[dev]

build:
	lake build

test: test-lean test-python lint

test-lean:
	lake build Lemma LemmaTests

test-python:
	cd pipeline && $(PY) -m pytest -q

lint:
	cd pipeline && ruff check . && ruff format --check .

format:
	cd pipeline && ruff format .

formalize:
	cd pipeline && $(LEMMA) --root .. formalize --offline

check:
	cd pipeline && $(LEMMA) --root .. check

score:
	cd pipeline && $(LEMMA) --root .. score

distinct:
	cd pipeline && $(LEMMA) --root .. distinct

verify:
	cd pipeline && $(LEMMA) --root .. verify --sample 20 --seed 1

report: formalize
	cd pipeline && $(LEMMA) --root .. report
	cd pipeline && $(LEMMA) --root .. verify --sample 20 --seed 1

clean:
	rm -rf .lake/build pipeline/.pytest_cache pipeline/.ruff_cache
	find . -name __pycache__ -type d -prune -exec rm -rf {} +
