#!/usr/bin/env bash

# Track creation time of windows to distinguish new popups from existing tabs
declare -A window_birthdays

# Function to handle events
handle_event() {
  local event="$1"
  local payload="$2"
  local current_time=$SECONDS

  # --- TRACKING LOGIC ---
  if [[ "$event" == "openwindow" ]]; then
    # Payload: ADDRESS,WORKSPACE,CLASS,TITLE
    local addr="${payload%%,*}"

    # Normalize address to 0x format
    if [[ "$addr" != "0x"* ]]; then addr="0x$addr"; fi

    # Record the birth time of this window
    window_birthdays["$addr"]=$current_time
    return
  fi

  if [[ "$event" == "closewindow" ]]; then
    # Payload: ADDRESS
    local addr="${payload%%,*}"
    if [[ "$addr" != "0x"* ]]; then addr="0x$addr"; fi

    # Clean up memory
    unset window_birthdays["$addr"]
    return
  fi

  # --- ACTION LOGIC ---
  if [[ "$event" == "windowtitlev2" ]]; then
    # Payload: ADDRESS,TITLE
    local addr="${payload%%,*}"
    local title="${payload#*,}" # Get everything after first comma

    if [[ "$addr" != "0x"* ]]; then addr="0x$addr"; fi

    # Check for target titles
    if [[ "$title" == "Sign in - Google Accounts —"* ]] || [[ "$title" == "Extension:"* ]]; then

      # 1. Check Window Age
      local birthday=${window_birthdays["$addr"]}

      # If birthday is unset, the window existed BEFORE script started (Old) -> Ignore
      if [[ -z "$birthday" ]]; then
        return
      fi

      # Calculate Age
      local age=$((current_time - birthday))

      # If window is older than 5 seconds, it's just a tab navigation -> Ignore
      if [[ "$age" -gt 5 ]]; then
        return
      fi

      # --- IF WE REACH HERE, IT IS A NEW POPUP ---

      # Check class to be safe (Zen Browser)
      local class
      class=$(hyprctl clients -j | jq -r --arg addr "$addr" '.[] | select(.address == $addr) | .class')

      if [[ "$class" == "zen"* ]]; then
        hyprctl dispatch setfloating "address:$addr" >/dev/null
        hyprctl dispatch resizewindowpixel "exact 30% 60%,address:$addr" >/dev/null
        hyprctl dispatch focuswindow "address:$addr" >/dev/null
        hyprctl dispatch centerwindow >/dev/null
      fi
    fi
  fi
}

# Dependency Check
for cmd in nc jq; do
  if ! command -v $cmd &>/dev/null; then
    echo "Error: '$cmd' is required but not installed." >&2
    exit 1
  fi
done

# Socket Setup
socket_path="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

# Pre-populate list (Optional: Mark all currently existing windows as "Old")
# This ensures that if you restart the script, it doesn't accidentally float
# an existing window if you navigate it immediately.
# We essentially strictly enforce that we only float windows we SAW getting created.

# Listen
nc -U "$socket_path" | while read -r line; do
  event="${line%%>>*}"
  payload="${line#*>>}"
  handle_event "$event" "$payload"
done
