-- [[ 快速指令 ]] --

	--	Credits:
	--	MONOUI: https://www.wowinterface.com/downloads/info18071-MonoUI.html
	--	https://www.wowinterface.com/forums/showthread.php?t=52673

-- [[ 協助選項，輸入/uihelp查看cmd ]] --

local HelpFrame = CreateFrame("Frame",nil,UIParent)
HelpFrame:RegisterEvent("PLAYER_LOGIN")
HelpFrame:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_LOGIN" then
		print("|cff00ffffEK|rCore:輸入/uihelp查看指令")
	end
end)

StaticPopupDialogs.UI_HELP = {
	text = "重載界面：/rl \n載入預設的介面設定：/setui \n\n載入預設的插件設定： \nBW或DBM設定：/setbw或/setdbm \nCompactraid設定：/setcr \nMSBT設定：/setmsbt \n\n聊天框體： \n清除單頁內容：/cc \n清除所有內容：/cca \n開啟大腳世界頻道：/dchat \n重置位置：/setchat \n\n自由拾取：/ffa \n準備確認：/rc \n角色職責檢查：/cr \n\n解散隊伍：/rd \n離開隊伍：/lg \n小隊團隊轉換：/rtp /ptr \n\n離開戰場或競技場：/lbg  \n重置副本：/dgr \n隨機副本傳送：/dgt \n\n切換副本模式： \n五人：/5n /5h /5m  \n舊團隊：/10n /10h /25n /25h \n團隊：/nm /hm /mm \n\n切換專精：/s#，#為專精排序數字 \n\n小地圖右鍵開啟微型選單 \n滾輪可縮放地圖，alt+滾輪可縮放框體",
	button1 = "知道了",
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 5,
}

SlashCmdList["UIHELP"] = function(msg)
	StaticPopup_Show("UI_HELP")
end
SLASH_UIHELP1 = "/uihelp"
SLASH_UIHELP2 = "/UIHELP"

-- [[ 常用 ]] --

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

-- GM ticket
SlashCmdList["GM"] = function(msg)
	ToggleHelpFrame()
end
SLASH_GM1 = "/gm"

--  quick bn broadcast / 輸入/bn直接發送廣播
SlashCmdList["BN"] = function(msg, editbox)
	BNSetCustomMessage(msg)
end
SLASH_BN1 = "/bn"

-- framestack
SlashCmdList["FSTACK"] = function(msg)
	UIParentLoadAddOn("Blizzard_DebugTools")
	FrameStackTooltip_Toggle()
end
SLASH_FSTACK1 = "/fs"

-- event trace
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

-- dump frame stack
SlashCmdList["FRAMENAME"] = function()
	local frame = EnumerateFrames()
	while frame do
		if (frame:IsVisible() and MouseIsOver(frame)) then
			print(frame:GetName() or string.format(UNKNOWN..": [%s]", tostring(frame)))
		end
		frame = EnumerateFrames(frame)
	end
end
SLASH_FRAMENAME1 = "/fsn"

-- align / 格線
local frame = frame
SlashCmdList["ALIGN"] = function()
	if frame then
		frame:Hide()
		frame = nil		
	else
		frame = CreateFrame("Frame", nil, UIParent)
		frame:SetAllPoints(UIParent)
		local w = GetScreenWidth() / 64
		local h = GetScreenHeight() / 36
		for i = 0, 64 do
			local texture = frame:CreateTexture(nil, "BACKGROUND")
			if i == 32 then
				texture:SetColorTexture(1, 1, 0, 0.5)
			else
				texture:SetColorTexture(1, 1, 1, 0.15)
			end
			texture:SetPoint("TOPLEFT", frame, "TOPLEFT", i * w - 1, 0)
			texture:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", i * w + 1, 0)
		end
		for i = 0, 36 do
			local texture = frame:CreateTexture(nil, "BACKGROUND")
			if i == 18 then
				texture:SetColorTexture(1, 1, 0, 0.5)
			else
				texture:SetColorTexture(1, 1, 1, 0.15)
			end
			texture:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -i * h + 1)
			texture:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 0, -i * h - 1)
		end
	end
end
SLASH_ALIGN1 = "/align"

-- [[ 專精切換 ]] --

SlashCmdList["S1"] = function(msg) 
	local specName = select(2, GetSpecializationInfo(1))
	SetSpecialization(1) 
	print(SWITCH.." >"..specName.."< "..SPECIALIZATION.."...") end
SLASH_S11 = "/s1"

SlashCmdList["S2"] = function(msg) 
	local specName = select(2, GetSpecializationInfo(2))
	SetSpecialization(2) 
	print(SWITCH.." >"..specName.."< "..SPECIALIZATION.."...") end
SLASH_S21 = "/s2"

SlashCmdList["S3"] = function(msg) 
	local specName = select(2, GetSpecializationInfo(3))
	SetSpecialization(3) 
	print(SWITCH.." >"..specName.."< "..SPECIALIZATION.."...") end
SLASH_S31 = "/s3"

SlashCmdList["S4"] = function(msg) 
	local specName = select(2, GetSpecializationInfo(4))
	SetSpecialization(4) 
	print(SWITCH.." >"..specName.."< "..SPECIALIZATION.."...") end
