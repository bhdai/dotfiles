-- ==============================================================================
-- Quickshell
-- ==============================================================================
--
-- The two ways this config reaches the shell, behind one interface.
--
-- Callers must know: a call with no fallback reports its own failure, a call with
-- one stays silent and lets the fallback answer. Nothing here detects whether the
-- shell handled the request — only whether it received it.

local shared = require("shared")

local qs_call = shared.scripts_path .. "/qs-call"

local M = {}

-- `qs ipc call`, via the wrapper that gives it an honest exit status.
--
-- opts.fallback: shell command to run if the call fails. Supplying one suppresses
-- the failure notification, because the fallback is the user-visible answer and a
-- toast on every keypress while the shell is down is noise.
function M.call(target, fn, opts)
	opts = opts or {}

	local cmd = qs_call .. " " .. target .. " " .. fn
	if opts.fallback then
		cmd = cmd .. " || " .. opts.fallback
	else
		cmd = cmd .. " --notify"
	end

	return hl.dsp.exec_cmd(cmd)
end

-- Quickshell's GlobalShortcut path: a direct compositor signal, no process spawn.
-- Nothing to detect and nothing to fall back to — the shell either registered the
-- shortcut at startup or the keypress goes nowhere.
function M.global(name)
	return hl.dsp.global("quickshell:" .. name)
end

return M
