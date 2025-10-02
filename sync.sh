#!/usr/bin/env bash
set -euo pipefail

# Ultra-minimal sync: only create symlinks if they don't exist
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
mkdir -p "$HOME/.config/i3"

link_once() {
  local src="$1" dst="$2"
  if [ -L "$dst" ]; then
    echo "✓ Symlink exists: $dst -> $(readlink "$dst")"
  elif [ -e "$dst" ]; then
    echo "! Exists and is not a symlink: $dst (skipping)"
  else
    ln -s "$src" "$dst"
    echo "→ Linked: $dst -> $src"
  fi
}

link_once "$ROOT/configs/i3/config" "$HOME/.config/i3/config"

# Ensure custom status bar script is executable
if [ -f "$ROOT/scripts/statusbar.sh" ]; then
  chmod +x "$ROOT/scripts/statusbar.sh"
fi

echo "Done. i3bar uses $ROOT/scripts/statusbar.sh (no i3status). Press Mod+Shift+R in i3 to reload."
