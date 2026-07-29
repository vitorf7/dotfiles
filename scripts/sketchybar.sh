#!/usr/bin/env bash
# sketchybar.sh — install / update the two things nix-darwin cannot manage:
#
#   1. SbarLua   — Lua bindings for sketchybar, built from source against
#                  Homebrew's lua. Must be rebuilt whenever sketchybar or
#                  Homebrew's lua is upgraded.
#
#   2. sketchybar-app-font — glyph font for app icons in the aerospace
#                            workspace indicator. Not in any Homebrew formula
#                            or Nix package.
#
# Everything else (sketchybar brew formula, lua, media-control, fonts) is
# managed declaratively by nix-darwin/homebrew.nix — do NOT re-add it here.
#
# Usage:
#   ./scripts/sketchybar.sh          # install / skip if already present
#   ./scripts/sketchybar.sh --force  # always rebuild SbarLua + re-download font

set -euo pipefail

FORCE="${1:-}"

RED='\033[0;31m'; GRN='\033[0;32m'; BLU='\033[0;34m'; RST='\033[0m'
info() { echo -e "${BLU}::${RST} $*"; }
ok()   { echo -e "${GRN}✓${RST}  $*"; }
die()  { echo -e "${RED}✗${RST}  $*" >&2; exit 1; }

# ── Prerequisites ─────────────────────────────────────────────────────────────
command -v brew   >/dev/null 2>&1 || die "Homebrew not found. Run nrs first."
command -v lua    >/dev/null 2>&1 || die "lua not found. Run nrs to install it via homebrew.nix."
command -v git    >/dev/null 2>&1 || die "git not found."

READLINE_INC="/opt/homebrew/opt/readline/include"
READLINE_LIB="/opt/homebrew/opt/readline/lib"
[[ -d "$READLINE_INC" ]] || die "Homebrew readline headers not found at $READLINE_INC. Run: brew install readline"

# ── 1. SbarLua ────────────────────────────────────────────────────────────────
SBAR_LUA="$HOME/.local/share/sketchybar_lua/sketchybar.so"

if [[ -f "$SBAR_LUA" && "$FORCE" != "--force" ]]; then
  ok "SbarLua already installed at $SBAR_LUA"
  echo "   Run with --force to rebuild (needed after sketchybar or lua upgrades)."
else
  info "Building SbarLua…"
  # Homebrew readline is keg-only — must supply headers (CPATH) and the lib
  # path (LIBRARY_PATH) explicitly so they propagate through nested make calls.
  (
    rm -rf /tmp/SbarLua
    git clone https://github.com/FelixKratz/SbarLua.git /tmp/SbarLua
    cd /tmp/SbarLua
    CPATH="$READLINE_INC" LIBRARY_PATH="$READLINE_LIB" make install
    rm -rf /tmp/SbarLua
  )
  ok "SbarLua installed to ~/.local/share/sketchybar_lua/"
fi

# ── 2. sketchybar-app-font ────────────────────────────────────────────────────
FONT_VERSION="v2.0.28"
FONT_PATH="$HOME/Library/Fonts/sketchybar-app-font.ttf"
FONT_URL="https://github.com/kvndrsslr/sketchybar-app-font/releases/download/${FONT_VERSION}/sketchybar-app-font.ttf"

if [[ -f "$FONT_PATH" && "$FORCE" != "--force" ]]; then
  ok "sketchybar-app-font already installed ($FONT_VERSION)"
else
  info "Downloading sketchybar-app-font ${FONT_VERSION}…"
  curl -fsSL "$FONT_URL" -o "$FONT_PATH"
  ok "sketchybar-app-font installed to ~/Library/Fonts/"
fi

# ── Done ──────────────────────────────────────────────────────────────────────
echo
ok "sketchybar extras ready. Restart sketchybar if it was already running:"
echo "   brew services restart felixkratz/formulae/sketchybar"
