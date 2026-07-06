#!/usr/bin/env bash
# initial_nixos_setup.sh — Bootstrap a fresh NixOS machine from dotfiles
#
# Remote one-liner (clones dotfiles automatically if absent, pulls if present):
#   bash <(curl -sL https://raw.githubusercontent.com/vitorf7/dotfiles/master/scripts/initial_nixos_setup.sh) <hostname>
#   # or: curl -sL <URL> | bash -s -- <hostname>
#
# Local (dotfiles already cloned):
#   ./scripts/initial_nixos_setup.sh <hostname>
#
# What it does:
#   1. Clone/pull dotfiles to $HOME/dotfiles (skipped when running locally)
#   2. Stow the nixos package  ($HOME/.nixos symlink)
#   3. Copy /etc/nixos/hardware-configuration.nix into the host directory
#      and git-stage it (required — Nix flakes ignore untracked files)
#   4. Run `nixos-rebuild boot --flake .#<hostname>` (activates on next reboot)
#
# Prerequisites:
#   - /etc/nixos/hardware-configuration.nix already generated
#     (if not: sudo nixos-generate-config)

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
  ls "$DOTFILES/nixos/.nixos/hosts" 2>/dev/null | sed 's/^/  /'
  exit 1
}

# ─── Bootstrap: clone/pull dotfiles when run remotely (curl | bash) ──────────
# Detect whether we're running from within the real dotfiles repo.
# When piped via curl, ${BASH_SOURCE[0]} is "/dev/fd/N", "bash", or empty —
# none of which resolve to a path containing nixos/.nixos/flake.nix.
_script_src="${BASH_SOURCE[0]:-}"
_candidate_dir="$(cd "$(dirname "$_script_src")" 2>/dev/null && pwd)" || _candidate_dir=""
_candidate_dotfiles="$(dirname "$_candidate_dir")"

if [[ ! -f "$_candidate_dotfiles/nixos/.nixos/flake.nix" ]]; then
  _dotfiles_target="$HOME/dotfiles"

  if [[ -d "$_dotfiles_target/.git" ]]; then
    info "Updating dotfiles at $_dotfiles_target…"
    git -C "$_dotfiles_target" pull origin master || \
      nix-shell -p git --run "git -C '$_dotfiles_target' pull origin master"
  elif [[ -e "$_dotfiles_target" ]]; then
    die "$_dotfiles_target exists but is not a git repo. Remove it and retry."
  else
    info "Cloning dotfiles to $_dotfiles_target…"
    git clone https://github.com/vitorf7/dotfiles.git "$_dotfiles_target" || \
      nix-shell -p git --run "git clone https://github.com/vitorf7/dotfiles.git '$_dotfiles_target'"
  fi

  # Re-exec from the real file so ${BASH_SOURCE[0]} resolves correctly from here on.
  exec bash "$_dotfiles_target/scripts/initial_nixos_setup.sh" "$@"
fi

# ─── Paths (derived from the script's own location) ───────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES="$(dirname "$SCRIPT_DIR")"

