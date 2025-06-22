#!/bin/bash

icons=("" "" "" "" "" "" "" "" "" "" "")

if command -v upower &>/dev/null; then
  battery=$(upower -e | grep -m1 'BAT')
  if [[ -n "$battery" ]]; then
    percent=$(upower -i "$battery" | awk '/percentage:/ {gsub("%", ""); print $2}')
    state=$(upower -i "$battery" | awk '/state:/ {print $2}')
  fi
fi

if [[ -z "$percent" ]] && [[ -d /sys/class/power_supply ]]; then
  battery_dir=$(find /sys/class/power_supply/ -name 'BAT*' | head -n1)
  if [[ -n "$battery_dir" ]]; then
    percent=$(cat "$battery_dir/capacity")
    state=$(cat "$battery_dir/status")
  fi
fi

if [[ -z "$percent" ]]; then
  echo "No Battery"
  exit 0
fi

idx=$((percent / 10))
((idx < 0)) && idx=0
((idx > 10)) && idx=10

icon="${icons[$idx]}"

if [[ "$state" == "charging" || "$state" == "fully-charged" ]]; then
  charged=""
  echo "$charged $icon "
  exit 0
else
  echo "$icon "
  exit 0
fi
