#!/usr/bin/env bash
# i3blocks battery widget using Font Awesome icons with Pango markup

BAT_PATH=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -n1)
if [ -z "$BAT_PATH" ]; then
  echo "<span font='FontAwesome'></span> --"
  echo
  echo "#ff5555"
  exit 0
fi

cap=$(cat "$BAT_PATH/capacity" 2>/dev/null || echo 0)
stat=$(cat "$BAT_PATH/status" 2>/dev/null || echo "Unknown")

# Pick icon based on capacity
icon="<span font='FontAwesome'></span>" # 0-10%
if [ "$cap" -ge 90 ]; then icon="<span font='FontAwesome'></span>"; fi
if [ "$cap" -lt 90 ] && [ "$cap" -ge 70 ]; then icon="<span font='FontAwesome'></span>"; fi
if [ "$cap" -lt 70 ] && [ "$cap" -ge 45 ]; then icon="<span font='FontAwesome'></span>"; fi
if [ "$cap" -lt 45 ] && [ "$cap" -ge 20 ]; then icon="<span font='FontAwesome'></span>"; fi

# If charging, show bolt in front
if [ "$stat" = "Charging" ]; then
  icon="<span font='FontAwesome'></span> $icon"
fi

# Color by level
color="#50fa7b"
if [ "$cap" -lt 20 ]; then color="#ff5555"; elif [ "$cap" -lt 45 ]; then color="#f1fa8c"; fi

printf "%s %s%%\n" "$icon" "$cap"
echo
echo "$color"
