#!/usr/bin/env bash
set -euo pipefail

# Simple GPU load test without installing packages.
# 1) Opens a local WebGL page to generate GPU work in your default browser.
# 2) Samples Intel iGPU counters from sysfs while the page runs.

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HTML="$HERE/gpu_webgl_stress.html"

open_in_browser() {
  local url="file://$HTML"
  if command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$url" >/dev/null 2>&1 &
  elif command -v sensible-browser >/dev/null 2>&1; then
    sensible-browser "$url" >/dev/null 2>&1 &
  elif command -v firefox >/dev/null 2>&1; then
    firefox "$url" >/dev/null 2>&1 &
  elif command -v chromium >/dev/null 2>&1; then
    chromium "$url" >/dev/null 2>&1 &
  else
    echo "Open this URL manually in a browser: $url"
  fi
}

echo "Starting WebGL load page..."
open_in_browser
sleep 2

# Detect DRM card path (Intel iGPU typical)
card_path=""
for c in /sys/class/drm/card*; do
  [ -d "$c" ] || continue
  if [ -f "$c/gt_cur_freq_mhz" ] || [ -f "$c/device/gt_cur_freq_mhz" ]; then
    card_path="$c"
    break
  fi
done

if [ -z "$card_path" ]; then
  echo "Could not locate Intel iGPU frequency counters under /sys/class/drm." >&2
  echo "You can still eyeball GPU usage via the WebGL animation."
  exit 0
fi

read_counter() {
  local f
  for f in \
    "$card_path/gt_cur_freq_mhz" \
    "$card_path/device/gt_cur_freq_mhz"; do
    if [ -f "$f" ]; then cat "$f" 2>/dev/null && return 0; fi
  done
  echo ""; return 1
}

read_rc6() {
  local f="$card_path/power/rc6_residency_ms"
  [ -f "$f" ] && cat "$f" 2>/dev/null || echo ""
}

read_max() {
  local f
  for f in \
    "$card_path/gt_max_freq_mhz" \
    "$card_path/device/gt_max_freq_mhz"; do
    [ -f "$f" ] && cat "$f" 2>/dev/null && return 0
  done
  echo ""
}

max=$(read_max || true)
echo "Sampling GPU freq for ~10 seconds (Ctrl+C to stop)."
printf "%-8s %-8s %-8s\n" "time" "freq(MHz)" "rc6(ms)"
start=$(date +%s)
for i in $(seq 1 20); do
  now=$(($(date +%s) - start))
  freq=$(read_counter || true)
  rc6=$(read_rc6 || true)
  printf "%-8s %-8s %-8s\n" "${now}s" "${freq:-?}" "${rc6:-?}"
  sleep 0.5
done

echo
echo "If freq climbs toward max (${max:-unknown}) and rc6 stops increasing while the page is visible, your GPU is being used."
