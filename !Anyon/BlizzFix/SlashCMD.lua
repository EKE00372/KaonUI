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
	-- 準備確認：/rc
	-- 角色職責檢查：/cr
	-- 切換專精：/s#，#為專精排序數字
	
	-- 解散隊伍：/rd
	-- 離開隊伍：/lg
	-- 小隊團隊轉換：/rtp /ptr
	-- 離開戰場或競技場：/lbg
	-- 重置副本：/dgr
	-- 隨機副本傳送：/dgt
	
	-- 切換副本模式：
	-- 五人：/5n /5h /5m
	-- 舊團隊：/10n /10h /25n /25h
	-- 團隊：/nm /hm /mm
]]--

local GetUnitSpeed = GetUnitSpeed
local format, tostring = string.format, tostring

local EnumerateFrames = EnumerateFrames
local GetScreenWidth, GetScreenHeight = GetScreenWidth, GetScreenHeight
local GetSpecializationInfo, SetSpecialization = GetSpecializationInfo, SetSpecialization

local LoggingCombat, IsInInstance = LoggingCombat, IsInInstance
local IsInRaid, IsInGroup = IsInRaid, IsInGroup
local GetNumGroupMembers, GetRaidRosterInfo, UnitIsGroupLeader = GetNumGroupMembers, GetRaidRosterInfo, UnitIsGroupLeader

local UnitName, UnitExists, UninviteUnit = UnitName, UnitExists, UninviteUnit
local ConvertToParty, ConvertToRaid, LeaveParty = C_PartyInfo.ConvertToParty, C_PartyInfo.ConvertToRaid, C_PartyInfo.LeaveParty

local frame = frame

--=====================================================--
-----------------    [[ Functions ]]    -----------------
--=====================================================--

--[[ get fstack name /fsn ]]--
local function fstackName()
	local frame = EnumerateFrames()
	while frame do
		if (frame:IsVisible() and MouseIsOver(frame)) then
			print(frame:GetName() or string.format(UNKNOWN..": [%s]", tostring(frame)))
		end
		frame = EnumerateFrames(frame)
	end
end

--[[ switch spec /si i=number ]]--
local function easySpecSwitch(i)
	local specID = GetSpecialization()
	local specName = select(2, GetSpecializationInfo(i))
	-- if target spec is same then dont do anything
	if i == specID then return end
	-- make sure number of spec id is avaliable
	if specName ~= nil then
		SetSpecialization(i)
		print(SWITCH.." >"..specName.."< "..SPECIALIZATION.."...")
	else
		return
	end
	
	return easySpecSwitch
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

--[[ leave battlegrould /lvbg ]]--
local function easyLeave()
	local instanceType = select(2, IsInInstance())
	
	if instanceType == "arena" or instanceType == "pvp" then
		StaticPopupDialogs["LeaveBattleField"] = {
			text = LEAVE_BATTLEGROUND, 
			button1 = YES,
			button2 = NO,
			timeout = 20,
			whileDead = true, 
			hideOnEscape = true,
			OnAccept = function() LeaveBattlefield() end,
			OnCancel = function() end,
			preferredIndex = 5,
		}
		
		StaticPopup_Show("LeaveBattleField")
	end
end

-- [[ raid and party switch /rtp /ptr]]--
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
		C_PartyInfo.ConvertToRaid()
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
			if online and name ~= pName then
				UninviteUnit(name)
			end
		end
	else
		SendChatMessage("Disbanding group. 解散隊伍。", "PARTY")
		
		for i = MAX_PARTY_MEMBERS, 1, -1 do
			if UnitExists("party"..i) then
				UninviteUnit(UnitName("party"..i))
			end
		end
	end

	LeaveParty()	-- 最後離開團隊
end

local function easyDisband()
	if IsInGroup() then
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
	BNSetCustomMessage(msg)
end
SLASH_BN1 = "/bn"

--====================================================--
-----------------    [[ Devloper ]]    -----------------
--====================================================--

-- framestack / 框架層級檢視器，CTRL指向顯示詳細內容
SlashCmdList["FSTACK"] = function(msg)
	UIParentLoadAddOn("Blizzard_DebugTools")
	FrameStackTooltip_Toggle()
end
SLASH_FSTACK1 = "/fs"

-- event trace / 事件檢事器
SlashCmdList["ETTRACE"] = function(msg)
	UIParentLoadAddOn("Blizzard_DebugTools")
	EventTraceFrame_HandleSlashCmd(msg)
end
SLASH_ETTRACE1 = "/et" --etrace

-- Blizzard_Console
SlashCmdList["DEV"] = function(msg)
	UIParentLoadAddOn("Blizzard_Console")
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
for i = 1, GetNumSpecializations() do
    SlashCmdList["S"..i] = function(msg)
        easySpecSwitch(i)
    end
    _G["SLASH_S"..i.."1"] = "/s"..i
end

--====================================================--
-----------------    [[ Dungeons ]]    -----------------
--====================================================--

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

-- 五人副本模式切換 
SlashCmdList["DGFIVE"] = function(msg)
	SetDungeonDifficultyID(1)
end
SLASH_DGFIVE1 = "/5n"

SlashCmdList["DGHERO"] = function(msg)
	SetDungeonDifficultyID(2)
end
SLASH_DGHERO1 = "/5h"

SlashCmdList["DGMYTH"] = function(msg)
	SetDungeonDifficultyID(23)
end
SLASH_DGMYTH1 = "/5m"

-- 舊團隊副本模式切換(存在問題)

SlashCmdList["RAIDTENMAN"] = function(msg)
	--SetRaidDifficultyID(3)
	SetLegacyRaidDifficultyID(3)
end
SLASH_RAIDTENMAN1 = "/10n"

SlashCmdList["RAIDTENHERO"] = function(msg)
	--SetRaidDifficultyID(5)
	SetLegacyRaidDifficultyID(5)
end
SLASH_RAIDTENHERO1 = "/10h"

SlashCmdList["RAIDTFMAN"] = function(msg)
	--SetRaidDifficultyID(4)
	SetLegacyRaidDifficultyID(4)
end
SLASH_RAIDTFMAN1 = "/25n"

SlashCmdList["RAIDTFHERO"] = function(msg)
	--SetRaidDifficultyID(6)
	SetLegacyRaidDifficultyID(6)
end
SLASH_RAIDTFHERO1 = "/25h"

-- 團隊副本模式切換
SlashCmdList["FLEXNORMAL"] = function(msg)
	SetRaidDifficultyID(14)
end
SLASH_FLEXNORMAL1 = "/nm"

SlashCmdList["FLEXHERO"] = function(msg)
	SetRaidDifficultyID(15)
end
SLASH_FLEXHERO1 = "/hm"

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

-- 小隊轉團隊 /ptr
SlashCmdList["PARTYTORAID"] = function(msg)
	partyToRaid()
end
SLASH_PARTYTORAID1 = "/ptr"

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
