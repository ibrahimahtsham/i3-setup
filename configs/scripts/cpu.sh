#!/usr/bin/env bash
# i3blocks CPU usage widget: averages usage across all cores

ICON="<span font='FontAwesome 13'></span>"
STATE_FILE="/tmp/i3blocks_cpu_prev"

read -r TOTAL IDLE <<< "$(awk '/^cpu /{idle=$5+$6; for(i=2;i<=NF;i++) s+=$i; print s, idle}' /proc/stat)"

USAGE="--"
if [ -f "$STATE_FILE" ]; then
  read -r PTOTAL PIDLE < "$STATE_FILE"
  DT=$(( TOTAL - PTOTAL ))
  DI=$(( IDLE - PIDLE ))
  if [ $DT -gt 0 ]; then
    USED=$(( DT - DI ))
    USAGE=$(( 100 * USED / DT ))
  fi
fi

echo "$TOTAL $IDLE" > "$STATE_FILE"

COLOR="#FFFFFF"
if [ "$USAGE" != "--" ]; then
  if [ "$USAGE" -ge 85 ] 2>/dev/null; then COLOR="#ff5555"
  elif [ "$USAGE" -ge 60 ] 2>/dev/null; then COLOR="#f1fa8c"
  fi
fi

# Output for i3blocks: full_text, short_text, color
printf "%s %s%%\n" "$ICON" "$USAGE"
echo
echo "$COLOR"
