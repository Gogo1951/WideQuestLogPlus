local _, ns = ...

local GetClientHeader = ns.GetDiagnosticClientHeader

--------------------------------------------------------------------------------
-- API Endpoints
--------------------------------------------------------------------------------

--[[
	Existence and shape checks only: read-only, no side effects, no protected
	calls. One row per API the add-on calls or replaces, wherever it lives. The
	two clients' quest logs share nothing, so each client checks the shared rows
	plus its own quest log's.
]]

local function Resolve(path)
	local value = _G
	for part in string.gmatch(path, "[^.]+") do
		if type(value) ~= "table" then
			return nil
		end
		value = value[part]
	end
	return value
end

local function Rows(kind, paths)
	local rows = {}
	for _, path in ipairs(paths) do
		rows[#rows + 1] = {
			path,
			function()
				return type(Resolve(path)) == kind
			end,
		}
	end
	return rows
end

local function Append(target, rows)
	for _, row in ipairs(rows) do
		target[#target + 1] = row
	end
end

local SHARED_FUNCTIONS = {
	"C_AddOns.GetAddOnMetadata",
	"C_AddOns.IsAddOnLoaded",
	"C_AddOns.GetAddOnInfo",
	"C_AddOns.GetNumAddOns",
	"C_Seasons.GetActiveSeason",
	"C_Timer.After",
	"Settings.OpenToCategory",
	"hooksecurefunc",
	"GetQuestDifficultyColor",
}

local CLASSIC_FUNCTIONS = {
	"QuestLog_Update",
	"QuestLog_UpdateQuestDetails",
	"QuestFrameItems_Update",
	"SetUIPanelAttribute",
	"GetNumQuestLogEntries",
	"GetQuestLogTitle",
	"GetQuestLogSelection",
	"GetQuestTagInfo",
	"GetNumQuestLeaderBoards",
	"GetQuestLogLeaderBoard",
	"FauxScrollFrame_Update",
	"FauxScrollFrame_GetOffset",
	"QuestLog_SetSelection",
	"IsQuestWatched",
	"IsUnitOnQuest",
	"GetNumSubgroupMembers",
}

local FOREVER_FUNCTIONS = {
	"C_QuestLog.GetInfo",
	"C_QuestLog.GetNumQuestLogEntries",
	"C_QuestLog.GetQuestTagInfo",
	"C_QuestLog.IsEliteQuest",
	"C_QuestLog.IsComplete",
	"C_QuestLog.IsFailed",
	"C_QuestLog.GetTitleForQuestID",
	"C_QuestLog.GetLogIndexForQuestID",
	"C_QuestLog.GetHeaderIndexForQuest",
	"C_QuestLog.GetSelectedQuest",
	"C_QuestLog.SetSelectedQuest",
	"C_QuestLog.GetNextWaypointText",
	"C_QuestLog.AddQuestWatch",
	"C_QuestLog.RemoveQuestWatch",
	"C_QuestLog.GetNumQuestWatches",
	"C_QuestLog.CanAbandonQuest",
	"C_QuestLog.IsPushableQuest",
	"C_QuestLog.IsQuestDisabledForSession",
	"C_QuestLog.GetMaxNumQuestsCanAccept",
	"ExpandQuestHeader",
	"CollapseQuestHeader",
	"GetNumQuestLeaderBoards",
	"GetQuestLogLeaderBoard",
	"QuestInfo_Display",
	"QuestUtils_IsQuestWatched",
	"QuestUtil.CanRemoveQuestWatch",
	"QuestMapQuestOptions_AbandonQuest",
	"QuestMapQuestOptions_ShareQuest",
	"ToggleQuestLog",
	"QuestMapFrame_OpenToQuestDetails",
	"CreateScrollBoxListLinearView",
	"CreateDataProvider",
	"ScrollUtil.InitScrollBoxListWithScrollBar",
	"MenuUtil.CreateContextMenu",
	"ChatFrameUtil.TryInsertQuestLinkForQuestID",
	"QuestTextContrast.IsEnabled",
	"QuestTextContrast.GetDefaultBackgroundAtlas",
	"CopyTable",
	"IsCurrentQuestFailed",
	"GetQuestLink",
}

ns.DIAGNOSTIC_API_CHECKS = {}
Append(ns.DIAGNOSTIC_API_CHECKS, Rows("function", SHARED_FUNCTIONS))
Append(ns.DIAGNOSTIC_API_CHECKS, Rows("table", { "Enum.SeasonID", "QuestDifficultyColors" }))
Append(ns.DIAGNOSTIC_API_CHECKS, Rows("string", { "QUEST_LOG" }))
if ns.FLAVOR == "Camelot" then
	Append(ns.DIAGNOSTIC_API_CHECKS, Rows("function", FOREVER_FUNCTIONS))
	Append(
		ns.DIAGNOSTIC_API_CHECKS,
		Rows("table", {
			"QUEST_TEMPLATE_LOG",
			"QuestMapFrame",
			"QuestFrame",
			"QuestLogPopupDetailFrame",
			"QuestDifficultyHighlightColors",
		})
	)
	Append(ns.DIAGNOSTIC_API_CHECKS, Rows("number", { "Constants.QuestWatchConsts.MAX_QUEST_WATCHES" }))
	Append(ns.DIAGNOSTIC_API_CHECKS, Rows("string", { "QUEST_TITLE_FORMAT_FAILED", "PARENS_TEMPLATE" }))
else
	Append(ns.DIAGNOSTIC_API_CHECKS, Rows("function", CLASSIC_FUNCTIONS))
	Append(ns.DIAGNOSTIC_API_CHECKS, Rows("table", { "QuestLogFrame", "QuestLogTitle1" }))
	Append(ns.DIAGNOSTIC_API_CHECKS, Rows("number", { "QUESTS_DISPLAYED", "LE_QUEST_FREQUENCY_DAILY" }))
	Append(ns.DIAGNOSTIC_API_CHECKS, Rows("string", { "ELITE" }))
end

--------------------------------------------------------------------------------
-- Libraries
--------------------------------------------------------------------------------

--[[
	The LibStub libraries the TOC loads from Includes/Libraries. LibStub keeps
	only the highest minor of each, so the version reported is whichever copy
	won, ours or a newer one from another add-on.
]]
ns.DIAGNOSTIC_LIBRARIES = {
	"AceConfig-3.0",
	"AceConfigCmd-3.0",
	"AceConfigDialog-3.0",
	"AceConfigRegistry-3.0",
	"AceDB-3.0",
	"AceDBOptions-3.0",
	"AceGUI-3.0",
	"AceLocale-3.0",
	"CallbackHandler-1.0",
}

--------------------------------------------------------------------------------
-- Data Sources
--------------------------------------------------------------------------------

-- The add-on ships no static game data, so there is nothing to validate.
ns.DIAGNOSTIC_DATA_SOURCES = {}

--------------------------------------------------------------------------------
-- Quest Log Context
--------------------------------------------------------------------------------

ns.DiagnosticsStrings.EVENT_LOG_EXAMPLES =
	"Best for 'the quest log didn't update' or 'tracking didn't change' reports on WoW Forever."

local function Setting(lines, label, key)
	local value = ns.db and ns.db.profile[key]
	lines[#lines + 1] = string.format("%s: %s", label, tostring(value))
end

local function Loaded(name)
	return C_AddOns.IsAddOnLoaded(name) and "loaded" or "not loaded"
end

-- The state behind "the quest log looks wrong" and "tracking doesn't work" reports. Reads only.
function ns:BuildQuestLogContextReport()
	local lines = { GetClientHeader(), "" }

	if ns.FLAVOR == "Camelot" then
		lines[#lines + 1] = "Quest log: the add-on's own window (WoW Forever)"
		lines[#lines + 1] = string.format("Quest log entries: %d", C_QuestLog.GetNumQuestLogEntries())
		lines[#lines + 1] = string.format("Selected quest: %s", tostring(ns.questLog and ns.questLog.selectedQuestID))
	else
		lines[#lines + 1] = "Quest log: Blizzard's quest log, widened"
		lines[#lines + 1] = string.format("Quest log entries: %d", GetNumQuestLogEntries())
		lines[#lines + 1] = string.format("List rows (QUESTS_DISPLAYED): %s", tostring(QUESTS_DISPLAYED))
	end

	lines[#lines + 1] = ""
	Setting(lines, "Zone order", "zoneSort")
	Setting(lines, "Space above zone names", "zoneGap")
	Setting(lines, "Quest order", "questSort")
	Setting(lines, "Mark untracked quests", "markUntracked")
	if ns.FLAVOR == "Camelot" then
		Setting(lines, "Wide quest log enabled", "enableWideQuestLog")
		lines[#lines + 1] =
			string.format("Quest log key taken over this session: %s", tostring(ns.questLogTakenOver == true))
	end
	Setting(lines, "Welcome message", "showWelcome")

	lines[#lines + 1] = ""
	lines[#lines + 1] = string.format("Questie: %s", Loaded("Questie"))
	lines[#lines + 1] = string.format("ElvUI: %s", Loaded("ElvUI"))
	lines[#lines + 1] = string.format("VoiceOver: %s", Loaded("AI_VoiceOver"))
	if ns.FLAVOR == "Camelot" then
		local profile = Questie and Questie.db and Questie.db.profile
		lines[#lines + 1] = string.format("Questie tracker enabled: %s", tostring(profile and profile.trackerEnabled))
	end

	return table.concat(lines, "\n")
end
