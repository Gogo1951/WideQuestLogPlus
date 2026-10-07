local _, ns = ...

-- Classic Era and TBC: the quest details (right pane) of Blizzard's widened quest log.

local LAYOUT = ns.LAYOUT

--------------------------------------------------------------------------------
-- Quest details (right pane)
--------------------------------------------------------------------------------

-- Beside the list, reaching to the right edge of the parchment
QuestLogDetailScrollFrame:ClearAllPoints()
QuestLogDetailScrollFrame:SetPoint(
	"TOPLEFT",
	QuestLogListScrollFrame,
	"TOPRIGHT",
	LAYOUT.DETAIL_LEFT - (LAYOUT.LIST_LEFT + LAYOUT.LIST_WIDTH),
	0
)
QuestLogDetailScrollFrame:SetWidth(LAYOUT.PARCHMENT_RIGHT - LAYOUT.DETAIL_LEFT)
QuestLogDetailScrollChildFrame:SetWidth(LAYOUT.PARCHMENT_RIGHT - LAYOUT.DETAIL_LEFT)

--[[
	Quest text as wide as two columns of reward buttons, with the same margin of parchment on the left,
	right and top, and the title level with the first quest row of the list. Only the title is anchored
	to the pane; everything else hangs off it
]]
QuestLogQuestTitle:SetPoint(
	"TOPLEFT",
	QuestLogDetailScrollChildFrame,
	"TOPLEFT",
	LAYOUT.CONTENT_LEFT - LAYOUT.DETAIL_LEFT,
	-(LAYOUT.CONTENT_TOP - LAYOUT.PANE_TOP)
)
QuestLogObjectivesText:SetPoint("TOPLEFT", QuestLogQuestTitle, "BOTTOMLEFT", 0, -LAYOUT.HEADING_SPACE_BELOW)
QuestLogQuestDescription:SetPoint("TOPLEFT", QuestLogDescriptionTitle, "BOTTOMLEFT", 0, -LAYOUT.HEADING_SPACE_BELOW)
QuestLogRewardTitleText:SetPoint("TOPLEFT", QuestLogQuestDescription, "BOTTOMLEFT", 0, -LAYOUT.HEADING_SPACE_ABOVE)

-- Blizzard hangs the Description heading under whatever comes last above it each time; keep its anchor, change the gap
local function SpaceAboveDescription()
	if QuestLogDescriptionTitle:GetNumPoints() > 0 then
		local point, relativeTo, relativePoint, x = QuestLogDescriptionTitle:GetPoint(1)
		QuestLogDescriptionTitle:SetPoint(point, relativeTo, relativePoint, x, -LAYOUT.HEADING_SPACE_ABOVE)
	end
end
for _, name in ipairs({
	"QuestLogQuestTitle",
	"QuestLogObjectivesText",
	"QuestLogTimerText",
	"QuestLogDescriptionTitle",
	"QuestLogQuestDescription",
	"QuestLogRewardTitleText",
	"QuestLogItemChooseText",
}) do
	if _G[name] then
		_G[name]:SetWidth(LAYOUT.CONTENT_WIDTH)
	end
end
local objective = 1
while _G["QuestLogObjective" .. objective] do
	_G["QuestLogObjective" .. objective]:SetWidth(LAYOUT.CONTENT_WIDTH)
	objective = objective + 1
end

-- Gold right-aligned two spaces in from the edge of the text column, like the objective counts
local function AlignMoney()
	QuestLogMoneyFrame:ClearAllPoints()
	QuestLogMoneyFrame:SetPoint(
		"RIGHT",
		QuestLogItemReceiveText,
		"LEFT",
		LAYOUT.CONTENT_WIDTH + LAYOUT.MONEY_RIGHT_PADDING - ns.TwoSpacesWide(QuestLogQuestDescription),
		0
	)
end

--[[
	Objective lines: check, name and a right-aligned count (ns.StyleObjective). The quest log has one line per
	leaderboard entry
]]
local function StyleObjectives()
	ns.ClearObjectiveCounts()
	for index = 1, GetNumQuestLeaderBoards() do
		local line = _G["QuestLogObjective" .. index]
		if not line then
			break
		end
		local text, objectiveType, finished = GetQuestLogLeaderBoard(index)
		if line:IsShown() then
			ns.StyleObjective(
				line,
				(text and text ~= "") and text or objectiveType,
				finished,
				LAYOUT.CONTENT_WIDTH,
				QuestLogQuestDescription
			)
		end
	end
