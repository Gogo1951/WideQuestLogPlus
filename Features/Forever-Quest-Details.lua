local _, ns = ...

local LAYOUT = ns.LAYOUT
local PANE_TOP = LAYOUT.PANE_TOP
local frame = ns.questLogFrame
local state = ns.questLog

--------------------------------------------------------------------------------
-- Quest details (right pane)
--------------------------------------------------------------------------------

--[[
	QuestInfo_Display() expects the scroll child's grandparent to carry the quest ID and the seal
	texture, the same arrangement as Blizzard's QuestLogPopupDetailFrame. It covers the parchment
]]
local detail = CreateFrame("Frame", nil, frame)
detail:SetPoint("TOPLEFT", LAYOUT.PARCHMENT_LEFT, -(PANE_TOP - 2))
detail:SetWidth(LAYOUT.PARCHMENT_RIGHT - LAYOUT.PARCHMENT_LEFT)

detail.SealMaterialBG = detail:CreateTexture(nil, "BACKGROUND")
detail.SealMaterialBG:SetAllPoints()
detail.SealMaterialBG:Hide()

-- Shown over the parchment when the accessibility "Quest Text Contrast" option is on
detail.ContrastBG = detail:CreateTexture(nil, "BACKGROUND", nil, -1)
detail.ContrastBG:SetAllPoints()
detail.ContrastBG:Hide()

-- The scroll bar sits in the slot to the right of the parchment
local detailScroll = CreateFrame("ScrollFrame", nil, detail, "ScrollFrameTemplate")
detailScroll:SetPoint("TOPLEFT", 0, -2)
detailScroll:SetPoint("BOTTOMRIGHT", 0, 2)
local scrollBarX = (LAYOUT.DETAIL_SCROLL_SLOT_X - 4) - LAYOUT.PARCHMENT_RIGHT
detailScroll.ScrollBar:ClearAllPoints()
detailScroll.ScrollBar:SetPoint("TOPLEFT", detailScroll, "TOPRIGHT", scrollBarX, -4)
detailScroll.ScrollBar:SetPoint("BOTTOMLEFT", detailScroll, "BOTTOMRIGHT", scrollBarX, 4)

local detailChild = CreateFrame("Frame", nil, detailScroll)
detailChild:SetSize(LAYOUT.PARCHMENT_RIGHT - LAYOUT.PARCHMENT_LEFT, 300)
detailScroll:SetScrollChild(detailChild)

--[[
	The quest giver window and Blizzard's own quest detail panes use the same QuestInfo elements as this
	one. Taking them while one of those is open would blank it (mid turn-in, say), so wait until it closes
]]
local function QuestInfoInUseElsewhere()
	if (QuestFrame and QuestFrame:IsShown()) or (QuestLogPopupDetailFrame and QuestLogPopupDetailFrame:IsShown()) then
		return true
	end
	local mapDetails = QuestMapFrame and QuestMapFrame.DetailsFrame
	return (mapDetails and mapDetails:IsVisible()) and true or false
end

-- The quest ID, right-aligned under the rewards (or whatever comes last), in the description's colour
local questIDRow = CreateFrame("Frame", nil, detailChild)
questIDRow:SetSize(LAYOUT.CONTENT_WIDTH, 14)
questIDRow.Text = questIDRow:CreateFontString(nil, "ARTWORK", "QuestFontNormalSmall")
questIDRow.Text:SetPoint("RIGHT")
questIDRow.Text:SetJustifyH("RIGHT")

local function QuestInfo_ShowQuestID()
	ns.StyleQuestID(questIDRow.Text, C_QuestLog.GetSelectedQuest(), QuestInfoDescriptionText)
	questIDRow.Text:ClearAllPoints()
	questIDRow.Text:SetPoint("RIGHT", -ns.TwoSpacesWide(QuestInfoDescriptionText), 0)
	questIDRow:Show()
	return questIDRow
end

