#!/usr/bin/env bash
set -euo pipefail

FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/nixos/.nixos/pkgs/claude-code-latest.nix"

BASE_URL="https://downloads.claude.ai/claude-code-releases"
VERSION="$(curl -sf "$BASE_URL/latest")"
echo "Latest claude-code version: ${VERSION}"

perl -pi -e "s|version = \"[^\"]*\"; # claude-update:version|version = \"${VERSION}\"; # claude-update:version|" "$FILE"

MANIFEST="$(curl -sf "$BASE_URL/$VERSION/manifest.zst.json")"

for platform in linux-x64 linux-arm64 darwin-arm64; do
  hash="$(printf '%s' "$MANIFEST" | jq -r ".platforms[\"$platform\"].checksum")"
  perl -pi -e "s|checksum = \"[^\"]*\"; # claude-update:${platform}|checksum = \"${hash}\"; # claude-update:${platform}|" "$FILE"
done

echo "Updated ${FILE} to claude-code ${VERSION}"
