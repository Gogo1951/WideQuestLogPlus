local L = LibStub("AceLocale-3.0"):NewLocale("WideQuestLogPlus", "ptBR")
if not L then
	return
end

--------------------------------------------------------------------------------
-- Add-on
--------------------------------------------------------------------------------

L["ADDON_TITLE"] = "Wide Quest Log Plus"
L["CHAT_LOADED"] =
	"Versão %s. As configurações (incluindo a opção de desativar esta mensagem) ficam em Opções > AddOns > Wide Quest Log Plus. Está gostando do add-on? Conte para um amigo! (="
L["CHAT_OPTIONS_IN_COMBAT"] = "Por precaução, a interface de opções não pode ser aberta durante o combate."

--------------------------------------------------------------------------------
-- Options
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"Registro de missões largo, com dois painéis, níveis de missão, marcações de masmorra, raide e elite, e IDs de missão. Veja sua lista de missões inteira e os detalhes de cada missão ao mesmo tempo, ordenados do seu jeito. Um registro de missões maior que mantém o visual da Blizzard."
L["ENABLE_WELCOME_MESSAGE"] = "Ativar mensagem de boas-vindas"
L["ENABLE_WELCOME_MESSAGE_DESCRIPTION"] = "Mostra a saudação do Wide Quest Log Plus ao entrar no jogo."
L["ENABLE_WIDE_QUEST_LOG"] = "Ativar o registro de missões largo para este perfil"
L["ENABLE_WIDE_QUEST_LOG_DESCRIPTION"] =
	"Faz a tecla do registro de missões, o botão do micromenu e os cliques em missões no rastreador de objetivos abrirem este registro de missões largo. Desative para usar em vez dele o registro de missões padrão da Blizzard, acoplado ao mapa-múndi. Entra em vigor após recarregar."
L["RELOAD_PROMPT"] = "O Wide Quest Log Plus troca de registro de missões após recarregar. Recarregar agora?"
L["ZONE_ORDER"] = "Ordem das zonas"
L["ZONE_ORDER_DESCRIPTION"] = "Muda a ordem das zonas na lista de missões."
L["SORT_ALPHABETICAL_DEFAULT"] = "Alfabética (padrão)"
L["SORT_AVERAGE_LEVEL_HIGHEST"] = "Nível médio, maior primeiro"
L["SORT_AVERAGE_LEVEL_LOWEST"] = "Nível médio, menor primeiro"
L["ZONE_GAP"] = "Espaço acima dos nomes de zona"
L["ZONE_GAP_DESCRIPTION"] =
	"Adiciona uma linha em branco acima de cada nome de zona. Útil se suas missões estão espalhadas por muitas zonas."
L["QUEST_ORDER"] = "Ordem das missões"
L["QUEST_ORDER_DESCRIPTION"] = "Muda a ordem das missões dentro de cada zona."
L["SORT_LEVEL_LOWEST_DEFAULT"] = "Nível, menor primeiro (padrão)"
L["SORT_LEVEL_HIGHEST"] = "Nível, maior primeiro"
L["SORT_ALPHABETICAL"] = "Alfabética"
L["MARK_UNTRACKED"] = "Marcar missões não acompanhadas"
L["MARK_UNTRACKED_DESCRIPTION"] =
	"Missões acompanhadas perdem a marca de seleção %s, e missões não acompanhadas ganham um olho %s no lugar. Útil se você acompanha quase tudo."
L["RESET_WINDOW"] = "Redefinir tamanho e posição"
L["RESET_WINDOW_DESCRIPTION"] = "Volta o registro de missões ao tamanho e à posição padrão."
L["RESET_WINDOW_CONFIRM"] = "Redefinir o registro de missões para o tamanho e a posição padrão?"
L["OPTIONS_COMMANDS_HEADER"] = "/Comandos"
L["OPTIONS_COMMAND"] = "/wide"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Abre a interface de opções deste add-on."
L["FEEDBACK_HEADER"] = "Feedback e suporte"
L["FEEDBACK_GITHUB"] = "GitHub"
L["FEEDBACK_CURSEFORGE"] = "CurseForge"
L["OPTIONS_VERSION"] = "Versão %s"

--------------------------------------------------------------------------------
-- Quest List and Details
--------------------------------------------------------------------------------

L["QUEST_SUFFIX_DUNGEON"] = "M"
L["QUEST_SUFFIX_RAID"] = "R"
L["QUEST_SUFFIX_PVP"] = "J"
L["QUEST_SUFFIX_GROUP"] = "G"
L["QUEST_SUFFIX_ELITE"] = "E"
L["QUEST_ID"] = "ID %d"
L["RESIZE_TOOLTIP"] = "Arraste para redimensionar o registro de missões"

--------------------------------------------------------------------------------
-- Questie Tracking
--------------------------------------------------------------------------------

L["QUESTIE_CANNOT_SHOW"] =
	"O rastreador do Questie não consegue mostrar %s porque a missão não está no banco de dados do Questie."
L["QUESTIE_CANNOT_TRACK"] = "O Questie ainda não consegue acompanhar esta missão"
