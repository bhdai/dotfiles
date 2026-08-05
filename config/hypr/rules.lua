-- ==============================================================================
-- Window Rules and Layer Rules
-- ==============================================================================
--
-- Rule order matters: evaluated top to bottom (named rules before anonymous).

local quake = require("quake")

-- -------------------------------------------------------------------------
-- Dialog windows
-- Tag-first pattern: match on class/title, apply tag, then downstream rules
-- act on the tag.
-- -------------------------------------------------------------------------
hl.window_rule({
	match = {
		class = ".*(confirm|org.freedesktop.impl.portal.desktop.kde|dialog|pavucontrol|nm-connection-editor|blueman-manager|cpupower-gui|waypaper).*",
	},
	tag = "+dialog",
})
hl.window_rule({
	match = { title = ".*File Upload.*" },
	tag = "+dialog",
})
hl.window_rule({ match = { tag = "dialog" }, float = true })
hl.window_rule({ match = { tag = "dialog" }, center = true })
hl.window_rule({ match = { tag = "dialog" }, size = { "monitor_w*0.60", "monitor_h*0.65" } })

-- -------------------------------------------------------------------------
-- Zen browser popups
-- -------------------------------------------------------------------------
-- Live Hyprland 0.56.1 probe: `window.title` yielded `1 arg(s): userdata`,
-- whose address, class, and title fields were readable. Go: use HL.Window directly.
local window_birthdays = {}
local processed_popups = {}

hl.on("window.open", function(window)
	window_birthdays[window.address] = os.time()
end)

hl.on("window.close", function(window)
	window_birthdays[window.address] = nil
	processed_popups[window.address] = nil
end)

hl.on("window.title", function(window)
	local address = window.address
	local birthday = window_birthdays[address]
	if not birthday or processed_popups[address] then
		return
	end

	local title = window.title
	local is_popup = title:find("Sign in - Google Accounts —", 1, true) == 1
		or title:find("Extension:", 1, true) == 1
	if not is_popup or window.class:find("zen", 1, true) ~= 1 then
		return
	end

	-- Matching titles also appear when an existing tab navigates. Limiting the action
	-- to windows seen opening in the last five seconds distinguishes new popups and
	-- prevents a config reload from reclassifying windows that already existed.
	if os.time() - birthday > 5 then
		return
	end

	processed_popups[address] = true

	local monitor = hl.get_active_monitor()
	local target = "address:" .. address
	hl.dispatch(hl.dsp.window.float({ action = "on", window = target }))
	hl.dispatch(hl.dsp.window.resize({
		x = monitor.width * 0.30,
		y = monitor.height * 0.60,
		relative = false,
		window = target,
	}))
	hl.dispatch(hl.dsp.focus({ window = target }))
	hl.dispatch(hl.dsp.window.center({ window = target }))
end)

-- -------------------------------------------------------------------------
-- Librepods
-- -------------------------------------------------------------------------
hl.window_rule({
	match = { class = "me.kavishdevar.librepods" },
	float = true,
	center = true,
	size = { "monitor_w*0.25", "monitor_h*0.30" },
})

-- -------------------------------------------------------------------------
-- Smart borders: hide borders when only one tiled window is present
-- -------------------------------------------------------------------------
hl.window_rule({ match = { float = false, workspace = "w[tv1]" }, border_size = 0 })
hl.window_rule({ match = { float = false, workspace = "f[1]" }, border_size = 0 })

-- -------------------------------------------------------------------------
-- Quake terminal
-- -------------------------------------------------------------------------
quake.register_rules()

-- -------------------------------------------------------------------------
-- Idle inhibit: prevent screen lock while fullscreen in browsers
-- -------------------------------------------------------------------------
hl.window_rule({ match = { class = "(firefox|zen)" }, idle_inhibit = "fullscreen" })

-- -------------------------------------------------------------------------
-- Rofi animation
-- -------------------------------------------------------------------------
hl.window_rule({ match = { title = "Rofi" }, animation = "popin" })

-- -------------------------------------------------------------------------
-- Picture-in-Picture
-- -------------------------------------------------------------------------
hl.window_rule({
	match = { title = "[Pp]icture.?[Ii]n.?[Pp]icture" },
	tag = "+picture-in-picture",
})
hl.window_rule({ match = { tag = "picture-in-picture" }, float = true })
hl.window_rule({ match = { tag = "picture-in-picture" }, keep_aspect_ratio = true })
hl.window_rule({
	match = { tag = "picture-in-picture" },
	move = { "monitor_w*0.73", "monitor_h*0.72" },
})
hl.window_rule({
	match = { tag = "picture-in-picture" },
	size = { "monitor_w*0.25", "monitor_h*0.25" },
})
hl.window_rule({ match = { tag = "picture-in-picture" }, pin = true })

-- -------------------------------------------------------------------------
-- Layer Rules
-- -------------------------------------------------------------------------
hl.layer_rule({ match = { namespace = "waybar" }, blur = true })
-- hl.layer_rule({ match = { namespace = "quickshell:.*" }, blur = true })
hl.layer_rule({ match = { namespace = "bar-1" }, blur = true })

-- hyprpicker's fullscreen freeze layer (used both by the color picker and by
-- grimblast --freeze for screenshots) otherwise inherits the popin layersIn/Out
-- animation, which scales the whole screen in and out.
hl.layer_rule({ match = { namespace = "hyprpicker" }, no_anim = true })

-- slurp's area-selection box. grimblast tries to disable its animation at
-- runtime, but `hyprctl keyword layerrule` is rejected under the Lua parser
-- ("keyword can't work with non-legacy parsers"), so it must be set here.
hl.layer_rule({ match = { namespace = "selection" }, no_anim = true })
