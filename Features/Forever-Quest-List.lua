local _, ns = ...

local LAYOUT = ns.LAYOUT
local ROW_HEIGHT, PANE_TOP = LAYOUT.ROW_HEIGHT, LAYOUT.PANE_TOP
local frame = ns.questLogFrame
local state = ns.questLog

--------------------------------------------------------------------------------
-- Quest list (left pane)
--------------------------------------------------------------------------------

local listBox = CreateFrame("Frame", nil, frame, "WowScrollBoxList")
listBox:SetPoint("TOPLEFT", LAYOUT.LIST_LEFT, -PANE_TOP)
listBox:SetWidth(LAYOUT.LIST_WIDTH)

local listBar = CreateFrame("EventFrame", nil, frame, "MinimalScrollBar")
listBar:SetPoint("TOPLEFT", listBox, "TOPRIGHT", 8, -4)
listBar:SetPoint("BOTTOMLEFT", listBox, "BOTTOMRIGHT", 8, 4)

local noQuestsText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
noQuestsText:SetPoint("TOP", listBox, "TOP", 0, -90)
noQuestsText:SetText(QUESTLOG_NO_QUESTS_TEXT)
noQuestsText:Hide()

local PLUS_TEXTURE = "Interface\\Buttons\\UI-PlusButton-Up"
local MINUS_TEXTURE = "Interface\\Buttons\\UI-MinusButton-Up"
local TITLE_HIGHLIGHT = "Interface\\QuestFrame\\UI-QuestLogTitleHighlight"

local function ToggleHeader(questLogIndex)
	local entry = C_QuestLog.GetInfo(questLogIndex)
	if not entry then
		return
	end
	if entry.isCollapsed then
		ExpandQuestHeader(questLogIndex)
	else
		CollapseQuestHeader(questLogIndex)
	end
	ns.RequestUpdate()
end

-- Every zone starts the session open; collapsing one only lasts until the next login or reload
function ns.ExpandAllZones()
	for index = C_QuestLog.GetNumQuestLogEntries(), 1, -1 do
		local entry = C_QuestLog.GetInfo(index)
		if entry and entry.isHeader and entry.isCollapsed then
			ExpandQuestHeader(index)
		end
	end
end

-- The tag at the right of a quest's row: (Failed), (Complete), or its type
local function GetQuestTag(questID)
	if C_QuestLog.IsFailed(questID) then
		return FAILED
	elseif C_QuestLog.IsComplete(questID) then
		return COMPLETE
	end
	local tagDetails = C_QuestLog.GetQuestTagInfo(questID)
	if tagDetails and tagDetails.tagName then
		return tagDetails.tagName
	elseif C_QuestLog.IsEliteQuest(questID) then
		return ELITE
	end
end

local function ColorRow(row, highlighted)
	local data = row.data
	if (not data) or data.isSpacer then
		return
	end
	local color, highlight
	if data.isHeader then
		color, highlight = QuestDifficultyColors.header, QuestDifficultyHighlightColors.header
	else
		color, highlight = GetQuestDifficultyColor(data.difficultyLevel or data.level, data.isScaling, data.questID)
	end
	local text = (highlighted or (data.questID and data.questID == state.selectedQuestID)) and highlight or color
	row.Text:SetTextColor(text.r, text.g, text.b)
	row.Tag:SetTextColor(text.r, text.g, text.b)
	row.Highlight:SetVertexColor(color.r, color.g, color.b)
	row.Selected:SetVertexColor(color.r, color.g, color.b)
end

local function OpenQuestMenu(row)
	local questID = row.data.questID
	MenuUtil.CreateContextMenu(row, function(_, root)
		root:CreateButton(ns.IsTracked(questID) and UNTRACK_QUEST or TRACK_QUEST, function()
			ns.ToggleTracking(questID)
		end):SetEnabled(ns.CanTrack(questID))
		root:CreateButton(SHARE_QUEST, function()
			QuestMapQuestOptions_ShareQuest(questID)
		end):SetEnabled(C_QuestLog.IsPushableQuest(questID) and IsInGroup())
		if C_QuestLog.CanAbandonQuest(questID) then
			root:CreateButton(ABANDON_QUEST, function()
				QuestMapQuestOptions_AbandonQuest(questID)
			end)
		end
	end)
end

local function Row_OnClick(self, button)
	local data = self.data
	if (not data) or data.isSpacer then
		return
	end

	if data.isHeader then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		ToggleHeader(data.questLogIndex)
	elseif ChatFrameUtil and ChatFrameUtil.TryInsertQuestLinkForQuestID(data.questID) then
		return -- Shift-click with a chat box open links the quest
	elseif IsShiftKeyDown() then
		ns.ToggleTracking(data.questID) -- Otherwise it toggles tracking, as in Classic
	elseif button == "RightButton" then
		OpenQuestMenu(self)
	else
		PlaySound(SOUNDKIT.IG_QUEST_LOG_OPEN)
		ns.ShowQuest(data.questID)
	end
