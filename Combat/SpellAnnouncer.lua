local addon, ns = ...
local C, F, G, L = unpack(ns)

--=================================================--
-----------------    [[ Notes ]]    -----------------
--=================================================--

-- [[ 法術通報 ]] --
--[[
	daily question on NGA:
	http://bbs.ngacn.cc/read.php?tid=14607924
	http://nga.178.com/read.php?tid=14484432
	http://bbs.ngacn.cc/read.php?tid=14628478
	combat log CLEU wiki
	https://wow.gamepedia.com/COMBAT_LOG_EVENT

	credits to:
	HopeASD (NGA qfeizaijun)
	aunty by Sjak
	https://wow.curseforge.com/projects/aunty
	Krys Interrupt! by blizzart
	https://www.wowinterface.com/downloads/info21408-Krys_InterruptWoDReady.html
	SaySapped by bitbyte
	https://www.wowinterface.com/downloads/info9631-SaySapped.html
	SaymassRez
	https://www.wowinterface.com/downloads/info21078-SaymassRez.html
]]--
--==================================================--
-----------------    [[ Config ]]    -----------------
--==================================================--

-- [[ config ]] --

local channel = "SAY"	-- "PARTY", "RAID"	-- player's broadcast channel

-- [[ spell list ]] --

-- taunt list / 嘲諷
local taunts = {
	[355]    = true, -- Warrior
	--[114198] = true, -- Warrior (Mocking Banner)
	
	[2649]   = true, -- Hunter (Pet)
	[20736]  = true, -- Hunter (Distracting Shot)
	[123588] = true, -- Hunter (Distracting Shot - glyphed)
	
	[6795]   = true, -- Druid
	--[205644] = true, -- Druid (Force of Nature)
	
	[17735]  = true, -- Warlock (Voidwalker)
	[97827]  = true, -- Warlock (Provocation (Metamorphosis))
	
	[49560]  = true, -- Death Knight (Death Grip (aura))
	[56222]  = true, -- Death Knight
	
	[73684]  = true, -- Shaman (Unleash Earth)
	
	[62124]  = true, -- Paladin
	
	[116189] = true, -- Monk (Provoke (aura))
	[118635] = true, -- Monk (Black Ox Provoke)
	
	[281854] = true, -- DH 輸出折磨
	[198589] = true, -- DH 坦克折磨
}

-- mass rez list / 群復
local massRez = {
	[212036] = true,
	[212040] = true,
	[212048] = true,
	[212051] = true,
	[212056] = true,
	[361178] = true,
}

-- CC / 控場
local ccBlacklist = {
	[99] = true,		-- 夺魂咆哮
	[122] = true,		-- 冰霜新星
	[1776] = true,		-- 凿击
	[1784] = true,		-- 潜行
	[115191] = true,	-- 潜行
	[5246] = true,		-- 破胆怒吼
	[8122] = true,		-- 心灵尖啸
	[31661] = true,		-- 龙息术
	[33395] = true,		-- 冰冻术
	[64695] = true,		-- 陷地
	[82691] = true,		-- 冰霜之环
	[91807] = true,		-- 蹒跚冲锋
	[228600] = true,	-- 冰川長槍
	[197214] = true,	-- 裂地术
	[157997] = true,	-- 寒冰新星
	[102359] = true,	-- 群体缠绕
	[226943] = true,	-- 心灵炸弹
	[105421] = true,	-- 盲目之光
	[207167] = true,	-- 致盲冰雨
	[378760] = true,	-- 霜寒刺骨
	--[[
	[198121] = true,	-- 冰霜撕咬
	[207685] = true,	-- 悲苦咒符
	[285515] = true,	-- 能量湍流
	[331866] = true,	-- 混沌代理人
	[354051] = true,	-- 轻盈步
	[355689] = true,	-- 山崩
	[386770] = true,	-- 极寒
	]]--
}

-- battle rez / 戰復
local battleRez = {
	[95750]  = true,	-- 靈魂石
	[20484]  = true,	-- 復生
	[20707]  = true,	-- 靈魂石
	[61999]  = true,	-- 盟友復生
	[391054] = true,	-- 代禱

	[265116] = true,	-- 不穩定的時間轉移器
	[345130] = true,	-- 拋棄式光學相位復生器
	[384893] = true,	-- 極為實用的起搏器
}

-- items(to do)
local items = {}

--====================================================--
-----------------    [[ Function ]]    -----------------
--====================================================--

local CombatLogGetCurrentEventInfo, C_Spell_GetSpellLink = CombatLogGetCurrentEventInfo, C_Spell.GetSpellLink
local GetRealmName, IsInInstance, GetInstanceInfo = GetRealmName, IsInInstance, GetInstanceInfo
local UnitGUID, UnitGroupRolesAssigned = UnitGUID, UnitGroupRolesAssigned
local IsInGroup, IsInRaid, UnitInRaid, UnitInParty = IsInGroup, IsInRaid, UnitInRaid, UnitInParty