SLASH_S41 = "/s4"


-- [[ 副本 ]] --

-- 戰鬥紀錄
SlashCmdList["EASYLOGGER"] = function(msg)
	if not LoggingCombat() then
		LoggingCombat(true)
		print("|cff00FF00"..COMBATLOGENABLED.."|r")
	else
		LoggingCombat(false)
		print("|cffFF0000"..COMBATLOGDISABLED.."|r")
		
	end
end
SLASH_EASYLOGGER1 = "/el"

-- 重置副本
SlashCmdList["DGR"] = function(msg)
	ResetInstances()
end
SLASH_DGR1 = "/dgr"

-- 傳送副本
SlashCmdList["DGT"] = function(msg)
	local inInstance, _ = IsInInstance()
	if inInstance then
		LFGTeleport(true)
	else
		LFGTeleport()
	end
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
	SetRaidDifficultyID(3)
end
SLASH_RAIDTENMAN1 = "/10n"

SlashCmdList["RAIDTENHERO"] = function(msg)
	SetRaidDifficultyID(5)
end
SLASH_RAIDTENHERO1 = "/10h"

SlashCmdList["RAIDTFMAN"] = function(msg)
	SetRaidDifficultyID(4)
end
SLASH_RAIDTFMAN1 = "/25n"

SlashCmdList["RAIDTFHERO"] = function(msg)
	SetRaidDifficultyID(6)
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

-- [[ 團隊 ]] --

-- 準備確認
SlashCmdList["READYCHECKSLASHRC"] = function(msg)
	DoReadyCheck()
end
SLASH_READYCHECKSLASHRC1 = "/rdc"

-- 角色職責確認
SlashCmdList["CHECKROLE"] = function(msg)
	InitiateRolePoll()
end
SLASH_CHECKROLE1 = "/cr"

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
	if IsInRaid() then	--在團隊中
		if (GetNumGroupMembers() <= MEMBERS_PER_RAID_GROUP) then	-- 人數在5以下
			if UnitIsGroupLeader("player") then	-- 是團長
				ConvertToParty()
				print(CONVERT_TO_PARTY)
			else	-- 無權限
				print(ERR_GUILD_PERMISSIONS)
			end
		else	-- 超過5人
				print(ERR_READY_CHECK_THROTTLED)
		end
	elseif (IsInGroup() and not IsInRaid()) then	--不在團隊中
		print(ERR_NOT_IN_RAID)
	else
		print(ERR_NOT_IN_GROUP)
	end
end
SLASH_RAIDTOPARTY1 = "/rtp"

-- 小隊轉團隊 /ptr
SlashCmdList["PARTYTORAID"] = function(msg)
	if IsInRaid() then	-- 在團隊中
		print(ERR_PARTY_CONVERTED_TO_RAID)
	elseif (IsInGroup() and UnitIsGroupLeader("player")) and not IsInRaid() then	-- 是隊長
		ConvertToRaid()
		print(CONVERT_TO_RAID)
	elseif (IsInGroup() and not UnitIsGroupLeader("player")) and not IsInRaid() then	-- 不是隊長
		print(LFG_LIST_NOT_LEADER)	-- or use ERR_GUILD_PERMISSIONS
	else	-- 不在隊伍中
		print(ERR_NOT_IN_GROUP)
	end
end
SLASH_PARTYTORAID1 = "/ptr"

-- 解散隊伍
local GroupDisband = function()
	local pName = UnitName("player")
	if IsInRaid() then
		for i = 1, GetNumGroupMembers() do
			local name, _, _, _, _, _, _, online = GetRaidRosterInfo(i)
			if online and name ~= pName then
				UninviteUnit(name)
				SendChatMessage("Disbanding group.", "RAID")
			end
		end
	else
		for i = MAX_PARTY_MEMBERS, 1, -1 do
			if (UnitExists("party"..i)) then
				UninviteUnit(UnitName("party"..i))
				SendChatMessage("Disbanding group.", "PARTY")	-- TEAM_DISBAND
			end
		end
	end
	LeaveParty()
end
StaticPopupDialogs["DISBAND_RAID"] = {
	text = TEAM_DISBAND,
	button1 = YES,
	button2 = NO,
	OnAccept = GroupDisband,
	timeout = 20,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 5,
	}
SlashCmdList["GROUPDISBAND"] = function(msg)
	if  IsInRaid() then
		StaticPopup_Show("DISBAND_RAID")
	end
end
SLASH_GROUPDISBAND1 = "/rd"

-- 離開pvp場地
SlashCmdList["BG"] = function(msg)
	local _, instanceType = IsInInstance()
	if instanceType == "arena" or instanceType == "pvp" then
		if instanceType == "pvp" then
			instanceType = "battleground"	-- 戰場
		elseif instanceType == "arena" then
			if select(2, IsActiveBattlefieldArena()) then 
				instanceType = "rated arena match"	-- 積分
			else 
				instanceType = "arena skirmish"	-- 練習
			end
		end
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
SLASH_BG1 = "/lbg"
