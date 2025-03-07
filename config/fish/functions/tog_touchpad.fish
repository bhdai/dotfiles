function tog_touchpad
    set config_file ~/.config/hypr/touchpad.conf
    set state (rg -oP "(?<=enabled = )(true|false)" $config_file)

    if test "$state" = false
        # enable touch pad
        sed -i 's/enabled = false/enabled = true/' $config_file
        echo "touchpaed enabled"
    else
        # disable touchpad
        sed -i 's/enabled = true/enabled = false/' $config_file
        echo "touchpad disabled"
    end

    hyprctl reload
end
