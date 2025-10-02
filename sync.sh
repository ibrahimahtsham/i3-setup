#!/usr/bin/env bash
set -euo pipefail

# Ultra-minimal sync: only create symlinks if they don't exist
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
mkdir -p "$HOME/.config/i3" "$HOME/.config/i3status"

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
link_once "$ROOT/configs/i3status/config" "$HOME/.config/i3status/config"

echo "Done. Edit files under $ROOT/configs/* and press Mod+Shift+R in i3 to apply."
