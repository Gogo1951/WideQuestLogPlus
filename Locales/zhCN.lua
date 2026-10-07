local L = LibStub("AceLocale-3.0"):NewLocale("WideQuestLogPlus", "zhCN")
if not L then
	return
end

--------------------------------------------------------------------------------
-- Add-on
--------------------------------------------------------------------------------

L["ADDON_TITLE"] = "Wide Quest Log Plus"
L["CHAT_LOADED"] =
	"版本 %s。设置（包括关闭此消息的选项）位于 选项 > 插件 > Wide Quest Log Plus。喜欢这个插件吗？推荐给朋友吧！(="
L["CHAT_OPTIONS_IN_COMBAT"] = "出于安全考虑，战斗中无法打开设置界面。"

--------------------------------------------------------------------------------
-- Options
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"宽版双栏任务日志，显示任务等级、地下城、团队副本和精英标记以及任务 ID。一次看清完整任务列表和每个任务的详情，并按你的方式排序。更大的任务日志，保留暴雪原版外观。"
L["ENABLE_WELCOME_MESSAGE"] = "启用欢迎消息"
L["ENABLE_WELCOME_MESSAGE_DESCRIPTION"] = "登录时显示 Wide Quest Log Plus 的欢迎语。"
L["ENABLE_WIDE_QUEST_LOG"] = "为此配置文件启用宽任务日志"
L["ENABLE_WIDE_QUEST_LOG_DESCRIPTION"] =
	"让任务日志快捷键、微型菜单按钮以及在任务追踪中点击任务时打开这个宽任务日志。关闭后改为打开嵌在世界地图中的暴雪默认任务日志。重新加载界面后生效。"
L["RELOAD_PROMPT"] = "Wide Quest Log Plus 需要重新加载界面才能切换任务日志。现在重新加载吗？"
L["ZONE_ORDER"] = "区域顺序"
L["ZONE_ORDER_DESCRIPTION"] = "更改任务列表中区域的顺序。"
L["SORT_ALPHABETICAL_DEFAULT"] = "按名称（默认）"
L["SORT_AVERAGE_LEVEL_HIGHEST"] = "平均等级，从高到低"
L["SORT_AVERAGE_LEVEL_LOWEST"] = "平均等级，从低到高"
L["ZONE_GAP"] = "区域名称上方留空"
L["ZONE_GAP_DESCRIPTION"] =
	"在每个区域名称上方添加一个空行。如果你的任务分布在许多区域，会很方便。"
L["QUEST_ORDER"] = "任务顺序"
L["QUEST_ORDER_DESCRIPTION"] = "更改每个区域下任务的顺序。"
L["SORT_LEVEL_LOWEST_DEFAULT"] = "等级，从低到高（默认）"
L["SORT_LEVEL_HIGHEST"] = "等级，从高到低"
L["SORT_ALPHABETICAL"] = "按名称"
L["MARK_UNTRACKED"] = "标记未追踪的任务"
L["MARK_UNTRACKED_DESCRIPTION"] =
	"已追踪的任务不再显示对勾 %s，改为在未追踪的任务前显示眼睛 %s。如果你几乎追踪所有任务，会很方便。"
L["RESET_WINDOW"] = "重置大小和位置"
L["RESET_WINDOW_DESCRIPTION"] = "将任务日志恢复为默认大小和位置。"
L["RESET_WINDOW_CONFIRM"] = "将任务日志重置为默认大小和位置？"
L["OPTIONS_COMMANDS_HEADER"] = "/命令"
L["OPTIONS_COMMAND"] = "/wide"
L["OPTIONS_COMMAND_DESCRIPTION"] = "打开此插件的设置界面。"
L["FEEDBACK_HEADER"] = "反馈与支持"
L["FEEDBACK_GITHUB"] = "GitHub"
L["FEEDBACK_CURSEFORGE"] = "CurseForge"
L["OPTIONS_VERSION"] = "版本 %s"

--------------------------------------------------------------------------------
-- Quest List and Details
--------------------------------------------------------------------------------

L["QUEST_SUFFIX_DUNGEON"] = "副"
L["QUEST_SUFFIX_RAID"] = "团"
L["QUEST_SUFFIX_PVP"] = "战"
L["QUEST_SUFFIX_GROUP"] = "组"
L["QUEST_SUFFIX_ELITE"] = "精"
L["QUEST_ID"] = "ID %d"
L["RESIZE_TOOLTIP"] = "拖动以调整任务日志大小"

--------------------------------------------------------------------------------
-- Questie Tracking
--------------------------------------------------------------------------------

L["QUESTIE_CANNOT_SHOW"] = "Questie 追踪器无法显示 %s，因为 Questie 数据库中缺少该任务。"
L["QUESTIE_CANNOT_TRACK"] = "Questie 暂时无法追踪此任务"
