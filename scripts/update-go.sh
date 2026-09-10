#!/usr/bin/env bash
set -euo pipefail

FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/nixos/.nixos/pkgs/go-latest.nix"

VERSION="$(curl -sf 'https://go.dev/dl/?mode=json' | jq -r '.[0].version' | sed 's/^go//')"
echo "Latest go version: ${VERSION}"

perl -pi -e "s|version = \"[^\"]*\"; # go-update:version|version = \"${VERSION}\"; # go-update:version|" "$FILE"

for pair in "x86_64-linux:linux-amd64" "aarch64-linux:linux-arm64" "aarch64-darwin:darwin-arm64"; do
  system="${pair%%:*}"
  suffix="${pair##*:}"
  url="https://go.dev/dl/go${VERSION}.${suffix}.tar.gz"
  echo "Prefetching ${system} (${url})..."
  hash="$(nix store prefetch-file --json "$url" | jq -r '.hash')"
  perl -pi -e "s|hash = \"[^\"]*\"; # go-update:${system}|hash = \"${hash}\"; # go-update:${system}|" "$FILE"
done

echo "Updated ${FILE} to go ${VERSION}"
