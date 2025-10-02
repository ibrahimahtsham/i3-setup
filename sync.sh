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

# Seamless audio: enable PipeWire user services if available
if command -v systemctl >/dev/null 2>&1; then
  systemctl --user enable --now pipewire.socket pipewire-pulse.socket wireplumber.service >/dev/null 2>&1 || true
fi

# If PipeWire is present, try to pick a sensible default sink and set a sane volume
if command -v wpctl >/dev/null 2>&1; then
  # Prefer built-in Speaker, then Headphones, else first non-dummy sink
  SINK_ID=""
  # Get sinks as lines: "  59. Celeron... Speaker [vol: 0.40]"
  mapfile -t SINK_LINES < <(wpctl status 2>/dev/null | awk '/^\s*└─ Streams:/{p=0} /^Audio/{p=1} p && /^ \s*├─ Sinks:/{s=1;next} s && /^ \s*├─/{s=0} s')
  for l in "${SINK_LINES[@]}"; do
    id=$(echo "$l" | sed -n 's/^\s*[* ]\s*\([0-9]\+\)\. .*/\1/p')
    name=$(echo "$l" | sed -n 's/^\s*[* ]\s*[0-9]\+\. \(.*\) \[vol:.*/\1/p')
    [ -z "$id" ] && continue
    # Skip Dummy Output / auto_null
    echo "$name" | grep -qiE 'dummy|auto_null' && continue
    echo "$name" | grep -qi 'speaker' && { SINK_ID="$id"; break; }
    echo "$name" | grep -qi 'headphone' && { [ -z "$SINK_ID" ] && SINK_ID="$id"; continue; }
    # Fallback to first valid if none chosen yet
    [ -z "$SINK_ID" ] && SINK_ID="$id"
  done
  if [ -n "$SINK_ID" ]; then
    wpctl set-default "$SINK_ID" >/dev/null 2>&1 || true
    wpctl set-mute @DEFAULT_AUDIO_SINK@ 0 >/dev/null 2>&1 || true
    wpctl set-volume @DEFAULT_AUDIO_SINK@ 50% >/dev/null 2>&1 || true
  fi
fi

echo "Done. i3bar uses $ROOT/scripts/statusbar.sh (no i3status). Press Mod+Shift+R in i3 to reload."
