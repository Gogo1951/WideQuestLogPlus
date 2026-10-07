local L = LibStub("AceLocale-3.0"):NewLocale("WideQuestLogPlus", "koKR")
if not L then
	return
end

--------------------------------------------------------------------------------
-- Add-on
--------------------------------------------------------------------------------

L["ADDON_TITLE"] = "Wide Quest Log Plus"
L["CHAT_LOADED"] =
	"버전 %s. 설정(이 메시지를 끄는 옵션 포함)은 설정 > 애드온 > Wide Quest Log Plus에서 찾을 수 있습니다. 애드온이 마음에 드시나요? 친구에게도 알려 주세요! (="
L["CHAT_OPTIONS_IN_COMBAT"] = "안전을 위해 전투 중에는 설정 창을 열 수 없습니다."

--------------------------------------------------------------------------------
-- Options
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"퀘스트 레벨, 던전, 공격대, 정예 표시와 퀘스트 ID를 갖춘 넓은 2단 퀘스트 목록. 전체 퀘스트 목록과 각 퀘스트의 세부 정보를 원하는 순서로 정렬해 한 번에 확인하세요. 블리자드 디자인을 그대로 살린 더 큰 퀘스트 목록입니다."
L["ENABLE_WELCOME_MESSAGE"] = "환영 메시지 사용"
L["ENABLE_WELCOME_MESSAGE_DESCRIPTION"] = "접속할 때 Wide Quest Log Plus 환영 인사를 표시합니다."
L["ENABLE_WIDE_QUEST_LOG"] = "이 프로필에서 넓은 퀘스트 목록 사용"
L["ENABLE_WIDE_QUEST_LOG_DESCRIPTION"] =
	"퀘스트 목록 단축키, 마이크로 메뉴 버튼, 목표 추적기의 퀘스트 클릭이 이 넓은 퀘스트 목록을 열도록 합니다. 끄면 대신 세계 지도에 붙어 있는 블리자드 기본 퀘스트 목록이 열립니다. UI를 다시 불러온 후에 적용됩니다."
L["RELOAD_PROMPT"] =
	"Wide Quest Log Plus는 UI를 다시 불러온 후에 퀘스트 목록을 전환합니다. 지금 다시 불러오시겠습니까?"
L["ZONE_ORDER"] = "지역 순서"
L["ZONE_ORDER_DESCRIPTION"] = "퀘스트 목록에서 지역의 순서를 바꿉니다."
L["SORT_ALPHABETICAL_DEFAULT"] = "이름순 (기본값)"
L["SORT_AVERAGE_LEVEL_HIGHEST"] = "평균 레벨, 높은 순"
L["SORT_AVERAGE_LEVEL_LOWEST"] = "평균 레벨, 낮은 순"
L["ZONE_GAP"] = "지역 이름 위 여백"
L["ZONE_GAP_DESCRIPTION"] =
	"각 지역 이름 위에 빈 줄을 추가합니다. 퀘스트가 여러 지역에 흩어져 있다면 유용합니다."
L["QUEST_ORDER"] = "퀘스트 순서"
L["QUEST_ORDER_DESCRIPTION"] = "각 지역 아래 퀘스트의 순서를 바꿉니다."
L["SORT_LEVEL_LOWEST_DEFAULT"] = "레벨, 낮은 순 (기본값)"
L["SORT_LEVEL_HIGHEST"] = "레벨, 높은 순"
L["SORT_ALPHABETICAL"] = "이름순"
L["MARK_UNTRACKED"] = "추적하지 않는 퀘스트 표시"
L["MARK_UNTRACKED_DESCRIPTION"] =
	"추적 중인 퀘스트의 체크 %s 표시가 사라지고, 대신 추적하지 않는 퀘스트에 눈 %s 표시가 붙습니다. 거의 모든 퀘스트를 추적한다면 유용합니다."
L["RESET_WINDOW"] = "크기 및 위치 초기화"
L["RESET_WINDOW_DESCRIPTION"] = "퀘스트 목록을 기본 크기와 위치로 되돌립니다."
L["RESET_WINDOW_CONFIRM"] = "퀘스트 목록을 기본 크기와 위치로 초기화할까요?"
L["OPTIONS_COMMANDS_HEADER"] = "/명령어"
L["OPTIONS_COMMAND"] = "/wide"
L["OPTIONS_COMMAND_DESCRIPTION"] = "이 애드온의 설정 창을 엽니다."
L["FEEDBACK_HEADER"] = "피드백 및 지원"
L["FEEDBACK_GITHUB"] = "GitHub"
L["FEEDBACK_CURSEFORGE"] = "CurseForge"
L["OPTIONS_VERSION"] = "버전 %s"

--------------------------------------------------------------------------------
-- Quest List and Details
--------------------------------------------------------------------------------

L["QUEST_SUFFIX_DUNGEON"] = "던"
L["QUEST_SUFFIX_RAID"] = "공"
L["QUEST_SUFFIX_PVP"] = "전"
L["QUEST_SUFFIX_GROUP"] = "파"
L["QUEST_SUFFIX_ELITE"] = "정"
L["QUEST_ID"] = "ID %d"
L["RESIZE_TOOLTIP"] = "끌어서 퀘스트 목록 크기 조절"

--------------------------------------------------------------------------------
-- Questie Tracking
--------------------------------------------------------------------------------

L["QUESTIE_CANNOT_SHOW"] =
	"Questie 데이터베이스에 없는 퀘스트라서 Questie 추적기에 %s 퀘스트를 표시할 수 없습니다."
L["QUESTIE_CANNOT_TRACK"] = "Questie가 아직 이 퀘스트를 추적할 수 없습니다"
