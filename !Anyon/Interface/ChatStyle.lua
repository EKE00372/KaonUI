local _, ns = ...
local F = ns[2]
local M = F.RegisterModule("ChatStyle", "SetChat")

local issecretvalue = issecretvalue

local CHAT_FONT = STANDARD_TEXT_FONT
local CHAT_FONT_SIZE = 18
local CHAT_WIDTH = 440
local CHAT_HEIGHT = 220

local globalControls = {
	"ChatFrameMenuButton",
	"ChatFrameChannelButton",
	"ChatFrameToggleVoiceDeafenButton",
	"ChatFrameToggleVoiceMuteButton",
	"TextToSpeechButtonFrame",
	"QuickJoinToastButton",
}

local eventFrame
local settingChat	-- 為跨函數讀取宣告一個初始值為nil的local讓函數用以保存狀態
local hiddenObjects = setmetatable({}, {__mode = "k"})	-- 記住已處理物件以免重覆 hook

-- 延遲更新
local function DelayApply()
	if not InCombatLockdown() then return false end
	eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
	return true
end

-- 隱藏雜七雜八按鈕
local function KeepHidden(object)
	if not object then return end
	if not DelayApply() then object:Hide() end

	if hiddenObjects[object] then return end

	hiddenObjects[object] = true
	hooksecurefunc(object, "Show", KeepHidden)
	hooksecurefunc(object, "SetShown", KeepHidden)
end

-- 邊框材質，不用 backdroptemplete
local function CreateChatBorder(parent)
	local border = CreateFrame("Frame", nil, parent)
	local frameLevel = parent:GetFrameLevel()
	border:SetFrameLevel(frameLevel > 2 and frameLevel - 2 or 0)
	border:SetPoint("TOPLEFT", parent, "TOPLEFT", -2, 2)
	border:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 2, -2)

	local background = border:CreateTexture(nil, "BACKGROUND")
	background:SetColorTexture(0, 0, 0, .6)
	background:SetPoint("TOPLEFT", parent, "TOPLEFT")
	background:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT")

	local top = border:CreateTexture(nil, "BORDER")
	top:SetPoint("TOPLEFT")
	top:SetPoint("TOPRIGHT")
	top:SetHeight(2)

	local bottom = border:CreateTexture(nil, "BORDER")
	bottom:SetPoint("BOTTOMLEFT")
	bottom:SetPoint("BOTTOMRIGHT")
	bottom:SetHeight(2)

	local left = border:CreateTexture(nil, "BORDER")
	left:SetPoint("TOPLEFT")
	left:SetPoint("BOTTOMLEFT")
	left:SetWidth(2)

	local right = border:CreateTexture(nil, "BORDER")
	right:SetPoint("TOPRIGHT")
	right:SetPoint("BOTTOMRIGHT")
	right:SetWidth(2)

	for _, edge in ipairs({top, bottom, left, right}) do
		edge:SetColorTexture(0, 0, 0, 1)
	end

	return border
end

-- 固定字型並加描邊
local function SetOutline(fontObject, size)
	if not size then
		local _, fontSize = fontObject:GetFont()
		if issecretvalue(fontSize) then return end
		size = fontSize
	end

	fontObject:SetFont(CHAT_FONT, size, "OUTLINE")
	fontObject:SetShadowColor(0, 0, 0, 0)
end

-- 固定主聊天框
local function SetChatFrame(frame)
	if settingChat then return end
	if DelayApply() then return end

	settingChat = true

	frame:SetUserPlaced(true)
	frame:SetClampRectInsets(0, 0, 0, 0)
	frame:SetClampedToScreen(false)
	frame:ClearAllPoints()
	frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 10, 10)
	frame:SetWidth(CHAT_WIDTH)
	frame:SetHeight(CHAT_HEIGHT)

	settingChat = false
end

-- 設定外觀
local function StyleChatFrame(frame)
	-- ChatFrame2 (戰鬥紀錄) 保留原生外觀
	if frame == ChatFrame2 then return end

	-- 套用外觀
	local frameName = frame:GetName()
	SetOutline(frame)
	if frame == ChatFrame1 then SetChatFrame(frame) end
	-- 停用原生背景與邊框
	frame:DisableDrawLayer("BACKGROUND")
	frame:DisableDrawLayer("BORDER")
	-- 隱藏其他按鈕
	KeepHidden(frame.buttonFrame)
	KeepHidden(frame.ResizeButton)
	KeepHidden(frame.ScrollBar)
	KeepHidden(frame.ScrollToBottomButton)

	-- 輸入框
	local editBox = frame.editBox
	editBox:SetAltArrowKeyMode(false)
	editBox:ClearAllPoints()
	editBox:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 4, 32)
	editBox:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -40, 56)
	editBox:DisableDrawLayer("BACKGROUND")
	editBox:DisableDrawLayer("BORDER")
	if not editBox.kaonBorder then
		editBox.kaonBorder = CreateChatBorder(editBox)
	end

	local languageButton = _G[editBox:GetName() .. "Language"]
	languageButton:GetNormalTexture():SetAlpha(0)
	languageButton:ClearAllPoints()
	languageButton:SetPoint("LEFT", editBox, "RIGHT", 5, 0)
	languageButton:SetSize(24, 24)
	if not languageButton.kaonBorder then
		languageButton.kaonBorder = CreateChatBorder(languageButton)
	end

	SetOutline(editBox, CHAT_FONT_SIZE)
	SetOutline(editBox.header, CHAT_FONT_SIZE)
	SetOutline(editBox.headerSuffix, CHAT_FONT_SIZE)
	SetOutline(editBox.languageHeader, CHAT_FONT_SIZE)
	SetOutline(editBox.NewcomerHint, CHAT_FONT_SIZE)
	SetOutline(editBox.prompt, CHAT_FONT_SIZE)

	-- 分頁標籤
	local tab = _G[frameName .. "Tab"]
	SetOutline(tab.Text)
end

-- 套用所有聊天框外觀
local function ApplyChatStyle()
	if DelayApply() then return end

	for _, frameName in ipairs(CHAT_FRAMES) do
		local frame = _G[frameName]
		if frame then
			StyleChatFrame(frame)
		end
	end

	for _, name in ipairs(globalControls) do
		KeepHidden(_G[name])
	end

	eventFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
end

function M:OnEnable()
	eventFrame = CreateFrame("Frame")
	eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	eventFrame:SetScript("OnEvent", ApplyChatStyle)

	hooksecurefunc(ChatFrame1, "SetPoint", SetChatFrame)
	hooksecurefunc("FCF_OpenTemporaryWindow", ApplyChatStyle) -- 側載聊天框套用外觀設定
end
