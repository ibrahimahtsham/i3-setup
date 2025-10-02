#!/usr/bin/env bash
# i3blocks network widget using Font Awesome icons

ssid=""
state=""
connected=0

# Prefer NetworkManager (nmcli) for robust detection
if command -v nmcli >/dev/null 2>&1; then
  # WIFI state: enabled/disabled
  state=$(nmcli -t -f WIFI g 2>/dev/null)

  # Get active Wi‑Fi connection name (SSID) reliably
  ssid=$(nmcli -t -f NAME,TYPE connection show --active 2>/dev/null | awk -F: '$2=="wifi"{print $1; exit}')

  # Fallback: query the Wi‑Fi device's current connection
  if [ -z "$ssid" ]; then
    wifi_dev=$(nmcli -t -f DEVICE,TYPE device 2>/dev/null | awk -F: '$2=="wifi"{print $1; exit}')
    if [ -n "$wifi_dev" ]; then
      ssid=$(nmcli -t -f GENERAL.CONNECTION device show "$wifi_dev" 2>/dev/null | awk -F: '$1=="GENERAL.CONNECTION"{gsub(/^ +/,"",$2); print $2; exit}')
    fi
  fi
fi

# Final fallback if NetworkManager didn’t yield an SSID
if [ -z "$ssid" ]; then
  ssid=$(iwgetid -r 2>/dev/null)
fi

# As a generic connectivity fallback (works in containers/Crostini):
# consider the system connected if there is a default route/interface up.
default_iface=$(ip route get 1.1.1.1 2>/dev/null | awk '/dev /{for(i=1;i<=NF;i++) if ($i=="dev"){print $(i+1); exit}}')
if [ -n "$default_iface" ] && [ -f "/sys/class/net/$default_iface/operstate" ]; then
  if [ "$(cat "/sys/class/net/$default_iface/operstate" 2>/dev/null)" = "up" ]; then
    connected=1
  fi
fi

if [ -n "$ssid" ] || [ $connected -eq 1 ]; then
  # Connected
  echo "<span font='FontAwesome 9' color='#50fa7b'></span>"
  echo
  echo "#50fa7b"
else
  # Not connected; distinguish disabled vs searching
  if [ "$state" = "disabled" ]; then
    echo "<span font='FontAwesome 9' color='#ffb86c'></span>"
    echo
    echo "#ffb86c"
  else
    echo "<span font='FontAwesome 9' color='#ff5555'></span>"
    echo
    echo "#ff5555"
  fi
fi
