local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor

--------------------------------------------------------------------------------
-- Messaging
--------------------------------------------------------------------------------

function ns:PrintMessage(message)
	print(
		GetColor("INFO")
			.. L["ADDON_TITLE"]
			.. "|r "
			.. GetColor("SEPARATOR")
			.. "//"
			.. "|r "
			.. GetColor("TEXT")
			.. message
			.. "|r"
	)
end
