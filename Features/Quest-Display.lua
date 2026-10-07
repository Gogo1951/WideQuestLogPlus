local _, ns = ...
local L = ns.L

-- How both quest logs draw a quest: its title text, tracking mark, quest ID and objective lines.

--------------------------------------------------------------------------------
-- Quest Text
--------------------------------------------------------------------------------

--[[
	Letters after the level in the quest list, by quest tag (Enum.QuestTag): D dungeon, R raid, P PvP,
	G group. Elite quests without one of those get E
]]
local QUEST_TAG_SUFFIX = {
	[81] = L["QUEST_SUFFIX_DUNGEON"], -- Dungeon
	[85] = L["QUEST_SUFFIX_DUNGEON"], -- Heroic
	[62] = L["QUEST_SUFFIX_RAID"], -- Raid
	[88] = L["QUEST_SUFFIX_RAID"], -- Raid (10)
	[89] = L["QUEST_SUFFIX_RAID"], -- Raid (25)
	[41] = L["QUEST_SUFFIX_PVP"], -- PvP
	[1] = L["QUEST_SUFFIX_GROUP"], -- Group
}
local ELITE_SUFFIX = L["QUEST_SUFFIX_ELITE"]

function ns.QuestSuffix(tagID, isElite)
	return (tagID and QUEST_TAG_SUFFIX[tagID]) or (isElite and ELITE_SUFFIX) or ""
end

-- "[13] Quest Name", or "[13D] Quest Name" for a dungeon quest, and so on
function ns.LevelTitle(level, title, suffix)
	return format("[%d%s] %s", level or 0, suffix or "", title or "")
end

--[[
	Questie's tracker takes over tracking a few seconds after login, once Questie's startup reaches it.
	Until then every quest reads as untracked, which would flash an eye on every row with markUntracked
	on. So while it's pending no marks are drawn, and the quest log redraws the moment it starts
]]
local questieTracker, redrawOnTrackerStart
local function IsQuestieTrackerPending()
	if not (Questie and Questie.db and Questie.db.profile and Questie.db.profile.trackerEnabled) then
		return false
	end
	questieTracker = questieTracker or ns.ImportQuestieModule("QuestieTracker")
	if not questieTracker or questieTracker.started then
		return false
	end
	if not redrawOnTrackerStart and type(questieTracker.HookBaseTracker) == "function" then
		redrawOnTrackerStart = true
		hooksecurefunc(questieTracker, "HookBaseTracker", function()
			ns.RefreshQuestLog()
		end)
	end
	return true
end

--[[
	Draws the tracking mark for a quest in its slot texture: the check when it's tracked, or with
	markUntracked on, the crossed-out eye when it isn't. Hidden otherwise, and while Questie's tracker
	is still starting up
]]
function ns.ShowTrackingMark(texture, isTracked)
	local markUntracked = ns.db and ns.db.profile.markUntracked
	local mark = markUntracked and ns.TRACKING_MARKS.untracked or ns.TRACKING_MARKS.tracked
	texture:SetTexture(mark.texture)
	texture:SetVertexColor(mark.r, mark.g, mark.b)
	texture:SetShown(
		(isTracked and true or false) ~= (markUntracked and true or false) and not IsQuestieTrackerPending()
	)
end

function ns.QuestIDText(questID)
	return format(L["QUEST_ID"], questID)
end

--[[
	Shows a quest ID in a FontString, in the same font and colour as source (the description) but
	smaller
]]
function ns.StyleQuestID(text, questID, source)
	local file, size, flags = source:GetFont()
	if file and size then
		text:SetFont(file, size - ns.LAYOUT.QUEST_ID_FONT_SHRINK, flags)
	end
	text:SetTextColor(source:GetTextColor())
	text:SetText(ns.QuestIDText(questID))
end

