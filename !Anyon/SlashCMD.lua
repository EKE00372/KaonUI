--=================================================--
-----------------    [[ Notes ]]    -----------------
--=================================================--

-- [[ 快速指令 ]] --
--[[
	-- Credits:
	-- MONOUI: https://www.wowinterface.com/downloads/info18071-MonoUI.html
	-- https://www.wowinterface.com/forums/showthread.php?t=52673
	
	-- 重載界面：/rl
	-- 載入預設的介面設定：/setui
	
	-- 偽造成就：/fa 貼成就或成就id 日/月/年
	
	-- 載入預設的插件設定：
	-- BW或DBM設定：/setbw或/setdbm
	-- Compactraid設定：/setcr
	-- MSBT設定：/setmsbt
	
	-- 聊天框體：
	-- 清除單頁內容：/cc
	-- 清除所有內容：/cca
	-- 重置位置：/setchat
	
	-- 自由拾取：/ffa
	-- 準備確認：/rdc
	-- 角色職責檢查：/rc
	-- 切換專精：/s#，#為專精排序數字
	
	-- 解散隊伍：/rd
	-- 離開隊伍：/lg
	-- 小隊團隊轉換：/rtp /p2r
	-- 離開戰場或競技場：/lbg
	-- 重置副本：/dgr
	-- 隨機副本傳送：/dgt
	
	-- 切換副本模式：
	-- 五人：/5n /5h /5m
	-- 團隊：/nm /hm /mm
	-- 舊團隊快捷：/10n /10h /25n /25h
]]--

local format = string.format
local tostring = tostring

local Ambiguate = Ambiguate
local EnumerateFrames = EnumerateFrames
local GetUnitSpeed = GetUnitSpeed
local GetSpecializationInfo, SetSpecialization = GetSpecializationInfo, SetSpecialization

local LoggingCombat, IsInInstance = LoggingCombat, IsInInstance
local IsInRaid, IsInGroup = IsInRaid, IsInGroup
local GetNumGroupMembers, GetRaidRosterInfo, UnitIsGroupLeader = GetNumGroupMembers, GetRaidRosterInfo, UnitIsGroupLeader

local UnitName, UnitExists = UnitName, UnitExists
local ConvertToParty, ConvertToRaid, LeaveParty = C_PartyInfo.ConvertToParty, C_PartyInfo.ConvertToRaid, C_PartyInfo.LeaveParty
local DoReadyCheck, SetEveryoneIsAssistant, UninviteUnit = C_PartyInfo.DoReadyCheck, C_PartyInfo.SetEveryoneIsAssistant, C_PartyInfo.UninviteUnit
local SetBattleNetStatus = C_BattleNet and C_BattleNet.SetCustomMessage

--=====================================================--
-----------------    [[ Functions ]]    -----------------
--=====================================================--

--[[ get fstack name /fsn ]]--
local function fstackName()
	local frame = EnumerateFrames()
	while frame do
		if (frame:IsVisible() and MouseIsOver(frame)) then
			print(frame:GetName() or format(UNKNOWN..": [%s]", tostring(frame)))
		end
		frame = EnumerateFrames(frame)
	end
end

--[[ combatlog /el ]]--
local function easyLogger()
	if not LoggingCombat() then
		LoggingCombat(true)
		print("|cff00FF00"..COMBATLOGENABLED.."|r")
	else
		LoggingCombat(false)
		print("|cffFF0000"..COMBATLOGDISABLED.."|r")		
	end
end

--[[ dungeon teleport ]]--
local function easyTeleport()
	local inInstance = IsInInstance()
	
	if inInstance then
		LFGTeleport(true)
	else
		LFGTeleport()
	end
end

--[[ leave battleground /lvbg ]]--
local function easyLeave()
	local instanceType = select(2, IsInInstance())
	
	if instanceType == "arena" or instanceType == "pvp" then
		-- 沿用暴雪流程，保留評級懲罰倒數與不同 PvP 類型的確認文字。
		if ConfirmOrLeaveBattlefield then
			ConfirmOrLeaveBattlefield()
		elseif StaticPopupDialogs["CONFIRM_LEAVE_BATTLEFIELD"] then
			StaticPopup_Show("CONFIRM_LEAVE_BATTLEFIELD")
		else
			LeaveBattlefield()
		end
	end
end

-- [[ raid and party switch /rtp /p2r]]--
local function raidToParty()
	if IsInRaid() then
		if GetNumGroupMembers() <= MEMBERS_PER_RAID_GROUP then
			-- 5人以下
			if UnitIsGroupLeader("player") then
				ConvertToParty()
			else
				print("|cffFFFF00"..LFG_LIST_NOT_LEADER.."|r")
			end
		else
			-- 超過5人
			print("|cffFFFF00"..ERR_READY_CHECK_THROTTLED.."|r")
		end
	elseif (IsInGroup() and not IsInRaid()) then
		print("|cffFFFF00"..ERR_NOT_IN_RAID.."|r")
	else
		print("|cffFFFF00"..ERR_NOT_IN_GROUP.."|r")
	end
end

