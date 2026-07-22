-- ==============================================================================
-- Monitor Declarations
-- ==============================================================================

hl.monitor({
	output = "eDP-1",
	mode = "preferred",
	position = "0x0",
	scale = 1.07,
})

hl.monitor({
	output = "HDMI-A-1",
	mode = "preferred",
	position = "auto",
	scale = 1,
	mirror = "eDP-1",
})
