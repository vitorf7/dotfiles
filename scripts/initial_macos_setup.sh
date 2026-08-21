#!/usr/bin/env bash
# initial_macos_setup.sh — Bootstrap a fresh macOS machine from dotfiles
#
# Remote one-liner:
#   bash <(curl -sL https://raw.githubusercontent.com/vitorf7/dotfiles/master/scripts/initial_macos_setup.sh) <hostname>
#   # or: curl -sL <URL> | bash -s -- <hostname>
#
# Local (dotfiles already cloned):
#   ./scripts/initial_macos_setup.sh <hostname>
#
# Example:
#   ./scripts/initial_macos_setup.sh uw-mac-m1
#
# What it does:
#   1. Check Xcode Command Line Tools (required for Homebrew)
#   2. Install Homebrew if absent
#   3. Install Nix (NixOS/nix-installer) if absent
#   4. Clone / pull dotfiles to $HOME/dotfiles, and nvim-kick to $HOME/nvim-kick
#      (core.nix symlinks ~/.config/nvim -> ~/nvim-kick on every host)
#   5. Wire strongbox git filter (required for nixos/.nixos/secrets/* in the repo)
#      and verify the sops age key is in place (sops-nix decrypts secrets on activation)
#   6. Stow the nixos package ($HOME/.nixos symlink — same as Linux, makes nrs work)
#   7. First nix-darwin activation (darwin-rebuild does not exist until this succeeds)
#      sops-nix activation decrypts fish/private_config.fish and weather_vars.lua
#   8. Build + install SbarLua (sketchybar Lua bindings) — requires Homebrew lua
#      and readline (keg-only, so CPATH must be set explicitly during build)
#   9. Set macOS hostname via scutil (best-effort; MDM may reassert its own name)
#  10. Set fish as the default login shell (chsh) if not already set
#  11. Record the flake host in ~/.config/nix-darwin-host so `nrs` (no args)
#      works from now on — macOS hostname can't be trusted for this (MDM
#      like Jamf/Kandji can reassert an asset-tag-based ComputerName that
#      doesn't match the flake attribute)
#
# Prerequisites:
#   - ~/.strongbox_identity present (retrieve from 1Password — needed for git filter
#     on nixos/.nixos/secrets/wiresteward-secrets.nix)
#   - ~/.config/sops/age/keys.txt present (retrieve from 1Password as
#     "age key — <hostname>" — needed for sops-nix to decrypt secrets on activation)
#
# After the script completes:
#   1. Open a new terminal and verify Nix tools are on PATH
#   2. After a week of use, flip homebrew.onActivation.cleanup to "zap" in homebrew.nix

set -euo pipefail

# ─── Colours ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
YLW='\033[0;33m'
GRN='\033[0;32m'
BLU='\033[0;34m'
BLD='\033[1m'
RST='\033[0m'

info()  { echo -e "${BLU}::${RST} $*"; }
ok()    { echo -e "${GRN}✓${RST}  $*"; }
warn()  { echo -e "${YLW}⚠${RST}  $*"; }
die()   { echo -e "${RED}✗${RST}  $*" >&2; exit 1; }

# ─── Usage ────────────────────────────────────────────────────────────────────
usage() {
  echo -e "${BLD}Usage:${RST} $(basename "$0") <hostname>"
  echo
  echo "Available hosts:"
  ls "${DOTFILES:-$DOTFILES_TARGET}/nixos/.nixos/modules/hosts" 2>/dev/null | sed 's/^/  /'
  exit 1
}

# ─── Safety ───────────────────────────────────────────────────────────────────
[[ $EUID -eq 0 ]] && die "Do not run as root."
[[ "$(uname)" == "Darwin" ]] || die "This script is macOS-only."

# ─── Bootstrap: clone/pull dotfiles when run remotely (curl | bash) ──────────
_script_src="${BASH_SOURCE[0]:-}"
_candidate_dir="$(cd "$(dirname "$_script_src")" 2>/dev/null && pwd)" || _candidate_dir=""
_candidate_dotfiles="$(dirname "$_candidate_dir")"

