function on_touchpad
    set config_file ~/.config/hypr/touchpad.conf
    sed -i 's/enabled = false/enabled = true/' $config_file
    echo "switching touchpad on"
    hyprctl reload
end

function off_touchpad
    set config_file ~/.config/hypr/touchpad.conf
    sed -i 's/enabled = true/enabled = false/' $config_file
    echo "switching touchpad off"
    hyprctl reload
end


function tog_touchpad -a cmd
    switch $cmd
        case on
            on_touchpad
        case off
            off_touchpad
        case '*'
            return 1
    end
end