end

local function Row_OnEnter(self)
	ColorRow(self, true)
end

local function Row_OnLeave(self)
	ColorRow(self, false)
end

local function SetupRow(row)
	row:RegisterForClicks("LeftButtonUp", "RightButtonUp")

	row.Icon = row:CreateTexture(nil, "ARTWORK")
	row.Icon:SetSize(16, 16)
	row.Icon:SetPoint("LEFT", 3, 0)

	row.Text = row:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	row.Text:SetJustifyH("LEFT")
	row.Text:SetWordWrap(false)

	row.Tag = row:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	row.Tag:SetPoint("RIGHT", -2, 0)
	row.Tag:SetJustifyH("RIGHT")

	row.Check = row:CreateTexture(nil, "ARTWORK")
	row.Check:SetSize(16, 16)
	row.Check:SetPoint("LEFT", LAYOUT.CHECK_X, 0)

	row.Selected = row:CreateTexture(nil, "BACKGROUND")
	row.Selected:SetTexture(TITLE_HIGHLIGHT)
	row.Selected:SetBlendMode("ADD")
	row.Selected:SetAllPoints()

	row.Highlight = row:CreateTexture(nil, "HIGHLIGHT")
	row.Highlight:SetTexture(TITLE_HIGHLIGHT)
	row.Highlight:SetBlendMode("ADD")
	row.Highlight:SetAllPoints()

	row:SetScript("OnClick", Row_OnClick)
	row:SetScript("OnEnter", Row_OnEnter)
	row:SetScript("OnLeave", Row_OnLeave)
end

--[[
	Rows are recycled between zone headers, quests and the blank spacers above headers, so each one is
	set up from scratch for whatever it's showing now
]]
local function InitRow(row, data)
	if not row.Text then
		SetupRow(row)
	end
	row.data = data

	row.Text:SetWidth(0)
	row.Tag:SetText(nil)
	row.Check:Hide()
	row:EnableMouse(not data.isSpacer)

	if data.isSpacer then
		row.Icon:Hide()
		row.Text:SetText(nil)
		row.Selected:Hide()
		return
	end

	if data.isHeader then
		row.Text:SetPoint("LEFT", LAYOUT.HEADER_TEXT_X, 0)
		row.Icon:SetTexture(data.isCollapsed and PLUS_TEXTURE or MINUS_TEXTURE)
		row.Icon:Show()
		row.Text:SetText(data.title)
		row.Selected:Hide()
	else
		local questID = data.questID
		local tagDetails = C_QuestLog.GetQuestTagInfo(questID)
		local elite = C_QuestLog.IsEliteQuest(questID) or (tagDetails and tagDetails.isElite)
		row.Text:SetPoint("LEFT", LAYOUT.QUEST_TEXT_X, 0)
		row.Icon:Hide()
		row.Text:SetText(
			ns.LevelTitle(
				data.difficultyLevel or data.level,
				data.title,
				ns.QuestSuffix(tagDetails and tagDetails.tagID, elite)
			)
		)

		local tag = GetQuestTag(questID)
		if tag then
			row.Tag:SetText(PARENS_TEMPLATE and PARENS_TEMPLATE:format(tag) or ("(" .. tag .. ")"))
		end

		-- Shorten the title if it would run into the tag
		local room = LAYOUT.LIST_WIDTH - LAYOUT.QUEST_TEXT_X - (tag and (row.Tag:GetStringWidth() + 6) or 2)
		if row.Text:GetStringWidth() > room then
			row.Text:SetWidth(room)
		end
		ns.ShowTrackingMark(row.Check, ns.IsTracked(questID))
		row.Selected:SetShown(questID == state.selectedQuestID)
	end

	ColorRow(row, row:IsMouseOver())
end

local listView = CreateScrollBoxListLinearView()
listView:SetElementExtentCalculator(function(_, data)
	return data.isSpacer and LAYOUT.HEADER_GAP or ROW_HEIGHT
end)
listView:SetElementInitializer("Button", InitRow)
ScrollUtil.InitScrollBoxListWithScrollBar(listBox, listBar, listView)

