#!/usr/bin/env bash
# Rofi launcher wrapper that ensures Flatpak applications show up
# by setting XDG_DATA_DIRS and PATH to include Flatpak export dirs.

set -euo pipefail

# Compute desired XDG_DATA_DIRS including Flatpak exports
FLATPAK_SHARE_USER="$HOME/.local/share/flatpak/exports/share"
FLATPAK_SHARE_SYS="/var/lib/flatpak/exports/share"

# Preserve existing XDG_DATA_DIRS if set; otherwise use sensible defaults
DEFAULT_XDG="/usr/local/share:/usr/share"
XDG_BASE="${XDG_DATA_DIRS:-$DEFAULT_XDG}"

# Prepend Flatpak dirs if not already present
prepend_unique() {
  local dir="$1"; shift
  local data="$1"
  if [[ -d "$dir" ]] && [[ ":$data:" != *":$dir:"* ]]; then
    printf "%s:%s" "$dir" "$data"
  else
    printf "%s" "$data"
  fi
}

XDG_WITH_FLATPAK="$XDG_BASE"
XDG_WITH_FLATPAK="$(prepend_unique "$FLATPAK_SHARE_USER" "$XDG_WITH_FLATPAK")"
XDG_WITH_FLATPAK="$(prepend_unique "$FLATPAK_SHARE_SYS" "$XDG_WITH_FLATPAK")"

# Ensure Flatpak bin exports are in PATH for run mode fallback
FLATPAK_BIN_USER="$HOME/.local/share/flatpak/exports/bin"
FLATPAK_BIN_SYS="/var/lib/flatpak/exports/bin"
PATH_WITH_FLATPAK="$PATH"
for d in "$FLATPAK_BIN_USER" "$FLATPAK_BIN_SYS"; do
  if [[ -d "$d" ]] && [[ ":$PATH_WITH_FLATPAK:" != *":$d:"* ]]; then
    PATH_WITH_FLATPAK="$PATH_WITH_FLATPAK:$d"
  fi
done

export XDG_DATA_DIRS="$XDG_WITH_FLATPAK"
export PATH="$PATH_WITH_FLATPAK"

# Launch rofi in drun mode with icons
exec rofi -modi drun,run -show drun -show-icons "$@"
