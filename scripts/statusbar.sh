#!/usr/bin/env bash
# Minimal i3bar JSON status script (no extra deps)
# Order: BRI, V, BAT, Wi, C, G, R, T, time

set -uo pipefail

COLOR_GOOD="#00ff00"
COLOR_DEG="#ffcc00"
COLOR_BAD="#ff0000"

# Optional debug for click events: export STATUSBAR_DEBUG=1 to log events to /tmp/statusbar-clicks.log
DEBUG_CLICK="${STATUSBAR_DEBUG:-}"
DEBUG_LOG="/tmp/statusbar-clicks.log"

log_dbg() {
  if [ -n "$DEBUG_CLICK" ]; then
    printf '%s\n' "$*" >> "$DEBUG_LOG" 2>/dev/null || true
  fi
}

read_bri() {
  local b="/sys/class/backlight" dev raw max pct
  if [ -d "$b" ]; then
    dev=$(ls -1 "$b" 2>/dev/null | head -n1)
    if [ -n "$dev" ] && [ -r "$b/$dev/brightness" ] && [ -r "$b/$dev/max_brightness" ]; then
      raw=$(cat "$b/$dev/brightness")
      max=$(cat "$b/$dev/max_brightness")
      if [ "${max:-0}" -gt 0 ]; then
        pct=$(( raw * 100 / max ))
        echo "BRI: ${pct}%"; return
      fi
    fi
  fi
  echo "BRI: n/a"
}

