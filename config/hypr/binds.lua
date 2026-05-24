-- ==============================================================================
-- Keybindings, Submaps, and Gestures
-- ==============================================================================

local shared = require("shared")
local meh = shared.meh

-- -------------------------------------------------------------------------
-- App Launchers
-- -------------------------------------------------------------------------
hl.bind("SUPER + Return", hl.dsp.exec_cmd("ghostty"))
hl.bind("SUPER + B", hl.dsp.exec_cmd("zen-browser"))
hl.bind("SUPER + E", hl.dsp.exec_cmd("dolphin"))
hl.bind("SUPER + D", hl.dsp.exec_cmd("discord"))

-- -------------------------------------------------------------------------
-- Session Actions
-- -------------------------------------------------------------------------
hl.bind(meh .. " + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(meh .. " + N", hl.dsp.exec_cmd("makoctl dismiss -a"))

-- -------------------------------------------------------------------------
-- Screenshots (grimblast)
-- -------------------------------------------------------------------------
hl.bind("Print", hl.dsp.exec_cmd("grimblast -w 0.3 --notify --freeze copy area"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("grimblast -w 0.3 --notify save area"))
hl.bind("SUPER + Print", hl.dsp.exec_cmd("grimblast -w 0.3 --notify copy screen"))
hl.bind("SUPER + SHIFT + Print", hl.dsp.exec_cmd("grimblast -w 0.3 --notify save screen"))

-- OCR: capture area → tesseract → clipboard
-- Anchored to /tmp/hypr-ocr.png instead of bare tmp.png
hl.bind(
	meh .. " + S",
	hl.dsp.exec_cmd(
		"grimblast save area /tmp/hypr-ocr.png"
			.. " && tesseract -l eng /tmp/hypr-ocr.png - | wl-copy"
			.. " && rm /tmp/hypr-ocr.png"
	)
)

-- -------------------------------------------------------------------------
-- Quickshell IPC
-- -------------------------------------------------------------------------
hl.bind("XF86PowerOff", hl.dsp.exec_cmd("qs ipc call session open"))
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("qs ipc call session open"))
hl.bind("SUPER + space", hl.dsp.exec_cmd("qs ipc call launcher toggle"))
hl.bind("SUPER + F1", hl.dsp.exec_cmd("qs ipc call gamingMode toggle"))

-- Brightness with Quickshell fallback
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("qs ipc call brightness decrement || brightnessctl s 5%+"))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("qs ipc call brightness increment || brightnessctl s 5%-"))

-- Power profile
hl.bind("XF86Launch4", hl.dsp.exec_cmd("qs ipc call powerProfile cycle || asusctl profile --next"))

-- -------------------------------------------------------------------------
-- Media and Volume
-- -------------------------------------------------------------------------
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%-"),
	{ repeating = true }
)
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ repeating = true }
)
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("pactl set-source-mute @DEFAULT_SOURCE@ toggle"))

