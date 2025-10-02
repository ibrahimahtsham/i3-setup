#!/usr/bin/env bash
# i3blocks RAM usage widget: percentage based on MemAvailable

ICON="<span font='FontAwesome'></span>"

read -r TOTAL AVAIL <<< "$(awk '
/^MemTotal:/ {t=$2}
/^MemAvailable:/ {a=$2}
END {print t, a}' /proc/meminfo)"

if [ -z "$TOTAL" ] || [ -z "$AVAIL" ]; then
  PCT="--"
else
  USED=$(( TOTAL - AVAIL ))
  PCT=$(( 100 * USED / TOTAL ))
fi

COLOR="#FFFFFF"
if [ "$PCT" != "--" ]; then
  if [ "$PCT" -ge 85 ] 2>/dev/null; then COLOR="#ff5555"
  elif [ "$PCT" -ge 60 ] 2>/dev/null; then COLOR="#f1fa8c"
  fi
fi

printf "%s %s%%\n" "$ICON" "$PCT"
echo
echo "$COLOR"
