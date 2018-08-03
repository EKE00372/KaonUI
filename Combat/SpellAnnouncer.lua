-- [[ 法術通報 ]] --

-- daily question on NGA:
-- http://bbs.ngacn.cc/read.php?tid=14607924
-- http://nga.178.com/read.php?tid=14484432
-- http://bbs.ngacn.cc/read.php?tid=14628478
-- combat log CLEU wiki
-- https://wow.gamepedia.com/COMBAT_LOG_EVENT

-- credits to:
-- HopeASD (NGA qfeizaijun)
-- aunty by Sjak 
-- https://wow.curseforge.com/projects/aunty
-- Krys Interrupt! by blizzart 
-- https://www.wowinterface.com/downloads/info21408-Krys_InterruptWoDReady.html
-- SaySapped by bitbyte
-- https://www.wowinterface.com/downloads/info9631-SaySapped.html
-- SayMassRez
-- https://www.wowinterface.com/downloads/info21078-SayMassRez.html

-- [[ config ]] --

local channel = "SAY"	-- "PARTY", "RAID"	-- player broadcast channel

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
	[118585] = true, -- Monk (Leer of the Ox)
	[118635] = true, -- Monk (Black Ox Provoke)
	
	[281854] = true, -- DH 輸出折磨
	[198589] = true, -- DH 坦克折磨
}

-- mass rez list / 群復
local massrez = {
	[212036] = true,
	[212040] = true,
	[212048] = true,
	[212051] = true,
	[212056] = true,
}

-- CC / 控場
local ccblackList = {
	[99] = true,		-- 夺魂咆哮
	[122] = true,		-- 冰霜新星
	[1784] = true,		-- 潜行 115191
	[5246] = true,		-- 破胆怒吼
	[8122] = true,		-- 心灵尖啸
	[33395] = true,		-- 冰冻术
	[228600] = true,	-- 冰川尖刺
	[197214] = true,	-- 裂地术
	[157997] = true,	-- 寒冰新星
	[102359] = true,	-- 群体缠绕
	[226943] = true,	-- 心灵炸弹
	[105421] = true,	-- 盲目之光
	[207167] = true,	-- 致盲冰雨
}

-- items(to do)
local items = {}

-- reset timestamp / 防洗頻
local cache = {}

-- [[ to get realm locale ]] --

