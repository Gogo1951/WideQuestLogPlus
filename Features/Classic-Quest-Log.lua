local _, ns = ...

-- Classic Era and TBC: widens Blizzard's own quest log window into the shared two-pane layout (ns.LAYOUT).

local LAYOUT = ns.LAYOUT
local BASE_WIDTH, BASE_HEIGHT = LAYOUT.BASE_WIDTH, LAYOUT.BASE_HEIGHT
local BOTTOM_CLAMP = 140 + 12 -- Blizzard's: keeps the bottom of the window clear of the action bars
local rowHeight = ns.GetQuestRowHeight()

-- Hooks only; the few writes Blizzard's code sees are unprotected on these clients (README-Technical: Taint).

--[[
	ElvUI's skin can't know about this add-on's replacement art, so when ElvUI is loaded, hide Blizzard's
	art but don't draw any parchment of our own
]]
local hideParchment = C_AddOns.IsAddOnLoaded("ElvUI")

local function SetPanelAttribute(name, value)
	if SetUIPanelAttribute then
		SetUIPanelAttribute(QuestLogFrame, name, value)
	end
end

--------------------------------------------------------------------------------
-- Window
--------------------------------------------------------------------------------

QuestLogFrame:SetWidth(BASE_WIDTH)
SetPanelAttribute("width", BASE_WIDTH)

QuestLogTitleText:ClearAllPoints()
QuestLogTitleText:SetPoint("TOP", QuestLogFrame, "TOP", 0, -17)

--[[
	Which piece of Blizzard's art a texture is, if it's one of pieces (fileDataID -> name). On current
	clients XML textures resolve to fileDataIDs and GetTextureFilePath() returns nil, so the ID comes
	first, with the file name (prefix .. name) as a fallback
]]
local function IdentifyBlizzardArt(region, pieces, prefix)
	local fileID = region.GetTextureFileID and region:GetTextureFileID()
	if fileID and pieces[fileID] then
		return pieces[fileID]
	end
	local path = region.GetTextureFilePath and region:GetTextureFilePath() or region:GetTexture()
	if type(path) == "string" then
		for _, name in pairs(pieces) do
			if strlower(path) == strlower(prefix .. name) then
				return name
			end
		end
	end
end

-- Interface\QuestFrame\UI-QuestLog-<TopLeft|TopRight|BotLeft|BotRight>, replaced by the shared art
local QUEST_LOG_ART = {
	[136798] = "BotLeft",
	[136799] = "BotRight",
	[136804] = "TopLeft",
	[136805] = "TopRight",
}
for _, region in ipairs({ QuestLogFrame:GetRegions() }) do
	if
		region:IsObjectType("Texture")
		and IdentifyBlizzardArt(region, QUEST_LOG_ART, "Interface\\QuestFrame\\UI-QuestLog-")
	then
		region:SetTexture(nil)
		region:SetAlpha(0)
	end
end
local LayoutArt = (not hideParchment) and ns.CreateWindowArt(QuestLogFrame, 1)

--[[
	Some of the bottom row of buttons are pinned to the window's top edge; re-hang them off the bottom
	edge so they follow it when the window is dragged taller
]]
for _, child in ipairs({ QuestLogFrame:GetChildren() }) do
	for i = 1, child:GetNumPoints() do
		local point, relativeTo, relativePoint, x, y = child:GetPoint(i)
		local anchoredToWindow = (relativeTo == QuestLogFrame or relativeTo == nil)
		local anchoredToTop = relativePoint and relativePoint:find("^TOP")
		local nearTheBottom = y and y < -(BASE_HEIGHT * 0.6)
		if anchoredToWindow and anchoredToTop and nearTheBottom then
			child:SetPoint(point, relativeTo, (relativePoint:gsub("^TOP", "BOTTOM")), x, y + BASE_HEIGHT)
		end
	end
end

--------------------------------------------------------------------------------
-- Resizing
--------------------------------------------------------------------------------

--[[
	Height the window may take out of the space the panel manager keeps below it. The default window
	stops well above the action bars; dragging it taller trades that away a pixel at a time, which is
	the only way there's meaningful room to grow at a normal UI scale
]]
local function BottomClamp(height)
	return math.max(LAYOUT.MINIMUM_BOTTOM_CLAMP, BOTTOM_CLAMP - (height - BASE_HEIGHT))
end

