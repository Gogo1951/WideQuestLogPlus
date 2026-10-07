local _, ns = ...
local L = ns.L

--------------------------------------------------------------------------------
-- WoW Forever Quest Log
--------------------------------------------------------------------------------

-- The Quest Log section of the General panel goes while the wide quest log is off
function ns.QuestLogOptionsHidden()
	return not ns.db.profile.enableWideQuestLog
end

-- Merged into the General panel under Enable Welcome Message; only the Camelot TOC loads this file.
function ns.BuildForeverQuestLogOptions()
	return {
		enableWideQuestLog = {
			type = "toggle",
			name = L["ENABLE_WIDE_QUEST_LOG"],
			desc = L["ENABLE_WIDE_QUEST_LOG_DESCRIPTION"],
			width = "full",
			order = 4,
			get = function()
				return ns.db.profile.enableWideQuestLog
			end,
			set = function(_, value)
				ns.db.profile.enableWideQuestLog = value
			end,
		},
	}
end

--------------------------------------------------------------------------------
-- Reload Prompt
--------------------------------------------------------------------------------

StaticPopupDialogs.WIDEQUESTLOGPLUS_RELOAD = {
	text = L["RELOAD_PROMPT"],
	button1 = RELOADUI,
	button2 = CANCEL,
	OnAccept = function()
		ReloadUI()
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

-- The topmost frame under UIParent holding the panel: the Options window, once the panel is shown in it
local function OptionsWindow(panel)
	local window = panel
	while window:GetParent() and window:GetParent() ~= UIParent do
		window = window:GetParent()
	end
	return window
end

--[[
	The quest log key is taken over only at load (Forever-Quest-Log.lua), so when the Options window
	closes with the profile asking for the other quest log, offer the reload that switches it. Comparing
	against the load-time state covers a profile switch too, and stays quiet after a toggle flipped back.

	The hook sits on the add-on's own panels, which exist from load on every client, rather than on the
	game's Options window, which may not exist yet when this file loads. A panel also hides when another
	category is picked, so the check waits a frame and goes on only once the whole window is closed.
]]
function ns.WatchOptionsForReload(panels)
	local window
	local function PromptIfClosed()
		if window and window:IsShown() then
			return
		end
		if ns.db.profile.enableWideQuestLog ~= (ns.questLogTakenOver == true) then
			StaticPopup_Show("WIDEQUESTLOGPLUS_RELOAD")
		end
	end
	for _, panel in ipairs(panels) do
		panel:HookScript("OnShow", function()
			window = OptionsWindow(panel)
		end)
		panel:HookScript("OnHide", function()
			C_Timer.After(0, PromptIfClosed)
		end)
	end
end
