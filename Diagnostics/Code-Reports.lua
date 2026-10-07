local _, ns = ...

local GetClientHeader = ns.GetDiagnosticClientHeader

--------------------------------------------------------------------------------
-- Event Registration
--------------------------------------------------------------------------------

--[[
    For every event the add-on registers (ns.EVENT_NAMES, exported by
    Core.lua), report whether it is valid on this client
    (C_EventUtils.IsEventValid) and whether RegisterEvent succeeds. The probe
    frame registers then immediately unregisters each event with no handler
    attached, so nothing is ever processed. The list is sourced from Core so it
    can never drift from the events the add-on actually uses.
]]

local probeFrame

local function GetProbeFrame()
	if not probeFrame then
		probeFrame = CreateFrame("Frame")
	end
	return probeFrame
end

function ns:RunEventChecks()
	local lines = { GetClientHeader(), "" }
	local hasIsEventValid = type(C_EventUtils) == "table" and type(C_EventUtils.IsEventValid) == "function"
	local probe = GetProbeFrame()
	local failures = 0
	for _, event in ipairs(ns.EVENT_NAMES or {}) do
		local valid = "n/a"
		if hasIsEventValid then
			valid = C_EventUtils.IsEventValid(event) and "valid" or "INVALID"
		end
		local ok = pcall(probe.RegisterEvent, probe, event)
		if ok then
			probe:UnregisterEvent(event)
		else
			failures = failures + 1
		end
		lines[#lines + 1] = string.format("[%s] %s (IsEventValid: %s)", ok and "PASS" or "FAIL", event, valid)
	end
	lines[#lines + 1] = ""
	if failures == 0 then
		lines[#lines + 1] = "All events register on this client."
	else
		lines[#lines + 1] = string.format("%d event(s) failed to register.", failures)
	end
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- API Endpoints
--------------------------------------------------------------------------------

function ns:RunApiChecks()
	local lines = { GetClientHeader(), "" }
	local failures = 0
	for _, check in ipairs(ns.DIAGNOSTIC_API_CHECKS) do
		local ok, result = pcall(check[2])
		local pass = ok and result
		if not pass then
			failures = failures + 1
		end
		lines[#lines + 1] = (pass and "[PASS] " or "[FAIL] ") .. check[1]
	end
	lines[#lines + 1] = ""
	if failures == 0 then
		lines[#lines + 1] = "Every API is present on this client."
	else
		lines[#lines + 1] = string.format("%d API(s) missing or the wrong type.", failures)
	end
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Library Versions
--------------------------------------------------------------------------------

-- Only the libraries the add-on bundles; everything else in LibStub belongs to other add-ons, so it's just counted.
function ns:BuildLibraryReport()
	local lines = { GetClientHeader(), "" }
	local bundled = {}
	for _, name in ipairs(ns.DIAGNOSTIC_LIBRARIES) do
		bundled[name] = true
		local minor = LibStub.minors[name]
		lines[#lines + 1] = string.format("%s (minor %s)", name, minor and tostring(minor) or "NOT LOADED")
	end
	local others = 0
	for name in LibStub:IterateLibraries() do
		if not bundled[name] then
			others = others + 1
		end
	end
	lines[#lines + 1] = ""
	lines[#lines + 1] = string.format("%d other libraries loaded by other add-ons.", others)
	return table.concat(lines, "\n")
end