-- The "no active quests" parchment, laid over the detail pane at whatever size it is
local EMPTY_ART = {
	[136800] = "BotLeft",
	[136801] = "BotRight",
	[136802] = "TopLeft",
	[136803] = "TopRight",
}
local EMPTY_TOP_CROP, EMPTY_BOTTOM_CROP = 0.37, 0.83
local EMPTY_TOP_HEIGHT = 256 * (1 - EMPTY_TOP_CROP)
local EMPTY_BOTTOM_HEIGHT = 128 * EMPTY_BOTTOM_CROP
local EMPTY_WIDTH, EMPTY_HEIGHT = 256 + 64, EMPTY_TOP_HEIGHT + EMPTY_BOTTOM_HEIGHT
local EMPTY_PIECES = { -- Size and position within the whole picture, and the part of the texture shown
	TopLeft = { 256, EMPTY_TOP_HEIGHT, 0, 0, EMPTY_TOP_CROP, 1 },
	TopRight = { 64, EMPTY_TOP_HEIGHT, 256, 0, EMPTY_TOP_CROP, 1 },
	BotLeft = { 256, EMPTY_BOTTOM_HEIGHT, 0, -EMPTY_TOP_HEIGHT, 0, EMPTY_BOTTOM_CROP },
	BotRight = { 64, EMPTY_BOTTOM_HEIGHT, 256, -EMPTY_TOP_HEIGHT, 0, EMPTY_BOTTOM_CROP },
}

local function LayoutEmptyArt()
	local scaleX = (QuestLogDetailScrollFrame:GetWidth() + 26) / EMPTY_WIDTH
	local scaleY = (QuestLogDetailScrollFrame:GetHeight() + 8) / EMPTY_HEIGHT
	for _, region in ipairs({ EmptyQuestLogFrame:GetRegions() }) do
		local piece = region:IsObjectType("Texture")
			and IdentifyBlizzardArt(region, EMPTY_ART, "Interface\\QuestFrame\\UI-QuestLog-Empty-")
		local placement = piece and EMPTY_PIECES[piece]
		if piece and hideParchment then
			region:Hide()
		elseif placement then
			local width, height, x, y, top, bottom = unpack(placement)
			region:SetTexCoord(0, 1, top, bottom)
			region:SetSize(width * scaleX, height * scaleY)
			region:ClearAllPoints()
			region:SetPoint("TOPLEFT", QuestLogDetailScrollFrame, "TOPLEFT", x * scaleX - 10, y * scaleY + 8)
		end
	end
end

local currentHeight

-- Resizes the window and everything inside it that has to follow the bottom edge
local function ApplyHeight(height)
	height = ns.ClampHeight(QuestLogFrame, height or BASE_HEIGHT, rowHeight)
	if height == currentHeight then
		return
	end
	currentHeight = height

	QuestLogFrame:SetHeight(height)

	--[[
		Keep the panel manager's idea of the window in step, or it scales the whole window down to fit
		the space it thinks the window still needs
	]]
	SetPanelAttribute("height", height)
	SetPanelAttribute("bottomClampOverride", BottomClamp(height))

	local paneHeight = height - LAYOUT.PANE_INSET
	QuestLogListScrollFrame:SetHeight(paneHeight)
	QuestLogDetailScrollFrame:SetHeight(paneHeight)

	if LayoutArt then
		LayoutArt(height)
	end
	LayoutEmptyArt()

	if ns.SetQuestRowCount(math.floor(paneHeight / rowHeight)) and QuestLogFrame:IsShown() then
		QuestLog_Update()
	end
end

local grip = ns.CreateResizeGrip(QuestLogFrame, ApplyHeight, function()
	return currentHeight
end)

--[[
	ElvUI draws the window as a backdrop inset from the frame's own edges, so follow that corner when
	it exists rather than the frame's, which sits outside the visible window
]]
local function AnchorGrip()
	if QuestLogFrame.backdrop then
		grip:ClearAllPoints()
		grip:SetPoint("BOTTOMRIGHT", QuestLogFrame.backdrop, "BOTTOMRIGHT", -2, 2)
	end
end

ApplyHeight(BASE_HEIGHT)

--------------------------------------------------------------------------------
-- Hooks
--------------------------------------------------------------------------------

QuestLogFrame:HookScript("OnHide", function()
	ns.ResetZoneOrder() -- Sorted afresh next time the window opens
end)

--[[
	The saved height is applied every time the window opens rather than when it loads, because the
	screen size and UI scale aren't settled then and the clamp to the screen would cut it short. The
	saved value is left alone, so a smaller screen only shrinks the window, not the setting
]]
QuestLogFrame:HookScript("OnShow", function()
	AnchorGrip()
	local height = ns.db.global.height or currentHeight
	currentHeight = nil
	ApplyHeight(height)
end)

--------------------------------------------------------------------------------
-- Options
--------------------------------------------------------------------------------

function ns.ResetWindow()
	ns.db.global.height = nil
	currentHeight = nil
	ApplyHeight(BASE_HEIGHT)
end

-- After a settings change: zones re-sort rather than keeping the order the window opened with
function ns.RefreshQuestLog()
	ns.ResetZoneOrder()
	if QuestLogFrame:IsShown() then
		QuestLog_Update()
	end
end
