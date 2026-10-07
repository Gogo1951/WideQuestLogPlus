local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor

--[[
	The Feedback & Support labels are one short word each, so they take only what a word needs and give
	the rest of the row to the URL.
]]
local LINK_LABEL_WIDTH = 0.6
local LINK_URL_WIDTH = ns.OPTIONS_ROW_WIDTH - LINK_LABEL_WIDTH

-- Reset Size and Position, a quarter wider than a standard button for the longer locales, right-aligned
local RESET_WINDOW_WIDTH = 1.25
local RESET_WINDOW_INDENT_WIDTH = ns.OPTIONS_ROW_WIDTH - RESET_WINDOW_WIDTH

-- WoW Forever hides the Quest Log section while the wide quest log is off; nil everywhere else
local questLogHidden = ns.QuestLogOptionsHidden

--[[
	One of the tracking marks as an inline icon, tinted as in the quest list, raised by offsetY. Blizzard's
	check sits high in its square while the eye fills its own, so the eye reads low beside the text
]]
local function TrackingMarkIcon(mark, offsetY)
	return format(
		"|T%s:16:16:0:%d:32:32:0:32:0:32:%d:%d:%d|t",
		mark.texture,
		offsetY or 0,
		mark.r * 255,
		mark.g * 255,
		mark.b * 255
	)
end

-- What Mark Untracked Quests does, with both tracking marks shown in the sentence
local MARK_UNTRACKED_TEXT = L["MARK_UNTRACKED_DESCRIPTION"]:format(
	TrackingMarkIcon(ns.TRACKING_MARKS.tracked),
	TrackingMarkIcon(ns.TRACKING_MARKS.untracked, 3)
)

--------------------------------------------------------------------------------
-- General Panel
--------------------------------------------------------------------------------

local function SortSelect(key, descriptionKey, values, sorting, order)
	return {
		type = "select",
		name = "",
		desc = L[descriptionKey],
		width = ns.OPTIONS_CONTROL_WIDTH,
		order = order,
		hidden = questLogHidden,
		values = values,
		sorting = sorting,
		get = function()
			return ns.db.profile[key]
		end,
		set = function(_, value)
			ns.db.profile[key] = value
			ns.RefreshQuestLog()
		end,
	}
end

local function AddCommands(args, order)
	args.spaceCommands0 = ns.OptionsSpacer(order)
	args.headerCommands = ns.OptionsHeader(L["OPTIONS_COMMANDS_HEADER"], order + 1)
	args.spaceCommands1 = ns.OptionsSpacer(order + 2)
	args.descCommands = ns.OptionsDesc(
		GetColor("INFO") .. L["OPTIONS_COMMAND"] .. "|r" .. "  " .. L["OPTIONS_COMMAND_DESCRIPTION"],
		order + 3
	)
end

local function AddFeedback(args, order)
	args.spaceFeedback0 = ns.OptionsSpacer(order)
	args.headerFeedback = ns.OptionsHeader(L["FEEDBACK_HEADER"], order + 1)
	args.spaceFeedback1 = ns.OptionsSpacer(order + 2)
	order = order + 3

	local urls = {
		{ L["FEEDBACK_GITHUB"], ns.URLS.GITHUB },
		{ L["FEEDBACK_CURSEFORGE"], ns.URLS.CURSEFORGE },
	}
	for index, row in ipairs(urls) do
		if index > 1 then
			args["urlSpace" .. index] = ns.OptionsSpacer(order)
			order = order + 1
		end
		local url = row[2]
		args["urlLabel" .. index] = ns.OptionsRowLabel(GetColor("TITLE") .. row[1] .. "|r", order, LINK_LABEL_WIDTH)
		args["urlValue" .. index] = {
			type = "input",
			name = "",
			width = LINK_URL_WIDTH,
			order = order + 1,
			get = function()
				return url
			end,
			set = function() end,
		}
		order = order + 2
	end
end