--[[
	Objective lines in the quest details: a green check for a finished objective (or
	a blank the same size, so the names line up), the objective's name, and its count ("8 / 8")
	right-aligned in a column of its own, two spaces in from the right edge of the text column
]]
local CHECK = "|TInterface\\RaidFrame\\ReadyCheck-Ready:0|t"
local NO_CHECK = "|TInterface\\Common\\spacer:0|t"
local COUNT_GAP = 8 -- Between a name and its count

--[[
	Body text wraps short of the column's edge, so a number flush against it (an objective's count, gold,
	experience, the quest ID) looks like it runs past the text. Those numbers end two spaces in instead, measured in
	the font given, on a hidden FontString: a pair of spaces between two zeros, less the zeros alone,
	since a FontString may not draw trailing spaces
]]
local measure = UIParent:CreateFontString(nil, "ARTWORK")
measure:Hide()

function ns.TwoSpacesWide(fontSource)
	local fontObject = fontSource:GetFontObject()
	if fontObject then
		measure:SetFontObject(fontObject)
	else
		measure:SetFont(fontSource:GetFont())
	end
	measure:SetText("0  0")
	local spaced = measure:GetStringWidth()
	measure:SetText("00")
	return spaced - measure:GetStringWidth()
end

--[[
	"8/8 Ragefire Trogg slain" (WoW Forever) or "Ragefire Trogg slain: 8/8" (Classic). Anything else, a
	reputation objective say, is all name
]]
local function SplitObjective(text)
	local have, need, name = text:match("^%s*(%d+)%s*/%s*(%d+)%s+(.+)$")
	if not have then
		name, have, need = text:match("^(.-):%s*(%d+)%s*/%s*(%d+)%s*$")
	end
	if have then
		return name, format("%s / %s", have, need)
	end
	return text
end

local objectiveCounts = {} -- Count column for each objective line, by line

-- Skins (ElvUI) recolour the lines in hooks that may run after styling, so the counts match them again a frame later
local recolorPending
local function RecolorCounts()
	recolorPending = nil
	for line, count in pairs(objectiveCounts) do
		if count:IsShown() then
			count:SetTextColor(line:GetTextColor())
		end
	end
end

-- Hides every count, before the objective lines showing now are styled
function ns.ClearObjectiveCounts()
	for _, count in pairs(objectiveCounts) do
		count:Hide()
	end
end

-- Gives a FontString the same font as another, keeping its own colour
local function MatchFont(region, source)
	local red, green, blue, alpha = region:GetTextColor()
	local fontObject = source:GetFontObject()
	if fontObject then
		region:SetFontObject(fontObject)
	else
		region:SetFont(source:GetFont())
	end
	region:SetTextColor(red, green, blue, alpha)
end

--[[
	Restyles one of Blizzard's objective lines (a FontString), whose left edge is the left edge of a
	text column width wide. text and finished are the objective's, from GetQuestLogLeaderBoard().
	Blizzard draws objectives a size smaller than the rest of the quest text; they take fontSource's
	font (the description's) instead
]]
function ns.StyleObjective(line, text, finished, width, fontSource)
	local name, countText = SplitObjective(text or "")
	MatchFont(line, fontSource)
	line:SetText((finished and CHECK or NO_CHECK) .. " " .. name)

	local count = objectiveCounts[line]
	if not count then
		count = line:GetParent():CreateFontString(nil, "ARTWORK")
		count:SetJustifyH("RIGHT")
		objectiveCounts[line] = count
	end
	if not countText then
		line:SetWidth(width)
		return
	end

	MatchFont(count, line)
	count:SetTextColor(line:GetTextColor())
	if not recolorPending then
		recolorPending = true
		C_Timer.After(0, RecolorCounts)
	end
	local inset = ns.TwoSpacesWide(count)
	count:SetText(countText)
	count:ClearAllPoints()
	count:SetPoint("TOPRIGHT", line, "TOPLEFT", width - inset, 0)
	count:Show()
	line:SetWidth(width - inset - count:GetStringWidth() - COUNT_GAP)
end