# ─── Argument validation ──────────────────────────────────────────────────────
[[ $# -eq 1 ]] || { echo -e "${RED}error:${RST} hostname argument required" >&2; usage; }
HOSTNAME="$1"
HOST_DIR="$DOTFILES/nixos/.nixos/hosts/$HOSTNAME"
FLAKE_DIR="$HOME/.nixos"

# ─── Safety checks ────────────────────────────────────────────────────────────
if [[ $EUID -eq 0 ]]; then
  die "Do not run this script as root. Only nixos-rebuild is called with sudo."
fi

if ! command -v nixos-rebuild &>/dev/null; then
  die "nixos-rebuild not found — is this actually a NixOS machine?"
fi

if [[ ! -d "$HOST_DIR" ]]; then
  echo -e "${RED}error:${RST} unknown host '${HOSTNAME}'" >&2
  usage
fi

if [[ ! -f /etc/nixos/hardware-configuration.nix ]]; then
  die "/etc/nixos/hardware-configuration.nix not found.\n   Run: sudo nixos-generate-config\n   Then re-run this script."
fi

# ─── Pre-flight: NVIDIA bus IDs (T480 only) ──────────────────────────────────
if [[ "$HOSTNAME" == "thinkpad-t480" ]]; then
  info "Detecting NVIDIA/Intel PCI bus IDs for PRIME offload…"

  # Bootstrap pciutils if lspci is not present on the minimal install
  if command -v lspci &>/dev/null; then
    _lspci_out=$(lspci)
  else
    info "lspci not in PATH — running via nix-shell…"
    _lspci_out=$(nix-shell -p pciutils --run lspci)
  fi

  # Convert lspci BB:DD.F (hex fields) to NixOS PCI:B:D:F (decimal fields)
  pci_to_nix() {
    local addr="$1" bus dev fn
    bus=$(printf '%d' "0x$(echo "$addr" | cut -d: -f1)")
    dev=$(printf '%d' "0x$(echo "$addr" | cut -d: -f2 | cut -d. -f1)")
    fn=$(printf  '%d' "0x$(echo "$addr" | cut -d. -f2)")
    echo "PCI:${bus}:${dev}:${fn}"
  }

  _intel_raw=$(echo "$_lspci_out"  | grep -i 'VGA' | grep -i intel  | awk '{print $1}' | head -1)
  _nvidia_raw=$(echo "$_lspci_out" | grep -i '3D'  | grep -i nvidia | awk '{print $1}' | head -1)

  [[ -n "$_intel_raw" ]]  || die "Could not detect Intel VGA device. Run: lspci | grep -i VGA"
  [[ -n "$_nvidia_raw" ]] || die "Could not detect NVIDIA 3D device. Run: lspci | grep -i 3D"

  INTEL_ID=$(pci_to_nix "$_intel_raw")
  NVIDIA_ID=$(pci_to_nix "$_nvidia_raw")
  ok "Intel  $_intel_raw  → $INTEL_ID"
  ok "NVIDIA $_nvidia_raw → $NVIDIA_ID"

  _NVIDIA_NIX="$DOTFILES/nixos/.nixos/modules/system/nvidia-hybrid.nix"
  sed -i "s|intelBusId = \".*\";|intelBusId = \"$INTEL_ID\";|"   "$_NVIDIA_NIX"
  sed -i "s|nvidiaBusId = \".*\";|nvidiaBusId = \"$NVIDIA_ID\";|" "$_NVIDIA_NIX"
  git -C "$DOTFILES" add "nixos/.nixos/modules/system/nvidia-hybrid.nix"
  ok "Updated and staged nvidia-hybrid.nix."
  echo
fi

# ─── Step 1: Stow the nixos package ──────────────────────────────────────────
info "Stowing nixos package…"

# stow and git may not be present on a minimal NixOS install — use nix-shell
# to bootstrap them without permanently installing anything.
if command -v stow &>/dev/null && command -v git &>/dev/null; then
  stow -v -d "$DOTFILES" -t "$HOME" --restow nixos
else
  info "stow/git not in PATH — running via nix-shell (this may take a moment)…"
  nix-shell -p stow git --run \
    "stow -v -d '$DOTFILES' -t '$HOME' --restow nixos"
fi

ok "Symlink created: $HOME/.nixos → $DOTFILES/nixos/.nixos"

# ─── Step 2: Copy + stage hardware-configuration.nix ─────────────────────────
HARDWARE_SRC=/etc/nixos/hardware-configuration.nix
HARDWARE_DST="$HOST_DIR/hardware-configuration.nix"
HARDWARE_REL="nixos/.nixos/hosts/$HOSTNAME/hardware-configuration.nix"

info "Copying hardware config for host '${HOSTNAME}'…"
cp "$HARDWARE_SRC" "$HARDWARE_DST"
ok "Copied $HARDWARE_SRC → $HARDWARE_DST"

info "Staging hardware config in git (required for flake evaluation)…"
if command -v git &>/dev/null; then
  git -C "$DOTFILES" add "$HARDWARE_REL"
else
  nix-shell -p git --run "git -C '$DOTFILES' add '$HARDWARE_REL'"
fi
ok "Staged: $HARDWARE_REL"

# ─── Step 3: Build ────────────────────────────────────────────────────────────
echo
echo -e "${BLD}Building NixOS configuration for '${HOSTNAME}'…${RST}"
echo -e "(${YLW}boot${RST} mode — activate by rebooting)"
echo

# Pass experimental-features explicitly: a fresh NixOS install may not have
# flakes enabled in /etc/nix/nix.conf yet.
sudo nixos-rebuild boot \
  --flake "${FLAKE_DIR}#${HOSTNAME}" \
  --option extra-experimental-features 'nix-command flakes'

# ─── Done ─────────────────────────────────────────────────────────────────────
echo
ok "Build succeeded!"
echo
echo -e "  Next steps:"
echo -e "  1. ${BLD}Reboot${RST} to activate the new configuration."
echo -e "  2. Commit the staged hardware config once you're happy:"
echo -e "     ${BLU}git -C $DOTFILES commit -m 'feat(nixos): add hardware config for $HOSTNAME'${RST}"

if [[ "$HOSTNAME" == "thinkpad-t480" ]]; then
  echo
  warn "NVIDIA bus IDs were auto-detected and set to Intel=$INTEL_ID / NVIDIA=$NVIDIA_ID"
  warn "Verify with: lspci | grep -E 'VGA|3D'"
fi
