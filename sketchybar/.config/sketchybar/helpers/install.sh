#!/usr/bin/env bash
# Thin wrapper — delegates to the canonical sketchybar extras installer.
#
# All Homebrew packages (lua, sketchybar, media-control, fonts) are now
# managed declaratively by nix-darwin (homebrew.nix). This script only
# needs to handle SbarLua and sketchybar-app-font, both of which live in
# scripts/sketchybar.sh.
#
# Usage:
#   ./helpers/install.sh          # install / skip if already present
#   ./helpers/install.sh --force  # force rebuild of SbarLua + re-download font

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CANONICAL="$DOTFILES/scripts/sketchybar.sh"

if [[ ! -f "$CANONICAL" ]]; then
  echo "error: canonical script not found at $CANONICAL" >&2
  exit 1
fi

exec bash "$CANONICAL" "$@"
