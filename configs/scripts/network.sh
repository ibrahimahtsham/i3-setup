#!/usr/bin/env bash
# i3blocks network widget using Font Awesome icons

ssid=$(iwgetid -r 2>/dev/null)
if [ -z "$ssid" ]; then
  ssid=$(nmcli -t -f ACTIVE,SSID dev wifi 2>/dev/null | awk -F: '/^yes:/ {print $2; exit}')
fi

if [ -z "$ssid" ]; then
  echo "<span font='FontAwesome'></span> Offline"
  echo
  echo "#ff5555"
else
  echo "<span font='FontAwesome'></span> $ssid"
  echo
  echo "#50fa7b"
fi
