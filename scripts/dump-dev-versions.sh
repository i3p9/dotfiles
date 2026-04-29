#!/usr/bin/env bash
# Regenerate ~/dotfiles/dev-versions.txt from the live machine state.
# Usage: ~/dotfiles/scripts/dump-dev-versions.sh

set -euo pipefail

OUT="$HOME/dotfiles/dev-versions.txt"

# shellcheck disable=SC1091
[ -s "$HOME/.nvm/nvm.sh" ] && . "$HOME/.nvm/nvm.sh"

{
  echo "# Snapshot of language-runtime versions + globally installed packages."
  echo "# Re-generate with: ~/dotfiles/scripts/dump-dev-versions.sh"
  echo "# Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo
  echo "============================== nvm =============================="
  nvm ls --no-colors 2>/dev/null || echo "(nvm not loaded)"
  echo
  echo "----- npm globals per version -----"
  for v in $(nvm ls --no-colors 2>/dev/null | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | sort -uV); do
    echo
    echo "--- $v ---"
    nvm exec --silent "$v" npm ls -g --depth=0 2>/dev/null | tail -n +2 || true
  done

  echo
  echo "============================== pipx ============================="
  if command -v pipx >/dev/null 2>&1; then
    pipx list --short 2>/dev/null || true
  else
    echo "(pipx not installed)"
  fi

  echo
  echo "============================== cargo ============================"
  echo "# Tracked in the Brewfile (cargo \"...\" entries)."
} > "$OUT"

echo "Wrote $OUT"
