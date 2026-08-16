-- Top-level code here runs on every config reload (the old `exec`); the
-- hl.on("hyprland.start") body runs once per session (the old `exec-once`).

local shared = require("shared")

-- Idempotent, so re-applying them on every reload is harmless.
hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-theme " .. shared.system_theme)
hl.exec_cmd("gsettings set org.gnome.desktop.interface icon-theme " .. shared.icon_theme)
hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'")

hl.on("hyprland.start", function()
	-- xdg-desktop-portal >= 1.22 has Requisite=graphical-session.target, so the portal
	-- (screen sharing picker) won't start unless that target is active. Chained so the
	-- target only starts once the environment is in place.
	hl.exec_cmd(
		"systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP && "
			.. "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XAUTHORITY && "
			.. "systemctl --user start hyprland-session.target"
	)

	hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")
	hl.exec_cmd("kded6")
	hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
	hl.exec_cmd("fcitx5")
	hl.exec_cmd("quickshell")
	hl.exec_cmd("hypridle")
	-- Hyprpaper does not autostart because Quickshell owns the wallpaper. Offline recovery:
	-- systemctl --user unmask hyprpaper.service
	-- hyprpaper &
	-- hyprctl hyprpaper preload "$HOME/Pictures/wall/leaves.jpg"
	-- hyprctl hyprpaper wallpaper "eDP-1,$HOME/Pictures/wall/leaves.jpg"
	hl.exec_cmd("hyprsunset")

	-- The one daemon here started through systemd rather than exec'd directly, because
	-- dictation fails silently -- a dead daemon looks exactly like a key that did
	-- nothing. voxtype-bin's unit carries Restart=on-failure, and puts the daemon's
	-- output in the journal instead of Hyprland's stdout, where the rest of these go
	-- to die.
	--
	-- Started rather than enabled: the shipped unit is WantedBy=graphical-session.target
	-- and nothing on this machine activates that target, so enabling it would install a
	-- want that never fires. Starting it here also places it after the environment
	-- import above, which wtype needs to have a display to type into.
	hl.exec_cmd("systemctl --user start voxtype.service")

	-- TODO: verify exec_cmd rules syntax for workspace placement
	hl.exec_cmd("zen-browser", { workspace = "1 silent" })
	hl.exec_cmd("ghostty", { workspace = "2 silent" })
	hl.exec_cmd("thunderbird", { workspace = "3 silent" })

	hl.exec_cmd("wl-clip-persist --clipboard regular")
	hl.exec_cmd("wl-paste --type text --watch cliphist store")
	hl.exec_cmd("wl-paste --type image --watch cliphist store")

	hl.exec_cmd("journalctl-desktop-notification")
end)
