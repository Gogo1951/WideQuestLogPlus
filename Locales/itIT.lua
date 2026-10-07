local L = LibStub("AceLocale-3.0"):NewLocale("WideQuestLogPlus", "itIT")
if not L then
	return
end

--------------------------------------------------------------------------------
-- Add-on
--------------------------------------------------------------------------------

L["ADDON_TITLE"] = "Wide Quest Log Plus"
L["CHAT_LOADED"] =
	"Versione %s. Le impostazioni (inclusa l'opzione per disattivare questo messaggio) si trovano in Opzioni > AddOn > Wide Quest Log Plus. Ti piace l'add-on? Parlane a un amico! (="
L["CHAT_OPTIONS_IN_COMBAT"] =
	"Per precauzione, l'interfaccia delle opzioni non può essere aperta durante il combattimento."

--------------------------------------------------------------------------------
-- Options
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"Registro delle missioni largo a doppio pannello, con livelli delle missioni, etichette per spedizioni, incursioni ed élite, e ID delle missioni. Vedi tutto l'elenco delle missioni e i dettagli di ognuna insieme, ordinati come preferisci. Un registro delle missioni più grande che mantiene lo stile Blizzard."
L["ENABLE_WELCOME_MESSAGE"] = "Attiva messaggio di benvenuto"
L["ENABLE_WELCOME_MESSAGE_DESCRIPTION"] = "Mostra il saluto di Wide Quest Log Plus quando accedi."
L["ENABLE_WIDE_QUEST_LOG"] = "Attiva il registro delle missioni largo per questo profilo"
L["ENABLE_WIDE_QUEST_LOG_DESCRIPTION"] =
	"Fa sì che il tasto del registro delle missioni, il pulsante del micromenu e i clic sulle missioni nel tracciamento degli obiettivi aprano questo registro delle missioni largo. Disattivalo per usare invece il registro delle missioni predefinito di Blizzard, integrato nella mappa del mondo. Ha effetto dopo un ricaricamento."
L["RELOAD_PROMPT"] = "Wide Quest Log Plus cambia registro delle missioni dopo un ricaricamento. Ricaricare ora?"
L["ZONE_ORDER"] = "Ordine delle zone"
L["ZONE_ORDER_DESCRIPTION"] = "Cambia l'ordine delle zone nell'elenco delle missioni."
L["SORT_ALPHABETICAL_DEFAULT"] = "Alfabetico (predefinito)"
L["SORT_AVERAGE_LEVEL_HIGHEST"] = "Livello medio, prima il più alto"
L["SORT_AVERAGE_LEVEL_LOWEST"] = "Livello medio, prima il più basso"
L["ZONE_GAP"] = "Spazio sopra i nomi delle zone"
L["ZONE_GAP_DESCRIPTION"] =
	"Aggiunge una riga vuota sopra ogni nome di zona. Utile se le tue missioni sono sparse in molte zone."
L["QUEST_ORDER"] = "Ordine delle missioni"
L["QUEST_ORDER_DESCRIPTION"] = "Cambia l'ordine delle missioni sotto ogni zona."
L["SORT_LEVEL_LOWEST_DEFAULT"] = "Livello, prima il più basso (predefinito)"
L["SORT_LEVEL_HIGHEST"] = "Livello, prima il più alto"
L["SORT_ALPHABETICAL"] = "Alfabetico"
L["MARK_UNTRACKED"] = "Segna le missioni non seguite"
L["MARK_UNTRACKED_DESCRIPTION"] =
	"Le missioni seguite perdono la spunta %s e quelle non seguite hanno invece un occhio %s. Utile se segui quasi tutto."
L["RESET_WINDOW"] = "Ripristina dimensioni e posizione"
L["RESET_WINDOW_DESCRIPTION"] = "Riporta il registro delle missioni alle dimensioni e alla posizione predefinite."
L["RESET_WINDOW_CONFIRM"] = "Ripristinare le dimensioni e la posizione predefinite del registro delle missioni?"
L["OPTIONS_COMMANDS_HEADER"] = "/Comandi"
L["OPTIONS_COMMAND"] = "/wide"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Apre l'interfaccia delle opzioni di questo add-on."
L["FEEDBACK_HEADER"] = "Feedback e supporto"
L["FEEDBACK_GITHUB"] = "GitHub"
L["FEEDBACK_CURSEFORGE"] = "CurseForge"
L["OPTIONS_VERSION"] = "Versione %s"

--------------------------------------------------------------------------------
-- Quest List and Details
--------------------------------------------------------------------------------

L["QUEST_SUFFIX_DUNGEON"] = "S"
L["QUEST_SUFFIX_RAID"] = "I"
L["QUEST_SUFFIX_PVP"] = "P"
L["QUEST_SUFFIX_GROUP"] = "G"
L["QUEST_SUFFIX_ELITE"] = "E"
L["QUEST_ID"] = "ID %d"
L["RESIZE_TOOLTIP"] = "Trascina per ridimensionare il registro delle missioni"

--------------------------------------------------------------------------------
-- Questie Tracking
--------------------------------------------------------------------------------

L["QUESTIE_CANNOT_SHOW"] =
	"Il tracker di Questie non può mostrare %s perché la missione manca dal database di Questie."
L["QUESTIE_CANNOT_TRACK"] = "Questie non può ancora seguire questa missione"
