-- ==============================================================================
-- Autostart
-- ==============================================================================
--
-- Two sections:
--   1. Top-level code runs on every config reload (replaces `exec`)
--   2. hl.on("hyprland.start") runs once at session start (replaces `exec-once`)

local shared = require("shared")

-- -------------------------------------------------------------------------
-- Run on every reload: theme application via gsettings
-- These are idempotent, so re-running on reload is safe.
-- -------------------------------------------------------------------------
hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-theme " .. shared.system_theme)
hl.exec_cmd("gsettings set org.gnome.desktop.interface icon-theme " .. shared.icon_theme)
hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'")

-- -------------------------------------------------------------------------
-- Run once at session start
-- -------------------------------------------------------------------------
hl.on("hyprland.start", function()
	-- Session/environment setup
	hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
	hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XAUTHORITY")

	-- Desktop services
	hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")
	hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
	hl.exec_cmd("fcitx5")
	hl.exec_cmd("sleep 3 && quickshell")
	hl.exec_cmd("hypridle")
	hl.exec_cmd("hyprpaper")
	hl.exec_cmd("hyprsunset")

	-- App launches pinned to workspaces
	-- TODO: verify exec_cmd rules syntax for workspace placement
	hl.exec_cmd("zen-browser", { workspace = "1 silent" })
	hl.exec_cmd("ghostty", { workspace = "2 silent" })
	hl.exec_cmd("thunderbird", { workspace = "3 silent" })

	-- Helper scripts
	hl.exec_cmd(shared.scripts_path .. "/zen_popup.sh")

	-- Clipboard persistence and history
	hl.exec_cmd("wl-clip-persist --clipboard regular")
	hl.exec_cmd("wl-paste --type text --watch cliphist store")
	hl.exec_cmd("wl-paste --type image --watch cliphist store")

	-- Misc
	hl.exec_cmd("journalctl-desktop-notification")
	-- hl.exec_cmd("sleep 30 && librepods --hide")
end)
