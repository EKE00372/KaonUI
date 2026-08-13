local _, ns = ...
local _, F = unpack(ns)

local format = string.format
local SetCVar = C_CVar.SetCVar

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

local eventFrame = CreateFrame("Frame")
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

-- 字型描邊
local function SetOutline(fontObject, size)
	if not fontObject then return end

	local fontFile, fontSize = fontObject:GetFont()
	fontObject:SetFont(fontFile, size or fontSize, "OUTLINE")
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

-- 只接收 frame，不讀取原始錨點參數
hooksecurefunc(ChatFrame1, "SetPoint", SetChatFrame)

-- 側載聊天框套用外觀設定
local function StyleChatFrame(frame)
	-- ChatFrame2 (戰鬥紀錄) 保留原生外觀
	if frame == ChatFrame2 then return end

	-- 套用外觀
	local frameName = frame and frame:GetName()
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
	editBox:ClearAllPoints()
	editBox:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 4, 32)
	editBox:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -40, 56)
	editBox:DisableDrawLayer("BACKGROUND")
	editBox:DisableDrawLayer("BORDER")
	if not editBox.kaonBorder then
		editBox.kaonBorder = F.CreateBD(editBox, editBox, 2, 0, 0, 0, .6, 1)
	end

	local languageButton = _G[editBox:GetName() .. "Language"]
	languageButton:GetNormalTexture():SetAlpha(0)
	languageButton:ClearAllPoints()
	languageButton:SetPoint("LEFT", editBox, "RIGHT", 5, 0)
	languageButton:SetSize(24, 24)
	if not languageButton.kaonBorder then
		languageButton.kaonBorder = F.CreateBD(languageButton, languageButton, 2, 0, 0, 0, .6, 1)
	end

	SetOutline(editBox, CHAT_FONT_SIZE)
	SetOutline(editBox.header, CHAT_FONT_SIZE)
	SetOutline(editBox.headerSuffix, CHAT_FONT_SIZE)
	SetOutline(editBox.languageHeader, CHAT_FONT_SIZE)
	SetOutline(editBox.NewcomerHint, CHAT_FONT_SIZE)
	SetOutline(editBox.prompt, CHAT_FONT_SIZE)

	-- 分頁標籤
	local tab = _G[frameName .. "Tab"]
	if tab and tab.Text then
		SetOutline(tab.Text)
	end
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

eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:SetScript("OnEvent", ApplyChatStyle)

-- 動態建立的臨時框需要補套外觀
hooksecurefunc("FCF_OpenTemporaryWindow", ApplyChatStyle)

-----------------
-- 手動載入設定 --
-----------------

-- 手動重建分頁時先清空原有設定，再加入指定選項
local function SetChatFrameMessageGroups(frame, groups)
	frame:RemoveAllChannels()
	frame:RemoveAllMessageGroups()

	for _, group in ipairs(groups) do
		frame:AddMessageGroup(group)
	end
end

