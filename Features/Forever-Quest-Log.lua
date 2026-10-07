local _, ns = ...
local L = ns.L

--[[
	WoW Forever: the two-pane quest log as a window of its own (ns.LAYOUT), with the quest log key,
	the micro menu button and the objective tracker routed to it.
]]

-- Replaces ToggleQuestLog and QuestMapFrame_OpenToQuestDetails; see README-Technical: Taint before changing either.

local LAYOUT = ns.LAYOUT
local BASE_WIDTH, BASE_HEIGHT, PANE_TOP, ROW_HEIGHT =
	LAYOUT.BASE_WIDTH, LAYOUT.BASE_HEIGHT, LAYOUT.PANE_TOP, LAYOUT.ROW_HEIGHT
local DEFAULT_POINT = { "TOPLEFT", "UIParent", "TOPLEFT", 0, -104 }

--[[
	Shared with the list and details files: the quest shown in the details, and a quest opened from
	elsewhere that the list should bring into view
]]
local state = {}
ns.questLog = state

local currentHeight

--------------------------------------------------------------------------------
-- Window
--------------------------------------------------------------------------------

local frame = CreateFrame("Frame", "WideQuestLogPlusFrame", UIParent)
ns.questLogFrame = frame
frame:Hide()
frame:SetSize(BASE_WIDTH, BASE_HEIGHT)
frame:SetPoint(unpack(DEFAULT_POINT))
frame:SetFrameStrata("MEDIUM")
frame:SetToplevel(true)
frame:EnableMouse(true)
frame:SetMovable(true)
frame:SetClampedToScreen(true)
frame:RegisterForDrag("LeftButton")
tinsert(UISpecialFrames, frame:GetName())

-- Book icon behind the portrait ring of the art
local bookIcon = frame:CreateTexture(nil, "BACKGROUND")
bookIcon:SetTexture("Interface\\QuestFrame\\UI-QuestLog-BookIcon")
bookIcon:SetSize(64, 64)
bookIcon:SetPoint("TOPLEFT", 4, -4)

local LayoutArt = ns.CreateWindowArt(frame)

local windowTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
windowTitle:SetPoint("TOP", 0, -17)
windowTitle:SetText(QUEST_LOG)

local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButtonNoScripts")
closeButton:SetPoint("CENTER", frame, "TOPRIGHT", -46, -24)
closeButton:SetScript("OnClick", function()
	frame:Hide()
end)

local questCountText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
questCountText:SetPoint("RIGHT", frame, "TOPRIGHT", -52, -53)

-- Moved by dragging its title bar
frame:SetScript("OnDragStart", function(self)
	local _, y = GetCursorPosition()
	if (self:GetTop() - y / self:GetEffectiveScale()) <= PANE_TOP then
		self:StartMoving()
	end
end)
frame:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
	local point, _, relativePoint, x, y = self:GetPoint(1)
	ns.db.global.point = { point, "UIParent", relativePoint, x, y }
end)

--------------------------------------------------------------------------------
-- Buttons along the bottom
--------------------------------------------------------------------------------

local function CreateBottomButton(text, width, onClick)
	local button = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	button:SetSize(width or LAYOUT.BUTTON_WIDTH, LAYOUT.BUTTON_HEIGHT)
	button:SetText(text)
	button:SetScript("OnClick", onClick)
	return button
end

local function ForSelectedQuest(action)
	return function()
		if state.selectedQuestID then
			action(state.selectedQuestID)
		end
	end
end

local abandonButton = CreateBottomButton(ABANDON_QUEST, 125, ForSelectedQuest(QuestMapQuestOptions_AbandonQuest))
abandonButton:SetPoint("BOTTOMLEFT", LAYOUT.BUTTON_LEFT, LAYOUT.BUTTON_BOTTOM)

local exitButton = CreateBottomButton(EXIT, 77, function()
	frame:Hide()
end)
exitButton:SetPoint("BOTTOMRIGHT", -LAYOUT.BUTTON_RIGHT, LAYOUT.BUTTON_BOTTOM)