DOTFILES_TARGET="$HOME/dotfiles"

if [[ ! -f "$_candidate_dotfiles/nixos/.nixos/flake.nix" ]]; then
  if [[ -d "$DOTFILES_TARGET/.git" ]]; then
    info "Updating dotfiles at ${DOTFILES_TARGET}…"
    git -C "$DOTFILES_TARGET" pull origin master || {
      warn "git pull failed (git may not be installed yet) — re-downloading tarball…"
      curl -fsSL https://github.com/vitorf7/dotfiles/archive/refs/heads/master.tar.gz \
        | tar xz -C "$DOTFILES_TARGET" --strip-components=1
    }
  elif [[ -e "$DOTFILES_TARGET" ]]; then
    die "$DOTFILES_TARGET exists but is not a git repo. Remove it and retry."
  else
    info "Cloning dotfiles to ${DOTFILES_TARGET}…"
    git clone https://github.com/vitorf7/dotfiles.git "$DOTFILES_TARGET" 2>/dev/null || {
      info "git not available — downloading tarball instead (Xcode CLT will be installed in Step 1)…"
      mkdir -p "$DOTFILES_TARGET"
      curl -fsSL https://github.com/vitorf7/dotfiles/archive/refs/heads/master.tar.gz \
        | tar xz -C "$DOTFILES_TARGET" --strip-components=1
    }
  fi
  exec bash "$DOTFILES_TARGET/scripts/initial_macos_setup.sh" "$@"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES="$(dirname "$SCRIPT_DIR")"

