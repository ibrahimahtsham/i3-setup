#!/usr/bin/env bash
# i3blocks network widget using Font Awesome icons

ssid=$(iwgetid -r 2>/dev/null)
state=""
if command -v nmcli >/dev/null 2>&1; then
  state=$(nmcli -t -f WIFI g 2>/dev/null)
fi
if [ -z "$ssid" ] && command -v nmcli >/dev/null 2>&1; then
  ssid=$(nmcli -t -f ACTIVE,SSID dev wifi 2>/dev/null | awk -F: '/^yes:/ {print $2; exit}')
fi

if [ -n "$ssid" ]; then
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
