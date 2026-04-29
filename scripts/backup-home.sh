#!/usr/bin/env bash
# Mirror visible $HOME folders to a destination (e.g. external SSD).
# Usage:
#   ~/dotfiles/scripts/backup-home.sh /Volumes/BackupSSD/home
#   ~/dotfiles/scripts/backup-home.sh /Volumes/BackupSSD/home --dry-run
#
# What's backed up: visible top-level folders in $HOME (codes, Documents,
# Desktop, Downloads, Movies, Music, Pictures, dotfiles, Keys, Scripts, etc.)
#
# What's skipped (see backup-excludes.txt for the full list):
#   - All hidden dot-entries at $HOME root (.config, .cache, .aws, .nvm, …)
#   - bin/, opt/, Applications/, Library/, overrides_chrome/
#   - node_modules, .venv, build/dist dirs (recursively, anywhere)
#   - macOS junk (.DS_Store, caches, logs)

set -euo pipefail

DEST="${1:-}"
shift || true

if [[ -z "$DEST" ]]; then
  echo "usage: $0 <destination> [--dry-run]" >&2
  exit 2
fi

if [[ ! -d "$DEST" ]]; then
  echo "destination does not exist: $DEST" >&2
  echo "(create it first, or mount the drive)" >&2
  exit 1
fi

EXCLUDES="$HOME/dotfiles/backup-excludes.txt"
if [[ ! -f "$EXCLUDES" ]]; then
  echo "missing exclude file: $EXCLUDES" >&2
  exit 1
fi

echo "→ Source:      $HOME/"
echo "→ Destination: $DEST"
echo "→ Excludes:    $EXCLUDES"
echo

rsync -aHh --delete --stats \
  --info=progress2 \
  --exclude-from="$EXCLUDES" \
  "$@" \
  "$HOME/" "$DEST/"

echo
echo "✓ Done. Tip: run with --dry-run first if unsure."