# Adjust brightness by +/- percentage using brightnessctl if present, else sysfs
adj_bri_pct() {
  local delta="$1" # e.g., +5 or -5 (percent)
  local abs op
  abs="${delta#[-+]}"; op="+"; [ "${delta#-}" != "$delta" ] && op="-"
  if command -v brightnessctl >/dev/null 2>&1; then
    log_dbg "BRI using brightnessctl: ${abs}%${op}"
    if brightnessctl -q set "${abs}%${op}" >/dev/null 2>&1; then return; fi
  fi
  # Fallback to sysfs write (may require permissions)
  local b="/sys/class/backlight" dev raw max new
  dev=$(ls -1 "$b" 2>/dev/null | head -n1)
  if [ -n "$dev" ] && [ -r "$b/$dev/brightness" ] && [ -r "$b/$dev/max_brightness" ]; then
    raw=$(cat "$b/$dev/brightness")
    max=$(cat "$b/$dev/max_brightness")
    if [ "${max:-0}" -gt 0 ]; then
      local step=$(( max * ${delta#-} / 100 ))
      if [ "${delta#-}" != "$delta" ]; then
        new=$(( raw - step ))
      else
        new=$(( raw + step ))
      fi
      if [ $new -lt 1 ]; then new=1; fi
      if [ $new -gt $max ]; then new=$max; fi
      log_dbg "BRI using sysfs: new=$new (max=$max)"
      echo "$new" > "$b/$dev/brightness" 2>/dev/null || true
    fi
  fi
}

read_vol() {
  if command -v wpctl >/dev/null 2>&1; then
    # PipeWire
    local p
    p=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{print int($2*100)}')
    if [ -n "${p:-}" ]; then echo "V: ${p}%"; return; fi
  elif command -v pactl >/dev/null 2>&1; then
    # PulseAudio
    local s p
    s=$(pactl get-default-sink 2>/dev/null)
    p=$(pactl list sinks 2>/dev/null | awk -v s="$s" '/Name:/{n=$2} /Volume:/ && n==s{print $5; exit}')
    [ -n "$p" ] && echo "V: ${p}" && return
  elif command -v amixer >/dev/null 2>&1; then
    local p
    p=$(amixer sget Master 2>/dev/null | awk -F"[][]" '/%/{print $2; exit}')
    [ -n "$p" ] && echo "V: ${p}" && return
  fi
  echo "V: n/a"
}

# Adjust volume by +/- percentage using wpctl, pactl, or amixer
adj_vol_pct() {
  local delta="$1"   # e.g., +5 or -5
  local abs op
  abs="${delta#[-+]}"
  op="+"; [ "${delta#-}" != "$delta" ] && op="-"

  if command -v wpctl >/dev/null 2>&1; then
    # wpctl needs "5%+" or "5%-"; unmute when increasing
    log_dbg "VOL using wpctl: ${abs}%${op}"
    if [ "$op" = "+" ]; then wpctl set-mute @DEFAULT_AUDIO_SINK@ 0 >/dev/null 2>&1 || true; fi
    if wpctl set-volume @DEFAULT_AUDIO_SINK@ "${abs}%${op}" >/dev/null 2>&1; then return; fi
  fi
  if command -v pactl >/dev/null 2>&1; then
    # pactl supports "+5%" or "-5%"; unmute when increasing
    log_dbg "VOL using pactl: ${delta}%"
    if [ "$op" = "+" ]; then pactl set-sink-mute @DEFAULT_SINK@ 0 >/dev/null 2>&1 || true; fi
    if pactl set-sink-volume @DEFAULT_SINK@ "${delta}%" >/dev/null 2>&1; then return; fi
  fi
  if command -v amixer >/dev/null 2>&1; then
    # amixer needs "5%+" or "5%-"
    log_dbg "VOL using amixer: ${abs}%${op}"
    if [ "$op" = "+" ]; then amixer set Master unmute >/dev/null 2>&1 || true; fi
    amixer set Master "${abs}%${op}" >/dev/null 2>&1 || true
    return
  fi
}

read_bat() {
  local p="/sys/class/power_supply" bat
  bat=$(ls -1 "$p" 2>/dev/null | grep -E '^BAT' | head -n1)
  if [ -n "$bat" ] && [ -r "$p/$bat/capacity" ]; then
    local cap stat
    cap=$(cat "$p/$bat/capacity")
    [ -r "$p/$bat/status" ] && stat=$(cat "$p/$bat/status") || stat=""
    echo "BAT: ${cap}%"
  else
    echo "BAT: n/a"
  fi
}

read_wifi() {
  local iface=""
  if command -v iw >/dev/null 2>&1; then
    iface=$(iw dev 2>/dev/null | awk '/Interface/{print $2; exit}')
  fi
  if [ -z "$iface" ]; then
    iface=$(ls -1 /sys/class/net 2>/dev/null | grep -vE '^(lo|docker|veth|br-|virbr|tun|tap|wg)' | head -n1 || true)
  fi
  if [ -n "$iface" ] && [ -r "/sys/class/net/$iface/operstate" ]; then
    local state
    state=$(cat "/sys/class/net/$iface/operstate")
    if [ "$state" = up ]; then echo "Wi: CON"; else echo "Wi: DIS"; fi
  else
    echo "Wi: DIS"
  fi
}

# CPU usage via /proc/stat deltas
prev_total=0; prev_idle=0
read_cpu() {
  local cpu user nice sys idle iow irq sirq steal guest guest_n
  read cpu user nice sys idle iow irq sirq steal guest guest_n < /proc/stat
  local idle_all=$(( idle + iow ))
  local non_idle=$(( user + nice + sys + irq + sirq + steal ))
  local total=$(( idle_all + non_idle ))
  local totald=$(( total - prev_total ))
  local idled=$(( idle_all - prev_idle ))
  local usage=0
  if [ $totald -gt 0 ]; then usage=$(( (100 * (totald - idled)) / totald )); fi
  prev_total=$total; prev_idle=$idle_all
  echo "C: ${usage}%"
}

read_gpu() {
  # Intel iGPU: no simple sysfs metric; keep placeholder unless intel-gpu-tools is available
  if command -v intel_gpu_top >/dev/null 2>&1; then
    # One-shot sample over ~100ms, parse busy
    local j busy
    j=$(intel_gpu_top -J -s 100 2>/dev/null | tail -n +2 | head -n 1)
    busy=$(echo "$j" | sed -n 's/.*"busy":\([0-9]\+\).*/\1/p')
    [ -n "$busy" ] && echo "G: ${busy}%" && return
  fi
  echo "G: n/a"
}

read_ram() {
  local mt ma used
  mt=$(awk '/MemTotal:/{print $2}' /proc/meminfo)
  ma=$(awk '/MemAvailable:/{print $2}' /proc/meminfo)
  used=$(( (mt - ma) * 1024 ))
  # to GiB, 1 decimal
  printf "R: %.1f GiB\n" "$(awk -v u=$used 'BEGIN{printf u/1024/1024/1024}')"
}

# Pick a CPU temperature zone: prefer TCPU then x86_pkg_temp
find_temp_zone() {
  local z
  for z in /sys/class/thermal/thermal_zone*; do
    [ -r "$z/type" ] || continue
    case "$(cat "$z/type")" in
      TCPU) echo "$z"; return;;
    esac
  done
  for z in /sys/class/thermal/thermal_zone*; do
    [ -r "$z/type" ] || continue
    case "$(cat "$z/type")" in
      x86_pkg_temp) echo "$z"; return;;
    esac
  done
  # fallback first
  ls -d /sys/class/thermal/thermal_zone* 2>/dev/null | head -n1
}
TEMP_ZONE="$(find_temp_zone)"
read_temp() {
  local t
  if [ -r "$TEMP_ZONE/temp" ]; then
    t=$(cat "$TEMP_ZONE/temp")
    if [ "$t" -gt 1000 ]; then t=$(( t / 1000 )); fi
    echo "T: ${t}°C"; return
  fi
  echo "T: n/a"
}

read_time() {
  date +"%a %-d %b %Y %-I:%M:%S%p"
}

# i3bar protocol header (enable click events)
printf '{"version":1,"click_events":true}\n'
echo '['
# First empty array per protocol
echo '[]'

# Prime CPU stats baseline
read_cpu >/dev/null
 
# Duplicate stdin to FD 3 (i3bar sends click events on stdin)
exec 3<&0

# Click event listener (background)
(
  while IFS= read -r -u 3 line; do
    # Expect JSON objects like: {"name":"bri","button":4,...}
    [ -n "$DEBUG_CLICK" ] && printf '%s\n' "$line" >> "$DEBUG_LOG" 2>/dev/null || true
    # Parse name and button with sed (no external deps like jq)
    name=$(echo "$line" | sed -n 's/.*"name":"\([^"]*\)".*/\1/p')
    button=$(echo "$line" | sed -n 's/.*"button":\([0-9][0-9]*\).*/\1/p')
    if [ -n "$name" ] && [ -n "$button" ]; then
      [ -n "$DEBUG_CLICK" ] && log_dbg "CLICK parsed: name=$name button=$button"
      if [ "$name" = "bri" ]; then
        case "$button" in
          4) adj_bri_pct +5 ;;
          5) adj_bri_pct -5 ;;
        esac
      elif [ "$name" = "vol" ]; then
        case "$button" in
          4) adj_vol_pct +5 ;;
          5) adj_vol_pct -5 ;;
        esac
      fi
    fi
  done
) &

