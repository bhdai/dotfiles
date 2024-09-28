function powersave --description "Toggle power-saving mode"
  set -l USER monarch
  set -l MIN_BRIGHTNESS 1000

  function run_as_user
    set -l DBUS "unix:path=/run/user/(id -u $USER)/bus"
    cd /home/$USER || return 1
    sudo -u $USER DBUS_SESSION_BUS_ADDRESS="$DBUS" /usr/bin/systemd-run --user --property=TimeoutStopSec=1 --property=KillMode=mixed $argv
  end

  # If running as root, re-run as user
  if test (id -u) -eq 0
    run_as_user power_management $argv
    return
  end

  # Check for required commands
  for cmd in brightnessctl hyprctl
    if not command -v $cmd &>/dev/null
      return 1
    end
  end

  switch $argv[1]
    case "true"
      echo "Enabling power-saving mode"
      brightnessctl -s set $MIN_BRIGHTNESS
      hyprctl keyword decoration:drop_shadow false
      hyprctl keyword decoration:blur:enabled false
    case "false"
      echo "Disabling power-saving mode"
      brightnessctl -r
      hyprctl keyword decoration:drop_shadow true
      hyprctl keyword decoration:blur:enabled true
    case '*'
      echo "Invalid argument: $argv[1]. Use 'true' or 'false'."
      return 1
  end
end
