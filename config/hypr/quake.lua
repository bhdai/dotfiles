-- ==============================================================================
-- Quake Terminal
-- ==============================================================================

local class = "dai.quake"
local tag = "quake"
local special_workspace = "special:quake"
local size = { 1400, 875 }

local previous_window = nil

local M = {}

local function find_quake_window()
	for _, window in ipairs(hl.get_windows()) do
		if window.class == class then
			return window
		end
	end
end

-- Registers the identity rule before the tag-based property rules. Call this at
-- the point in rules.lua where the quake rules should enter evaluation order.
function M.register_rules()
	local class_pattern = "(" .. class:gsub("([^%w])", "\\%1") .. ")"

	hl.window_rule({ match = { class = class_pattern }, tag = "+" .. tag })
	hl.window_rule({ match = { tag = tag }, float = true })
	hl.window_rule({ match = { tag = tag }, center = true })
	hl.window_rule({ match = { tag = tag }, decorate = false })
	hl.window_rule({ match = { tag = tag }, dim_around = true })
	hl.window_rule({ match = { tag = tag }, no_anim = true })
	hl.window_rule({ match = { tag = tag }, size = size })
end

-- Toggles the sole quake terminal. Focus restoration is retained only for the
-- lifetime of the current Hyprland Lua context.
function M.toggle()
	local quake_window = find_quake_window()
	local active_window = hl.get_active_window()

	if not quake_window then
		previous_window = active_window
		hl.dispatch(hl.dsp.exec_cmd("ghostty --class=" .. class))
		return
	end

	if quake_window.workspace and quake_window.workspace.name == special_workspace then
		previous_window = active_window

		if active_window and active_window.fullscreen ~= 0 then
			hl.dispatch(hl.dsp.window.fullscreen_state({
				internal = 0,
				client = 0,
				window = active_window,
			}))
		end

		hl.dispatch(hl.dsp.window.move({
			workspace = hl.get_active_workspace(),
			window = quake_window,
		}))
		hl.dispatch(hl.dsp.focus({ window = quake_window }))
		hl.dispatch(hl.dsp.window.bring_to_top())
		return
	end

	hl.dispatch(hl.dsp.window.move({ workspace = special_workspace, window = quake_window }))
	if previous_window then
		hl.dispatch(hl.dsp.focus({ window = previous_window }))
	end
	hl.dispatch(hl.dsp.window.bring_to_top())
end

return M