local smartSource, smartDest = smartSource, smartDest
local cache = {}	-- reset timestamp / 防洗頻
local colon = HEADER_COLON

-- [[ Get realm locale ]] --

-- note: this only check if UTF-8 or not, actually cant distinguish chinese, korean, or jepanese
local realmLocale
local realm = GetRealmName()
local byt = {string.byte(realm, 1, #realm)}
for i, v in ipairs(byt) do
	if v > 127 then realmLocale = "zh" else realmLocale = "us" end
end

--=====================================================--
-----------------    [[ Announcer ]]    -----------------
--=====================================================--

-- [[ core ]] --
local function OnEvent(self, event)
	-- [[ enable options ]] --
	
	-- 野外停用 / disable when out of instance
	local instanceType = select(2, IsInInstance())
	if instanceType == "none" or instanceType == "pvp" then return end
	-- 戰爭前線、海島、幻象、探究停用
	local difficulty = select(3, GetInstanceInfo())
	if F.Multicheck(difficulty, 11, 12, 147, 149, 38, 39, 40, 152, 153, 208) then return end
	
--[[
	單人狀態停用 / disable when solo
	if not IsInGroup() then return end
	排隨機停用 / disable in LFG
	if IsInLFGDungeon() then return end
	在伊利丹排隨機停用 / disable in Illidan
	if IsInLFGDungeon() and (GetRealmName() == "Illidan") then return end
	施放者不是隊友不啟用，但會忽略寵物 / disable if source not in group
	if not UnitInRaid(sourceName) or UnitInParty(sourceName) then return end
	只對自己生效 / only enable on player
	if sourceName ~= UnitName("player") then return end
]]--

	-- [[ filter ]] --
	
	-- get CLEU
	local timestamp, subEvent, _, sourceGUID, sourceName, sourceFlags, _, _, destName, destFlags, _, spellID, _, _, EspellID, _, missType = CombatLogGetCurrentEventInfo()
	
	-- 無施放者時不生效(例如：震地) / avoid source nil error suck as quake interrupt
	if (sourceGUID == nil or sourceName == nil) then return end

	-- 寵物與守護者的簡單過濾 / filter way for pets and guardian if need
	if bit.band(sourceFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY) == 0 then return end
	
	-- [[ 去除伺服器後綴 / remove player realm ]] --
	
	if bit.band(sourceFlags, COMBATLOG_OBJECT_TYPE_PLAYER) == 0 then
		smartSource = sourceName
	else
		smartSource = Ambiguate(sourceName, "short")
	end
	
	if bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) == 0 then
		smartDest = destName
	else
		smartDest = Ambiguate(destName, "short")
	end
	
	-- [[ start announce ]] --
	
	-- 打斷 / interrupt
	if cache[timestamp] ~= spellID and subEvent == "SPELL_INTERRUPT" then
		-- 格式：中斷：角色[技能] > 怪物[技能]
		local msg = INTERRUPT..colon..smartSource..C_Spell_GetSpellLink(spellID).." > "..smartDest..C_Spell_GetSpellLink(EspellID)
		
		-- 通報自己的打斷，輸出他人的打斷至聊天框但不通報
		if sourceGUID == UnitGUID("player") or sourceGUID == UnitGUID("pet") then -- or smartSource == UnitName("player")
			if realmLocale == "zh" then
				SendChatMessage(INTERRUPT..colon..smartDest..C_Spell_GetSpellLink(EspellID), channel)
			else
				SendChatMessage("Interrupted "..C_Spell_GetSpellLink(EspellID), channel)
			end
		else
			DEFAULT_CHAT_FRAME:AddMessage(msg, 0.6, 1, 1)
		end
		-- 避免群體驅散和群體打斷的洗頻
		cache[timestamp] = spellID
	
	-- 驅散 / dispel
	elseif cache[timestamp] ~= spellID and subEvent == "SPELL_DISPEL" then
		local msg = DISPELS..colon..smartSource..C_Spell_GetSpellLink(spellID).." > "..smartDest..C_Spell_GetSpellLink(EspellID)
		DEFAULT_CHAT_FRAME:AddMessage(msg, 0.6, 1, 1)
		cache[timestamp] = spellID
	
	-- 偷取 / stolen
	elseif subEvent == "SPELL_STOLEN" then
		local msg = ACTION_SPELL_STOLEN..colon..smartSource..C_Spell_GetSpellLink(spellID).." > "..smartDest..C_Spell_GetSpellLink(EspellID)
		DEFAULT_CHAT_FRAME:AddMessage(msg, 0.6, 1, 1)
	
	-- 反射 / reflec
	elseif subEvent == "SPELL_MISSED" and Misstype == "REFLECT" then
		local msg = REFLEC..colon..smartSource..C_Spell_GetSpellLink(spellID).." > "..smartDest..C_Spell_GetSpellLink(EspellID)	-- ACTION_SPELL_MISSED_REFLECT
		DEFAULT_CHAT_FRAME:AddMessage(msg, 0.6, 1, 1)
	
	-- 嘲諷 / taunt
	elseif cache[timestamp] ~= spellID and subEvent == "SPELL_AURA_APPLIED" and taunts[spellID] then
	--elseif cache[timestamp] ~= spellID and subEvent == "SPELL_AURA_APPLIED" and taunts[spellID] and (UnitInRaid(smartSource) or UnitInParty(smartSource)) then
		local role = UnitGroupRolesAssigned(smartSource)
		local msg = EMOTE137_CMD1:gsub("/(.*)","%1")..colon..smartSource..C_Spell_GetSpellLink(spellID).." > "..smartDest
		
		-- 播放音效
		PlaySoundFile(G.TauntBeep, "Master")
		
		-- 通報非坦克職責的嘲諷，輸出坦克職業的嘲諷至聊天框但不通報
		if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and role ~= "TANK" then
			SendChatMessage(msg, "INSTANCE_CHAT")
		elseif IsInGroup() and not IsInRaid() and role ~= "TANK" then
			SendChatMessage(msg, "PARTY")
		elseif IsInRaid() and role ~= "TANK" then
			SendChatMessage(msg, "RAID")
		else
			DEFAULT_CHAT_FRAME:AddMessage(msg, 0.6, 1, 1)
		end
		-- 避免群嘲洗頻
		cache[timestamp] = spellID
	
	-- 嘲諷失敗 / taunt failed
	elseif subEvent == "SPELL_MISSED" and taunts[spellID] and Misstype == "IMMUNE" then
		local msg = EMOTE137_CMD1:gsub("/(.*)","%1")..colon..smartSource..C_Spell_GetSpellLink(spellID).." > "..smartDest.."|cffFF0000 "..FAILED.."|r"
		DEFAULT_CHAT_FRAME:AddMessage(msg, 0.6, 1, 1)
	
	-- 控場破壞 / cc break
	elseif cache[timestamp] ~= spellID and subEvent == "SPELL_AURA_BROKEN_SPELL" then
		if auraType and auraType == AURA_TYPE_BUFF or ccBlacklist[spellID] then return end
		
		local msg = ACTION_SPELL_AURA_BROKEN..colon..smartSource..C_Spell_GetSpellLink(EspellID).." > "..smartDest..C_Spell_GetSpellLink(spellID)
		DEFAULT_CHAT_FRAME:AddMessage(msg, 0.6, 1, 1)
		cache[timestamp] = spellID
	
	elseif subEvent == "SPELL_AURA_BROKEN" then
		local msg = ACTION_SPELL_AURA_BROKEN..colon..smartSource.." melee > "..smartDest
		DEFAULT_CHAT_FRAME:AddMessage(msg, 0.6, 1, 1)
	
	-- 群復 / mess rez
	elseif subEvent == "SPELL_CAST_START" and massRez[spellID] and (UnitInRaid(smartSource) or UnitInParty(smartSource)) then
		local msg = RESURRECT..colon..smartSource..C_Spell_GetSpellLink(spellID)
		DEFAULT_CHAT_FRAME:AddMessage(msg, 0.6, 1, 1)
	
	-- 悶棍 / sapped by rouge
	elseif subEvent == "SPELL_AURA_APPLIED" and spellID == 6770 and smartDest == UnitName("player") then
		local msg = LOSS_OF_CONTROL_DISPLAY_SAP..colon..smartSource
		DEFAULT_CHAT_FRAME:AddMessage(msg, 0.6, 1, 1)
		
		if realmLocale == "zh" then
			SendChatMessage("被悶棍了！", channel)
		else
			SendChatMessage("Sapped!", channel)
		end
	
	-- 戰復 / battle rez
	elseif subEvent == "SPELL_CAST_SUCCESS" and battleRez[spellID] and (UnitInRaid(smartSource) or UnitInParty(smartSource)) then
		local msg = C_Spell_GetSpellLink(spellID)..colon..smartSource.." > "..smartDest
		DEFAULT_CHAT_FRAME:AddMessage(msg, 0.6, 1, 1)
		if smartDest == UnitName("player") then
			PlaySound(12889, "Master")
		end
	else
		return
	end
end

local SpellAnnouncer = CreateFrame("Frame")
	SpellAnnouncer:SetScript("OnEvent", OnEvent)
	SpellAnnouncer:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")