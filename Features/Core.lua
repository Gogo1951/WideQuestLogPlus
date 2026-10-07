local ADDON_NAME, ns = ...
local L = ns.L

local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

--------------------------------------------------------------------------------
-- Version
--------------------------------------------------------------------------------

local function GetVersion()
	local version = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Version")
	if not version or version:find("@") then
		return "Dev"
	end
	return version
end

ns.Version = GetVersion()

--------------------------------------------------------------------------------
-- Events
--------------------------------------------------------------------------------

--[[
	Every event the add-on can handle, in registration order, with its handler.
	Feature files define the handlers; an event is registered only once a loaded
	file defines its handler, so a client never registers an event only another
	client's files use. ns.EVENT_NAMES lists what was actually registered.
]]
local EVENTS = {
	{ "ADDON_LOADED", "OnAddonLoaded" },
	{ "PLAYER_LOGIN", "OnPlayerLogin" },
	{ "QUEST_LOG_UPDATE", "OnQuestLogUpdate" },
	{ "QUEST_WATCH_LIST_CHANGED", "OnQuestWatchListChanged" },
	{ "QUEST_ACCEPTED", "OnQuestAccepted" },
	{ "QUEST_REMOVED", "OnQuestRemoved" },
	{ "QUEST_TURNED_IN", "OnQuestTurnedIn" },
	{ "UNIT_QUEST_LOG_CHANGED", "OnUnitQuestLogChanged" },
	{ "GROUP_ROSTER_UPDATE", "OnGroupRosterUpdate" },
	{ "PLAYER_LEVEL_UP", "OnPlayerLevelUp" },
}

local EVENT_HANDLERS = {}
for _, event in ipairs(EVENTS) do
	EVENT_HANDLERS[event[1]] = event[2]
end

ns.EVENT_NAMES = {}

local eventFrame = CreateFrame("Frame")

eventFrame:SetScript("OnEvent", function(_, event, ...)
	if ns.diagnostics and ns.diagnostics.logging then
		ns:LogEvent(event, ...)
	end

	local handler = ns[EVENT_HANDLERS[event]]
	if handler then
		handler(ns, ...)
	end
end)

local function RegisterEvent(event)
	eventFrame:RegisterEvent(event)
	ns.EVENT_NAMES[#ns.EVENT_NAMES + 1] = event
end

RegisterEvent("ADDON_LOADED")

--------------------------------------------------------------------------------
-- Saved Variables
--------------------------------------------------------------------------------

function ns:ApplyProfile()
	ns.RefreshQuestLog()
	for _, registryName in pairs(ns.OPTIONS_REGISTRY) do
		AceConfigRegistry:NotifyChange(registryName)
	end
end

function ns:OnAddonLoaded(name)
	if name ~= ADDON_NAME then
		return
	end

	-- MIGRATION (remove after 2026-11-06): drops the pre-AceDB top-level keys, which nothing reads.
	local saved = _G[ns.SAVED_VARIABLES_NAME]
	if type(saved) == "table" then
		saved.height, saved.point, saved.useMap = nil, nil, nil
	end

	ns.db = LibStub("AceDB-3.0"):New(ns.SAVED_VARIABLES_NAME, ns.DATABASE_DEFAULTS, true)
	for _, message in ipairs({ "OnProfileChanged", "OnProfileReset", "OnProfileCopied" }) do
		ns.db.RegisterCallback(ns, message, "ApplyProfile")
	end
	ns.RegisterOptionsPanels()

	if ns.OnDatabaseReady then
		ns:OnDatabaseReady()
	end

	for _, event in ipairs(EVENTS) do
		if event[1] ~= "ADDON_LOADED" and ns[event[2]] then
			RegisterEvent(event[1])
		end
	end
end

--------------------------------------------------------------------------------
-- Welcome
--------------------------------------------------------------------------------

function ns:PrintWelcome()
	if not ns.db.profile.showWelcome then
		return
	end
	ns:PrintMessage(L["CHAT_LOADED"]:format(ns.Version))
end

function ns:OnPlayerLogin()
	ns:PrintWelcome()
end
