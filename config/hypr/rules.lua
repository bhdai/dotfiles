-- ==============================================================================
-- Window Rules and Layer Rules
-- ==============================================================================
--
-- Rule order matters: evaluated top to bottom (named rules before anonymous).

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
	match = { title = ".*(Extension.*Bitwarden|.*File Upload.*).*" },
	tag = "+dialog",
})
hl.window_rule({ match = { tag = "dialog" }, float = true })
hl.window_rule({ match = { tag = "dialog" }, center = true })
hl.window_rule({ match = { tag = "dialog" }, size = { "monitor_w*0.60", "monitor_h*0.65" } })

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
-- Quake terminal (dai.quake)
-- -------------------------------------------------------------------------
hl.window_rule({ match = { class = "(dai\\.quake)" }, float = true })
hl.window_rule({ match = { class = "(dai\\.quake)" }, center = true })
hl.window_rule({ match = { class = "(dai\\.quake)" }, decorate = false })
hl.window_rule({ match = { class = "(dai\\.quake)" }, dim_around = true })
hl.window_rule({ match = { class = "(dai\\.quake)" }, no_anim = true })
hl.window_rule({ match = { class = "(dai\\.quake)" }, size = { 1400, 875 } })

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
hl.window_rule({ match = { title = "[Pp]icture.?[Ii]n.?[Pp]icture" }, float = true })
hl.window_rule({ match = { title = "[Pp]icture.?[Ii]n.?[Pp]icture" }, keep_aspect_ratio = true })
hl.window_rule({
	match = { title = "[Pp]icture.?[Ii]n.?[Pp]icture" },
	move = { "monitor_w*0.73", "monitor_h*0.72" },
})
hl.window_rule({
	match = { title = "[Pp]icture.?[Ii]n.?[Pp]icture" },
	size = { "monitor_w*0.25", "monitor_h*0.25" },
})
hl.window_rule({ match = { title = "[Pp]icture.?[Ii]n.?[Pp]icture" }, pin = true })

-- -------------------------------------------------------------------------
-- Layer Rules
-- -------------------------------------------------------------------------
hl.layer_rule({ match = { namespace = "waybar" }, blur = true })
-- hl.layer_rule({ match = { namespace = "quickshell:.*" }, blur = true })
hl.layer_rule({ match = { namespace = "bar-1" }, blur = true })
