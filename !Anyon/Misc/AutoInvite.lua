local _, ns = ...
local F = ns[2]
local M = F.RegisterModule("AutoInvite", "AutoInvite")

local format, strlower, strmatch = string.format, string.lower, string.match
local type = type

local BNInviteFriend, BNIsSelf, CanCooperateWithGameAccount = BNInviteFriend, BNIsSelf, CanCooperateWithGameAccount
local C_BattleNet_GetAccountInfoByID = C_BattleNet.GetAccountInfoByID
local GuildInvite, InviteToGroup = C_GuildInfo.Invite, C_PartyInfo.InviteUnit

local IsAltKeyDown, IsControlKeyDown, IsModifierKeyDown = IsAltKeyDown, IsControlKeyDown, IsModifierKeyDown
local IsInGroup, UnitIsGroupAssistant, UnitIsGroupLeader = IsInGroup, UnitIsGroupAssistant, UnitIsGroupLeader
local Ambiguate, UnitGUID, UnitInParty, UnitInRaid = Ambiguate, UnitGUID, UnitInParty, UnitInRaid

local ChatEdit_ClearChat, StaticPopup_Show = ChatEdit_ClearChat, StaticPopup_Show
local CreateFrame, hooksecurefunc = CreateFrame, hooksecurefunc
local issecretvalue = issecretvalue or function() return false end

local INVITE_KEYWORDS = {
	["111"] = true,
	["+++"] = true,
	["inv"] = true,
}

local GUILD_INVITE_KEYWORDS = {
	["g++"] = true,
	["ginv"] = true,
	["加公會"] = true,
	["加公会"] = true,
}

-- 戰網暱稱轉換為角色名字
local function GetBattleNetGameAccount(presenceID)
	local accountInfo = presenceID and C_BattleNet_GetAccountInfoByID(presenceID)
	if not accountInfo or not CanCooperateWithGameAccount(accountInfo) then return end

	local gameAccountInfo = accountInfo.gameAccountInfo
	if not gameAccountInfo or not gameAccountInfo.gameAccountID then return end

	return gameAccountInfo
end

-- 公會邀請獲取完整角色名
local function GetBattleNetUnit(gameAccountInfo)
	local charName = gameAccountInfo and gameAccountInfo.characterName
	local realmName = gameAccountInfo and gameAccountInfo.realmName
	if charName and realmName then
		return charName.."-"..realmName
	end
end

-- 只處理純文字
local function GetKeyword(msg)
	if type(msg) ~= "string" then return end
	return strlower(msg)
end

local function IsGroupedUnit(unit)
	return unit and (UnitInRaid(unit) or UnitInParty(unit))
end

-- 公會邀請確認視窗
StaticPopupDialogs["ANYON_GUILD_INVITE"] = {
	text = format(ERR_GUILD_INVITE_S, "%s"),
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(_, unit)
		if unit then
			GuildInvite(unit)
		end
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

-- Alt 組隊邀請，Ctrl 公會邀請
local function OnSetItemRef(link, _, button)
	if button ~= "LeftButton" or not IsModifierKeyDown() then return end

	local linkType, value = strmatch(link, "(%a+):(.+)")
	if not linkType or not value then return end

	local handled
	if linkType == "player" then
		local unit = strmatch(value, "([^:]+)")
		if IsAltKeyDown() then
			InviteToGroup(unit)
			handled = true
		elseif IsControlKeyDown() then
			GuildInvite(unit)
			handled = true
		end
	elseif linkType == "BNplayer" then
		local _, bnID = strmatch(value, "([^:]*):([^:]*):")
		local gameAccountInfo = GetBattleNetGameAccount(tonumber(bnID))
		if gameAccountInfo then
			if IsAltKeyDown() then
				BNInviteFriend(gameAccountInfo.gameAccountID)
				handled = true
			elseif IsControlKeyDown() then
				local unit = GetBattleNetUnit(gameAccountInfo)
				if unit then
					GuildInvite(unit)
					handled = true
				end
			end
		end
	end

	if handled then
		ChatEdit_ClearChat(ChatFrame1.editBox)
	end
end

-- 密語關鍵字組隊邀請
local function InviteByWhisper(event, author, presenceID)
	if IsInGroup() and not UnitIsGroupLeader("player") and not UnitIsGroupAssistant("player") then return end

	if event == "CHAT_MSG_BN_WHISPER" then
		local gameAccountInfo = GetBattleNetGameAccount(presenceID)
		if gameAccountInfo and not IsGroupedUnit(GetBattleNetUnit(gameAccountInfo)) then
			BNInviteFriend(gameAccountInfo.gameAccountID)
		end
	else
		InviteToGroup(author)
	end
end

-- 密語關鍵字公會邀請
local function GuildInviteByWhisper(event, author, presenceID)
	local unit = author
	if event == "CHAT_MSG_BN_WHISPER" then
		unit = GetBattleNetUnit(GetBattleNetGameAccount(presenceID))
	end
	if unit then
		StaticPopup_Show("ANYON_GUILD_INVITE", unit, nil, unit)
	end
end

-- 只接受完全相同的關鍵字
local function OnWhisper(_, event, ...)
	local msg, author, _, _, _, flag, _, _, _, _, _, guid, presenceID = ...
	if issecretvalue(msg) then return end
	if event == "CHAT_MSG_WHISPER" then
		local unit = author and Ambiguate(author, "none")
		if flag == "GM" or flag == "DEV" or IsGroupedUnit(unit) or guid == UnitGUID("player") then return end
	end
	if event == "CHAT_MSG_BN_WHISPER" and BNIsSelf and BNIsSelf(presenceID) then return end

	local keyword = GetKeyword(msg)
	if not keyword then return end

	if INVITE_KEYWORDS[keyword] then
		InviteByWhisper(event, author, presenceID)
	elseif GUILD_INVITE_KEYWORDS[keyword] then
		GuildInviteByWhisper(event, author, presenceID)
	end
end

function M:OnEnable()
	hooksecurefunc("SetItemRef", OnSetItemRef)

	local whisperInvite = CreateFrame("Frame")
	whisperInvite:RegisterEvent("CHAT_MSG_WHISPER")
	whisperInvite:RegisterEvent("CHAT_MSG_BN_WHISPER")
	whisperInvite:SetScript("OnEvent", OnWhisper)
end
