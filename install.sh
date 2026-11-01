#!/usr/bin/env bash
# One-step Lemma setup for macOS and Linux.
#
#   curl -fsSL https://raw.githubusercontent.com/sumervaid/lemma/main/install.sh | bash
#
# Everything lands inside the Lemma folder, ~/.local/bin, ~/.elan and the uv cache.
# Options: --browse-only skips Lean, --dir PATH picks the folder.
set -euo pipefail

REPO_URL="${LEMMA_REPO_URL:-https://github.com/sumervaid/lemma}"
DEST="${LEMMA_HOME:-$HOME/lemma}"
WITH_LEAN=1

while [ $# -gt 0 ]; do
  case "$1" in
    --browse-only) WITH_LEAN=0 ;;
    --dir) shift; DEST="$1" ;;
    -h|--help) sed -n '2,8p' "${BASH_SOURCE[0]:-/dev/null}"; exit 0 ;;
    *) echo "Unknown option $1. Options are --browse-only and --dir PATH."; exit 2 ;;
  esac
  shift
done

say() { printf '\n==> %s\n' "$1"; }
LOG=""
on_error() {
  echo
  echo "Setup stopped before finishing."
  [ -n "$LOG" ] && [ -f "$LOG" ] && { echo "Last lines of $LOG:"; tail -20 "$LOG"; }
  echo "Please report the message above at $REPO_URL/issues"
  echo "The Explorer needs no setup: https://sumervaid.github.io/lemma/"
}
trap on_error ERR

case "$(uname -s)" in
  Darwin|Linux) ;;
  *)
    echo "This script supports macOS and Linux."
    echo "On Windows, use a Codespace: https://codespaces.new/sumervaid/lemma"
    exit 1
    ;;
esac

command -v curl >/dev/null || { echo "curl is required. Install curl, then run this script again."; exit 1; }

# Use the surrounding checkout when run from one. Otherwise fetch a copy.
HERE="$(cd "$(dirname "${BASH_SOURCE[0]:-/nonexistent}")" 2>/dev/null && pwd || true)"
if [ -n "$HERE" ] && [ -f "$HERE/lakefile.lean" ]; then
  ROOT="$HERE"
elif [ -f "$DEST/lakefile.lean" ]; then
  ROOT="$DEST"
  say "Using the existing copy at $ROOT"
else
  say "Downloading Lemma to $DEST"
  if command -v git >/dev/null; then
    git clone --quiet --depth 1 "$REPO_URL" "$DEST"
  else
    mkdir -p "$DEST"
    curl -fsSL "$REPO_URL/archive/refs/heads/main.tar.gz" | tar -xz --strip-components=1 -C "$DEST"
  fi
  ROOT="$DEST"
fi
cd "$ROOT"
mkdir -p "$ROOT/.lake"
LOG="$ROOT/.lake/install.log"
: > "$LOG"

export PATH="$HOME/.local/bin:$HOME/.elan/bin:$HOME/.cargo/bin:$PATH"

say "Setting up Python"
if ! command -v uv >/dev/null; then
  curl -LsSf https://astral.sh/uv/install.sh | env UV_NO_MODIFY_PATH=1 sh >>"$LOG" 2>&1
fi
[ -x .venv/bin/python ] || uv venv --quiet --python 3.13 .venv
uv pip install --quiet --python .venv/bin/python -e "pipeline[dev]"

if [ "$WITH_LEAN" = 1 ]; then
  say "Setting up Lean, a download of about 250 MB on the first run"
  if ! command -v lake >/dev/null; then
    curl -fsSL https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh \
      | sh -s -- -y --no-modify-path --default-toolchain none >>"$LOG" 2>&1
  fi
  say "Compiling the library, a minute or two on the first run"
  lake build Lemma >>"$LOG" 2>&1
fi

say "Adding the lemma command"
LAUNCHER="$ROOT/.venv/bin/lemma-launch"
cat > "$LAUNCHER" <<LAUNCH
#!/usr/bin/env bash
export PATH="\$HOME/.elan/bin:\$PATH"
exec "$ROOT/.venv/bin/python" -m lemma.cli --root "$ROOT" "\$@"
LAUNCH
chmod +x "$LAUNCHER"
mkdir -p "$HOME/.local/bin"
ln -sf "$LAUNCHER" "$HOME/.local/bin/lemma"

trap - ERR
echo
"$LAUNCHER" doctor || true
echo
echo "Lemma is ready at $ROOT"
case ":${ORIGINAL_PATH:-${PATH#"$HOME/.local/bin:$HOME/.elan/bin:$HOME/.cargo/bin:"}}:" in
  *":$HOME/.local/bin:"*) CMD="lemma" ;;
  *)
    CMD="$HOME/.local/bin/lemma"
    echo "To shorten the command to lemma, add this line to the shell profile:"
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    ;;
esac
echo
echo "Try these next"
echo "  $CMD tour"
echo "  $CMD site --open"
echo "  $CMD new"
