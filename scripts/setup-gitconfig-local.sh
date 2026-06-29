#!/usr/bin/env bash
# setup-gitconfig-local.sh
#
# Creates ~/.gitconfig.local with your personal git identity and 1Password
# SSH signing key. This file is included by the Nix-managed git config but
# is never committed to the dotfiles repo.
#
# How to find your signing key:
#   1. Open 1Password -> your SSH key item
#   2. Click the public key field -> Copy
#   It looks like: ssh-ed25519 AAAA...
#   Alternatively: op read "op://Personal/<key-name>/public key"

set -euo pipefail

TARGET="$HOME/.gitconfig.local"

echo ""
echo "=== Git local config setup ==="
echo "This will create $TARGET"
echo ""

if [[ -f "$TARGET" ]]; then
  read -p "$TARGET already exists. Overwrite? (y/N): " confirm
  if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Aborted."
    exit 0
  fi
  echo ""
fi

read -p "Git name: " gitName
read -p "Git email: " gitEmail

echo ""
echo "Signing key: paste your SSH public key from 1Password"
echo "  -> Open 1Password -> SSH key item -> copy the public key (ssh-ed25519 AAAA...)"
echo "  -> Or run: op read \"op://Personal/<key-name>/public key\""
echo ""
read -p "Signing key: " signingKey

cat <<EOF >"$TARGET"
[user]
  name = $gitName
  email = $gitEmail
  signingKey = $signingKey
EOF

echo ""
echo "Written to $TARGET"
echo ""
echo "Verify with: git config --list | grep -E 'user|signing'"
