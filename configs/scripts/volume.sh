#!/usr/bin/env bash
# i3blocks volume widget: shows %, click to mute, scroll to change

STEP="5%"

# Handle clicks/scroll first
case "$BLOCK_BUTTON" in
  4) pactl set-sink-volume @DEFAULT_SINK@ +$STEP >/dev/null ;;
  5) pactl set-sink-volume @DEFAULT_SINK@ -$STEP >/dev/null ;;
  1) pactl set-sink-mute @DEFAULT_SINK@ toggle >/dev/null ;;
  3) pactl set-sink-volume @DEFAULT_SINK@ 100% >/dev/null ;;
esac

# Read state
vol=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | awk -F'/' 'NR==1{gsub(/ /,"");print $2}')
mute=$(pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | awk '{print $2}')

[ -z "$vol" ] && vol="--"

icon_span="<span font='FontAwesome 9'></span>"
color="#FFFFFF"
if [ "$mute" = "yes" ]; then
  icon_span="<span font='FontAwesome 9'></span>"
  color="#ff5555"
fi

# Output for i3blocks: text, short_text, color
printf "%s %s\n" "$icon_span" "$vol"
echo
echo "$color"
