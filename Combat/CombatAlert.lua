-- [[ 戰鬥提示 ]] --

--	Credit:
--	original author: fgprodigal

-- [[ config ]] --

local Setting = {
	EnableCombat = true,		-- 戰鬥狀態/combat
	EnableHealth = true,		-- 低血量/health
	EnableMana = true,			-- 低法力/mana
	EnableInterrupt = true,		-- 打斷/unterrupt
	EnableExecute = true,		-- 斬殺/execute
	
	OnlyShowBoss = true,		-- 只顯示首領戰斬殺提示/only show execute in boss fight
	AutoThreshold = false,		-- 根據職業判斷斬殺血量
	ExecuteThreshold = 0.2,		-- 斬殺血量/default
}

local Texts = {
	EnterCombat = {
		"LEEROOOOOOOOY JEEEENKIIIIIIIIIIINS!",
		},
	LeaveCombat = {
		"At least I have chicken.",
		},
	ExecutePhase = {
		"Nuke it!",
		},
	Hplow = {
		"Oops!",
		"Ouch!",
		"Alas!",
		},
	Mplow = {
		"OOM!",
		},
}

local class = {
	["WARRIOR"] = { 0.2, 0.2, 0},
	["DRUID"] = { 0, 0.25, 0.25, 0},
	["PALADIN"] = { 0.2, 0.2, 0.35},
	["PRIEST"] = { 0, 0, 0.25},
	["DEATHKNIGHT"] = { 0, 0.35, 0},
	["WARLOCK"] = { 0.25, 0.25, 0.25},
	["ROGUE"] = { 0.35, 0, 0},
	["HUNTER"] = { 0.2, 0.2, 0.2},
	["MAGE"] = { 0.2, 0.35, 0.2},
	["SHAMAN"] = { 0, 0, 0},
	["MONK"] = { 0, 0, 0},
	["DEMONHUNTER"] = { 0, 0},
}

-- [[ core ]] --
local CBA = CreateFrame("Frame")

-- texture/材質
local imsg = CreateFrame("Frame", "CombatAlert")
imsg:SetSize(418, 72)
imsg:SetPoint("TOP", 0, -190)
imsg:Hide()

imsg.bg = imsg:CreateTexture(nil, "BACKGROUND")
imsg.bg:SetTexture([[Interface\LevelUp\LevelUpTex]])
imsg.bg:SetPoint("BOTTOM")
imsg.bg:SetSize(326, 103)
imsg.bg:SetTexCoord(0.00195313, 0.63867188, 0.03710938, 0.23828125)
imsg.bg:SetVertexColor(1, 1, 1, 0.6)

imsg.lineTop = imsg:CreateTexture(nil, "BACKGROUND")
imsg.lineTop:SetDrawLayer("BACKGROUND", 2)
imsg.lineTop:SetTexture([[Interface\LevelUp\LevelUpTex]])
imsg.lineTop:SetPoint("TOP")
imsg.lineTop:SetSize(418, 7)
imsg.lineTop:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)

imsg.lineBottom = imsg:CreateTexture(nil, "BACKGROUND")
imsg.lineBottom:SetDrawLayer("BACKGROUND", 2)
imsg.lineBottom:SetTexture([[Interface\LevelUp\LevelUpTex]])
imsg.lineBottom:SetPoint("BOTTOM")
imsg.lineBottom:SetSize(418, 7)
imsg.lineBottom:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)

imsg.text = imsg:CreateFontString(nil, "ARTWORK", "GameFont_Gigantic")
imsg.text:SetPoint("BOTTOM", 0, 12)
imsg.text:SetTextColor(1, 0.82, 0)
imsg.text:SetJustifyH("CENTER")

CombatAlert:SetScale(0.85)

local flag = 0
ExecuteThreshold =  Setting.ExecuteThreshold
local function ShowAlert(Texts)
	CombatAlert.text:SetText(Texts[math.random(1,table.getn(Texts))])
	CombatAlert:Show()
