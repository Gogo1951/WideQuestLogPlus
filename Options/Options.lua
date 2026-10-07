local _, ns = ...
local L = ns.L

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

--------------------------------------------------------------------------------
-- Registration
--------------------------------------------------------------------------------

-- Called from Core right after AceDB:New, since the Profiles builder reads ns.db.
function ns.RegisterOptionsPanels()
	AceConfig:RegisterOptionsTable(ns.OPTIONS_REGISTRY.General, ns.BuildGeneralOptions)

	--[[
		AddToBlizOptions returns (frame, categoryID), and the category ID is the only dependable way
		back to this panel: on clients where it's a number assigned at registration, a lookup by
		title finds nothing and the panel opens as a floating window instead.
	]]
	local mainPanel, mainCategoryID = AceConfigDialog:AddToBlizOptions(ns.OPTIONS_REGISTRY.General, L["ADDON_TITLE"])
	ns.optionsFrames = { main = mainPanel, categoryID = mainCategoryID }

	local profilesOptions = ns.BuildProfilesOptions()
	AceConfig:RegisterOptionsTable(ns.OPTIONS_REGISTRY.Profiles, profilesOptions)
	local profilesPanel =
		AceConfigDialog:AddToBlizOptions(ns.OPTIONS_REGISTRY.Profiles, profilesOptions.name, L["ADDON_TITLE"])

	AceConfig:RegisterOptionsTable(ns.OPTIONS_REGISTRY.Diagnostics, ns.BuildDiagnosticsOptions)
	local diagnosticsPanel =
		AceConfigDialog:AddToBlizOptions(ns.OPTIONS_REGISTRY.Diagnostics, ns.DiagnosticsStrings.TAB, L["ADDON_TITLE"])

	-- WoW Forever's reload prompt, when that client's TOC loaded it
	if ns.WatchOptionsForReload then
		ns.WatchOptionsForReload({ mainPanel, profilesPanel, diagnosticsPanel })
	end
end

--------------------------------------------------------------------------------
-- Opening the Panel
--------------------------------------------------------------------------------

function ns:OpenOptionsPanel()
	if InCombatLockdown() then
		ns:PrintMessage(L["CHAT_OPTIONS_IN_COMBAT"])
		return
	end
	if not ns.optionsFrames then
		return
	end
	if Settings and Settings.OpenToCategory and ns.optionsFrames.categoryID then
		Settings.OpenToCategory(ns.optionsFrames.categoryID)
		return
	end
	AceConfigDialog:Open(ns.OPTIONS_REGISTRY.General)
end

--------------------------------------------------------------------------------
-- Slash Commands
--------------------------------------------------------------------------------

SLASH_WIDEQUESTLOGPLUSOPTIONS1 = "/wide"
SlashCmdList.WIDEQUESTLOGPLUSOPTIONS = function()
	ns:OpenOptionsPanel()
end
