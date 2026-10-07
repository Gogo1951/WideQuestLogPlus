local _, ns = ...

-- The window's height and point live in global with no default: Reset Profile must not move or resize it.
ns.DATABASE_DEFAULTS = {
	profile = {
		showWelcome = true,
		enableWideQuestLog = true,
		zoneGap = false,
		markUntracked = false,
		zoneSort = "ALPHABETICAL",
		questSort = "LEVEL_LOWEST_FIRST",
	},
	global = {},
}