# ─── Argument validation ──────────────────────────────────────────────────────
[[ $# -eq 1 ]] || { echo -e "${RED}error:${RST} hostname argument required" >&2; usage; }
HOSTNAME_ARG="$1"
HOST_DIR="$DOTFILES/nixos/.nixos/modules/hosts/$HOSTNAME_ARG"

if [[ ! -d "$HOST_DIR" ]]; then
  echo -e "${RED}error:${RST} unknown host '${HOSTNAME_ARG}'" >&2
  usage
fi

# ─── Step 1: Xcode Command Line Tools ────────────────────────────────────────
info "Checking Xcode Command Line Tools…"
if ! xcode-select -p &>/dev/null; then
  warn "Xcode CLT not found. Triggering installer…"
  xcode-select --install
  echo
  die "Xcode CLT installation opened. Re-run this script after it completes."
fi
ok "Xcode CLT present: $(xcode-select -p)"

# ─── Step 2: Homebrew ─────────────────────────────────────────────────────────
info "Checking Homebrew…"
if ! command -v brew &>/dev/null; then
  info "Installing Homebrew…"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
  ok "Homebrew installed."
else
  ok "Homebrew already present: $(brew --version | head -1)"
fi

# ─── Step 3: Nix (NixOS/nix-installer) ───────────────────────────────────────
info "Checking Nix…"

_nix_is_working() {
  command -v nix &>/dev/null && nix --version &>/dev/null && return 0
  [[ -x /nix/var/nix/profiles/default/bin/nix ]] && \
    /nix/var/nix/profiles/default/bin/nix --version &>/dev/null && return 0
  return 1
}

_nix_artifacts_exist() {
  [[ -d /nix ]] && return 0
  [[ -f /etc/synthetic.conf ]] && grep -q '^nix$' /etc/synthetic.conf 2>/dev/null && return 0
  [[ -f /etc/fstab ]] && grep -q 'nix' /etc/fstab 2>/dev/null && return 0
  [[ -f /Library/LaunchDaemons/systems.determinate.nix-store.plist ]] && return 0
  [[ -f /Library/LaunchDaemons/org.nixos.nix-daemon.plist ]] && return 0
  return 1
}

_nix_install() {
  curl -fsSL https://artifacts.nixos.org/nix-installer \
    | sh -s -- install --no-confirm "$@"
}

_nix_source_env() {
  # shellcheck disable=SC1091
  if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  fi
}

if _nix_is_working; then
  ok "Nix already present: $(nix --version)"
elif _nix_artifacts_exist; then
  warn "Partial/failed Nix installation detected."

  if [[ -x /nix/nix-installer && -f /nix/receipt.json ]]; then
    info "Found /nix/nix-installer and receipt.json — automated cleanup is available."
    echo -e "  This will run: ${BLU}sudo /nix/nix-installer uninstall --no-confirm${RST}"
    echo -e "  Then reinstall Nix from scratch."
    echo
    read -r -p "Proceed with cleanup and reinstall? [y/N] " _reply
    [[ "$_reply" =~ ^[Yy]$ ]] || die "Aborted. Run this script again when ready."
    sudo /nix/nix-installer uninstall --no-confirm
    info "Cleanup complete. Re-installing Nix…"
    _nix_install
    _nix_source_env
    ok "Nix installed (after cleanup)."

  elif [[ -x /nix/nix-installer ]]; then
    warn "No /nix/receipt.json found — will attempt install with --force."
    echo -e "  This will run: ${BLU}curl … | sh -s -- install --no-confirm --force${RST}"
    echo
    read -r -p "Proceed with --force install? [y/N] " _reply
    [[ "$_reply" =~ ^[Yy]$ ]] || die "Aborted. Run this script again when ready."
    _nix_install --force
    _nix_source_env
    ok "Nix installed (with --force)."

  else
    echo
    die "Partial Nix install detected but /nix/nix-installer is missing.\n\
   Manual cleanup required before retrying:\n\n\
   1. Find and remove the orphaned Nix Store APFS volume — 'deleteVolume /nix'\n\
      won't work here since /nix likely never mounted successfully:\n\
      ${BLU}diskutil apfs list | grep -i 'nix store'   # note its diskXsY identifier${RST}\n\
      ${BLU}sudo diskutil apfs deleteVolume <diskXsY>${RST}\n\
   2. Remove the /etc/fstab entry for Nix:\n\
      ${BLU}sudo vifs   # delete the line containing 'nix'${RST}\n\
   3. Remove the synthetic.conf entry:\n\
      ${BLU}sudo sed -i '' '/^nix\$/d' /etc/synthetic.conf${RST}\n\
   4. Remove LaunchDaemons:\n\
      ${BLU}sudo rm -f /Library/LaunchDaemons/systems.determinate.nix-* /Library/LaunchDaemons/org.nixos.nix-daemon.plist${RST}\n\
   5. Remove the mount point:\n\
      ${BLU}sudo rm -rf /nix${RST}\n\
   6. Reboot, then re-run this script.\n"
  fi
else
  info "Installing Nix…"
  _nix_install
  _nix_source_env
  ok "Nix installed."
fi

NIX_OPTS=(--extra-experimental-features 'nix-command flakes')

# ─── Helper: git with nix-shell fallback (available now that Nix is installed) ─
if command -v git &>/dev/null; then
  _git() { git "$@"; }
else
  info "git not in PATH — routing git calls through nix-shell…"
  _git() { nix-shell -p git --run "git $*"; }
fi

# ─── Step 4: Dotfiles clone/pull (already done above if remote, skip if local) ─
if [[ -d "$DOTFILES_TARGET/.git" ]]; then
  ok "Dotfiles present at $DOTFILES (git repo)."
elif [[ -d "$DOTFILES_TARGET" ]]; then
  info "Converting tarball-extracted dotfiles to git repo…"
  rm -rf "$DOTFILES_TARGET"
  _git clone https://github.com/vitorf7/dotfiles.git "$DOTFILES_TARGET"
  DOTFILES="$DOTFILES_TARGET"
  ok "Dotfiles cloned (replaced tarball) at $DOTFILES"
else
  info "Cloning dotfiles to ${DOTFILES_TARGET}…"
  _git clone https://github.com/vitorf7/dotfiles.git "$DOTFILES_TARGET"
  DOTFILES="$DOTFILES_TARGET"
  ok "Dotfiles cloned at $DOTFILES"
fi

# ─── Step 4b: nvim-kick clone/pull (next to dotfiles, same as Linux hosts) ────
# core.nix symlinks ~/.config/nvim -> ~/nvim-kick unconditionally, so this
# needs to exist before the first nix-darwin switch links it.
NVIM_KICK_TARGET="$HOME/nvim-kick"
if [[ -d "$NVIM_KICK_TARGET/.git" ]]; then
  info "Updating nvim-kick at ${NVIM_KICK_TARGET}…"
  git -C "$NVIM_KICK_TARGET" pull origin master || \
    nix-shell -p git --run "git -C '$NVIM_KICK_TARGET' pull origin master"
elif [[ -e "$NVIM_KICK_TARGET" ]]; then
  die "$NVIM_KICK_TARGET exists but is not a git repo. Remove it and retry."
else
  info "Cloning nvim-kick to ${NVIM_KICK_TARGET}…"
  git clone https://github.com/vitorf7/nvim-kick "$NVIM_KICK_TARGET" || \
    nix-shell -p git --run "git clone https://github.com/vitorf7/nvim-kick '$NVIM_KICK_TARGET'"
fi
ok "nvim-kick present at $NVIM_KICK_TARGET"

# ─── Step 5: Strongbox + sops age key ────────────────────────────────────────
# Strongbox: still required as a git filter for nixos/.nixos/secrets/* (the
# wiresteward-secrets.nix file is imported at nix eval time and stays on
# strongbox). Fish and sketchybar secrets are now managed by sops-nix and
# decrypted automatically at activation — no manual checkout needed.
#
# sops age key: must be in place before darwin-rebuild switch so sops-nix can
# decrypt secrets during activation.
info "Checking strongbox keyring…"
if [[ ! -f "$HOME/.strongbox_identity" ]]; then
  die "~/.strongbox_identity not found.\n   Retrieve from 1Password, save to ~/.strongbox_identity, then re-run."
fi

# Wire the strongbox git filter (needed before any git operations on nixos/.nixos/secrets/*)
_git config --global filter.strongbox.clean "strongbox -clean %f"
_git config --global filter.strongbox.smudge "strongbox -smudge %f"
_git config --global filter.strongbox.required true
_git config --global diff.strongbox.textconv "strongbox -diff"

# Build strongbox from the flake so the git filter binary is available
info "Building strongbox…"
STRONGBOX_OUT=$(nix build "${NIX_OPTS[@]}" --no-link --print-out-paths \
  "$DOTFILES/nixos/.nixos#strongbox")
export PATH="$STRONGBOX_OUT/bin:$PATH"
ok "strongbox: $(strongbox -version 2>/dev/null || echo 'built')"

# sops age key — sops-nix decrypts fish/private_config.fish and weather_vars.lua
# automatically during activation; the key must exist first.
info "Checking sops age key…"
SOPS_KEY="$HOME/.config/sops/age/keys.txt"
if [[ ! -f "$SOPS_KEY" ]]; then
  die "sops age key not found at $SOPS_KEY.\n   Retrieve from 1Password (\"age key — ${HOSTNAME_ARG}\"), save it there, then re-run.\n   To generate a new key: mkdir -p ~/.config/sops/age && age-keygen -o $SOPS_KEY"
fi
ok "sops age key present."

# ─── Step 6: Stow nixos → ~/.nixos ───────────────────────────────────────────
# This creates ~/.nixos -> dotfiles/nixos/.nixos — same as on Linux —
# so the nrs fish function works identically on both OSes.
info "Stowing nixos package to create ~/.nixos…"
if [[ ! -e "$HOME/.nixos" ]]; then
  if command -v stow &>/dev/null && command -v git &>/dev/null; then
    stow -v -d "$DOTFILES" -t "$HOME" --restow nixos
  else
    info "stow/git not in PATH — running via nix-shell…"
    nix-shell -p stow git --run \
      "stow -v -d '$DOTFILES' -t '$HOME' --restow nixos"
  fi
  ok "Symlink created: $HOME/.nixos → $DOTFILES/nixos/.nixos"
else
  ok "~/.nixos already exists — skipping stow."
fi

# ─── Step 7: First darwin-rebuild switch ──────────────────────────────────────
echo
echo -e "${BLD}Activating nix-darwin configuration for ${HOSTNAME_ARG}…${RST}"
echo -e "(${YLW}darwin-rebuild${RST} does not exist until this first activation)"
echo

# Move /etc files nix-darwin wants to own, if present and not yet moved.
# /etc/nix/nix.conf: Nix itself (Step 3) writes this as a plain file before
# nix-darwin ever runs — with nix.enable defaulting to true, this clashes on
# every fresh install. /etc/shells: macOS ships one by default; environment.shells
# above needs to replace it.
for f in /etc/bashrc /etc/zshrc /etc/zprofile /etc/zshenv /etc/nix/nix.conf /etc/shells; do
  if [[ -f "$f" && ! -f "${f}.before-nix-darwin" ]]; then
    info "Moving ${f} aside for nix-darwin…"
    sudo mv "$f" "${f}.before-nix-darwin"
  fi
done

sudo nix "${NIX_OPTS[@]}" run nix-darwin -- switch --flake "$HOME/.nixos#${HOSTNAME_ARG}"

# ─── Step 7b: Bootstrap standalone home-manager (for the `hm` command) ──────
# `programs.home-manager.enable` inside the darwin-integrated
# home-manager.users.<user> block never self-installs the standalone
# `home-manager` CLI — home-manager's own module gates that on
# `!submoduleSupport.enable`, which the darwin integration always sets true.
# So darwin-rebuild alone will never provide the CLI, no matter how many
# times it's run. Bootstrap it once here via the flake's own
# homeConfigurations.<host> output, which shares its home-manager module
# config with the darwin-integrated one (see hosts/<host>/default.nix) so
# this can never drift into a competing generation — both write to the same
# ~/.local/state/nix/profiles/home-manager lineage. This self-installs the
# `home-manager` package going forward, so `hm`/`home-manager news`/
# `home-manager generations` etc. work afterward without further bootstrap.
info "Bootstrapping standalone home-manager (for the 'hm' command)…"
nix "${NIX_OPTS[@]}" run github:nix-community/home-manager/master -- \
  switch -b hm-bak --flake "$HOME/.nixos#${HOSTNAME_ARG}"
ok "Standalone home-manager activated — 'hm'/'home-manager' now on PATH."

# ─── Step 8: SbarLua — Lua bindings for sketchybar ───────────────────────────
# Must run after nix-darwin activation so that Homebrew lua and readline are
# already installed. Homebrew readline is keg-only (not auto-linked). CPATH
# supplies headers; LIBRARY_PATH supplies the lib to gcc through nested makes.
info "Building and installing SbarLua…"
if [[ -f "$HOME/.local/share/sketchybar_lua/sketchybar.so" ]]; then
  ok "SbarLua already installed at ~/.local/share/sketchybar_lua/sketchybar.so — skipping."
else
  (
    SBARLUA_TMP=$(mktemp -d)
    GIT_CONFIG_GLOBAL=/dev/null git clone https://github.com/FelixKratz/SbarLua.git "$SBARLUA_TMP" || \
      nix-shell -p git --run "GIT_CONFIG_GLOBAL=/dev/null git clone https://github.com/FelixKratz/SbarLua.git '$SBARLUA_TMP'"
    cd "$SBARLUA_TMP"
    CPATH=/opt/homebrew/opt/readline/include LIBRARY_PATH=/opt/homebrew/opt/readline/lib make install
    rm -rf "$SBARLUA_TMP"
  )
  ok "SbarLua installed to ~/.local/share/sketchybar_lua/"
fi

# ─── Step 8b: sketchybar-app-font ────────────────────────────────────────────
# Required for aerospace workspace icons in sketchybar. The font is not in any
# Homebrew formula or Nix package — install it directly from GitHub releases.
info "Installing sketchybar-app-font…"
SBAR_FONT="$HOME/Library/Fonts/sketchybar-app-font.ttf"
if [[ -f "$SBAR_FONT" ]]; then
  ok "sketchybar-app-font already present — skipping."
else
  curl -L \
    "https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v2.0.28/sketchybar-app-font.ttf" \
    -o "$SBAR_FONT"
  ok "sketchybar-app-font installed to ~/Library/Fonts/"
fi

# ─── Step 9: Set macOS hostname ───────────────────────────────────────────────
# Best-effort: if the machine is MDM-managed (Jamf/Kandji) the MDM may
# reassert its own hostname after reboot. The ~/.config/nix-darwin-host file
# (Step 11) is the authoritative source for `nrs` regardless.
info "Setting macOS hostname to '${HOSTNAME_ARG}'…"
sudo scutil --set ComputerName  "${HOSTNAME_ARG}"
sudo scutil --set HostName      "${HOSTNAME_ARG}"
sudo scutil --set LocalHostName "${HOSTNAME_ARG}"
ok "Hostname set to '${HOSTNAME_ARG}'"

# ─── Step 10: Set fish as the default login shell ─────────────────────────────
FISH_PATH="/run/current-system/sw/bin/fish"
if [[ "$SHELL" == "$FISH_PATH" ]]; then
  ok "fish is already the default shell — skipping chsh."
elif grep -qF "$FISH_PATH" /etc/shells 2>/dev/null; then
  info "Setting fish as the default login shell…"
  chsh -s "$FISH_PATH"
  ok "Default shell set to $FISH_PATH (takes effect in a new terminal)."
else
  warn "$FISH_PATH is not yet in /etc/shells."
  warn "Open a new terminal and run: chsh -s $FISH_PATH"
fi

# ─── Step 11: Record the flake host for `nrs` ────────────────────────────────
# macOS hostname can't be trusted here — MDM (Jamf/Kandji/etc.) can reassert
# an asset-tag-based ComputerName that doesn't match the flake attribute.
# This file is what `nrs` (no args) reads on Darwin.
mkdir -p "$HOME/.config"
echo "$HOSTNAME_ARG" > "$HOME/.config/nix-darwin-host"
ok "Recorded flake host '${HOSTNAME_ARG}' → ~/.config/nix-darwin-host"

# ─── Step 12: Remove bootstrap ~/.gitconfig ───────────────────────────────────
# The strongbox git filter wiring (Step 5) wrote entries into ~/.gitconfig.
# nix-darwin activation (Step 7) has since deployed the full, home-manager-
# managed git config via symlink or generation. Remove the bootstrap file so
# the nix-managed config is the sole source of truth.
info "Removing bootstrap ~/.gitconfig (nix-managed config is now active)…"
if [[ -f "$HOME/.gitconfig" && ! -L "$HOME/.gitconfig" ]]; then
  rm "$HOME/.gitconfig"
  ok "Removed bootstrap ~/.gitconfig"
elif [[ -L "$HOME/.gitconfig" ]]; then
  ok "~/.gitconfig is already a symlink (nix-managed) — skipping removal."
else
  ok "~/.gitconfig not present — nothing to remove."
fi

# ─── Done ─────────────────────────────────────────────────────────────────────
echo
ok "Activation succeeded!"
echo
echo -e "  ${BLD}Next steps:${RST}"
echo -e "  1. Open a ${BLD}new terminal${RST} and verify Nix tools are on PATH:"
echo -e "     ${BLU}which git eza fd fzf starship${RST}"
echo -e "  2. Verify sops secrets decrypted: ${BLU}echo \$GITHUB_TOKEN${RST} (should be non-empty)"
echo -e "  3. Verify Homebrew packages: ${BLU}brew bundle check --global${RST}"
echo -e "  4. Once everything looks good, flip ${BLD}homebrew.onActivation.cleanup${RST} to ${BLU}\"zap\"${RST} in"
echo -e "     ${BLU}modules/darwin/homebrew.nix${RST} and run ${BLU}nrs${RST} again (host is now recorded)."
echo -e "  5. Sign into the Mac App Store, then run ${BLU}nrs${RST} once more to install mas apps."