-- note: this only check if UTF-8 or not, actually cant distinguish chinese, korean, or jepanese
local realmLocale
local realm = GetRealmName()
local byt = {string.byte(realm, 1, #realm)}
for i, v in ipairs(byt) do
	if v > 127 then
		realmLocale = "zh"
	else
		realmLocale = "us"
	end 
end

-- [[ core ]] --
local SpellAnnouncer = CreateFrame("Frame")

local function OnEvent(self, event)
	-- 野外停用 / disable when out of instance
	local instanceType = select(2, IsInInstance())
	if instanceType == "none" then return end
	
	-- 單人狀態停用 / disable when solo
	--if not IsInGroup() then return end
	
	-- 排隨機停用 / disable in LFG
	--if IsInLFGDungeon() then return end
	
	-- 在伊利丹排隨機停用
	--if IsInLFGDungeon() and (GetRealmName() == "Illidan") then return end
	
	-- get CLEU
	local timestamp, subEvent, _, sourceGUID, sourceName, sourceFlags, _, _, destName, _, _, spellID, _, _, EspellID, _, missType = CombatLogGetCurrentEventInfo()
	
	-- 無施放者時不生效(例如：震地) / avoid source nil error suck as quake interrupt
	if sourceGUID == nil or sourceName == nil then return end
	
	-- 施放者不是隊友不啟用 / disable if source not in group
	--if not UnitInRaid(sourceName) or UnitInParty(sourceName) then return end
	
	-- 寵物與守護者的簡單過濾 / filter way for pets and guardian if need
	if bit.band(sourceFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY) == 0 then return end
	
	-- 只對自己生效 / only enable on player
	--if sourceName ~= UnitName("player") then return end
	
	-- 打斷 / interrupt
	if cache[timestamp] ~= spellID and subEvent == "SPELL_INTERRUPT" then
		-- 格式： 中斷：角色[技能] > 怪物[技能]
		local msg = INTERRUPT..HEADER_COLON..sourceName..GetSpellLink(spellID).." > "..destName..GetSpellLink(EspellID)
		-- 通報自己的打斷，輸出他人的打斷至聊天框但不通報
		if sourceGUID == UnitGUID("player") or sourceGUID == UnitGUID("pet") then -- or sourceName == UnitName("player")
			if realmLocale == "zh" then
				SendChatMessage(INTERRUPT..HEADER_COLON..destName..GetSpellLink(EspellID), channel)
			else
				SendChatMessage("Interrupted "..GetSpellLink(EspellID), channel)
			end
		else
			DEFAULT_CHAT_FRAME:AddMessage(msg, 0.6, 1, 1)
		end
		cache[timestamp] = spellID
	
	-- 驅散 / dispel
	elseif cache[timestamp] ~= spellID and subEvent == "SPELL_DISPEL" then
		local msg = DISPELS..HEADER_COLON..sourceName..GetSpellLink(spellID).." > "..destName..GetSpellLink(EspellID)
		DEFAULT_CHAT_FRAME:AddMessage(msg, 0.6, 1, 1)
		cache[timestamp] = spellID
	
	-- 偷取 / stolen
	elseif subEvent == "SPELL_STOLEN" then
		local msg = ACTION_SPELL_STOLEN..HEADER_COLON..sourceName..GetSpellLink(spellID).." > "..destName..GetSpellLink(EspellID)
		DEFAULT_CHAT_FRAME:AddMessage(msg, 0.6, 1, 1)
	
	-- 反射 / reflec
	elseif subEvent == "SPELL_MISSED" and Misstype == "REFLECT" then
		local msg = REFLEC..HEADER_COLON..sourceName..GetSpellLink(spellID).." > "..destName..GetSpellLink(EspellID)	-- ACTION_SPELL_MISSED_REFLECT
		DEFAULT_CHAT_FRAME:AddMessage(msg, 0.6, 1, 1)
	
	-- 嘲諷 / taunt
	elseif cache[timestamp] ~= spellID and subEvent == "SPELL_AURA_APPLIED" and taunts[spellID] then
	--elseif cache[timestamp] ~= spellID and subEvent == "SPELL_AURA_APPLIED" and taunts[spellID] and (UnitInRaid(sourceName) or UnitInParty(sourceName)) then
		local role = UnitGroupRolesAssigned(sourceName)
		local msg = EMOTE137_CMD1:gsub("/(.*)","%1")..HEADER_COLON..sourceName..GetSpellLink(spellID).." > "..destName
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
		cache[timestamp] = spellID
	
	-- 嘲諷失敗 / taunt failed
	elseif subEvent == "SPELL_MISSED" and taunts[spellID] and Misstype == "IMMUNE" then
		local msg = EMOTE137_CMD1:gsub("/(.*)","%1")..HEADER_COLON..sourceName..GetSpellLink(spellID).." > "..destName.."|cffFF0000 "..FAILED.."|r"
		DEFAULT_CHAT_FRAME:AddMessage(msg, 0.6, 1, 1)
	
	-- 控場破壞 / cc break
	elseif subEvent == "SPELL_AURA_BROKEN_SPELL" then
		if auraType and auraType == AURA_TYPE_BUFF or ccblackList[spellID] then return end
		local msg = ACTION_SPELL_AURA_BROKEN..HEADER_COLON..sourceName..GetSpellLink(EspellID).." > "..destName..GetSpellLink(spellID)
		DEFAULT_CHAT_FRAME:AddMessage(msg, 0.6, 1, 1)
	elseif subEvent == "SPELL_AURA_BROKEN" then
		local msg = ACTION_SPELL_AURA_BROKEN..HEADER_COLON..sourceName.." melee > "..destName
		DEFAULT_CHAT_FRAME:AddMessage(msg, 0.6, 1, 1)
	
	-- 群復 / mess rez
	elseif subEvent == "SPELL_CAST_START" and massrez[spellID] and (UnitInRaid(sourceName) or UnitInParty(sourceName)) then
		local msg = RESURRECT..HEADER_COLON..sourceName..GetSpellLink(spellID)
		DEFAULT_CHAT_FRAME:AddMessage(msg, 0.6, 1, 1)
	
	-- 悶棍 / sapped by rouge
	elseif subEvent == "SPELL_AURA_APPLIED" and spellID == 6770 and destName == UnitName("player") then
		local msg = LOSS_OF_CONTROL_DISPLAY_SAP..HEADER_COLON..sourceName
		DEFAULT_CHAT_FRAME:AddMessage(msg, 0.6, 1, 1)
		if realmLocale == "zh" then
			SendChatMessage("被悶棍了！", channel)
		else
			SendChatMessage("Sapped!", channel)
		end
	else
		return
	end
end

SpellAnnouncer:SetScript("OnEvent", OnEvent)
SpellAnnouncer:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
--SpellAnnouncer:RegisterEvent("ADDON_LOADED")	-- actually doesnt need this event