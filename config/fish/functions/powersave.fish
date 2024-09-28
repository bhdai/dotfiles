function powersave
  set -l USER monarch

  function run_as_user
    set -l DBUS "unix:path=/run/user/(id -u $USER)/bus"
    cd /home/$USER || exit
    sudo -u $USER DBUS_SESSION_BUS_ADDRESS="$DBUS" /usr/bin/systemd-run --user --property=TimeoutStopSec=1 --property=KillMode=mixed $argv
  end

  # If running as root, re-run as user
  if test (id -u) -eq 0
    run_as_user power_management $argv
    return
  end

  # Check if on battery
  if test "$argv[1]" = "true"
    brightnessctl -s set 1000 # save brightness
    # tuned-adm profile laptop-battery-powersave
    # powerprofilesctl set power-saver
    hyprctl keyword decoration:drop_shadow false
    hyprctl keyword decoration:blur:enabled false
  else if test "$argv[1]" = "false"
    brightnessctl -r # restore brightness
    # powerprofilesctl set balanced
    # tuned-adm profile laptop-ac-powersave
    hyprctl keyword decoration:drop_shadow true
    hyprctl keyword decoration:blur:enabled true
  end

  # Reload waybar
  # pkill waybar
  # waybar
end
