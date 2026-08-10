-- Values referenced by more than one config file.

local home = os.getenv("HOME")

return {
	system_theme = "Arc-Dark",
	cursor_theme = "Adwaita",
	cursor_size = 24,
	icon_theme = "Papirus",

	dpi_scale = 1,
	text_scale = 1,

	scripts_path = home .. "/.config/hypr/scripts",

	-- Ctrl+Shift+Alt, the modifier for secondary keybinds
	meh = "CONTROL + SHIFT + ALT",
}