local function partyToRaid()
	if IsInRaid() then
		if UnitIsGroupLeader("player") then
			print("|cffFFFF00"..ERR_PARTY_CONVERTED_TO_RAID.."|r")
		else
			print("|cffFFFF00"..ERR_QUEST_SESSION_RESULT_IN_RAID.."|r")
		end
	elseif (IsInGroup() and UnitIsGroupLeader("player")) and not IsInRaid() then
		ConvertToRaid()
	elseif (IsInGroup() and not UnitIsGroupLeader("player")) and not IsInRaid() then
		print("|cffFFFF00"..LFG_LIST_NOT_LEADER.."|r")
	else
		print("|cffFFFF00"..ERR_NOT_IN_GROUP.."|r")
	end
end

-- [[ disband group /rd]
local function GroupDisband()
	local pName = UnitName("player")
	
	if IsInRaid() then
		SendChatMessage("Disbanding group. 解散隊伍。", "RAID")	-- TEAM_DISBAND OR ERR_GROUP_DISBANDED
		
		for i = 1, GetNumGroupMembers() do
			local name, _, _, _, _, _, _, online = GetRaidRosterInfo(i)
			local shortName = name and (Ambiguate and Ambiguate(name, "short") or name)
			if online and name and shortName ~= pName then
				UninviteUnit(name)
			end
		end
	else
		SendChatMessage("Disbanding group. 解散隊伍。", "PARTY")
		
		for i = MAX_PARTY_MEMBERS, 1, -1 do
			local unit = "party"..i
			if UnitExists(unit) then
				local name, realm = UnitName(unit)
				if name then
					-- 踢跨伺服器成員時保留 Realm，避免同名角色判斷錯誤。
					UninviteUnit(realm and realm ~= "" and name.."-"..realm or name)
				end
			end
		end
	end

	LeaveParty()	-- 最後離開團隊
end

local function easyDisband()
	if not IsInGroup() then return end

	if not UnitIsGroupLeader("player") then
		print("|cffFFFF00"..LFG_LIST_NOT_LEADER.."|r")
		return
	end

	StaticPopupDialogs["DISBAND_RAID"] = {
		text = TEAM_DISBAND,
		button1 = YES,
		button2 = NO,
		OnAccept = function() GroupDisband() end,
		timeout = 20,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 5,
	}
	
	StaticPopup_Show("DISBAND_RAID")
end

--===================================================--
-----------------    [[ General ]]    -----------------
--===================================================--

-- Blizzard edit mode / 暴雪介面編輯模式
SlashCmdList["EDITMODE"] = function(msg)
	ShowUIPanel(EditModeManagerFrame)
end
SLASH_EDITMODE1 = "/bem"

-- reload ui / 重載介面
SlashCmdList["RELOADUI"] = function(msg)
	ReloadUI()
end
SLASH_RELOADUI1 = "/rl"

-- moune emote / 座騎特殊動作
SlashCmdList["MOUNTSP"] = function(msg) 
	if GetUnitSpeed("player") == 0 then
		DoEmote("MOUNTSPECIAL")
	end
end
SLASH_MOUNTSP1 = "/ms"

-- GM ticket / 說明
SlashCmdList["GM"] = function(msg)
	ToggleHelpFrame()
end
SLASH_GM1 = "/gm"

--  quick bn broadcast / 輸入/bn直接發送廣播
SlashCmdList["BN"] = function(msg, editbox)
	if SetBattleNetStatus then
		SetBattleNetStatus(msg)
	end
end
SLASH_BN1 = "/bn"

--====================================================--
-----------------    [[ Devloper ]]    -----------------
--====================================================--

-- framestack / 框架層級檢視器，CTRL指向顯示詳細內容
SlashCmdList["FSTACK"] = function(msg)
	C_AddOns.LoadAddOn("Blizzard_DebugTools")
	FrameStackTooltip_Toggle()
end
SLASH_FSTACK1 = "/fs"

-- event trace / 事件檢事器
SlashCmdList["ETTRACE"] = function(msg)
	C_AddOns.LoadAddOn("Blizzard_DebugTools")
	EventTraceFrame_HandleSlashCmd(msg)
end
SLASH_ETTRACE1 = "/et" --etrace

-- Blizzard_Console
SlashCmdList["DEV"] = function(msg)
	C_AddOns.LoadAddOn("Blizzard_Console")
	DeveloperConsole:Toggle()	-- esc to exit
end
SLASH_DEV1 = "/dev"

-- dump frame stack / 輸出指向框架名稱
SlashCmdList["FRAMENAME"] = function()
	fstackName()
end
SLASH_FRAMENAME1 = "/fsn"

--================================================--
-----------------    [[ Spec ]]    -----------------
--================================================--

-- [[ 專精切換 ]] --
local SWITCH = "切換"
local SPECIALIZATION = "專精"

local function easySpecSwitch(i)
	local currentSpec = GetSpecialization()
	local numSpecs = GetNumSpecializations()
	if not numSpecs or i > numSpecs or i < 1 then
		print("|cffff5050"..SWITCH.."失敗：沒有這個專精。|r")
		return
	end

	local id, name = GetSpecializationInfo(i)
	if not id or not name then
		print("|cffff5050"..SWITCH.."失敗：無法獲取專精。|r")
		return
	end

	if i == currentSpec then
		print("|cffffff00已是 >"..name.."< "..SPECIALIZATION.."。|r")
		return
	end

	SetSpecialization(i)
	print("|cff00ff00"..SWITCH.." >"..name.."< "..SPECIALIZATION.."|r")
end

-- 自動為每個專精註冊指令
for i = 1, (GetNumSpecializations() or 0) do
	SlashCmdList["S"..i] = function(msg)
		easySpecSwitch(i)
	end
	_G["SLASH_S"..i.."1"] = "/s"..i
end

--====================================================--
-----------------    [[ Dungeons ]]    -----------------
--====================================================--

-- 團隊難度在 12.1 分成兩組：
-- SetRaidDifficultyID 控制現代團隊難度，SetLegacyRaidDifficultyID 控制舊團隊 10/25 人。
-- 戰鬥紀錄
SlashCmdList["EASYLOGGER"] = function(msg)
	easyLogger()
end
SLASH_EASYLOGGER1 = "/el"

-- 重置副本
SlashCmdList["DGR"] = function(msg)
	ResetInstances()
end
SLASH_DGR1 = "/dgr"

-- 傳送副本
SlashCmdList["DGT"] = function(msg)
	easyTeleport()
end
SLASH_DGT1 = "/dgt"

-- 五人普通
SlashCmdList["DGFIVE"] = function(msg)
	SetDungeonDifficultyID(1)
end
SLASH_DGFIVE1 = "/5n"

-- 五人英雄
SlashCmdList["DGHERO"] = function(msg)
	SetDungeonDifficultyID(2)
end
SLASH_DGHERO1 = "/5h"

-- 五人傳奇
SlashCmdList["DGMYTH"] = function(msg)
	SetDungeonDifficultyID(23)
end
SLASH_DGMYTH1 = "/5m"

-- 舊10人普通
SlashCmdList["RAIDTENMAN"] = function(msg)
	SetRaidDifficultyID(14)
	SetLegacyRaidDifficultyID(3)
end
SLASH_RAIDTENMAN1 = "/10n"

-- 舊10人英雄
SlashCmdList["RAIDTENHERO"] = function(msg)
	SetRaidDifficultyID(15)
	SetLegacyRaidDifficultyID(5)
end
SLASH_RAIDTENHERO1 = "/10h"

-- 舊25人普通
SlashCmdList["RAIDTFMAN"] = function(msg)
	SetRaidDifficultyID(14)
	SetLegacyRaidDifficultyID(4)
end
SLASH_RAIDTFMAN1 = "/25n"

-- 舊25人英雄
SlashCmdList["RAIDTFHERO"] = function(msg)
	SetRaidDifficultyID(15)
	SetLegacyRaidDifficultyID(6)
end
SLASH_RAIDTFHERO1 = "/25h"

-- 普通團隊
SlashCmdList["FLEXNORMAL"] = function(msg)
	SetRaidDifficultyID(14)
end
SLASH_FLEXNORMAL1 = "/nm"

-- 英雄團隊
SlashCmdList["FLEXHERO"] = function(msg)
	SetRaidDifficultyID(15)
end
SLASH_FLEXHERO1 = "/hm"

-- 傳奇團隊
SlashCmdList["MYTH"] = function(msg)
	SetRaidDifficultyID(16)
end
SLASH_MYTH1 = "/mm"

--=================================================--
-----------------    [[ Group ]]    -----------------
--=================================================--

-- [[ 團隊 ]] --

-- 準備確認
SlashCmdList["READYCHECKSLASHRC"] = function(msg)
	DoReadyCheck()
end
SLASH_READYCHECKSLASHRC1 = "/rdc"

-- 角色職責確認
SlashCmdList["ROLECHECK"] = function(msg)
	InitiateRolePoll()
end
SLASH_ROLECHECK1 = "/rc"

-- 離開隊伍
SlashCmdList["LG"] = function(msg)
	LeaveParty()
end
SLASH_LG1 = "/lg"

-- 全團權限
SlashCmdList["EIA"] = function(msg)
	SetEveryoneIsAssistant(true)
end
SLASH_EIA1 = "/ea"

-- 團隊轉小隊 /rtp
SlashCmdList["RAIDTOPARTY"] = function(msg)
	raidToParty()
end
SLASH_RAIDTOPARTY1 = "/rtp"

-- 小隊轉團隊 /p2r
SlashCmdList["PARTYTORAID"] = function(msg)
	partyToRaid()
end
SLASH_PARTYTORAID1 = "/ptr"
SLASH_PARTYTORAID2 = "/ptor"	-- for PTR realm

-- 解散隊伍
SlashCmdList["GROUPDISBAND"] = function(msg)
	easyDisband()
end
SLASH_GROUPDISBAND1 = "/rd"

-- 離開pvp場地
SlashCmdList["BG"] = function(msg)
	easyLeave()
end
SLASH_BG1 = "/lvbg"
