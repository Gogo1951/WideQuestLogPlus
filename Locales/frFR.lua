local L = LibStub("AceLocale-3.0"):NewLocale("WideQuestLogPlus", "frFR")
if not L then
	return
end

--------------------------------------------------------------------------------
-- Add-on
--------------------------------------------------------------------------------

L["ADDON_TITLE"] = "Wide Quest Log Plus"
L["CHAT_LOADED"] =
	"Version %s. Les paramètres (y compris l'option pour désactiver ce message) se trouvent dans Options > AddOns > Wide Quest Log Plus. L'add-on vous plaît ? Parlez-en à un ami ! (="
L["CHAT_OPTIONS_IN_COMBAT"] = "Par mesure de sécurité, l'interface des options ne peut pas être ouverte en combat."

--------------------------------------------------------------------------------
-- Options
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"Journal de quêtes large à deux volets, avec niveaux de quête, marqueurs de donjon, de raid et d'élite, et ID de quête. Voyez toute votre liste de quêtes et les détails de chaque quête à la fois, triés à votre façon. Un journal de quêtes plus grand qui garde le style de Blizzard."
L["ENABLE_WELCOME_MESSAGE"] = "Activer le message de bienvenue"
L["ENABLE_WELCOME_MESSAGE_DESCRIPTION"] = "Affiche le message d'accueil de Wide Quest Log Plus à la connexion."
L["ENABLE_WIDE_QUEST_LOG"] = "Activer le journal de quêtes large pour ce profil"
L["ENABLE_WIDE_QUEST_LOG_DESCRIPTION"] =
	"Fait en sorte que la touche du journal de quêtes, le bouton du micro-menu et les clics sur les quêtes du suivi des objectifs ouvrent ce journal de quêtes large. Désactivez-le pour utiliser à la place le journal de quêtes par défaut de Blizzard, intégré à la carte du monde. Prend effet après un rechargement."
L["RELOAD_PROMPT"] = "Wide Quest Log Plus change de journal de quêtes après un rechargement. Recharger maintenant ?"
L["ZONE_ORDER"] = "Ordre des zones"
L["ZONE_ORDER_DESCRIPTION"] = "Change l'ordre des zones dans la liste des quêtes."
L["SORT_ALPHABETICAL_DEFAULT"] = "Alphabétique (par défaut)"
L["SORT_AVERAGE_LEVEL_HIGHEST"] = "Niveau moyen, le plus haut d'abord"
L["SORT_AVERAGE_LEVEL_LOWEST"] = "Niveau moyen, le plus bas d'abord"
L["ZONE_GAP"] = "Espace au-dessus des noms de zone"
L["ZONE_GAP_DESCRIPTION"] =
	"Ajoute une ligne vide au-dessus de chaque nom de zone. Pratique si vos quêtes sont réparties sur de nombreuses zones."
L["QUEST_ORDER"] = "Ordre des quêtes"
L["QUEST_ORDER_DESCRIPTION"] = "Change l'ordre des quêtes sous chaque zone."
L["SORT_LEVEL_LOWEST_DEFAULT"] = "Niveau, le plus bas d'abord (par défaut)"
L["SORT_LEVEL_HIGHEST"] = "Niveau, le plus haut d'abord"
L["SORT_ALPHABETICAL"] = "Alphabétique"
L["MARK_UNTRACKED"] = "Marquer les quêtes non suivies"
L["MARK_UNTRACKED_DESCRIPTION"] =
	"Les quêtes suivies perdent leur coche %s, et les quêtes non suivies ont un œil %s à la place. Pratique si vous suivez presque tout."
L["RESET_WINDOW"] = "Réinitialiser la taille et la position"
L["RESET_WINDOW_DESCRIPTION"] = "Remet le journal de quêtes à sa taille et à sa position par défaut."
L["RESET_WINDOW_CONFIRM"] = "Remettre le journal de quêtes à sa taille et à sa position par défaut ?"
L["OPTIONS_COMMANDS_HEADER"] = "/Commandes"
L["OPTIONS_COMMAND"] = "/wide"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Ouvre l'interface des options de cet add-on."
L["FEEDBACK_HEADER"] = "Commentaires et assistance"
L["FEEDBACK_GITHUB"] = "GitHub"
L["FEEDBACK_CURSEFORGE"] = "CurseForge"
L["OPTIONS_VERSION"] = "Version %s"

--------------------------------------------------------------------------------
-- Quest List and Details
--------------------------------------------------------------------------------

L["QUEST_SUFFIX_DUNGEON"] = "D"
L["QUEST_SUFFIX_RAID"] = "R"
L["QUEST_SUFFIX_PVP"] = "J"
L["QUEST_SUFFIX_GROUP"] = "G"
L["QUEST_SUFFIX_ELITE"] = "E"
L["QUEST_ID"] = "ID %d"
L["RESIZE_TOOLTIP"] = "Faites glisser pour redimensionner le journal de quêtes"

--------------------------------------------------------------------------------
-- Questie Tracking
--------------------------------------------------------------------------------

L["QUESTIE_CANNOT_SHOW"] =
	"Le suivi de Questie ne peut pas afficher %s, car la quête est absente de la base de données de Questie."
L["QUESTIE_CANNOT_TRACK"] = "Questie ne peut pas encore suivre cette quête"
