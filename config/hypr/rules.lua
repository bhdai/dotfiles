-- Rules are evaluated top to bottom, and a named rule must be registered before
-- any rule that matches on its tag.

local quake = require("quake")
local popups = require("popups")

-- Tag-first: match once on class or title, then let the property rules below act
-- on the tag instead of repeating the match expression.
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

popups.register()

hl.window_rule({
	match = { class = "me.kavishdevar.librepods" },
	float = true,
	center = true,
	size = { "monitor_w*0.25", "monitor_h*0.30" },
})

-- The screenshot annotation editor sizes itself to the image it was handed, so a
-- full-screen shot opens a window the size of the screen. Capped rather than
-- sized, so a small region still opens at its own size instead of being inflated
-- to fill the cap.
hl.window_rule({ match = { class = "dev.tensaku.Tensaku" }, float = true })
hl.window_rule({ match = { class = "dev.tensaku.Tensaku" }, center = true })
hl.window_rule({
	match = { class = "dev.tensaku.Tensaku" },
	max_size = { "monitor_w*0.65", "monitor_h*0.65" },
})

-- Smart borders: w[tv1] and f[1] match workspaces holding a single tiled window,
-- where a border only draws a box around the whole screen.
hl.window_rule({ match = { float = false, workspace = "w[tv1]" }, border_size = 0 })
hl.window_rule({ match = { float = false, workspace = "f[1]" }, border_size = 0 })

quake.register_rules()

hl.window_rule({ match = { class = "(firefox|zen)" }, idle_inhibit = "fullscreen" })

-- A column stores its width once, at open time. scrolling:column_width defaults to
-- 0.5, and fullscreen_on_one_column only *draws* a lone column full-bleed, so these
-- would visibly snap to half the moment a second column appears. 1.0 makes the
-- stored width match what they already look like alone, so nothing snaps.
hl.window_rule({ match = { class = "(firefox|zen)" }, scrolling_width = 1.0 })
hl.window_rule({ match = { class = "org.mozilla.Thunderbird" }, scrolling_width = 1.0 })
-- Only the regular terminal; the quake dropdown runs under class dai.quake and
-- floats, so it never enters a column.
hl.window_rule({ match = { class = "com.mitchellh.ghostty" }, scrolling_width = 1.0 })

hl.window_rule({ match = { title = "Rofi" }, animation = "popin" })

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

hl.layer_rule({ match = { namespace = "waybar" }, blur = true })
hl.layer_rule({ match = { namespace = "bar-1" }, blur = true })

-- hyprpicker's fullscreen freeze layer (used both by the color picker and by
-- the screen freeze every capture selects over) otherwise inherits the popin
-- layersIn/Out animation, which scales the whole screen in and out.
hl.layer_rule({ match = { namespace = "hyprpicker" }, no_anim = true })

-- slurp's area-selection box. It has to be set here rather than at runtime,
-- because `hyprctl keyword layerrule` is rejected under the Lua parser
-- ("keyword can't work with non-legacy parsers").
hl.layer_rule({ match = { namespace = "selection" }, no_anim = true, animation = "none" })
