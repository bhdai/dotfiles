#!/bin/bash

wifi_icon=""
wired_icon=""
offline_icon=""

if command -v nmcli &>/dev/null; then
  state=$(nmcli -t -f WIFI g 2>/dev/null)
  if [[ "$state" == *"disabled"* ]]; then
    echo "$offline_icon "
    exit 0
  fi

  conn_type=$(nmcli -t -f TYPE,STATE d | grep ":connected" | cut -d: -f1 | head -n1)

  if [[ "$conn_type" == "wifi" ]]; then
    echo "$wifi_icon "
    exit 0
  elif [[ "$conn_type" == "ethernet" ]]; then
    echo "$wired_icon "
    exit 0
  else
    echo "$offline_icon "
    exit 0
  fi
fi
