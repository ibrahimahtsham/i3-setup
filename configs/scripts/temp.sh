#!/usr/bin/env bash
# i3blocks CPU temperature widget: reads from thermal zones, falls back to sensors

ICON="<span font='FontAwesome 13'></span>"
BEST=-1000000

choose() {
  local t="$1"
  case "${t,,}" in
    *pkg*|*cpu*|*x86*|*core*|*soc*|*acpi*|*pch*) echo 1 ;;
    *) echo 0 ;;
  esac
}

for Z in /sys/class/thermal/thermal_zone*; do
  [ -e "$Z/temp" ] || continue
  TYPE=$(cat "$Z/type" 2>/dev/null)
  TEMPmC=$(cat "$Z/temp" 2>/dev/null)
  [ -z "$TEMPmC" ] && continue
  if [ "$(choose "$TYPE")" -eq 1 ]; then
    [ "$TEMPmC" -gt "$BEST" ] 2>/dev/null && BEST="$TEMPmC"
  fi
done

if [ "$BEST" -lt 0 ] && command -v sensors >/dev/null 2>&1; then
  # Fallback: parse highest temp from lm-sensors
  HIGHEST=$(sensors 2>/dev/null | grep -Eo '[+]-?[0-9]+\.[0-9]+°C' | tr -d '+°C' | sort -nr | head -n1)
  if [ -n "$HIGHEST" ]; then
    TEMP="${HIGHEST%.*}"
  fi
else
  TEMP=$(( BEST / 1000 ))
fi

[ -z "$TEMP" ] && TEMP="--"

COLOR="#FFFFFF"
if [ "$TEMP" != "--" ]; then
  if [ "$TEMP" -ge 85 ] 2>/dev/null; then COLOR="#ff5555"
  elif [ "$TEMP" -ge 75 ] 2>/dev/null; then COLOR="#f1fa8c"
  fi
fi

printf "%s %s°C\n" "$ICON" "$TEMP"
echo
echo "$COLOR"
