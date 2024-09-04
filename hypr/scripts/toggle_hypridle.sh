#!/bin/bash

HYPRIDLE_CONFIG="$HOME/.config/hypr/hypridle.conf"
HYPRIDLE_TEMP_CONFIG="$HOME/.config/hypr/hypridle.conf.temp"

toggle_hypridle() {
    if [ -f "$HYPRIDLE_TEMP_CONFIG" ]; then
        mv "$HYPRIDLE_TEMP_CONFIG" "$HYPRIDLE_CONFIG"
        echo "Hypridle functionality re-enabled."
        notify-send "Hypridle" "Functionality re-enabled."
    else
        mv "$HYPRIDLE_CONFIG" "$HYPRIDLE_TEMP_CONFIG"
        echo "Hypridle functionality disabled."
        notify-send "Hypridle" "Functionality disabled."
    fi

    pkill hypridle && hypridle &
}

toggle_hypridle
