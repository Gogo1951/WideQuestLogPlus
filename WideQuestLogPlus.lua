-- Customize the appearance and behavior of the Quest Log window
UIPanelWindows["QuestLogFrame"] = {
	area = "left", -- the modern (11509+) panel manager has no "override" area
	pushable = 0,
	xoffset = -16,
	yoffset = 12,
	bottomClampOverride = 140 + 12,
	width = 724,
	height = 513,
	whileDead = 1
}

-- The panel manager copies UIPanelWindows entries into frame attributes on first use and reads
-- only the attributes afterward, so push the overrides there as well
if (SetUIPanelAttribute) then
	for name, value in pairs(UIPanelWindows["QuestLogFrame"]) do
		SetUIPanelAttribute(QuestLogFrame, name, value)
	end
end

-- Function to customize the appearance and behavior of the wide Quest Log
local function WideQuestLogPlus()
	local function IsAddOnLoadedCompat(addonName)
		if (C_AddOns and C_AddOns.IsAddOnLoaded) then
			return C_AddOns.IsAddOnLoaded(addonName)
		end
		return IsAddOnLoaded(addonName)
	end

	-- Check if VoiceOver is installed and enabled
	local isVoiceOverLoaded = IsAddOnLoadedCompat("AI_VoiceOver")

	-- ElvUI's Parchment Remover can't know about this addon's replacement art, so when ElvUI
	-- is handling the quest log's look, hide the originals but don't draw any parchment of our own
	local hideParchment = IsAddOnLoadedCompat("ElvUI")

	-- Widen the window
	QuestLogFrame:SetWidth(724)
	QuestLogFrame:SetHeight(513)

	-- Adjust quest log title text position
	QuestLogTitleText:ClearAllPoints()
	QuestLogTitleText:SetPoint("TOP", QuestLogFrame, "TOP", 0, -17)

	-- Relocate the quest detail frame
	QuestLogDetailScrollFrame:ClearAllPoints()
	QuestLogDetailScrollFrame:SetPoint("TOPLEFT", QuestLogListScrollFrame, "TOPRIGHT", 41, 0)
	QuestLogDetailScrollFrame:SetHeight(362)

	-- Relocate the "No Active Quests" text
	QuestLogNoQuestsText:ClearAllPoints()
	QuestLogNoQuestsText:SetPoint("TOP", QuestLogListScrollFrame, 0, -90)

	-- Expand the height of the quest list
	QuestLogListScrollFrame:SetHeight(362)

	-- Create additional rows for displaying quests
	local oldQuestsDisplayed = QUESTS_DISPLAYED
	QUESTS_DISPLAYED = QUESTS_DISPLAYED + 17

	-- Hook a script to update the quest titles and recommended levels
	QuestLogFrame:HookScript(
		"OnUpdate",
		function(self)
			local numEntries, numQuests = GetNumQuestLogEntries()

			if (numEntries == 0) then
				return
			end

			local questIndex, questLogTitle, title, level, _, isHeader, questTextFormatted, questCheck
			for i = 1, _G.QUESTS_DISPLAYED, 1 do
				questIndex = i + FauxScrollFrame_GetOffset(QuestLogListScrollFrame)

				if (questIndex <= numEntries) then
					questLogTitle = _G["QuestLogTitle" .. i]
					questCheck = _G["QuestLogTitle" .. i .. "Check"]
					title, level, _, isHeader = GetQuestLogTitle(questIndex)

					if (not isHeader) then
						if isVoiceOverLoaded then -- Adjustment for play button overlap
							questTextFormatted = format("	   [%d] %s", level, title)
						else -- Default spacing
							questTextFormatted = format("[%d] %s", level, title)
						end
						questLogTitle:SetText(questTextFormatted)
						questCheck:SetPoint("LEFT", questLogTitle, "LEFT", questLogTitle.Text:GetStringWidth() + 18, 0)
						questCheck:SetVertexColor(64 / 255, 224 / 255, 208 / 255)
						questCheck:SetDrawLayer("ARTWORK")
					else
						questCheck:Hide()
					end
				end
			end
		end
	)

	-- Add quest ID to quest text
	QuestLogFrame:HookScript(
		"OnUpdate",
		function(self)
			local index = GetQuestLogSelection()
			local title, _, _, _, _, _, _, id = GetQuestLogTitle(index)
			if (not title) then
				title = ""
			else
				title = format("%s [%d]", title, id)
			end
			if (IsCurrentQuestFailed()) then
				title = format("%s - (%s)", title, _G.FAILED)
			end
			QuestLogQuestTitle:SetText(title)
		end
	)

	-- Create additional rows for displaying quests
	for i = oldQuestsDisplayed + 1, QUESTS_DISPLAYED do
		local button = CreateFrame("Button", "QuestLogTitle" .. i, QuestLogFrame, "QuestLogTitleButtonTemplate")
		button:SetID(i)
		button:Hide()
		button:ClearAllPoints()
		button:SetPoint("TOPLEFT", _G["QuestLogTitle" .. (i - 1)], "BOTTOMLEFT", 0, 1)
	end

	-- Handle background textures
	local regions = {QuestLogFrame:GetRegions()}
	local xOffsets = {Left = 3, Middle = 259, Right = 515}
	local yOffsets = {Top = 0, Bot = -256}
	local textures = {
		TopLeft = "Interface\\AddOns\\WideQuestLogPlus\\img\\WQLP_TopLeft",
		TopMiddle = "Interface\\AddOns\\WideQuestLogPlus\\img\\WQLP_TopMid",
		TopRight = "Interface\\AddOns\\WideQuestLogPlus\\img\\WQLP_TopRight",
		BotLeft = "Interface\\AddOns\\WideQuestLogPlus\\img\\WQLP_BotLeft",
		BotMiddle = "Interface\\AddOns\\WideQuestLogPlus\\img\\WQLP_BotMid",
		BotRight = "Interface\\AddOns\\WideQuestLogPlus\\img\\WQLP_BotRight"
	}

	-- On modern clients (Interface 11509/20506+) XML-defined textures resolve to fileDataIDs and
	-- GetTextureFilePath() returns nil for Blizzard's art, so identify it by fileDataID first and
	-- fall back to path matching for older clients
	local function IdentifyBlizzardArt(region, fileIDs, pattern)
		local fileID = region.GetTextureFileID and region:GetTextureFileID()
		if (fileIDs[fileID]) then
			return fileIDs[fileID]
		end
		local path = region.GetTextureFilePath and region:GetTextureFilePath() or region:GetTexture()
		if (type(path) == "string") then
			return path:match(pattern)
		end
	end

	-- fileDataIDs of Interface\QuestFrame\UI-QuestLog-<TopLeft|TopRight|BotLeft|BotRight>
	local questLogArt = {
		[136798] = "BotLeft",
		[136799] = "BotRight",
		[136804] = "TopLeft",
		[136805] = "TopRight"
	}

	local PATTERN = "^Interface\\QuestFrame\\UI%-QuestLog%-(([A-Z][a-z]+)([A-Z][a-z]+))$"
	for _, region in ipairs(regions) do
		if (region:IsObjectType("Texture")) then
			local which = IdentifyBlizzardArt(region, questLogArt, PATTERN)
			local yOfs, xOfs
			if (which) then
				yOfs, xOfs = which:match("^([A-Z][a-z]+)([A-Z][a-z]+)$")
			end
			xOfs = xOfs and xOffsets[xOfs]
			yOfs = yOfs and yOffsets[yOfs]
			if (xOfs and yOfs and textures[which]) then
				-- Attempt to hide the original textures
				region:SetTexture(nil)
				region:SetAlpha(0)

				if (not hideParchment) then
					-- Create and configure a new texture region
					local newRegion = QuestLogFrame:CreateTexture(nil, "ARTWORK")
					newRegion:ClearAllPoints()
					newRegion:SetPoint("TOPLEFT", QuestLogFrame, "TOPLEFT", xOfs, yOfs)
					newRegion:SetWidth(256)
					newRegion:SetHeight(256)
					newRegion:SetTexture(textures[which])
				end

				-- Remove the stored texture reference
				textures[which] = nil
			end
		end
	end

	-- Place the local textures
	if (not hideParchment) then
		for name, path in pairs(textures) do
			local yOfs, xOfs = name:match("^([A-Z][a-z]+)([A-Z][a-z]+)$")
			xOfs = xOfs and xOffsets[xOfs]
			yOfs = yOfs and yOffsets[yOfs]
			if (xOfs and yOfs) then
				local region = QuestLogFrame:CreateTexture(nil, "ARTWORK")
				region:ClearAllPoints()
				region:SetPoint("TOPLEFT", QuestLogFrame, "TOPLEFT", xOfs, yOfs)
				region:SetWidth(256)
				region:SetHeight(256)
				region:SetTexture(path)

				-- Set the draw layer and sublevel for proper layering
				region:SetDrawLayer("ARTWORK", 2) -- Adjust the sublevel as needed to prevent the default UI textures from appearing in front of the new textures we're providing
			end
		end
	end

	-- Handle empty quest log textures
	local topOfs = 0.37
	local topH = 256 * (1 - topOfs)

	local botCap = 0.83
	local botH = 128 * botCap

	local xSize = 256 + 64
	local ySize = topH + botH

	local nxSize = QuestLogDetailScrollFrame:GetWidth() + 26
	local nySize = QuestLogDetailScrollFrame:GetHeight() + 8

	local function relocateEmpty(t, w, h, x, y)
		local nx = x / xSize * nxSize - 10
		local ny = y / ySize * nySize + 8
		local nw = w / xSize * nxSize
		local nh = h / ySize * nySize

		t:SetWidth(nw)
		t:SetHeight(nh)
		t:ClearAllPoints()
		t:SetPoint("TOPLEFT", QuestLogDetailScrollFrame, "TOPLEFT", nx, ny)
	end

	-- fileDataIDs of Interface\QuestFrame\UI-QuestLog-Empty-<piece>
	local emptyArt = {
		[136800] = "BotLeft",
		[136801] = "BotRight",
		[136802] = "TopLeft",
		[136803] = "TopRight"
	}

	-- Loop through and handle empty quest log frame textures
	local txset = {EmptyQuestLogFrame:GetRegions()}
	for _, t in ipairs(txset) do
		if (t:IsObjectType("Texture")) then
			local p = IdentifyBlizzardArt(t, emptyArt, "-([^-]+)$")
			if (p) then
				if (hideParchment) then
					t:Hide()
				elseif (p == "TopLeft") then
					t:SetTexCoord(0, 1, topOfs, 1)
					relocateEmpty(t, 256, topH, 0, 0)
				elseif (p == "TopRight") then
					t:SetTexCoord(0, 1, topOfs, 1)
					relocateEmpty(t, 64, topH, 256, 0)
				elseif (p == "BotLeft") then
					t:SetTexCoord(0, 1, 0, botCap)
					relocateEmpty(t, 256, botH, 0, -topH)
				elseif (p == "BotRight") then
					t:SetTexCoord(0, 1, 0, botCap)
					relocateEmpty(t, 64, botH, 256, -topH)
				else
					t:Hide() -- Hide textures that don't match expected patterns
				end
			end
		end
	end
end

-- Call the functions to customize the Quest Log appearance
WideQuestLogPlus()