-- 載入設定
local function SetChatCfg()
	if InCombatLockdown() then return end

	-- ChatFrame3 (語音) 要先關閉下列 CVAR 才能關閉
	SetCVar("speechToText", 0)
	SetCVar("remoteTextToSpeech", 0)
	-- 重置
	FCF_ResetChatWindows()

	local generalFrame = ChatFrame1
	local tradeFrame = FCF_OpenNewWindow(TRADE, true)
	local whisperFrame = FCF_OpenNewWindow(CHAT, true)
	local lootFrame = FCF_OpenNewWindow(LOOT, true)

	for _, frame in ipairs({generalFrame, ChatFrame2, tradeFrame, whisperFrame, lootFrame}) do
		FCF_SetLocked(frame, true)
	end

	-- [[ GENERAL ]] --
	SetChatFrameMessageGroups(generalFrame, {
		-- 玩家對話
		"SAY", "EMOTE", "YELL", "WHISPER", "BN_WHISPER",
		"GUILD", "OFFICER", "GUILD_DISCORD",
		"GUILD_ACHIEVEMENT", "ACHIEVEMENT",
		"PARTY", "PARTY_LEADER", "RAID", "RAID_LEADER", "RAID_WARNING",
		"INSTANCE_CHAT", "INSTANCE_CHAT_LEADER",
		-- PVP
		"BG_HORDE", "BG_ALLIANCE", "BG_NEUTRAL",
		-- 其他
		"SYSTEM", "ERRORS", "IGNORED", "CHANNEL", "TARGETICONS",
		"BN_INLINE_TOAST_ALERT", "PET_BATTLE_INFO", "PING",
		-- 怪物訊息
		"MONSTER_SAY", "MONSTER_EMOTE", "MONSTER_YELL",
		"MONSTER_WHISPER", "MONSTER_BOSS_EMOTE", "MONSTER_BOSS_WHISPER",
		-- 戰鬥
		"COMBAT_XP_GAIN", "COMBAT_HONOR_GAIN", "COMBAT_FACTION_CHANGE", "COMBAT_MISC_INFO",
		"SKILL", "LOOT", "CURRENCY", "MONEY",
	})
	generalFrame:AddChannel(GENERAL)

	-- [[ TRADE ]] --
	SetChatFrameMessageGroups(tradeFrame, {})
	tradeFrame:AddChannel(C_ChatInfo.GetChannelShortcutForChannelID(2))  -- 交易
	tradeFrame:AddChannel(C_ChatInfo.GetChannelShortcutForChannelID(42)) -- 交易（服務）
	tradeFrame:AddChannel(C_ChatInfo.GetChannelShortcutForChannelID(22)) -- 本地防務

	-- [[ LOOT ]] --
	SetChatFrameMessageGroups(lootFrame, {
		-- 經驗，榮譽，聲望
		"COMBAT_XP_GAIN", "COMBAT_HONOR_GAIN", "COMBAT_FACTION_CHANGE",
		-- 專業技能，製造與開啟，戰利品拾取，貨幣，金錢
		"SKILL", "TRADESKILLS", "OPENING", "LOOT", "CURRENCY", "MONEY",
	})

	-- [[ MSG ]] --
	SetChatFrameMessageGroups(whisperFrame, {
		-- 密語，戰網密語，系統，忽略
		"WHISPER", "BN_WHISPER", "SYSTEM", "IGNORED",
	})

	-- [[ 職業染色 ]] --
	local classColorGroups = {
		"SAY", "EMOTE", "YELL", "GUILD", "OFFICER", "GUILD_DISCORD",
		"GUILD_ACHIEVEMENT", "ACHIEVEMENT", "WHISPER",
		"PARTY", "PARTY_LEADER", "RAID", "RAID_LEADER", "RAID_WARNING",
		"INSTANCE_CHAT", "INSTANCE_CHAT_LEADER", "COMMUNITIES_CHANNEL", "VOICE_TEXT",
	}

	for _, group in ipairs(classColorGroups) do
		ToggleChatColorNamesByClassGroup(true, group)
	end

	for i = 1, Constants.ChatFrameConstants.MaxChatChannels do
		ToggleChatColorNamesByClassGroup(true, format("CHANNEL%d", i))
	end

	-- [[ 頻道染色 ]] --
	ChangeChatColor("CHANNEL1", 1.00, 0.75, 0.75) -- 1 綜合（預設顏色）
	ChangeChatColor("CHANNEL2", 1.00, 0.51, 0.51) -- 2 交易（橙紅色）
	ChangeChatColor("CHANNEL3", 1.00, 0.75, 0.75) -- 3 本地防務（預設顏色）
	ChangeChatColor("CHANNEL4", 0.59, 1.00, 0.73) -- 4 私人頻道（淺綠色）
	ChangeChatColor("CHANNEL5", 1.00, 1.00, 0.59) -- 5 私人頻道（米黃色）
	ChangeChatColor("CHANNEL6", 0.71, 0.78, 0.78) -- 6 私人頻道（藍灰色）
	ChangeChatColor("CHANNEL7", 0.76, 0.71, 0.88) -- 7 私人頻道（淡紫色）
	ChangeChatColor("CHANNEL8", 0.59, 0.78, 0.59) -- 8 私人頻道（綠色）

	-- FCF_OpenNewWindow 會選取新分頁，設定完成後切回主分頁
	FCF_SelectDockFrame(generalFrame)
	ReloadUI()
end

SlashCmdList["SETCHAT"] = SetChatCfg
SLASH_SETCHAT1 = "/setchat"