while sleep 1; do
  bri=$(read_bri)
  vol=$(read_vol)
  bat=$(read_bat)
  wifi=$(read_wifi)
  cpu=$(read_cpu)
  gpu=$(read_gpu)
  ram=$(read_ram)
  temp=$(read_temp)
  now=$(read_time)

  # Build JSON array with colors
  printf ',['
  printf '{"name":"bri","full_text":"%s","color":"%s"},' "$bri" "$COLOR_GOOD"
  printf '{"name":"vol","full_text":"%s","color":"%s"},' "$vol" "$COLOR_GOOD"
  printf '{"name":"bat","full_text":"%s"},' "$bat"
  # Wi-Fi color by state
  if echo "$wifi" | grep -q 'CON'; then wcolor=$COLOR_GOOD; else wcolor=$COLOR_BAD; fi
  printf '{"name":"wifi","full_text":"%s","color":"%s"},' "$wifi" "$wcolor"
  printf '{"name":"cpu","full_text":"%s"},' "$cpu"
  printf '{"name":"gpu","full_text":"%s"},' "$gpu"
  printf '{"name":"ram","full_text":"%s"},' "$ram"
  printf '{"name":"temp","full_text":"%s"},' "$temp"
  printf '{"name":"time","full_text":"%s"}' "$now"
  printf ']\n'

done
