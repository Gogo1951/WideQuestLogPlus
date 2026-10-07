local L = LibStub("AceLocale-3.0"):NewLocale("WideQuestLogPlus", "esMX")
if not L then
	return
end

--------------------------------------------------------------------------------
-- Add-on
--------------------------------------------------------------------------------

L["ADDON_TITLE"] = "Wide Quest Log Plus"
L["CHAT_LOADED"] =
	"Versión %s. Puedes encontrar la configuración (incluida la opción para desactivar este mensaje) en Opciones > Accesorios > Wide Quest Log Plus. ¿Te gusta el accesorio? ¡Cuéntale a un amigo! (="
L["CHAT_OPTIONS_IN_COMBAT"] = "Por seguridad, la interfaz de opciones no se puede abrir durante el combate."

--------------------------------------------------------------------------------
-- Options
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"Registro de misiones ancho y de doble panel con niveles de misión, etiquetas de calabozo, banda y élite, e ID de misión. Ve toda tu lista de misiones y los detalles de cada una al mismo tiempo, ordenadas a tu gusto. Un registro de misiones más grande que conserva el estilo de Blizzard."
L["ENABLE_WELCOME_MESSAGE"] = "Activar mensaje de bienvenida"
L["ENABLE_WELCOME_MESSAGE_DESCRIPTION"] = "Muestra el saludo de Wide Quest Log Plus al iniciar sesión."
L["ENABLE_WIDE_QUEST_LOG"] = "Activar el registro de misiones ancho para este perfil"
L["ENABLE_WIDE_QUEST_LOG_DESCRIPTION"] =
	"Hace que la tecla del registro de misiones, el botón del micromenú y los clics en misiones del seguimiento de objetivos abran este registro de misiones ancho. Desactívalo para usar en su lugar el registro de misiones predeterminado de Blizzard, integrado en el mapa del mundo. Se aplica después de recargar."
L["RELOAD_PROMPT"] = "Wide Quest Log Plus cambia de registro de misiones después de recargar. ¿Recargar ahora?"
L["ZONE_ORDER"] = "Orden de zonas"
L["ZONE_ORDER_DESCRIPTION"] = "Cambia el orden de las zonas en la lista de misiones."
L["SORT_ALPHABETICAL_DEFAULT"] = "Alfabético (predeterminado)"
L["SORT_AVERAGE_LEVEL_HIGHEST"] = "Nivel promedio, el más alto primero"
L["SORT_AVERAGE_LEVEL_LOWEST"] = "Nivel promedio, el más bajo primero"
L["ZONE_GAP"] = "Espacio sobre los nombres de zona"
L["ZONE_GAP_DESCRIPTION"] =
	"Agrega una línea en blanco sobre cada nombre de zona. Útil si tus misiones están repartidas en muchas zonas."
L["QUEST_ORDER"] = "Orden de misiones"
L["QUEST_ORDER_DESCRIPTION"] = "Cambia el orden de las misiones dentro de cada zona."
L["SORT_LEVEL_LOWEST_DEFAULT"] = "Nivel, el más bajo primero (predeterminado)"
L["SORT_LEVEL_HIGHEST"] = "Nivel, el más alto primero"
L["SORT_ALPHABETICAL"] = "Alfabético"
L["MARK_UNTRACKED"] = "Marcar misiones sin seguir"
L["MARK_UNTRACKED_DESCRIPTION"] =
	"Las misiones seguidas pierden su marca de verificación %s y las misiones sin seguir llevan un ojo %s en su lugar. Útil si sigues casi todo."
L["RESET_WINDOW"] = "Restablecer tamaño y posición"
L["RESET_WINDOW_DESCRIPTION"] = "Regresa el registro de misiones a su tamaño y posición predeterminados."
L["RESET_WINDOW_CONFIRM"] = "¿Restablecer el registro de misiones a su tamaño y posición predeterminados?"
L["OPTIONS_COMMANDS_HEADER"] = "/Comandos"
L["OPTIONS_COMMAND"] = "/wide"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Abre la interfaz de opciones de este accesorio."
L["FEEDBACK_HEADER"] = "Comentarios y soporte"
L["FEEDBACK_GITHUB"] = "GitHub"
L["FEEDBACK_CURSEFORGE"] = "CurseForge"
L["OPTIONS_VERSION"] = "Versión %s"

--------------------------------------------------------------------------------
-- Quest List and Details
--------------------------------------------------------------------------------

L["QUEST_SUFFIX_DUNGEON"] = "C"
L["QUEST_SUFFIX_RAID"] = "B"
L["QUEST_SUFFIX_PVP"] = "J"
L["QUEST_SUFFIX_GROUP"] = "G"
L["QUEST_SUFFIX_ELITE"] = "E"
L["QUEST_ID"] = "ID %d"
L["RESIZE_TOOLTIP"] = "Arrastra para cambiar el tamaño del registro de misiones"

--------------------------------------------------------------------------------
-- Questie Tracking
--------------------------------------------------------------------------------

L["QUESTIE_CANNOT_SHOW"] =
	"El seguimiento de Questie no puede mostrar %s porque la misión no está en la base de datos de Questie."
L["QUESTIE_CANNOT_TRACK"] = "Questie todavía no puede seguir esta misión"
