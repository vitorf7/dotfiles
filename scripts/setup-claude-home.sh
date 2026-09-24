#!/usr/bin/env bash
set -euo pipefail

REAL_HOME="${HOME:?}"
ISOLATED="$REAL_HOME/.claude-home"
STAMP="$(date +%Y%m%d-%H%M%S)"

mkdir -p "$ISOLATED/.config" "$ISOLATED/.local/share"

link() {
  local name="$1"
  local target="$2"
  local link_path="$ISOLATED/$name"
  if [[ ! -e $target ]]; then
    echo "skip    $name (target $target missing)"
    return
  fi
  if [[ -L $link_path ]]; then
    ln -sfn "$target" "$link_path"
    echo "linked  $name -> $target"
  elif [[ -e $link_path ]]; then
    mv "$link_path" "$link_path.pre-isolation-$STAMP"
    ln -s "$target" "$link_path"
    echo "moved   $name to $name.pre-isolation-$STAMP"
    echo "linked  $name -> $target"
  else
    ln -s "$target" "$link_path"
    echo "linked  $name -> $target"
  fi
}

link ".claude" "$REAL_HOME/.claude"
link ".claude.json" "$REAL_HOME/.claude.json"
link ".ssh" "$REAL_HOME/.ssh"
link ".kube" "$REAL_HOME/.kube"
link ".config/rtk" "$REAL_HOME/.config/rtk"
link ".local/share/rtk" "$REAL_HOME/.local/share/rtk"

echo
echo "ready: claude now runs with HOME=$ISOLATED (fish claude function)"