local shareButton = CreateBottomButton(SHARE_QUEST, nil, ForSelectedQuest(QuestMapQuestOptions_ShareQuest))
shareButton:SetPoint("RIGHT", exitButton, "LEFT")

local trackButton = CreateBottomButton(TRACK_QUEST_ABBREV, nil, ForSelectedQuest(ns.ToggleTracking))
trackButton:SetPoint("RIGHT", shareButton, "LEFT")

-- Say why the button is greyed out for quests Questie can't track
trackButton:SetMotionScriptsWhileDisabled(true)
trackButton:SetScript("OnEnter", function(self)
	if self.untrackable and state.selectedQuestID then
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:AddLine(L["QUESTIE_CANNOT_TRACK"], 1, 1, 1)
		GameTooltip:AddLine(ns.QuestieCannotShowText(state.selectedQuestID), nil, nil, nil, true)
		GameTooltip:Show()
	end
end)
trackButton:SetScript("OnLeave", GameTooltip_Hide)

local function UpdateButtons()
	local questID = state.selectedQuestID
	if not questID then
		abandonButton:Disable()
		shareButton:Disable()
		trackButton:Disable()
		return
	end

	local disabled = C_QuestLog.IsQuestDisabledForSession(questID)
	abandonButton:SetEnabled(not disabled and C_QuestLog.CanAbandonQuest(questID))
	shareButton:SetEnabled(not disabled and C_QuestLog.IsPushableQuest(questID) and IsInGroup())

	local tracked, trackable = ns.IsTracked(questID), ns.CanTrack(questID)
	trackButton:SetText(tracked and UNTRACK_QUEST_ABBREV or TRACK_QUEST_ABBREV)
	trackButton:SetEnabled(
		trackable and ((tracked and QuestUtil.CanRemoveQuestWatch()) or (not tracked and not disabled))
	)
	trackButton.untrackable = not trackable
end

--------------------------------------------------------------------------------
-- Refreshing
--------------------------------------------------------------------------------

local function UpdateCount(questCount)
	local maximumQuests = C_QuestLog.GetMaxNumQuestsCanAccept and C_QuestLog.GetMaxNumQuestsCanAccept() or 0
	local color = (questCount > maximumQuests) and RED_FONT_COLOR_CODE or HIGHLIGHT_FONT_COLOR_CODE
	questCountText:SetFormattedText(QUEST_LOG_COUNT_TEMPLATE, color, questCount, maximumQuests)
end

local function UpdateAll(resetScroll)
	if not frame:IsShown() then
		return
	end

	UpdateCount(ns.UpdateQuestList())
	ns.DisplayQuestDetails(resetScroll)
	UpdateButtons()
end

function ns.ShowQuest(questID)
	state.selectedQuestID = questID
	state.scrollToQuestID = questID

	-- Open the quest's zone if it's collapsed
	local headerIndex = C_QuestLog.GetHeaderIndexForQuest(questID)
	local header = headerIndex and C_QuestLog.GetInfo(headerIndex)
	if header and header.isCollapsed then
		ExpandQuestHeader(headerIndex)
	end

	if frame:IsShown() then
		UpdateAll(true)
	else
		frame:Show()
	end
end

-- QUEST_LOG_UPDATE comes in bursts, so repaint at most once a frame
local updatePending
function ns.RequestUpdate()
	if updatePending or not frame:IsShown() then
		return
	end
	updatePending = true
	C_Timer.After(0, function()
		updatePending = nil
		UpdateAll()
	end)
end

function ns:OnQuestLogUpdate()
	ns.RequestUpdate()
end

function ns:OnQuestWatchListChanged()
	ns.RequestUpdate()
end

function ns:OnQuestAccepted()
	ns.RequestUpdate()
end

function ns:OnQuestRemoved()
	ns.RequestUpdate()
end

function ns:OnQuestTurnedIn()
	ns.RequestUpdate()
end

function ns:OnUnitQuestLogChanged(unit)
	if unit == "player" then
		ns.RequestUpdate()
	end
end

function ns:OnGroupRosterUpdate()
	if frame:IsShown() then
		UpdateButtons()
	end
end

