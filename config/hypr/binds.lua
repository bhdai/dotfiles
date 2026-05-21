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
-- Focus Movement (vim-style)
-- -------------------------------------------------------------------------
hl.bind("SUPER + H", hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + J", hl.dsp.focus({ direction = "d" }))
hl.bind("SUPER + K", hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + L", hl.dsp.focus({ direction = "r" }))

-- Window movement
hl.bind("SUPER + ALT + H", hl.dsp.window.move({ direction = "l" }))
hl.bind("SUPER + ALT + J", hl.dsp.window.move({ direction = "d" }))
hl.bind("SUPER + ALT + K", hl.dsp.window.move({ direction = "u" }))
hl.bind("SUPER + ALT + L", hl.dsp.window.move({ direction = "r" }))

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

-- Resize active window with keyboard
hl.bind("SUPER + SHIFT + L", hl.dsp.window.resize({ x = 30, y = 0, relative = true }))
hl.bind("SUPER + SHIFT + H", hl.dsp.window.resize({ x = -30, y = 0, relative = true }))
hl.bind("SUPER + SHIFT + K", hl.dsp.window.resize({ x = 0, y = -30, relative = true }))
hl.bind("SUPER + SHIFT + J", hl.dsp.window.resize({ x = 0, y = 30, relative = true }))

-- -------------------------------------------------------------------------
-- Zoom (Quickshell IPC)
-- -------------------------------------------------------------------------
hl.bind("SUPER + ALT + Minus", hl.dsp.exec_cmd("qs ipc call zoom zoomOut"), { repeating = true })
hl.bind("SUPER + ALT + Equal", hl.dsp.exec_cmd("qs ipc call zoom zoomIn"), { repeating = true })

-- -------------------------------------------------------------------------
-- Gestures
-- -------------------------------------------------------------------------
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
