local font = STANDARD_TEXT_FONT
local fontsize = 16
local fontflag = "OUTLINE"
local portStatus = true
local minorStatus = false

local C_Timer, floor, fmod, format = C_Timer, math.floor, math.fmod, string.format
local GetHaste, GetCritChance, GetMasteryEffect = GetHaste, GetCritChance, GetMasteryEffect
local GetDodgeChance, GetParryChance, GetBlockChance = GetDodgeChance, GetParryChance, GetBlockChance
local UnitArmor, GetCombatRatingBonus = UnitArmor, GetCombatRatingBonus

local startTime = 0

--=============================================--
---------------    [[ APIs ]]     ---------------
--=============================================--
--[[
local function Multicheck(check, ...)
	for i = 1, select("#", ...) do
		if check == select(i, ...) then
			return true
		end
	end
	return false
end
]]--
local function CreateText(parent, yoffset, r, g, b)
	local text = parent:CreateFontString(nil, "OVERLAY")
	text:SetFont(font, fontsize, fontflag)
	text:SetShadowOffset(0, 0)
	text:SetWordWrap(false)
	text:SetJustifyH("RIGHT")
	text:SetPoint("RIGHT", parent, "LEFT", 0, yoffset)
	
	if r then
		text:SetTextColor(r, g, b)
	else
		text:SetTextColor(1, 1, 1)
	end
	
	return text
end

--=================================================--
---------------    [[ Elements ]]     ---------------
--=================================================--

local Stat = CreateFrame("Frame", "NougatFrame", UIParent)
	Stat:SetSize(100, 20)
	Stat:SetAlpha(.4)
	Stat:SetHitRectInsets(-5, -5, -10, -10)
	Stat:SetFrameStrata("BACKGROUND")
	Stat:SetPoint("CENTER", UIParent, -320, -125)

	local armorText = CreateText(Stat, 0, .9, .9, .9)
	local hasteText = CreateText(Stat, -(fontsize+2), 1, 1, 0)
	local critText = CreateText(Stat, -(fontsize+2)*2, 1, .6, 0)
	local mastText = CreateText(Stat, -(fontsize+2)*3, 1, 0, .8)
	local verText = CreateText(Stat, -(fontsize+2)*4, 0, 1, 1)
	local dodgeText = CreateText(Stat, -(fontsize+2)*5, 0, 1, 0)
	local parryText = CreateText(Stat, -(fontsize+2)*6, 0, 1, 0)
	local blockText = CreateText(Stat, -(fontsize+2)*7, 0, 1, 0)

	local timerText = CreateText(Stat, -(fontsize+2)*8, 1, 1, 1)

--==================================================--
---------------    [[ Functions ]]     ---------------
--==================================================--

local function getStatus()
	local armor, haste, crit, mast, dodge, parry, block, ver, avoid, steal = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	--[[local armor = select(2, UnitArmor("player"))
	
	local haste = GetHaste()
	local crit = GetCritChance()
	local mast = GetMasteryEffect()
	
	local dodge = GetDodgeChance()
	local parry = GetParryChance()
	local block = GetBlockChance()
	
	local ver = GetCombatRatingBonus(29)
	local avoid = GetCombatRatingBonus(21)
	local steal = GetCombatRatingBonus(17)
	
	local gcd = max(0.75, 1.5 * 100 / (100+haste))]]--
	
	armor = select(2, UnitArmor("player"))
	
	haste = format("%.0f", GetHaste())
	crit = format("%.0f", GetCritChance())
	mast = format("%.0f", GetMasteryEffect())
	
	if portStatus then
		dodge = format("%.0f", GetDodgeChance())
		parry = format("%.0f", GetParryChance())
		block = format("%.0f", GetBlockChance())
	end
	
	ver = format("%.0f", GetCombatRatingBonus(29))
	
	if minorStatus then
		avoid = format("%.0f", GetCombatRatingBonus(21))
		steal = format("%.0f", GetCombatRatingBonus(17))
	end
	
	return armor, haste, crit, mast, dodge, parry, block, ver, avoid, steal
end

local function updateStatus()
	local armor, haste, crit, mast, dodge, parry, block, ver, avoid, steal = getStatus()
	
	armorText:SetText(armor.." Ac")
	hasteText:SetText(haste.." Ha")
	critText:SetText(crit.." Cr")
	mastText:SetText(mast.." Ma")
	verText:SetText(ver.." Ve")
	
	if portStatus then
		dodgeText:SetText(dodge.."D")
		parryText:SetText(parry.."P")
		blockText:SetText(block.."B")
	end
	--if minorStatus then
end

local function timerDisplay(seconds)
	local minutes = floor(seconds / 60)
	-- floor sec because seconds for GetTime() is not a iinteger
	seconds = floor(fmod(seconds, 60))
	-- format as min:sec
	timerText:SetText((minutes < 10 and "0" or "") .. minutes .. ":" .. (seconds < 10 and "0" or "") .. seconds)
end

local function OnUpdate(self, elapsed)
	self.timer = (self.timer or .5) + elapsed
	
	if self.timer > .1 then
		timerDisplay(GetTime() - startTime)
		self.timer = 0
	end
end

local function timerStart(self)
	-- get system time
	startTime = GetTime()
	-- show timer
	timerText:Show()
	-- should reset timer when start, avoid reset issue happened if gain combat again less then 3 sec
	timerText:SetText("00:00")
	-- update timer
	self:SetScript("OnUpdate", OnUpdate)
end

local function timerEnd(self)
	-- stop update
	self:SetScript("OnUpdate", nil)
	-- fade out after 3 sec
	C_Timer.After(3, function() if not UnitAffectingCombat("player") then timerText:Hide() end end)
end

--================================================--
---------------    [[ Updates ]]     ---------------
--================================================--

local function OnEvent(self, event, ...)
	if event == "PLAYER_REGEN_DISABLED" then
		securecall(UIFrameFadeIn, Stat, .4, 0, 1)
		timerStart(self)
	elseif event == "PLAYER_REGEN_ENABLED" then
		securecall(UIFrameFadeOut, Stat, .8, 1, .4)
		timerEnd(self)
	else
		updateStatus()
	end
end

--================================================--
---------------    [[ Scripts ]]     ---------------
--================================================--

	Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
	Stat:RegisterEvent("COMBAT_RATING_UPDATE")
	Stat:RegisterEvent("PLAYER_REGEN_DISABLED")
	Stat:RegisterEvent("PLAYER_REGEN_ENABLED")
	Stat:RegisterUnitEvent("UNIT_RESISTANCES", "player")
	Stat:SetScript("OnEvent", OnEvent)