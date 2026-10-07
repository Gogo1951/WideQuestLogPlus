local L = LibStub("AceLocale-3.0"):NewLocale("WideQuestLogPlus", "zhTW")
if not L then
	return
end

--------------------------------------------------------------------------------
-- Add-on
--------------------------------------------------------------------------------

L["ADDON_TITLE"] = "Wide Quest Log Plus"
L["CHAT_LOADED"] =
	"版本 %s。設定（包括關閉此訊息的選項）位於 選項 > 插件 > Wide Quest Log Plus。喜歡這個插件嗎？推薦給朋友吧！(="
L["CHAT_OPTIONS_IN_COMBAT"] = "基於安全考量，戰鬥中無法開啟設定介面。"

--------------------------------------------------------------------------------
-- Options
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"寬版雙欄任務日誌，顯示任務等級、地城、團隊副本和精英標記以及任務 ID。一次看清完整任務清單和每個任務的詳細資訊，並依你的方式排序。更大的任務日誌，保留暴雪原版外觀。"
L["ENABLE_WELCOME_MESSAGE"] = "啟用歡迎訊息"
L["ENABLE_WELCOME_MESSAGE_DESCRIPTION"] = "登入時顯示 Wide Quest Log Plus 的歡迎詞。"
L["ENABLE_WIDE_QUEST_LOG"] = "為此設定檔啟用寬任務日誌"
L["ENABLE_WIDE_QUEST_LOG_DESCRIPTION"] =
	"讓任務日誌快捷鍵、微型選單按鈕以及在任務追蹤中點擊任務時開啟這個寬任務日誌。關閉後改為開啟嵌在世界地圖中的暴雪預設任務日誌。重新載入介面後生效。"
L["RELOAD_PROMPT"] = "Wide Quest Log Plus 需要重新載入介面才能切換任務日誌。現在重新載入嗎？"
L["ZONE_ORDER"] = "區域順序"
L["ZONE_ORDER_DESCRIPTION"] = "變更任務清單中區域的順序。"
L["SORT_ALPHABETICAL_DEFAULT"] = "依名稱（預設）"
L["SORT_AVERAGE_LEVEL_HIGHEST"] = "平均等級，由高到低"
L["SORT_AVERAGE_LEVEL_LOWEST"] = "平均等級，由低到高"
L["ZONE_GAP"] = "區域名稱上方留空"
L["ZONE_GAP_DESCRIPTION"] =
	"在每個區域名稱上方加入一個空行。如果你的任務分散在許多區域，會很方便。"
L["QUEST_ORDER"] = "任務順序"
L["QUEST_ORDER_DESCRIPTION"] = "變更每個區域下任務的順序。"
L["SORT_LEVEL_LOWEST_DEFAULT"] = "等級，由低到高（預設）"
L["SORT_LEVEL_HIGHEST"] = "等級，由高到低"
L["SORT_ALPHABETICAL"] = "依名稱"
L["MARK_UNTRACKED"] = "標記未追蹤的任務"
L["MARK_UNTRACKED_DESCRIPTION"] =
	"已追蹤的任務不再顯示勾號 %s，改為在未追蹤的任務前顯示眼睛 %s。如果你幾乎追蹤所有任務，會很方便。"
L["RESET_WINDOW"] = "重設大小和位置"
L["RESET_WINDOW_DESCRIPTION"] = "將任務日誌恢復為預設大小和位置。"
L["RESET_WINDOW_CONFIRM"] = "要將任務日誌重設為預設大小和位置嗎？"
L["OPTIONS_COMMANDS_HEADER"] = "/指令"
L["OPTIONS_COMMAND"] = "/wide"
L["OPTIONS_COMMAND_DESCRIPTION"] = "開啟此插件的設定介面。"
L["FEEDBACK_HEADER"] = "意見回饋與支援"
L["FEEDBACK_GITHUB"] = "GitHub"
L["FEEDBACK_CURSEFORGE"] = "CurseForge"
L["OPTIONS_VERSION"] = "版本 %s"

--------------------------------------------------------------------------------
-- Quest List and Details
--------------------------------------------------------------------------------

L["QUEST_SUFFIX_DUNGEON"] = "副"
L["QUEST_SUFFIX_RAID"] = "團"
L["QUEST_SUFFIX_PVP"] = "戰"
L["QUEST_SUFFIX_GROUP"] = "組"
L["QUEST_SUFFIX_ELITE"] = "精"
L["QUEST_ID"] = "ID %d"
L["RESIZE_TOOLTIP"] = "拖曳以調整任務日誌大小"

--------------------------------------------------------------------------------
-- Questie Tracking
--------------------------------------------------------------------------------

L["QUESTIE_CANNOT_SHOW"] = "Questie 追蹤器無法顯示 %s，因為 Questie 資料庫中缺少該任務。"
L["QUESTIE_CANNOT_TRACK"] = "Questie 暫時無法追蹤此任務"
