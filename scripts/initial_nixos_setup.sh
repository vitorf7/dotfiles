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
#   2. Clone/pull nvim-kick to $HOME/nvim-kick
#      (core.nix symlinks ~/.config/nvim -> ~/nvim-kick on every host)
#   3. Stow the nixos package  ($HOME/.nixos symlink)
#   4. Copy /etc/nixos/hardware-configuration.nix into the host directory
#      and git-stage it (required — Nix flakes ignore untracked files)
#   5. Run `nixos-rebuild boot --flake .#<hostname>` (activates on next reboot)
#
# Secret management:
#   - nixos/.nixos/secrets/wiresteward-secrets.nix is imported at nix eval time
#     and stays strongbox-encrypted. The strongbox keyring must be present before
#     running this script on thinkpad-t480.
#   - nixos/.nixos/sops/nixos/wiresteward-config.json is sops-encrypted and
#     decrypted automatically by sops-nix at activation time using the age key.
#   - The sops age key (/etc/sops/age/keys.txt) must be in place before the
#     first nixos-rebuild — retrieve it from 1Password ("age key — <hostname>"),
#     or generate a new one with: sudo age-keygen -o /etc/sops/age/keys.txt
#
# Prerequisites:
#   - /etc/nixos/hardware-configuration.nix already generated
#     (if not: sudo nixos-generate-config)
#   - thinkpad-t480 only: ~/.strongbox_keyring present (1Password)
#   - thinkpad-t480 only: /etc/sops/age/keys.txt present (1Password: "age key — thinkpad-t480")

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
    info "Updating dotfiles at ${_dotfiles_target}…"
    git -C "$_dotfiles_target" pull origin master || \
      nix-shell -p git --run "git -C '$_dotfiles_target' pull origin master"
  elif [[ -e "$_dotfiles_target" ]]; then
    die "$_dotfiles_target exists but is not a git repo. Remove it and retry."
  else
    info "Cloning dotfiles to ${_dotfiles_target}…"
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

# ─── Pre-flight: nvim-kick clone/pull (next to dotfiles) ─────────────────────
# core.nix symlinks ~/.config/nvim -> ~/nvim-kick unconditionally, so this
# needs to exist before the build (mirrors initial_macos_setup.sh).
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

# ─── Pre-flight: wiresteward secrets + sops age key (T480 only) ──────────────
# wiresteward-secrets.nix is imported at nix eval time so it stays strongbox-
# encrypted — the strongbox keyring must be present and the file must be plaintext
# on disk before nixos-rebuild runs.
# wiresteward-config.json is now sops-encrypted and decrypted automatically at
# activation by sops-nix; no manual checkout needed for it.
# The sops age key must also be present before the first activation.
if [[ "$HOSTNAME" == "thinkpad-t480" ]]; then
  # ── Strongbox (wiresteward-secrets.nix) ──
  info "Checking strongbox keyring…"
  if [[ ! -f "$HOME/.strongbox_keyring" ]]; then
    die "~/.strongbox_keyring not found.\n   Retrieve from 1Password, save to ~/.strongbox_keyring, then re-run."
  fi

  git config --global filter.strongbox.clean "strongbox -clean %f"
  git config --global filter.strongbox.smudge "strongbox -smudge %f"
  git config --global filter.strongbox.required true
  git config --global diff.strongbox.textconv "strongbox -diff"

  info "Building strongbox…"
  STRONGBOX_OUT=$(nix build --no-link --print-out-paths \
    --extra-experimental-features 'nix-command flakes' \
    "$DOTFILES/nixos/.nixos#strongbox")
  export PATH="$STRONGBOX_OUT/bin:$PATH"

  if head -1 "$DOTFILES/nixos/.nixos/secrets/wiresteward-secrets.nix" 2>/dev/null \
      | grep -q 'STRONGBOX ENCRYPTED RESOURCE'; then
    git -C "$DOTFILES" checkout -- nixos/.nixos/secrets
    ok "Wiresteward secrets decrypted."
  else
    ok "Wiresteward secrets already decrypted — leaving as-is."
  fi

  # ── sops age key (wiresteward-config.json + fish private_config) ──
  info "Checking sops age key…"
  SOPS_KEY="/etc/sops/age/keys.txt"
  if [[ ! -f "$SOPS_KEY" ]]; then
    die "sops age key not found at $SOPS_KEY.\n   Retrieve from 1Password (\"age key — thinkpad-t480\"), then:\n     sudo mkdir -p /etc/sops/age\n     sudo cp <key-file> $SOPS_KEY\n     sudo chmod 600 $SOPS_KEY\n   To generate a new key instead: sudo age-keygen -o $SOPS_KEY\n   Then add the public key to .sops.yaml and re-encrypt."
  fi
  ok "sops age key present."
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
echo -e "  2. Verify sops secrets decrypted (thinkpad): ${BLU}sudo cat /etc/wiresteward/config.json${RST}"
echo -e "  3. Commit the staged hardware config once you're happy:"
echo -e "     ${BLU}git -C $DOTFILES commit -m 'feat(nixos): add hardware config for $HOSTNAME'${RST}"

if [[ "$HOSTNAME" == "thinkpad-t480" ]]; then
  echo
  warn "NVIDIA bus IDs were auto-detected and set to Intel=$INTEL_ID / NVIDIA=$NVIDIA_ID"
  warn "Verify with: lspci | grep -E 'VGA|3D'"
fi