end

--[[
	The quest ID, right-aligned under the rewards (or whatever comes last). Blizzard hangs a spacer below
	the last thing in the pane, so it goes inside that, made tall enough to hold it
]]
local questIDText = QuestLogDetailScrollChildFrame:CreateFontString(nil, "ARTWORK", "QuestFontNormalSmall")
questIDText:SetJustifyH("RIGHT")
QuestLogSpacerFrame:SetHeight(LAYOUT.QUEST_ID_GAP + 20) -- Room for the ID, so it scrolls into view

local function PlaceQuestID()
	local spacerTop, childTop = QuestLogSpacerFrame:GetTop(), QuestLogDetailScrollChildFrame:GetTop()
	if spacerTop and childTop then
		questIDText:ClearAllPoints()
		questIDText:SetPoint(
			"TOPRIGHT",
			QuestLogDetailScrollChildFrame,
			"TOPLEFT",
			LAYOUT.CONTENT_LEFT + LAYOUT.CONTENT_WIDTH - LAYOUT.DETAIL_LEFT - ns.TwoSpacesWide(QuestLogQuestDescription),
			spacerTop - childTop - LAYOUT.QUEST_ID_GAP
		)
	end
end

--[[
	The pane is written by QuestLog_UpdateQuestDetails() and again while QuestFrameItems_Update()
	rebuilds it, so this follows both
]]
local function ShowQuestID()
	local title, _, _, _, _, _, _, questID = GetQuestLogTitle(GetQuestLogSelection())
	if (not title) or not questID then
		questIDText:Hide()
		return
	end
	-- Description's colour: dark on the parchment, white under ElvUI's parchment remover
	ns.StyleQuestID(questIDText, questID, QuestLogQuestDescription)
	questIDText:Show()
	PlaceQuestID()
	C_Timer.After(0, PlaceQuestID) -- Again once the pane's layout has settled
end

--[[
	Blizzard hangs the first reward button of each section 3px left of the text above it, and the
	reward captions 3px in. Line them all up with the rest of the text, as on WoW Forever, so two
	columns of buttons fill the text column exactly
]]
local function IsRewardButton(region)
	local name = region and region.GetName and region:GetName()
	return name and name:find("^QuestLogItem%d+$") ~= nil
end

local function Realign(region, offset, unlessAnchoredToButton)
	if (not region) or (not region:IsShown()) or (region:GetNumPoints() < 1) then
		return
	end
	local point, relativeTo, relativePoint, x, y = region:GetPoint(1)
	if unlessAnchoredToButton and IsRewardButton(relativeTo) then
		return -- Buttons further down a section only sit beside or below the one before
	end
	if x and math.abs(x - offset) < 0.01 then
		region:SetPoint(point, relativeTo, relativePoint, 0, y)
	end
end

-- The same space under the Rewards heading as under the title and Description, for whichever line comes first
local function SpaceUnderRewardsHeading(region)
	if region and region:IsShown() and region:GetNumPoints() > 0 then
		local point, relativeTo, relativePoint, x = region:GetPoint(1)
		if relativeTo == QuestLogRewardTitleText then
			region:SetPoint(point, relativeTo, relativePoint, x, -LAYOUT.HEADING_SPACE_BELOW)
		end
	end
end

local function AlignRewards()
	AlignMoney()
	Realign(QuestLogItemReceiveText, 3)
	Realign(QuestLogSpellLearnText, 3)
	SpaceUnderRewardsHeading(QuestLogItemChooseText)
	SpaceUnderRewardsHeading(QuestLogItemReceiveText)
	SpaceUnderRewardsHeading(QuestLogSpellLearnText)
	local index = 1
	while _G["QuestLogItem" .. index] do
		Realign(_G["QuestLogItem" .. index], -3, true)
		index = index + 1
	end
end

--------------------------------------------------------------------------------
-- Hooks
--------------------------------------------------------------------------------

hooksecurefunc("QuestLog_UpdateQuestDetails", function()
	SpaceAboveDescription()
	StyleObjectives()
	ShowQuestID()
end)
hooksecurefunc("QuestFrameItems_Update", function(questState)
	if questState == "QuestLog" then -- The quest giver window's rewards use it too
		AlignRewards()
		ShowQuestID()
	end
end)
