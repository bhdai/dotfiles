-- ==============================================================================
-- Shared Values
-- ==============================================================================
--
-- Central module for values referenced by multiple config files.

local home = os.getenv("HOME")

return {
	-- Theme
	system_theme = "Arc-Dark",
	cursor_theme = "Adwaita", -- previously WhiteSur-cursors
	cursor_size = 24,
	icon_theme = "Papirus",

	-- Scaling
	dpi_scale = 1,
	text_scale = 1,

	-- Paths
	scripts_path = home .. "/.config/hypr/scripts",

	-- Modifier alias: Ctrl+Shift+Alt, used for secondary keybinds
	meh = "CONTROL + SHIFT + ALT",
}
