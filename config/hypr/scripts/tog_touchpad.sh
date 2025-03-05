#!/bin/bash

CONFIG_FILE="$HOME/.config/hypr/touchpad.conf"

touchpad_toggle() {
  # check the current state of the touchpad
  state=$(rg -oP "(?<=enabled = )(true|false)" "$CONFIG_FILE")

  if [ "$state" = "false" ]; then
    # enable the touchpad
    sed -i "s/enabled = false/enabled = true/" "$CONFIG_FILE"
    # notify-send -u low "Touchpad Enabled" "The touchpad has been enabled."
  else
    # disable the touchpad
    sed -i "s/enabled = true/enabled = false/" "$CONFIG_FILE"
    # notify-send -u low "Touchpad Disabled" "The touchpad has been disabled."
  fi
  hyprctl reload
}

touchpad_toggle
