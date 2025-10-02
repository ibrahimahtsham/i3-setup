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

COLOR="#FFFFFF"
if [ "$VAL" != "--" ]; then
  if [ "$VAL" -ge 85 ] 2>/dev/null; then COLOR="#ff5555"
  elif [ "$VAL" -ge 60 ] 2>/dev/null; then COLOR="#f1fa8c"
  fi
fi

printf "%s %s%%\n" "$ICON" "$VAL"
echo
echo "$COLOR"
