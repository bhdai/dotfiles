#!/usr/bin/env bash

# Track creation time of windows to distinguish new popups from existing tabs
declare -A window_birthdays
# Track popups we have already processed so title-changes don't re-trigger
declare -A processed_popups

# Enable debug mode: set to 0 to silence, 1 to print
debug=1

log() {
  if [[ "$debug" -eq 1 ]]; then
    echo "[zen_popup] $*" >&2
  fi
}

# Function to handle events
handle_event() {
  local event="$1"
  local payload="$2"
  local current_time=$SECONDS

  log "EVENT: $event | PAYLOAD: $payload"

  # --- TRACKING LOGIC ---
  if [[ "$event" == "openwindow" ]]; then
    # Payload: ADDRESS,WORKSPACE,CLASS,TITLE
    local addr="${payload%%,*}"

    # Normalize address to 0x format
    if [[ "$addr" != "0x"* ]]; then addr="0x$addr"; fi

    # Record the birth time of this window
    window_birthdays["$addr"]=$current_time
    log "TRACKED openwindow: addr=$addr birthday=${window_birthdays[$addr]}"
    return
  fi

  if [[ "$event" == "closewindow" ]]; then
    # Payload: ADDRESS
    local addr="${payload%%,*}"
    if [[ "$addr" != "0x"* ]]; then addr="0x$addr"; fi

    # Clean up memory
    unset window_birthdays["$addr"]
    unset processed_popups["$addr"]
    log "UNTRACKED closewindow: addr=$addr"
    return
  fi

  # --- ACTION LOGIC ---
  if [[ "$event" == "windowtitlev2" ]]; then
    # Payload: ADDRESS,TITLE
    local addr="${payload%%,*}"
    local title="${payload#*,}" # Get everything after first comma

    if [[ "$addr" != "0x"* ]]; then addr="0x$addr"; fi

    log "windowtitlev2: addr=$addr title='$title'"

    # Guard: don't re-process a popup we already handled
    if [[ -n "${processed_popups[$addr]}" ]]; then
      log "SKIP: addr=$addr already processed as popup"
      return
    fi

    # Check for target titles
    if [[ "$title" == "Sign in - Google Accounts —"* ]] || [[ "$title" == "Extension:"* ]]; then
      log "MATCH: title matched target pattern"

      # 1. Check Window Age
      local birthday=${window_birthdays["$addr"]}

      # If birthday is unset, the window existed BEFORE script started (Old) -> Ignore
      if [[ -z "$birthday" ]]; then
        log "SKIP: addr=$addr has no birthday (pre-existing window)"
        return
      fi

      # Calculate Age
      local age=$((current_time - birthday))
      log "AGE CHECK: addr=$addr birthday=$birthday current=$current_time age=${age}s"

      # If window is older than 5 seconds, it's just a tab navigation -> Ignore
      if [[ "$age" -gt 5 ]]; then
        log "SKIP: addr=$addr is too old ($age > 5s) — likely tab navigation"
        return
      fi

      # --- IF WE REACH HERE, IT IS A NEW POPUP ---
      log "PASS: addr=$addr is a new popup (age=${age}s)"

      # Check class to be safe (Zen Browser)
      local class
      class=$(hyprctl clients -j | jq -r --arg addr "$addr" '.[] | select(.address == $addr) | .class')
      log "CLASS CHECK: addr=$addr class='$class'"

      if [[ "$class" == "zen"* ]]; then
        log "CLASS PASS: zen browser detected, applying popup rules..."

        # Compute 30% x 60% of the currently focused monitor for resizing
        local monitor_info
        monitor_info=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | "\(.width) \(.height)"')
        local monitor_w monitor_h
        read -r monitor_w monitor_h <<<"$monitor_info"
        local new_w=$((monitor_w * 30 / 100))
        local new_h=$((monitor_h * 60 / 100))
        log "MONITOR: ${monitor_w}x${monitor_h}  ->  resize to ${new_w}x${new_h}"

        # Mark as processed BEFORE dispatching so rapid follow-up title changes
        # don't re-trigger while the commands are in flight.
        processed_popups["$addr"]=1
        log "MARKED: addr=$addr as processed"

        local result

        # IMPORTANT: action = "on" (or "enable") — default is "toggle" which would
        # untoggle a window that is already floating. Documentation:
        #   float({ action?, window? })  action: toggle (default), enable/on, disable/off
        log "DISPATCH: float address:$addr (action=on)"
        result=$(hyprctl dispatch "hl.dsp.window.float({ action = 'on', window = 'address:$addr' })" 2>&1)
        log "RESULT (float): $result"

        log "DISPATCH: resize ${new_w}x${new_h} address:$addr (relative=false)"
        result=$(hyprctl dispatch "hl.dsp.window.resize({ x = $new_w, y = $new_h, relative = false, window = 'address:$addr' })" 2>&1)
        log "RESULT (resize): $result"

        log "DISPATCH: focus address:$addr"
        result=$(hyprctl dispatch "hl.dsp.focus({ window = 'address:$addr' })" 2>&1)
        log "RESULT (focus): $result"

        log "DISPATCH: center address:$addr"
        result=$(hyprctl dispatch "hl.dsp.window.center({ window = 'address:$addr' })" 2>&1)
        log "RESULT (center): $result"

        log "DONE: popup rules applied to $addr"
      else
        log "CLASS SKIP: class='$class' does not match 'zen*'"
      fi
    else
      log "NO MATCH: title does not match target patterns"
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
log "Socket path: $socket_path"
log "Starting zen_popup listener..."

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
