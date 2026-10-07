local _, ns = ...

local GetClientHeader = ns.GetDiagnosticClientHeader

--------------------------------------------------------------------------------
-- Display Context
--------------------------------------------------------------------------------

-- Answers "the quest log is off-screen / the wrong size" reports: screen size, UI scale, and the window.
function ns:BuildDisplayContextReport()
	local lines = { GetClientHeader(), "" }

	local width, height = GetPhysicalScreenSize()
	lines[#lines + 1] = string.format("Physical screen size: %s x %s", tostring(width), tostring(height))
	lines[#lines + 1] = string.format("UIParent scale: %s", tostring(UIParent and UIParent:GetScale()))
	-- uiScale is ignored while useUiScale is 0; the game then picks the scale itself.
	lines[#lines + 1] = string.format("useUiScale CVar: %s", tostring(GetCVar("useUiScale")))
	lines[#lines + 1] = string.format("uiScale CVar: %s", tostring(GetCVar("uiScale")))

	lines[#lines + 1] = ""
	local window = ns.questLogFrame or QuestLogFrame
	if window then
		lines[#lines + 1] = string.format("Quest log shown: %s", tostring(window:IsShown()))
		lines[#lines + 1] =
			string.format("Quest log size: %s x %s", tostring(window:GetWidth()), tostring(window:GetHeight()))
		lines[#lines + 1] = string.format("Quest log effective scale: %s", tostring(window:GetEffectiveScale()))
		local point, _, relativePoint, x, y = window:GetPoint(1)
		lines[#lines + 1] = string.format(
			"Quest log anchor: %s to %s, %s, %s",
			tostring(point),
			tostring(relativePoint),
			tostring(x),
			tostring(y)
		)
	end

	local saved = ns.db and ns.db.global
	-- The window only takes the saved height when it opens, and the clamp to the screen can shorten it.
	lines[#lines + 1] = string.format(
		"Saved height: %s (applied when the quest log opens, limited to the screen)",
		tostring(saved and saved.height)
	)
	local savedPoint = saved and saved.point
	lines[#lines + 1] = string.format(
		"Saved position: %s",
		type(savedPoint) == "table"
				and string.format(
					"%s to %s, %s, %s",
					tostring(savedPoint[1]),
					tostring(savedPoint[3]),
					tostring(savedPoint[4]),
					tostring(savedPoint[5])
				)
			or "(none)"
	)

	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Other Add-ons
--------------------------------------------------------------------------------

function ns:BuildAddOnReport()
	local lines = { GetClientHeader(), "" }
	local count = C_AddOns.GetNumAddOns()
	for index = 1, count do
		local name, _, _, loadable = C_AddOns.GetAddOnInfo(index)
		-- Many add-ons already prefix their version with "v"; drop it so we don't print "vv".
		local version = (C_AddOns.GetAddOnMetadata(index, "Version") or "?"):gsub("^[vV]", "")
		lines[#lines + 1] = string.format("%s v%s [%s]", name, version, loadable and "loadable" or "disabled")
	end
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Saved Variables
--------------------------------------------------------------------------------

local function DumpTable(value, indent, depth, lines)
	if depth > 8 then
		lines[#lines + 1] = indent .. "<max depth>"
		return
	end
	local keys = {}
	for key in pairs(value) do
		keys[#keys + 1] = key
	end
	table.sort(keys, function(a, b)
		return tostring(a) < tostring(b)
	end)
	for _, key in ipairs(keys) do
		local entry = value[key]
		if type(entry) == "table" then
			lines[#lines + 1] = indent .. tostring(key) .. " = {"
			DumpTable(entry, indent .. "    ", depth + 1, lines)
			lines[#lines + 1] = indent .. "}"
		else
			lines[#lines + 1] = indent .. tostring(key) .. " = " .. tostring(entry)
		end
	end
end

--[[
    Dumps the single AceDB-managed table (profiles, profileKeys, char, global)
    so a player can paste their exact configuration: every setting in each
    profile, and the window's saved size and position.
]]
function ns:BuildSavedVariablesReport()
	local lines = { GetClientHeader(), "", ns.SAVED_VARIABLES_NAME .. " = {" }
	DumpTable(_G[ns.SAVED_VARIABLES_NAME] or {}, "    ", 1, lines)
	lines[#lines + 1] = "}"
	return table.concat(lines, "\n")
end