function ns.BuildGeneralOptions()
	local args = {
		addonDescription = ns.OptionsDesc(L["OPTIONS_DESCRIPTION"], 1),
		spaceWelcome0 = ns.OptionsSpacer(2),
		showWelcome = {
			type = "toggle",
			name = L["ENABLE_WELCOME_MESSAGE"],
			desc = L["ENABLE_WELCOME_MESSAGE_DESCRIPTION"],
			width = "full",
			order = 3,
			get = function()
				return ns.db.profile.showWelcome
			end,
			set = function(_, value)
				ns.db.profile.showWelcome = value
			end,
		},

		spaceQuestLog0 = ns.OptionsSpacer(10, questLogHidden),
		headerQuestLog = ns.OptionsHeader(QUEST_LOG, 11, questLogHidden),
		spaceQuestLog1 = ns.OptionsSpacer(12, questLogHidden),
		zoneSortLabel = ns.OptionsRowLabel(L["ZONE_ORDER"], 14, nil, questLogHidden),
		zoneSort = SortSelect("zoneSort", "ZONE_ORDER_DESCRIPTION", {
			ALPHABETICAL = L["SORT_ALPHABETICAL_DEFAULT"],
			LEVEL_HIGHEST_FIRST = L["SORT_AVERAGE_LEVEL_HIGHEST"],
			LEVEL_LOWEST_FIRST = L["SORT_AVERAGE_LEVEL_LOWEST"],
		}, { "ALPHABETICAL", "LEVEL_HIGHEST_FIRST", "LEVEL_LOWEST_FIRST" }, 15),
		spaceZoneSort = ns.OptionsSpacer(16, questLogHidden),
		zoneGap = {
			type = "toggle",
			name = L["ZONE_GAP"],
			desc = L["ZONE_GAP_DESCRIPTION"],
			width = "full",
			order = 20,
			hidden = questLogHidden,
			get = function()
				return ns.db.profile.zoneGap
			end,
			set = function(_, value)
				ns.db.profile.zoneGap = value
				ns.RefreshQuestLog()
			end,
		},
		spaceQuestSort = ns.OptionsSpacer(21, questLogHidden),
		questSortLabel = ns.OptionsRowLabel(L["QUEST_ORDER"], 22, nil, questLogHidden),
		questSort = SortSelect("questSort", "QUEST_ORDER_DESCRIPTION", {
			LEVEL_LOWEST_FIRST = L["SORT_LEVEL_LOWEST_DEFAULT"],
			LEVEL_HIGHEST_FIRST = L["SORT_LEVEL_HIGHEST"],
			ALPHABETICAL = L["SORT_ALPHABETICAL"],
		}, { "LEVEL_LOWEST_FIRST", "LEVEL_HIGHEST_FIRST", "ALPHABETICAL" }, 23),
		spaceMarkUntracked = ns.OptionsSpacer(24, questLogHidden),
		markUntracked = {
			type = "toggle",
			name = L["MARK_UNTRACKED"],
			desc = MARK_UNTRACKED_TEXT,
			width = "full",
			order = 25,
			hidden = questLogHidden,
			get = function()
				return ns.db.profile.markUntracked
			end,
			set = function(_, value)
				ns.db.profile.markUntracked = value
				ns.RefreshQuestLog()
			end,
		},
		spaceQuestLog2 = ns.OptionsSpacer(40, questLogHidden),
		resetWindowIndent = ns.OptionsRowLabel(" ", 41, RESET_WINDOW_INDENT_WIDTH, questLogHidden),
		resetWindow = {
			type = "execute",
			name = L["RESET_WINDOW"],
			desc = L["RESET_WINDOW_DESCRIPTION"],
			width = RESET_WINDOW_WIDTH,
			order = 42,
			hidden = questLogHidden,
			confirm = true,
			confirmText = L["RESET_WINDOW_CONFIRM"],
			func = function()
				ns.ResetWindow()
			end,
		},

		spaceVersion = {
			type = "description",
			name = " ",
			width = "full",
			order = 998,
		},
		version = {
			type = "description",
			name = GetColor("MUTED") .. L["OPTIONS_VERSION"]:format(ns.Version) .. "|r",
			fontSize = "medium",
			order = 999,
		},
	}

	-- WoW Forever's quest log key option, when that client's TOC loaded it
	if ns.BuildForeverQuestLogOptions then
		for key, option in pairs(ns.BuildForeverQuestLogOptions()) do
			args[key] = option
		end
	end

	AddCommands(args, 100)
	AddFeedback(args, 200)

	return {
		type = "group",
		name = L["ADDON_TITLE"],
		args = args,
	}
end
