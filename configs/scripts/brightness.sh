#!/usr/bin/env bash
# i3blocks brightness widget: shows % and supports scroll to change
# Uses brightnessctl if available; falls back to sysfs for read-only display

ICON_SPAN="<span font='FontAwesome'></span>"
STEP="5%"

has_bctl=0
if command -v brightnessctl >/dev/null 2>&1; then
  has_bctl=1
fi

try_set() {
  # Try to set brightness; if permission denied, retry via sg video
  if brightnessctl set "$1" >/dev/null 2>&1; then
    return 0
  fi
  if command -v sg >/dev/null 2>&1; then
    sg video -c "brightnessctl set '$1' >/dev/null" 2>/dev/null && return 0
  fi
  return 1
}

get_percent() {
  if [ $has_bctl -eq 1 ]; then
    # brightnessctl -m output: name,class,id,brightness%
    brightnessctl -m | awk -F, '{gsub("%","",$4); print $4}'
  else
    dev=$(ls -1 /sys/class/backlight 2>/dev/null | head -n1)
    if [ -n "$dev" ]; then
      max=$(cat "/sys/class/backlight/$dev/max_brightness")
      cur=$(cat "/sys/class/backlight/$dev/brightness")
      echo $(( cur * 100 / max ))
    else
      echo 0
    fi
  fi
}

# Handle clicks/scroll
case "$BLOCK_BUTTON" in
  4) [ $has_bctl -eq 1 ] && try_set "+$STEP" ;;
  5) [ $has_bctl -eq 1 ] && try_set "$STEP-" ;;
  1) [ $has_bctl -eq 1 ] && try_set "50%" ;;
  3) [ $has_bctl -eq 1 ] && try_set "100%" ;;
 esac

pct=$(get_percent)
[ -z "$pct" ] && pct=0

# Output for i3blocks: text, short_text, color
printf "%s %s%%\n" "$ICON_SPAN" "$pct"
echo
if [ "$pct" -lt 25 ]; then
  echo "#ff5555"
elif [ "$pct" -lt 60 ]; then
  echo "#FFFFFF"
else
  echo "#FFFFFF"
fi