-- Player controls (locked = works on lockscreen)
hl.bind("SUPER + ALT + P", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("SUPER + ALT + bracketright", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("SUPER + ALT + bracketleft", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- -------------------------------------------------------------------------
-- Window Management
-- -------------------------------------------------------------------------
hl.bind("SUPER + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind("SUPER + M", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind("SUPER + P", hl.dsp.window.pseudo())
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + T", hl.dsp.window.float())
hl.bind("SUPER + Tab", hl.dsp.focus({ workspace = "previous" }))
hl.bind("SUPER + backslash", hl.dsp.exec_cmd(shared.scripts_path .. "/quake > /dev/null"))
hl.bind("SUPER + SHIFT + P", hl.dsp.exec_cmd("hyprpicker -a"))

-- -------------------------------------------------------------------------
-- Scrolling Layout Messages
-- -------------------------------------------------------------------------
hl.bind("SUPER + R", hl.dsp.layout("colresize +conf")) -- cycle preset widths (niri Mod+R)
hl.bind("SUPER + period", hl.dsp.layout("move +col"))
hl.bind("SUPER + comma", hl.dsp.layout("move -col"))
hl.bind("SUPER + SHIFT + period", hl.dsp.layout("swapcol r"))
hl.bind("SUPER + SHIFT + comma", hl.dsp.layout("swapcol l"))
hl.bind("SUPER + C", hl.dsp.layout("togglefit")) -- toggle center/fit mode (niri Mod+C)
hl.bind("SUPER + W", hl.dsp.layout("fit active")) -- fit active column to screen
hl.bind("SUPER + SHIFT + W", hl.dsp.layout("fit visible")) -- fit all visible to screen
hl.bind("SUPER + CTRL + W", hl.dsp.layout("fit all")) -- fit every column to screen
hl.bind("SUPER + G", hl.dsp.layout("promote"))

-- Column resize: only layoutmsg version kept.
-- Intentionally omitted: duplicate splitratio binds on the same keys that
-- were shadowing these and had no effect on the scrolling layout.
hl.bind("SUPER + Minus", hl.dsp.layout("colresize -0.1"))
hl.bind("SUPER + Equal", hl.dsp.layout("colresize +0.1"))

-- -------------------------------------------------------------------------
-- Focus / Move / Resize (vim-style, H J K L)
-- -------------------------------------------------------------------------
local vim_dirs = {
	H = { dir = "l", x = -30, y = 0 },
	J = { dir = "d", x = 0, y = 30 },
	K = { dir = "u", x = 0, y = -30 },
	L = { dir = "r", x = 30, y = 0 },
}
for key, d in pairs(vim_dirs) do
	hl.bind("SUPER + " .. key, hl.dsp.focus({ direction = d.dir }))
	hl.bind("SUPER + ALT + " .. key, hl.dsp.window.move({ direction = d.dir }))
	hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.resize({ x = d.x, y = d.y, relative = true }))
end

-- -------------------------------------------------------------------------
-- Workspaces
-- -------------------------------------------------------------------------
for i = 1, 9 do
	hl.bind("SUPER + " .. i, hl.dsp.focus({ workspace = i }))
	hl.bind("SUPER + ALT + " .. i, hl.dsp.window.move({ workspace = i }))
end
hl.bind("SUPER + 0", hl.dsp.focus({ workspace = 10 }))
hl.bind("SUPER + ALT + 0", hl.dsp.window.move({ workspace = 10 }))

-- Special workspace
hl.bind("SUPER + s", hl.dsp.workspace.toggle_special())
hl.bind("SUPER + ALT + s", hl.dsp.window.move({ workspace = "special" }))

-- Relative workspace navigation
hl.bind("SUPER + bracketleft", hl.dsp.focus({ workspace = "e-1" }))
hl.bind("SUPER + bracketright", hl.dsp.focus({ workspace = "e+1" }))

-- -------------------------------------------------------------------------
-- Mouse Binds
-- -------------------------------------------------------------------------
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + ALT + mouse:272", hl.dsp.window.resize(), { mouse = true })

-- -------------------------------------------------------------------------
-- Zoom
-- -------------------------------------------------------------------------
local function zoom(delta)
	local current = hl.get_config("cursor:zoom_factor")
	hl.config({ cursor = { zoom_factor = math.max(1.0, math.min(3.0, current + delta)) } })
end
hl.bind("SUPER + ALT + Minus", function()
	zoom(-0.3)
end, { repeating = true })
hl.bind("SUPER + ALT + Equal", function()
	zoom(0.3)
end, { repeating = true })

-- -------------------------------------------------------------------------
-- VM Submap
-- -------------------------------------------------------------------------
hl.define_submap("vm", function()
	hl.bind("SUPER + ALT + F1", function()
		if hl.get_current_submap() == "vm" then
			hl.dispatch(
				hl.dsp.exec_cmd("notify-send 'Exited Virtual Machine submap' 'Keybinds re-enabled' -a 'Hyprland'")
			)
			hl.dispatch(hl.dsp.submap("reset"))
		else
			hl.dispatch(
				hl.dsp.exec_cmd(
					"notify-send 'Entered Virtual Machine submap' 'Keybinds disabled. Hit Super+Alt+F1 to escape' -a 'Hyprland'"
				)
			)
			hl.dispatch(hl.dsp.submap("vm"))
		end
	end, { submap_universal = true })
end)

-- -------------------------------------------------------------------------
-- Gestures
-- -------------------------------------------------------------------------
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
