#!/usr/bin/env bash
# ───────────────────────────────────────────────────────────
#  lal uninstaller — removes lal source line from shell rc
# ───────────────────────────────────────────────────────────

set -e

remove_from_rc() {
  local rc="$1"
  if [ ! -f "$rc" ]; then
    return
  fi
  if grep -qF "lal.sh" "$rc" 2>/dev/null; then
    # Remove lines containing the lal source marker
    local tmp="${rc}.lal.tmp"
    grep -vF "lal.sh" "$rc" > "$tmp" && mv "$tmp" "$rc"
    echo "  Removed from $rc"
  else
    echo "  Not found in $rc — skipping."
  fi
}

echo ""
echo "  Uninstalling lal ..."
echo "  ──────────────────────────────────────────"

remove_from_rc "$HOME/.zshrc"
remove_from_rc "$HOME/.bashrc"

echo ""
echo "  Done. Restart your terminal or run:  source ~/.zshrc"
echo "  You can safely delete the lal directory now."
echo ""
