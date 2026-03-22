#!/usr/bin/env bash
# ───────────────────────────────────────────────────────────
#  lal installer — sets up lal (List Aliases) for your shell
# ───────────────────────────────────────────────────────────

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAL_PATH="$SCRIPT_DIR/lal.sh"

if [ ! -f "$LAL_PATH" ]; then
  echo "Error: lal.sh not found in $SCRIPT_DIR" >&2
  exit 1
fi

SOURCE_LINE="source \"$LAL_PATH\"  # lal — list aliases"

add_to_rc() {
  local rc="$1"
  if grep -qF "lal.sh" "$rc" 2>/dev/null; then
    echo "  Already installed in $rc — skipping."
  else
    printf '\n%s\n' "$SOURCE_LINE" >> "$rc"
    echo "  Added to $rc"
  fi
}

echo ""
echo "  Installing lal ..."
echo "  ──────────────────────────────────────────"

installed=0
if [ -f "$HOME/.zshrc" ]; then
  add_to_rc "$HOME/.zshrc"
  installed=1
fi
if [ -f "$HOME/.bashrc" ]; then
  add_to_rc "$HOME/.bashrc"
  installed=1
fi

if [ "$installed" -eq 0 ]; then
  echo "  No .zshrc or .bashrc found. Creating ~/.zshrc ..."
  add_to_rc "$HOME/.zshrc"
fi

echo ""
echo "  Done! To start using lal:"
echo ""
echo "    source ~/.zshrc    # (or open a new terminal)"
echo "    lal                # list and manage your aliases"
echo ""