function ns:OnPlayerLevelUp()
	ns.RequestUpdate()
end

--------------------------------------------------------------------------------
-- Resizing
--------------------------------------------------------------------------------

local function ApplyHeight(height)
	height = ns.ClampHeight(frame, height or BASE_HEIGHT, ROW_HEIGHT)
	if height == currentHeight then
		return
	end
	currentHeight = height

	frame:SetHeight(height)
	local paneHeight = height - LAYOUT.PANE_INSET
	ns.SetQuestListHeight(paneHeight)
	ns.SetQuestDetailsHeight(paneHeight + 4)
	LayoutArt(height)
end

ns.CreateResizeGrip(frame, ApplyHeight, function()
	return currentHeight
end)

--------------------------------------------------------------------------------
-- Showing and hiding
--------------------------------------------------------------------------------

--[[
	The saved height is applied every time the window opens rather than when it loads, because the
	screen size and UI scale aren't settled then and the clamp to the screen would cut it short. The
	saved value is left alone, so a smaller screen only shrinks the window, not the setting
]]
local headersOpened
frame:SetScript("OnShow", function()
	PlaySound(SOUNDKIT.IG_QUEST_LOG_OPEN)
	ApplyHeight(ns.db.global.height)
	if not headersOpened then
		headersOpened = true
		ns.ExpandAllZones()
	end
	UpdateAll(true)
end)

frame:SetScript("OnHide", function()
	state.scrollToQuestID = nil
	ns.ResetZoneOrder() -- Sorted afresh next time the window opens
	PlaySound(SOUNDKIT.IG_QUEST_LOG_CLOSE)
	StaticPopup_Hide("ABANDON_QUEST")
	StaticPopup_Hide("ABANDON_QUEST_WITH_ITEMS")
end)

local function Toggle()
	frame:SetShown(not frame:IsShown())
end

function ns.ResetWindow()
	ns.db.global.height, ns.db.global.point = nil, nil
	frame:ClearAllPoints()
	frame:SetPoint(unpack(DEFAULT_POINT))
	ApplyHeight(BASE_HEIGHT)
end

-- After a settings change: zones re-sort rather than keeping the order the window opened with
function ns.RefreshQuestLog()
	ns.ResetZoneOrder()
	ns.RequestUpdate()
end

--------------------------------------------------------------------------------
-- Taking over the quest log
--------------------------------------------------------------------------------

--[[
	The quest log key binding and the micro menu button call ToggleQuestLog(); the objective tracker (and
	Questie, and a few others) call QuestMapFrame_OpenToQuestDetails(). Both are routed to this window
	only when enableWideQuestLog is on at load; with it off, Blizzard's functions are never replaced and the
	world map keeps the quest log key. A change to it applies at the next /reload, which the Options window
	offers on close. See README-Technical: Taint
]]
local function TakeOverQuestLog()
	local BlizzardOpenToQuestDetails = QuestMapFrame_OpenToQuestDetails

	function ToggleQuestLog()
		Toggle()
	end

	function QuestMapFrame_OpenToQuestDetails(questID, ...)
		if not questID or not C_QuestLog.GetLogIndexForQuestID(questID) then
			return BlizzardOpenToQuestDetails(questID, ...)
		end
		ns.ShowQuest(questID)
	end

	ns.questLogTakenOver = true
end

--[[
	The saved position, the quest log takeover, and a refresh whenever Questie's tracker updates
	(untracking from its own menu doesn't always touch Blizzard's watch list). Core calls this once saved
	variables have loaded
]]
function ns:OnDatabaseReady()
	ApplyHeight(BASE_HEIGHT)

	if ns.db.profile.enableWideQuestLog then
		TakeOverQuestLog()
	end

	local point = ns.db.global.point
	if point then
		frame:ClearAllPoints()
		frame:SetPoint(point[1], UIParent, point[3], point[4], point[5])
	end

	local tracker = ns.ImportQuestieModule("QuestieTracker")
	if tracker and type(tracker.Update) == "function" then
		hooksecurefunc(tracker, "Update", function()
			ns.RequestUpdate()
		end)
	end
end