-- Collapse or expand every zone at once, like the classic "All" toggle
local collapseAll = CreateFrame("Button", nil, frame)
collapseAll:SetSize(60, 16)
collapseAll:SetPoint("TOPLEFT", 74, -45)
collapseAll.Icon = collapseAll:CreateTexture(nil, "ARTWORK")
collapseAll.Icon:SetSize(16, 16)
collapseAll.Icon:SetPoint("LEFT")
collapseAll:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight", "ADD")
collapseAll:GetHighlightTexture():ClearAllPoints()
collapseAll:GetHighlightTexture():SetAllPoints(collapseAll.Icon)
collapseAll.Text = collapseAll:CreateFontString(nil, "ARTWORK", "GameFontNormal")
collapseAll.Text:SetPoint("LEFT", collapseAll.Icon, "RIGHT", 2, 0)
collapseAll.Text:SetText(ALL)
collapseAll:SetScript("OnClick", function(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	local collapse = not self.allCollapsed
	for index = 1, C_QuestLog.GetNumQuestLogEntries() do
		local entry = C_QuestLog.GetInfo(index)
		if entry and entry.isHeader and entry.isCollapsed ~= collapse then
			if collapse then
				CollapseQuestHeader(index)
			else
				ExpandQuestHeader(index)
			end
		end
	end
	ns.RequestUpdate()
end)

--------------------------------------------------------------------------------
-- Sorting
--------------------------------------------------------------------------------

-- Zone ranks frozen while the window stays open (ns.SortZones)
local zoneOrder

--[[
	Same visibility rules as the map's quest list: no hidden quests, world quests or bonus objectives,
	and zones only when something under them would show. Quests outside any zone come first, then the
	zones in the zoneSort order, each after a blank spacer (zoneGap) but the first. Within each, quests
	go in the questSort order. Returns the list entries, every quest that would show with its zone
	open, and whether every zone is collapsed
]]
local function BuildEntries()
	local entries, quests, zones = {}, {}, {}
	local header

	for index = 1, C_QuestLog.GetNumQuestLogEntries() do
		local entry = C_QuestLog.GetInfo(index)
		if entry and entry.isHeader then
			header = entry
			header.quests = {}
			header.sortKey = ns.NameSortKey(header.title)
			header.sortIndex = header.questLogIndex
			zones[#zones + 1] = header
		elseif
			entry
			and not entry.isHidden
			and not entry.isTask
			and (not entry.isBounty or C_QuestLog.IsComplete(entry.questID))
		then
			entry.sortLevel = entry.difficultyLevel or entry.level or 0
			entry.sortIndex = entry.questLogIndex
			entry.sortKey = ns.NameSortKey(entry.title)
			quests[#quests + 1] = entry
			if header then
				header.quests[#header.quests + 1] = entry
			else
				entries[#entries + 1] = entry
			end
		end
	end

	local questSort = ns.db.profile.questSort
	ns.SortQuests(entries, questSort) -- Quests outside any zone
	for _, zone in ipairs(zones) do
		zone.averageLevel = ns.AverageLevel(zone.quests)
		ns.SortQuests(zone.quests, questSort)
	end
	zoneOrder = ns.SortZones(zones, ns.db.profile.zoneSort, zoneOrder)

	local anyHeader, anyExpanded = false, false
	for _, zone in ipairs(zones) do
		if #zone.quests > 0 then
			if #entries > 0 and ns.db.profile.zoneGap then
				entries[#entries + 1] = { isSpacer = true }
			end
			entries[#entries + 1] = zone
			anyHeader = true
			if not zone.isCollapsed then
				anyExpanded = true
				for _, quest in ipairs(zone.quests) do
					entries[#entries + 1] = quest
				end
			end
		end
	end

	return entries, quests, anyHeader and not anyExpanded
end

--[[
	Picks a quest to show when nothing (or a quest no longer in the log) is selected: the first one
	showing, or failing that the first one under a collapsed zone
]]
local function ValidateSelection(entries, quests)
	if state.selectedQuestID and C_QuestLog.GetLogIndexForQuestID(state.selectedQuestID) then
		return
	end
	state.selectedQuestID = nil
	for _, entry in ipairs(entries) do
		if entry.questID and not entry.isHeader then
			state.selectedQuestID = entry.questID
			return
		end
	end
	state.selectedQuestID = quests[1] and quests[1].questID
end

local function UpdateList(entries)
	listBox:SetDataProvider(CreateDataProvider(entries), ScrollBoxConstants.RetainScrollPosition)

	--[[
		Bring a quest opened from elsewhere into view once it's in the list (its zone may still have been
		opening)
	]]
	if state.scrollToQuestID then
		local index = listBox:FindElementDataIndexByPredicate(function(data)
			return data.questID == state.scrollToQuestID
		end)
		if index then
			state.scrollToQuestID = nil
			listBox:ScrollToElementDataIndex(
				index,
				ScrollBoxConstants.AlignNearest,
				0,
				ScrollBoxConstants.NoScrollInterpolation
			)
		end
	end
end

function ns.ResetZoneOrder()
	zoneOrder = nil
end

--------------------------------------------------------------------------------
-- Refreshing
--------------------------------------------------------------------------------

function ns.SetQuestListHeight(height)
	listBox:SetHeight(height)
end

-- Rebuilds the list and settles the selection; returns how many quests the log holds
function ns.UpdateQuestList()
	local entries, quests, allCollapsed = BuildEntries()
	ValidateSelection(entries, quests)

	noQuestsText:SetShown(#quests == 0)
	collapseAll.allCollapsed = allCollapsed
	collapseAll.Icon:SetTexture(allCollapsed and PLUS_TEXTURE or MINUS_TEXTURE)

	UpdateList(entries)
	return #quests
end
