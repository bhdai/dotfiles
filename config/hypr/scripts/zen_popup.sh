#!/usr/bin/env bash

# Function to handle events
handle_event() {
    local event="$1"
    local payload="$2"

    if [[ "$event" == "windowtitlev2" ]]; then
        # Payload format is ADDRESS,TITLE
        local addr="${payload%%,*}"
        local title="${payload#*,}"
        
        # Ensure address starts with 0x for hyprctl
        if [[ "$addr" != "0x"* ]]; then
            addr="0x$addr"
        fi



                # Check if title starts with "Sign in" or "Extension:"
                if [[ "$title" == "Sign in"* ]] || [[ "$title" == "Extension:"* ]]; then
                    # Verify the class is zen using hyprctl clients -j (more reliable than getprop)
                    local class
                    class=$(hyprctl clients -j | jq -r --arg addr "$addr" '.[] | select(.address == $addr) | .class')
                    
        
        
                    # Check if class starts with "zen"
                    if [[ "$class" == "zen"* ]]; then
                
                # 1. Set floating
                hyprctl dispatch setfloating "address:$addr" >/dev/null

                # 2. Resize to 30% width, 60% height
                hyprctl dispatch resizewindowpixel "exact 30% 60%,address:$addr" >/dev/null

                # 3. Center (requires focusing the window first)
                hyprctl dispatch focuswindow "address:$addr" >/dev/null
                hyprctl dispatch centerwindow >/dev/null
                

            fi
        fi
    fi
}

# Check dependencies
if ! command -v nc &>/dev/null; then
    echo "Error: 'nc' (netcat) is required but not installed." >&2
    exit 1
fi

# Locate Hyprland socket
socket_path="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

if [[ ! -S "$socket_path" ]]; then
    echo "Error: Hyprland socket not found at $socket_path" >&2
    exit 1
fi



# Listen to the socket using netcat
nc -U "$socket_path" | while read -r line; do
    # Split event and payload by the first '>>'
    event="${line%%>>*}"
    payload="${line#*>>}"
    
    handle_event "$event" "$payload"
done
