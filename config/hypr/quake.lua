-- The quake console: a terminal that drops down over whatever workspace is in
-- front. It lives in a special workspace so Hyprland does the showing, hiding,
-- and focus restoration, rather than this file tracking a window by hand. Its
-- bindings live in binds.lua and its slide is the specialWorkspace animation in
-- appearance.lua.

local workspace = "quake"

-- How much of the usable screen the console covers, measured from the top.
local share = 0.5

-- Seeded lazily rather than at boot, so nothing is running until the console is
-- first wanted. on_created_empty only fires when the workspace opens with
-- nothing in it, so a window stashed here by hand takes precedence and no
-- second terminal is spawned behind it.
--
-- The class no longer decides what the console is, but it still keeps this
-- terminal out of the scrolling_width rule rules.lua puts on ghostty. Pinned to
-- the workspace rather than trusting the spawn to inherit it, because that
-- inheritance rides on misc.initial_workspace_tracking, which is left at its
-- default here and would silently take the seed elsewhere if it were turned off.
local seed = "[workspace special:" .. workspace .. " silent] ghostty --class=dai.quake"

-- Dimming only applies while a special workspace is open, so the console gets
-- its separation from the workspace underneath without costing anything the
-- rest of the time.
hl.config({
	decoration = {
		dim_special = 0.5,
	},
})

-- Refitting replaces the rule in place rather than stacking a new one, but it
-- still schedules a monitor and window state refresh, and monitor.focused fires
-- on every hop between screens. Most of those hops do not change the number, so
-- only write the rule when it actually moves.
local covering = nil

local function cover(bottom)
	if covering == bottom then
		return
	end
	covering = bottom

	hl.workspace_rule({
		workspace = "special:" .. workspace,
		gaps_in = 0,
		gaps_out = { top = 0, right = 0, bottom = bottom, left = 0 },

		-- Nothing to highlight in a console that is only ever focused when it is
		-- open, and the active border reads as a stray frame around a panel the
		-- dimming behind it already sets apart.
		no_border = true,

		-- The console is flush to the top and to both sides, where a rounded
		-- corner cuts a notch out of the screen edge instead of softening the
		-- outline of a floating panel.
		no_rounding = true,

		on_created_empty = seed,
	})
end

-- Sizing the console with a window rule would freeze it at whatever the screen
-- measured when the window mapped, because Hyprland resolves those size
-- expressions once. Rescaling the monitor afterwards would leave a console that
-- is no longer a fraction of anything. Gaps are re-applied by the layout
-- instead, so the console is sized by the gap left underneath it and that gap is
-- recomputed whenever the monitor layout changes.
local function fit()
	local monitor = hl.get_active_monitor()

	-- A monitor handle whose output has gone away answers nil to every field, and
	-- layout changes are exactly when that happens, so this also covers reading
	-- height and reserved below.
	if not monitor or not monitor.scale or monitor.scale <= 0 then
		return
	end

	-- Monitor dimensions are in physical pixels; gaps are logical, so the scale
	-- has to come out before the reserved area (already logical) comes off.
	local reserved = monitor.reserved
	local usable = monitor.height / monitor.scale - reserved.top - reserved.bottom

	cover(math.max(0, math.floor(usable * (1 - share))))
end

-- Until a monitor can be read, cover the whole work area rather than leaving the
-- console unruled, so it is never seeded without its placement.
cover(0)
fit()

hl.on("monitor.layout_changed", fit)
hl.on("monitor.focused", fit)
