local L = LibStub("AceLocale-3.0"):NewLocale("WideQuestLogPlus", "enUS", true)
if not L then
	return
end

--------------------------------------------------------------------------------
-- Add-on
--------------------------------------------------------------------------------

L["ADDON_TITLE"] = "Wide Quest Log Plus"
L["CHAT_LOADED"] =
	"Version %s. Settings (including the option to disable this message) can be found under Options > AddOns > Wide Quest Log Plus. Enjoying the add-on? Tell a friend about it! (="
L["CHAT_OPTIONS_IN_COMBAT"] = "As a safety precaution, the Options Interface cannot be opened during combat."

--------------------------------------------------------------------------------
-- Options
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"Wide, dual-pane quest log with quest levels, dungeon, raid and elite tags, and quest IDs. See your whole quest list and every quest's details at once, sorted your way. A bigger quest log that keeps the Blizzard look."
L["ENABLE_WELCOME_MESSAGE"] = "Enable Welcome Message"
L["ENABLE_WELCOME_MESSAGE_DESCRIPTION"] = "Shows the Wide Quest Log Plus greeting when you log in."
L["ENABLE_WIDE_QUEST_LOG"] = "Enable Wide Quest Log for This Profile"
L["ENABLE_WIDE_QUEST_LOG_DESCRIPTION"] =
	"Makes the quest log key, the micro menu button and quest clicks in the objective tracker open this wide quest log. Turn it off to use Blizzard's default quest log, docked in the world map, instead. Takes effect after a reload."
L["RELOAD_PROMPT"] = "Wide Quest Log Plus switches quest logs after a reload. Reload now?"
L["ZONE_ORDER"] = "Zone Order"
L["ZONE_ORDER_DESCRIPTION"] = "Changes the order of the zones in the quest list."
L["SORT_ALPHABETICAL_DEFAULT"] = "Alphabetical (Default)"
L["SORT_AVERAGE_LEVEL_HIGHEST"] = "Average Level, Highest First"
L["SORT_AVERAGE_LEVEL_LOWEST"] = "Average Level, Lowest First"
L["ZONE_GAP"] = "Space Above Zone Names"
L["ZONE_GAP_DESCRIPTION"] =
	"Adds a blank line above each zone name. Handy when your quests are spread across lots of zones."
L["QUEST_ORDER"] = "Quest Order"
L["QUEST_ORDER_DESCRIPTION"] = "Changes the order of the quests under each zone."
L["SORT_LEVEL_LOWEST_DEFAULT"] = "Level, Lowest First (Default)"
L["SORT_LEVEL_HIGHEST"] = "Level, Highest First"
L["SORT_ALPHABETICAL"] = "Alphabetical"
L["MARK_UNTRACKED"] = "Mark Untracked Quests"
L["MARK_UNTRACKED_DESCRIPTION"] =
	"Tracked quests lose their checkmark %s, and untracked quests get an eye %s instead. Handy if you track almost everything."
L["RESET_WINDOW"] = "Reset Size and Position"
L["RESET_WINDOW_DESCRIPTION"] = "Puts the quest log back to its default size and position."
L["RESET_WINDOW_CONFIRM"] = "Reset the quest log to its default size and position?"
L["OPTIONS_COMMANDS_HEADER"] = "/Commands"
L["OPTIONS_COMMAND"] = "/wide"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Opens the Options Interface for this add-on."
L["FEEDBACK_HEADER"] = "Feedback & Support"
L["FEEDBACK_GITHUB"] = "GitHub"
L["FEEDBACK_CURSEFORGE"] = "CurseForge"
L["OPTIONS_VERSION"] = "Version %s"

--------------------------------------------------------------------------------
-- Quest List and Details
--------------------------------------------------------------------------------

L["QUEST_SUFFIX_DUNGEON"] = "D"
L["QUEST_SUFFIX_RAID"] = "R"
L["QUEST_SUFFIX_PVP"] = "P"
L["QUEST_SUFFIX_GROUP"] = "G"
L["QUEST_SUFFIX_ELITE"] = "E"
L["QUEST_ID"] = "ID %d"
L["RESIZE_TOOLTIP"] = "Drag to resize the quest log"

--------------------------------------------------------------------------------
-- Questie Tracking
--------------------------------------------------------------------------------

L["QUESTIE_CANNOT_SHOW"] = "Questie's tracker can't show %s because the quest is missing from Questie's database."
L["QUESTIE_CANNOT_TRACK"] = "Questie can't track this quest yet"
