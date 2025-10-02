#!/usr/bin/env bash
# i3blocks GPU usage widget
# Tries Intel i915 gt_busy_percent via sysfs, then intel_gpu_top JSON

ICON="<span font='FontAwesome'></span>"
VAL="--"

# Prefer sysfs (Intel: gt_busy_percent; AMD: gpu_busy_percent)
for P in \
  /sys/class/drm/card*/device/gt_busy_percent \
  /sys/class/drm/card*/gt_busy_percent \
  /sys/class/drm/card*/device/gpu_busy_percent \
  /sys/class/drm/card*/gpu_busy_percent; do
  if [ -r "$P" ]; then
    VAL=$(cat "$P" 2>/dev/null)
    break
  fi
done

# Fallback: try intel_gpu_top (requires intel-gpu-tools; may need permissions)
if [ "$VAL" = "--" ] && command -v intel_gpu_top >/dev/null 2>&1; then
  OUT="$(timeout 0.6s intel_gpu_top -J -s 200 2>/dev/null)"
  if [ -n "$OUT" ]; then
    BUSY=$(printf "%s\n" "$OUT" | grep -m1 -o '"busy":[ ]*[0-9]\+' | grep -o '[0-9]\+')
    [ -n "$BUSY" ] && VAL="$BUSY"
  fi
fi

# Fallback: NVIDIA via nvidia-smi (if driver installed)
if [ "$VAL" = "--" ] && command -v nvidia-smi >/dev/null 2>&1; then
  BUSY=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | awk 'NR==1{print $1}')
  [ -n "$BUSY" ] && VAL="$BUSY"
fi

# Fallback: Intel iGPU frequency heuristic (estimate % based on current vs min/max)
if [ "$VAL" = "--" ]; then
  calc_from_freq() {
    local cur="$1" min="$2" max="$3"
    if [ -n "$cur" ] && [ -n "$min" ] && [ -n "$max" ] && [ "$max" -gt "$min" ] 2>/dev/null; then
      # Clamp cur to [min,max]
      if [ "$cur" -lt "$min" ] 2>/dev/null; then cur="$min"; fi
      if [ "$cur" -gt "$max" ] 2>/dev/null; then cur="$max"; fi
      awk -v c="$cur" -v mn="$min" -v mx="$max" 'BEGIN{ pct = int((c-mn)*100/(mx-mn)+0.5); if(pct<0)pct=0; if(pct>100)pct=100; print pct }'
      return 0
    fi
    return 1
  }
  for C in /sys/class/drm/card*; do
    [ -d "$C" ] || continue
    # Prefer files directly under card path; fall back to device/ path
    for base in "$C" "$C/device"; do
      cur=""; min=""; max=""
      [ -r "$base/gt_cur_freq_mhz" ] && cur=$(cat "$base/gt_cur_freq_mhz" 2>/dev/null)
      [ -r "$base/gt_min_freq_mhz" ] && min=$(cat "$base/gt_min_freq_mhz" 2>/dev/null)
      [ -r "$base/gt_max_freq_mhz" ] && max=$(cat "$base/gt_max_freq_mhz" 2>/dev/null)
      if EST=$(calc_from_freq "${cur:-}" "${min:-}" "${max:-}"); then
        if echo "$EST" | grep -Eq '^[0-9]+$'; then VAL="$EST"; break 2; fi
      fi
    done
  done
fi

COLOR="#FFFFFF"
if [ "$VAL" != "--" ]; then
  if [ "$VAL" -ge 85 ] 2>/dev/null; then COLOR="#ff5555"
  elif [ "$VAL" -ge 60 ] 2>/dev/null; then COLOR="#f1fa8c"
  fi
fi

printf "%s %s%%\n" "$ICON" "$VAL"
echo
echo "$COLOR"
