-- Floats browser popups that a static window rule cannot match, because the title
-- identifying them only arrives after the window is mapped.

-- Window addresses seen opening, and those already floated. Both are keyed by
-- address and cleared on close, so the tables track only live windows.
local window_birthdays = {}
local processed_popups = {}

local max_age_seconds = 5

local function is_zen_popup(window)
	if window.class:find("zen", 1, true) ~= 1 then
		return false
	end

	local title = window.title
	return title:find("Sign in - Google Accounts —", 1, true) == 1 or title:find("Extension:", 1, true) == 1
end

local function float_centered(window)
	local monitor = hl.get_active_monitor()
	local target = "address:" .. window.address

	hl.dispatch(hl.dsp.window.float({ action = "on", window = target }))
	hl.dispatch(hl.dsp.window.resize({
		x = monitor.width * 0.30,
		y = monitor.height * 0.60,
		relative = false,
		window = target,
	}))
	hl.dispatch(hl.dsp.focus({ window = target }))
	hl.dispatch(hl.dsp.window.center({ window = target }))
end

local M = {}

-- Installs the window event handlers. Call once; a second call would double-register
-- them. The handlers receive a userdata HL.Window (probed against Hyprland 0.56.1),
-- so address, class, and title are read straight off it.
function M.register()
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

		if not is_zen_popup(window) then
			return
		end

		-- Matching titles also appear when an existing tab navigates. Limiting the action
		-- to windows seen opening recently distinguishes new popups and prevents a config
		-- reload from reclassifying windows that already existed.
		if os.time() - birthday > max_age_seconds then
			return
		end

		processed_popups[address] = true
		float_centered(window)
	end)
end

return M
