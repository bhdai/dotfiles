#!/bin/bash

if pgrep -x "hypridle" >/dev/null; then
  killall hypridle
  notify-send "Idle Management Disabled"
else
  hypridle &
  notify-send "Idle Management Enabled"
fi
