-- Rules are evaluated top to bottom, and a named rule must be registered before
-- any rule that matches on its tag.

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

hl.window_rule({ match = { class = "(firefox|zen)" }, idle_inhibit = "fullscreen" })

-- A column stores its width once, at open time. scrolling:column_width defaults to
-- 0.5, and fullscreen_on_one_column only *draws* a lone column full-bleed, so these
-- would visibly snap to half the moment a second column appears. 1.0 makes the
-- stored width match what they already look like alone, so nothing snaps.
hl.window_rule({ match = { class = "(firefox|zen)" }, scrolling_width = 1.0 })
hl.window_rule({ match = { class = "org.mozilla.Thunderbird" }, scrolling_width = 1.0 })
-- Only the regular terminal; the quake console runs under class dai.quake, so a
-- second window opened inside the console still splits instead of taking the
-- console's full width.
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

-- Every Quickshell surface that draws itself translucent. Transparency without blur is not a
-- partial version of this effect, it is a different and worse one, so the two belong together:
-- a surface that gets one and not the other reads as a bug.
--
-- `ignore_alpha` matters more than it looks: these surfaces are far larger than the card drawn
-- inside them (the dashboard's is fixed at its widest destination and masked down, and the
-- notification strip is mostly click-through), so without a threshold Hyprland blurs the whole
-- invisible rectangle. It is bounded on both sides. Below, by the launcher's drop shadow, which
-- must stay unblurred or its soft falloff grows a hard ring where blur stops. That bound moves:
-- `DropShadow` masks its `#40000000` by the source's alpha, and the source is the card itself,
-- so the shadow fades as the panels open up — at 0.70 background it peaks near 0.075, not the
-- 0.25 the color alone suggests. Above, by the panels' own ground: Appearance paints it at 1
-- minus `configuredBackgroundTransparency`, so raising that value walks the ground's alpha down
-- toward this number, and the moment it crosses, the panels stop being blurred at all rather
-- than becoming more translucent. 0.15 sits clear of both.
--
-- Deliberately no `xray`: it samples only the wallpaper layer, so a panel over a terminal blurs
-- the wallpaper it is hiding rather than the terminal. Cheaper, and wrong — a frosted surface
-- that ignores what it is actually covering stops reading as glass.
--
-- The bar is in the list even though its 40px exclusive zone keeps tiled windows out from
-- under it, so what it usually covers is the still wallpaper. Blur is still what the effect
-- needs: unblurred, its 0.88 alpha reads as a washed-out tint of whatever the wallpaper
-- happens to be under it, not as glass. Fullscreen windows ignore the exclusive zone and do
-- pass beneath it.
--
-- The notification namespace does not follow the `quickshell:<name>` convention the others use.
-- It is spelled the way the surface actually declares itself; a layer rule matches nothing if
-- it disagrees with the client by a single character.
local quickshell_surfaces = {
	"quickshell:bar",
	"quickshell:controlCenter",
	"quickshell:dashboard",
	"quickshell:launcher",
	"quickshell:osd:volume",
	"quickshell:osd:brightness",
	"quickshell-notification-popups",
}
for _, namespace in ipairs(quickshell_surfaces) do
	hl.layer_rule({ match = { namespace = namespace }, blur = true, ignore_alpha = 0.15 })
end

-- hyprpicker's fullscreen freeze layer (used both by the color picker and by
-- the screen freeze every capture selects over) otherwise inherits the popin
-- layersIn/Out animation, which scales the whole screen in and out.
hl.layer_rule({ match = { namespace = "hyprpicker" }, no_anim = true })

-- slurp's area-selection box. It has to be set here rather than at runtime,
-- because `hyprctl keyword layerrule` is rejected under the Lua parser
-- ("keyword can't work with non-legacy parsers").
hl.layer_rule({ match = { namespace = "selection" }, no_anim = true, animation = "none" })
