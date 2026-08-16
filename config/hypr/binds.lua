local shared = require("shared")
local qs = require("qs")
local quake = require("quake")
local meh = shared.meh

hl.bind("SUPER + Return", hl.dsp.exec_cmd("ghostty"))
hl.bind("SUPER + B", hl.dsp.exec_cmd("zen-browser"))
hl.bind("SUPER + E", hl.dsp.exec_cmd("dolphin"))
hl.bind("SUPER + D", hl.dsp.exec_cmd("discord"))

-- Locking through logind rather than a locker directly, so the keybind, the idle timeout
-- and pre-sleep all converge on one dbus lock event, one lock_cmd and one fallback chain —
-- and logind's LockedHint gets set. Routing through hypridle is the cost; a dead
-- hypridle already means no idle lock and no lock before suspend.
hl.bind(meh .. " + L", hl.dsp.exec_cmd("loginctl lock-session"))
hl.bind(meh .. " + N", hl.dsp.exec_cmd("makoctl dismiss -a"))

-- One Print for the common case, because the picker's smart mode already covers
-- what the old copy/save × area/screen matrix needed four chords for: drag for a
-- region, or click once to snap to the window or monitor under the cursor. The
-- shot lands on disk and the clipboard together, so neither is a separate bind.
hl.bind("Print", hl.dsp.exec_cmd(shared.scripts_path .. "/capture-screenshot"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd(shared.scripts_path .. "/capture-screenshot smart copy"))
hl.bind("SUPER + Print", hl.dsp.exec_cmd(shared.scripts_path .. "/capture-screenshot fullscreen"))

hl.bind(meh .. " + S", hl.dsp.exec_cmd(shared.scripts_path .. "/capture-text"))

-- Each of these is a toggle: whichever one starts a recording, any of them stops
-- it. The soundtrack has to be chosen up front because it cannot be added later,
-- and these are chords rather than a menu because there is no menu to hang them
-- off. Recording a whole monitor needs no bind of its own — click it in the
-- picker and the selection snaps to it.
hl.bind("ALT + Print", hl.dsp.exec_cmd(shared.scripts_path .. "/capture-screenrecording"))
hl.bind(
	"SHIFT + ALT + Print",
	hl.dsp.exec_cmd(shared.scripts_path .. "/capture-screenrecording --with-desktop-audio")
)
hl.bind(
	"CTRL + ALT + Print",
	hl.dsp.exec_cmd(
		shared.scripts_path .. "/capture-screenrecording --with-desktop-audio --with-microphone-audio"
	)
)

-- Keyboard control for the slurp region picker (see scripts/capture-region).
-- The binds live exactly as long as a selection layer is on screen (slurp opens
-- one per monitor), so they cannot leak or get stuck. Unbinding by key would
-- take a same-key binding out of the rest of this config with it, so each handle
-- is kept and removed individually.
local selection_layers = 0
local selection_binds = {}

hl.on("layer.opened", function(layer)
	if layer.namespace ~= "selection" then
		return
	end

	selection_layers = selection_layers + 1
	if selection_layers > 1 then
		return
	end

	local function pick(key, argument, description)
		table.insert(
			selection_binds,
			hl.bind(key, hl.dsp.exec_cmd(shared.scripts_path .. "/capture-region " .. argument), { description = description })
		)
	end

	pick("RETURN", "--take-window", "Capture highlighted window")
	pick("CTRL + RETURN", "--take-fullscreen", "Capture entire screen")
	pick("TAB", "--select-window next", "Select next window to capture")
	pick("CTRL + TAB", "--select-window prev", "Select previous window to capture")

	for _, direction in ipairs({ "left", "right", "up", "down" }) do
		pick(direction:upper(), "--select-window " .. direction, "Select window to capture")
	end
end)

hl.on("layer.closed", function(layer)
	if layer.namespace ~= "selection" or selection_layers == 0 then
		return
	end

	selection_layers = selection_layers - 1
	if selection_layers > 0 then
		return
	end

	for _, keybind in ipairs(selection_binds) do
		keybind:unbind()
	end
	selection_binds = {}
end)

hl.bind("XF86PowerOff", qs.call("session", "open"))
hl.bind("SUPER + SHIFT + S", qs.call("session", "open"))
hl.bind("SUPER + space", qs.global("launcherToggle"))
hl.bind("SUPER + F1", qs.call("gamingMode", "toggle"))

-- Spelled out rather than using meh, because shared.meh already contains SHIFT and
-- would collapse both wallpaper binds into the same chord.
hl.bind("CONTROL + ALT + W", qs.call("wallpaper", "next"))
hl.bind("CONTROL + ALT + SHIFT + W", qs.call("wallpaper", "prev"))

hl.bind("XF86MonBrightnessDown", qs.call("brightness", "decrement", { fallback = "brightnessctl s 5%-" }))
hl.bind("XF86MonBrightnessUp", qs.call("brightness", "increment", { fallback = "brightnessctl s 5%+" }))

hl.bind("XF86Launch4", qs.call("powerProfile", "cycle", { fallback = "asusctl profile --next" }))

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

-- locked = still reachable while the screen is locked
hl.bind("SUPER + ALT + P", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("SUPER + ALT + bracketright", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("SUPER + ALT + bracketleft", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

hl.bind("SUPER + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind("SUPER + M", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind("SUPER + P", hl.dsp.window.pseudo())
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + T", hl.dsp.window.float())
hl.bind("SUPER + Tab", hl.dsp.focus({ workspace = "previous" }))
-- Direct call rather than scripts/quake; that script exists for callers outside this
-- Lua state (nvim), and going through it here would spawn a shell and an hyprctl eval
-- round trip back into the state the keybind already fired from.
hl.bind("SUPER + backslash", quake.toggle)
hl.bind("SUPER + SHIFT + P", hl.dsp.exec_cmd("hyprpicker -a"))

hl.bind("SUPER + period", hl.dsp.layout("move +col"))
hl.bind("SUPER + comma", hl.dsp.layout("move -col"))
hl.bind("SUPER + SHIFT + period", hl.dsp.layout("swapcol r"))
hl.bind("SUPER + SHIFT + comma", hl.dsp.layout("swapcol l"))
hl.bind("SUPER + C", hl.dsp.layout("togglefit")) -- toggle center/fit mode, as niri Mod+C
hl.bind("SUPER + W", hl.dsp.layout("fit active"))
hl.bind("SUPER + SHIFT + W", hl.dsp.layout("fit visible"))
hl.bind("SUPER + CTRL + W", hl.dsp.layout("fit all"))
hl.bind("SUPER + G", hl.dsp.layout("promote"))

-- Resizing goes through layoutmsg only. A splitratio bind on these same keys does
-- nothing under the scrolling layout and shadows these.
hl.bind("SUPER + Minus", hl.dsp.layout("colresize -0.1"))
hl.bind("SUPER + Equal", hl.dsp.layout("colresize +0.1"))

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

for i = 1, 9 do
	hl.bind("SUPER + " .. i, hl.dsp.focus({ workspace = i }))
	hl.bind("SUPER + ALT + " .. i, hl.dsp.window.move({ workspace = i }))
end
hl.bind("SUPER + 0", hl.dsp.focus({ workspace = 10 }))
hl.bind("SUPER + ALT + 0", hl.dsp.window.move({ workspace = 10 }))

hl.bind("SUPER + s", hl.dsp.workspace.toggle_special())
hl.bind("SUPER + ALT + s", hl.dsp.window.move({ workspace = "special" }))

hl.bind("SUPER + bracketleft", hl.dsp.focus({ workspace = "e-1" }))
hl.bind("SUPER + bracketright", hl.dsp.focus({ workspace = "e+1" }))

hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + ALT + mouse:272", hl.dsp.window.resize(), { mouse = true })

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

-- Parks every other keybind so a VM can receive the raw chords. The toggle itself is
-- submap_universal, otherwise there would be no way back out.
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

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