--[[
	Blizzard's QUEST_TEMPLATE_LOG lays out the description, objectives and rewards in one column, as
	Classic did. A copy of it is placed and spaced to the shared layout, with the quest ID added at the end
]]
local LOG_TEMPLATE = CopyTable(QUEST_TEMPLATE_LOG)
LOG_TEMPLATE.contentWidth = LAYOUT.CONTENT_WIDTH
do
	local elements = LOG_TEMPLATE.elements
	for index = 1, #elements, 3 do
		local show = elements[index]
		if show == QuestInfo_ShowTitle then
			elements[index + 1] = LAYOUT.CONTENT_LEFT - LAYOUT.PARCHMENT_LEFT
			elements[index + 2] = -(LAYOUT.CONTENT_TOP - PANE_TOP)
		elseif show == QuestInfo_ShowObjectivesText then
			elements[index + 2] = -LAYOUT.HEADING_SPACE_BELOW
		elseif show == QuestInfo_ShowDescriptionText then
			elements[index + 2] = -LAYOUT.HEADING_SPACE_BELOW
		elseif show == QuestInfo_ShowDescriptionHeader then
			elements[index + 2] = -LAYOUT.HEADING_SPACE_ABOVE
		elseif show == QuestInfo_ShowRewards then
			elements[index + 2] = -LAYOUT.REWARDS_GAP
		end
	end
	for index = 1, #elements, 3 do
		if elements[index] == QuestInfo_ShowSpacer then
			tinsert(elements, index, -LAYOUT.QUEST_ID_GAP)
			tinsert(elements, index, 0)
			tinsert(elements, index, QuestInfo_ShowQuestID)
			break
		end
	end
end

--[[
	The quest giver window and the map's quest details use the same objective lines and reward frames,
	laid out Blizzard's way, so they go back to Blizzard's font and positions, without this add-on's
	count column, whenever anything else calls QuestInfo_Display
]]
local function RestoreSharedLayout(_, parentFrame)
	if parentFrame == detailChild then
		return
	end
	ns.ClearObjectiveCounts()
	for _, line in ipairs(QuestInfoObjectivesFrame.Objectives or {}) do
		local red, green, blue, alpha = line:GetTextColor()
		line:SetFontObject(QuestFontNormalSmall)
		line:SetTextColor(red, green, blue, alpha)
	end
	local rewardsFrame = QuestInfoRewardsFrame
	rewardsFrame.MoneyFrame:ClearAllPoints()
	rewardsFrame.MoneyFrame:SetPoint("LEFT", rewardsFrame.ItemReceiveText, "RIGHT", 15, 0)
	rewardsFrame.XPFrame.ValueText:ClearAllPoints()
	rewardsFrame.XPFrame.ValueText:SetPoint("LEFT", rewardsFrame.XPFrame.ReceiveText, "RIGHT", 15, 0)
end
hooksecurefunc("QuestInfo_Display", RestoreSharedLayout)

