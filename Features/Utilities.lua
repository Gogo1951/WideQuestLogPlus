local _, ns = ...

--------------------------------------------------------------------------------
-- Colors
--------------------------------------------------------------------------------

local COLORS = {}
for key, hex in pairs(ns.PALETTE) do
	COLORS[key] = "|cff" .. hex
end

function ns.GetColor(key)
	return COLORS[key] or COLORS.TEXT
end

--------------------------------------------------------------------------------
-- Questie
--------------------------------------------------------------------------------

function ns.ImportQuestieModule(name)
	if not QuestieLoader then
		return
	end
	local loaded, module = pcall(QuestieLoader.ImportModule, QuestieLoader, name)
	return loaded and type(module) == "table" and module or nil
end

--------------------------------------------------------------------------------
-- Sorting
--------------------------------------------------------------------------------

--[[
	Both quest logs sort the same records: quests carry sortLevel, sortKey and sortIndex (their quest log
	index), zones carry title, sortIndex, sortKey and averageLevel.
]]

-- Alphabetical by full name, as Blizzard's quest log lists zones, so The Hinterlands goes under T
function ns.NameSortKey(title)
	return strlower(title or "")
end

-- The average level of a zone's quests, or nil when none are listed
function ns.AverageLevel(quests)
	if #quests == 0 then
		return nil
	end
	local total = 0
	for _, quest in ipairs(quests) do
		total = total + quest.sortLevel
	end
	return total / #quests
end

--[[
	questSort: LEVEL_LOWEST_FIRST (the default) or LEVEL_HIGHEST_FIRST by level, or ALPHABETICAL by name. Ties keep the
	quest log's order
]]
function ns.SortQuests(quests, questSort)
	table.sort(quests, function(a, b)
		if questSort == "ALPHABETICAL" then
			if a.sortKey ~= b.sortKey then
				return a.sortKey < b.sortKey
			end
		elseif a.sortLevel ~= b.sortLevel then
			if questSort == "LEVEL_HIGHEST_FIRST" then
				return a.sortLevel > b.sortLevel
			end
			return a.sortLevel < b.sortLevel
		end
		return a.sortIndex < b.sortIndex
	end)
end

-- zoneSort: ALPHABETICAL (the default), LEVEL_HIGHEST_FIRST or LEVEL_LOWEST_FIRST by average quest level, then by name
local function CompareZones(a, b, zoneSort)
	if (zoneSort == "LEVEL_HIGHEST_FIRST" or zoneSort == "LEVEL_LOWEST_FIRST") and a.averageLevel ~= b.averageLevel then
		-- A zone whose level isn't known goes after the rest
		if not (a.averageLevel and b.averageLevel) then
			return a.averageLevel ~= nil
		end
		if zoneSort == "LEVEL_LOWEST_FIRST" then
			return a.averageLevel < b.averageLevel
		end
		return a.averageLevel > b.averageLevel
	end
	if a.sortKey ~= b.sortKey then
		return a.sortKey < b.sortKey
	end
	return a.sortIndex < b.sortIndex
end

--[[
	Sorts zones by zoneSort, except that frozen (zone title -> rank, from the first sort since the window
	opened) keeps zones where they were, so turning in or dropping a quest doesn't shuffle them under the
	cursor; zones it doesn't know go after. Returns the frozen ranks, made on the first call.
]]
function ns.SortZones(zones, zoneSort, frozen)
	table.sort(zones, function(a, b)
		local rankA, rankB = frozen and frozen[a.title or ""], frozen and frozen[b.title or ""]
		if rankA and rankB then
			return rankA < rankB
		elseif rankA or rankB then
			return rankA ~= nil
		end
		return CompareZones(a, b, zoneSort)
	end)
	if not frozen then
		frozen = {}
		for rank, zone in ipairs(zones) do
			frozen[zone.title or ""] = rank
		end
	end
	return frozen
end
