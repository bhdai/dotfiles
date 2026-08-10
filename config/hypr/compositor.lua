hl.config({
	cursor = {
		no_hardware_cursors = 0, -- 0 = use hardware cursors when the driver supports them
		inactive_timeout = 10,
	},

	input = {
		kb_layout = "us",
		kb_variant = "",
		kb_model = "",
		kb_rules = "",

		float_switch_override_focus = 0,
		follow_mouse = 2,
		repeat_rate = 25,
		repeat_delay = 200,
		sensitivity = 0.4, -- -1.0 to 1.0, 0 means no modification

		touchpad = {
			natural_scroll = true,
			scroll_factor = 0.4,
			drag_lock = 0,
			tap_and_drag = true,
			clickfinger_behavior = true,
			disable_while_typing = true,
		},
	},

	general = {
		allow_tearing = true,
		gaps_in = 4,
		gaps_out = 10,
		border_size = 2,
		col = {
			active_border = "rgba(07b5efff)",
			inactive_border = "rgba(292e42ff)",
		},
		layout = "scrolling",

		snap = {
			enabled = true,
			window_gap = 10,
			monitor_gap = 10,
		},
	},

	scrolling = {
		fullscreen_on_one_column = true,
		focus_fit_method = 1,
		explicit_column_widths = "0.333, 0.5, 0.667",
	},

	misc = {
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
		mouse_move_enables_dpms = true,
		enable_swallow = false,
		swallow_regex = "^(org\\.wezfurlong\\.wezterm)$",
		vrr = 1,
	},

	-- Forcing 1:1 scaling keeps XWayland apps from rendering blurry.
	xwayland = {
		force_zero_scaling = true,
	},

	-- Tuning only; the gesture itself is declared in binds.lua.
	gestures = {
		workspace_swipe_cancel_ratio = 0.2,
		workspace_swipe_min_speed_to_force = 5,
		workspace_swipe_direction_lock = true,
	},

	-- Kept so switching away from the scrolling layout still lands somewhere sane.
	dwindle = {
		preserve_split = true,
		smart_split = false,
		smart_resizing = false,
	},

	master = {
		new_status = "master",
	},

	binds = {
		allow_workspace_cycles = true,
		movefocus_cycles_fullscreen = true,
	},
})