end

local function ShowInterruptAlert(Texts,name)
	CombatAlert.text:SetText(INTERRUPT..HEADER_COLON..Texts.." "..KEY_MINUS.." "..name)
	CombatAlert:Show()
end

-- register event/註冊事件

if Setting.EnableCombat then
	CBA:RegisterEvent("PLAYER_REGEN_ENABLED")
	CBA:RegisterEvent("PLAYER_REGEN_DISABLED")
end
if Setting.EnableHealth then
	CBA:RegisterEvent("UNIT_HEALTH")
end
if Setting.EnableMana then
	CBA:RegisterEvent("UNIT_POWER_UPDATE")
end
if Setting.EnableExecute then
	CBA:RegisterEvent("UNIT_HEALTH")
	CBA:RegisterEvent("PLAYER_TARGET_CHANGED")
end
if Setting.AutoThreshold then
	CBA:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	CBA:RegisterEvent("PLAYER_ENTERING_WORLD")
end
if Setting.EnableInterrupt then
	CBA:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

CBA:SetScript("OnEvent", function(self, event)

	if event == "PLAYER_ENTERING_WORLD" or event == "ACTIVE_TALENT_GROUP_CHANGED" then
		ExecuteThreshold = class[select(2, UnitClass("player"))][GetSpecialization() or 1]
	end
	
	if event == "UNIT_HEALTH" then
		local lowHealth = UnitHealth("player")/UnitHealthMax("player") < 0.3
		local exeHealth = UnitHealth("target")/UnitHealthMax("target") < ExecuteThreshold
		-- 低血量
		if UnitName("player") and lowHealth and flag == 0 and not UnitIsDeadOrGhost("player") then
			ShowAlert(Texts.Hplow)
			flag = 1
		-- 斬殺
		elseif UnitName("target") and UnitCanAttack("player", "target") and not UnitIsDead("target") and exeHealth and flag == 0 then
			if (Setting.OnlyShowBoss and UnitLevel("target") == -1) or (not Setting.OnlyShowBoss) then
				ShowAlert(Texts.ExecutePhase)
				flag = 1
			end
		end
	end
	
	-- 戰鬥提示
	if event == "PLAYER_REGEN_DISABLED" then
		ShowAlert(Texts.EnterCombat)
		flag = 0
	elseif event == "PLAYER_REGEN_ENABLED" then
		ShowAlert(Texts.LeaveCombat)
		flag = 0
	-- 轉換目標時重置
	elseif event == "PLAYER_TARGET_CHANGED" then
		flag = 0
	end
	
	-- 低法力
	if event == "UNIT_POWER_UPDATE" then
		local lowMana = UnitPower("player")/UnitPowerMax("player") < 0.3
		local powerType = UnitPowerType("player")
		if UnitName("player") and powerType == 0 and lowMana and flag == 0 then
	  	ShowAlert(Texts.Mplow)
			flag = 1
		end
	end
	
	-- 打斷
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local _, subEvent, _, _, sourceName, _, _, _, destName = CombatLogGetCurrentEventInfo()
		if subEvent == "SPELL_INTERRUPT" and (sourceName == UnitName("player") or sourceName == UnitName("pet")) then
				local spellName = select(16, CombatLogGetCurrentEventInfo())
				ShowInterruptAlert(spellName, destName)

		end
	end
end)

-- 限制更新速度
local timer = 0
imsg:SetScript("OnShow", function(self)
	timer = 0
	self:SetScript("OnUpdate", function(self, elasped)
		timer = timer + elasped
		
		if timer < 0.5 then
			self:SetAlpha(timer*2)
		end
		
		if timer > 1 and timer < 1.5 then
			self:SetAlpha(1 - (timer - 1)*2)
		end
		
		if timer >= 1.5 then
			self:Hide()
		end
	end)
end)