function ns.DisplayQuestDetails(resetScroll)
	detailScroll:SetShown(state.selectedQuestID ~= nil)
	if (not state.selectedQuestID) or QuestInfoInUseElsewhere() then
		return
	end

	C_QuestLog.SetSelectedQuest(state.selectedQuestID)
	detail.questID = state.selectedQuestID

	if QuestTextContrast and QuestTextContrast.IsEnabled() then
		detail.ContrastBG:SetAtlas(QuestTextContrast.GetDefaultBackgroundAtlas())
		detail.ContrastBG:Show()
	else
		detail.ContrastBG:Hide()
	end

	QuestInfo_Display(LOG_TEMPLATE, detailChild)

	--[[
		Just the quest's name: Blizzard decorates it with the quest type's icon, and that and the level
		are already in the list
	]]
	local title = C_QuestLog.GetTitleForQuestID(state.selectedQuestID)
	if title then
		if IsCurrentQuestFailed() then
			title = QUEST_TITLE_FORMAT_FAILED:format(title)
		end
		QuestInfoTitleHeader:SetText(title)
	end

	--[[
		Objective lines: check, name and a right-aligned count. Blizzard's lines follow the leaderboard,
		skipping spell and log objectives, after an optional waypoint line
	]]
	ns.ClearObjectiveCounts()
	local lines = QuestInfoObjectivesFrame.Objectives
	local lineIndex = C_QuestLog.GetNextWaypointText(state.selectedQuestID) and 1 or 0
	for index = 1, GetNumQuestLeaderBoards() do
		local text, objectiveType, finished = GetQuestLogLeaderBoard(index)
		if objectiveType ~= "spell" and objectiveType ~= "log" then
			lineIndex = lineIndex + 1
			local line = lines and lines[lineIndex]
			if line and line:IsShown() then
				ns.StyleObjective(
					line,
					(text and text ~= "") and text or objectiveType,
					finished,
					LAYOUT.CONTENT_WIDTH,
					QuestInfoDescriptionText
				)
			end
		end
	end

	-- Gold and experience right-aligned two spaces in from the edge of the text column, like the objective counts (see RestoreSharedLayout)
	local rewardsFrame = QuestInfoRewardsFrame
	local right = LAYOUT.CONTENT_WIDTH - ns.TwoSpacesWide(QuestInfoDescriptionText)
	rewardsFrame.MoneyFrame:ClearAllPoints()
	rewardsFrame.MoneyFrame:SetPoint(
		"RIGHT",
		rewardsFrame.ItemReceiveText,
		"LEFT",
		right + LAYOUT.MONEY_RIGHT_PADDING,
		0
	)
	rewardsFrame.XPFrame.ValueText:ClearAllPoints()
	rewardsFrame.XPFrame.ValueText:SetPoint("RIGHT", rewardsFrame.XPFrame, "LEFT", right, 0)

	--[[
		The same space under the Rewards heading as under Description. Blizzard hangs the first reward line
		just under the heading and sizes the rewards block to fit, so move that line and grow the block to match
	]]
	local rewards = QuestInfoFrame.rewardsFrame
	local first = rewards and rewards:IsShown() and rewards.activeRewardElements and rewards.activeRewardElements[1]
	if first and first:GetNumPoints() > 0 then
		local point, relativeTo, relativePoint, x = first:GetPoint(1)
		if relativeTo == rewards.Header then
			first:SetPoint(point, relativeTo, relativePoint, x, -LAYOUT.HEADING_SPACE_BELOW)
			rewards:SetHeight(rewards:GetHeight() + LAYOUT.EXTRA_HEADING_GAP)
		end
	end

	--[[
		A blank line between the money and experience lines, again growing the rewards block to match.
		Without money, "You will also receive:" is the experience line's own label, so it stays right under it
	]]
	local experienceFrame = rewards and rewards:IsShown() and rewards.XPFrame
	local hasMoney = rewards and rewards.MoneyFrame and rewards.MoneyFrame:IsShown()
	if hasMoney and experienceFrame and experienceFrame:IsShown() and experienceFrame:GetNumPoints() > 0 then
		local point, relativeTo, relativePoint, x, y = experienceFrame:GetPoint(1)
		if relativeTo == rewards.ItemReceiveText then
			experienceFrame:SetPoint(point, relativeTo, relativePoint, x, y - LAYOUT.MONEY_EXPERIENCE_GAP)
			rewards:SetHeight(rewards:GetHeight() + LAYOUT.MONEY_EXPERIENCE_GAP)
		end
	end

	detailScroll:UpdateScrollChildRect()
	if resetScroll then
		detailScroll:SetVerticalScroll(0)
	end
end

-- Take the QuestInfo elements back once whatever borrowed them closes
for _, borrower in pairs({ QuestFrame, QuestLogPopupDetailFrame, QuestMapFrame and QuestMapFrame.DetailsFrame or nil }) do
	borrower:HookScript("OnHide", function()
		ns.RequestUpdate()
	end)
end

function ns.SetQuestDetailsHeight(height)
	detail:SetHeight(height)
end
