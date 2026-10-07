local _, ns = ...
local L = ns.L

--------------------------------------------------------------------------------
-- Tracking, and Questie
--------------------------------------------------------------------------------

-- While Questie's tracker is in charge, a quest counts as tracked only if it shows there (README-Technical).
local questieTracker, questiePlayer

--[[
	Returns Questie's tracker if it's in charge of this quest, false if it's in charge but can't show
	the quest, or nil if Blizzard's tracker is in charge
]]
local function TrackerFor(questID)
	if not (Questie and Questie.db and Questie.db.profile and Questie.db.profile.trackerEnabled) then
		return nil
	end
	questieTracker = questieTracker or ns.ImportQuestieModule("QuestieTracker")
	questiePlayer = questiePlayer or ns.ImportQuestieModule("QuestiePlayer")
	if not (questieTracker and questieTracker.IsTrackedByQuestie and questiePlayer) then
		return nil
	end
	local log = questiePlayer.currentQuestlog
	return (log and log[questID] ~= nil) and questieTracker or false
end

function ns.CanTrack(questID)
	return TrackerFor(questID) ~= false
end

function ns.IsTracked(questID)
	local tracker = TrackerFor(questID)
	if tracker then
		return tracker.IsTrackedByQuestie(questID) and true or false
	elseif tracker == false then
		return false
	end
	return QuestUtils_IsQuestWatched(questID)
end

function ns.QuestieCannotShowText(questID)
	return L["QUESTIE_CANNOT_SHOW"]:format(GetQuestLink(questID) or C_QuestLog.GetTitleForQuestID(questID) or questID)
end

local warnedUntrackable = {}
function ns.ToggleTracking(questID)
	local tracker = TrackerFor(questID)
	if tracker == false then
		if not warnedUntrackable[questID] then
			warnedUntrackable[questID] = true
			ns:PrintMessage(ns.QuestieCannotShowText(questID))
		end
		UIErrorsFrame:AddMessage(L["QUESTIE_CANNOT_TRACK"], 1.0, 0.1, 0.1, 1.0)
		return
	end

	local watched = QuestUtils_IsQuestWatched(questID)
	if ns.IsTracked(questID) then
		if tracker and not watched then
			tracker:UntrackQuestId(questID)
		elseif QuestUtil.CanRemoveQuestWatch() then
			C_QuestLog.RemoveQuestWatch(questID) -- Also untracks it in Questie
		end
	elseif not watched and C_QuestLog.GetNumQuestWatches() >= Constants.QuestWatchConsts.MAX_QUEST_WATCHES then
		UIErrorsFrame:AddMessage(OBJECTIVES_WATCH_TOO_MANY, 1.0, 0.1, 0.1, 1.0)
	else
		-- Adding a watch that already exists is harmless, and is what tells Questie to track it
		C_QuestLog.AddQuestWatch(questID)
	end
	ns.RequestUpdate()
end
