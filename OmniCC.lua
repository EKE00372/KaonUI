--=================================================--
-----------------    [[ Notes ]]    -----------------
--=================================================--

--[[
	OmniCC Basic
    
    A featureless, "pure" version of OmniCC.
    This version should work on absolutely everything, but I"ve removed pretty much all of the options
	
	https://github.com/tullamods/tullaCC
	https://github.com/tullamods/OmniCC
	https://github.com/siweia/NDui/blob/master/Interface/AddOns/NDui/Modules/ActionBar/Cooldown.lua
--]]

--===================================================--
-----------------    [[ Configs ]]    -----------------
--===================================================--

----------------------
-- Dont touch this! --
----------------------

-- hack to work around detection from other addons for OmniCC
--Omnicc = true
--OmniCC              = OmniCC or {}
--OmniCC.Cooldown     = OmniCC.Cooldown or {}

-------------
-- Configs --
-------------

local FONT_COLOR = {1, 1, 1}
local FONT_FACE, FONT_SIZE = STANDARD_TEXT_FONT, 18 

local MIN_DURATION = 2.5                    -- the minimum duration to show cooldown text for
local DECIMAL_THRESHOLD = 2                 -- threshold in seconds to start showing decimals

local MIN_SCALE = 0.5                       -- the minimum scale we want to show cooldown counts at, anything below this will be hidden
local ICON_SIZE = 36

-------------
-- Globals --
-------------

local DAY, HOUR, MINUTE = 86400, 3600, 60
local DAYISH, HOURISH, MINUTEISH = 3600 * 23.5, 60 * 59.5, 59.5 
local HALFDAYISH, HALFHOURISH, HALFMINUTEISH = DAY/2 + 0.5, HOUR/2 + 0.5, MINUTE/2 + 0.5

local hideNumbers, active, hooked = {}, {}, {}
local GetTime, GetActionCooldown = GetTime, GetActionCooldown
local pairs, floor, format, strfind = pairs, math.floor, string.format, strfind

--==================================================--
-----------------    [[ Format ]]    -----------------
--==================================================--

local round = function(x) 
    return floor(x + 0.5) 
end

local function getTimeText(s, modRate)
    if s < DECIMAL_THRESHOLD + 0.5 then
		-- 小於2.5秒顯示小數點
        return format("|cffff0000%.1f|r", s), (s - format("%.1f", s)) / modRate
    elseif s < MINUTEISH then
        local seconds = round(s)
		-- 低於59.5秒顯示秒數
        return format("|cffffff00%d|r", seconds), s - (seconds - 0.51)
    elseif (s < HOURISH) then
        local minutes = round(s/MINUTE)
		-- 低於59分30秒顯示分鐘
        return format("|cffffffff%dm|r", minutes), minutes > 1 and (s - (minutes*MINUTE - HALFMINUTEISH)) or (s - MINUTEISH)
    elseif (s < DAYISH) then
        local hours = round(s/HOUR)
		-- 低於23小時30分顯示天數
        return format("|cffccccff%dh|r", hours), hours > 1 and (s - (hours*HOUR - HALFHOURISH)) or (s - HOURISH)
    else
        local days = round(s/DAY)
		-- 低於一天半顯示為一天
        return format("|cffcccccc%dd|r", days), days > 1 and (s - (days*DAY - HALFDAYISH)) or (s - DAYISH)
    end
end

--==========================================================--
-----------------    [[ Timer Function ]]    -----------------
--==========================================================--

-- stop the timer
local function Timer_Stop(self)
    self.enabled = nil
    self:Hide()
end

-- forces the given timer to update on the next frame
local function Timer_ForceUpdate(self)
    self.nextUpdate = 0
    self:Show()
end

-- adjust font size whenever the timer"s parent size changes, hide if it gets too tiny
local function Timer_OnSizeChanged(self, width, height)
    local fontScale = floor(width + 0.5) / ICON_SIZE
    if fontScale == self.fontScale then return end
    self.fontScale = fontScale

    if fontScale < MIN_SCALE then
        self:Hide()
    else
        self.text:SetFont(FONT_FACE, fontScale * FONT_SIZE, "OUTLINE")
        self.text:SetShadowColor(0, 0, 0, 0.5)
        self.text:SetShadowOffset(2, -2)

        if self.enabled then
            Timer_ForceUpdate(self)
        end
    end
end

-- update timer text, if it needs to be, hide the timer if done
local function Timer_OnUpdate(self, elapsed)
    if self.nextUpdate > 0 then
        self.nextUpdate = self.nextUpdate - elapsed
    else
        local passTime = GetTime() - self.start
		local remain = passTime >= 0 and ((self.duration - passTime) / self.modRate) or self.duration
        if remain > 0 then
            local getTime, nextUpdate = getTimeText(remain, self.modRate)
            self.text:SetText(getTime)
            self.nextUpdate = nextUpdate
        else
            Timer_Stop(self)
        end
    end
end

-- returns a new timer object
local function Timer_Create(self)
    local scaler = CreateFrame("Frame", nil, self)
    scaler:SetAllPoints(self)

    local timer = CreateFrame("Frame", nil, scaler)
    timer:Hide()
    timer:SetAllPoints(scaler)
    timer:SetScript("OnUpdate", Timer_OnUpdate)
    scaler.timer = timer

    local text = timer:CreateFontString(nil, "BACKGROUND")
    text:SetPoint("TOPLEFT", 1, -1)
    text:SetJustifyH("CENTER")
    timer.text = text

    Timer_OnSizeChanged(timer, scaler:GetSize())
    scaler:SetScript("OnSizeChanged", function(self, ...) 
        Timer_OnSizeChanged(timer, ...) 
    end)

    self.timer = timer
    return timer
end

--[[
  In WoW 4.3 and later, action buttons can completely bypass lua for updating cooldown timers
  This set of code is there to check and force OmniCC to update timers on standard action buttons (henceforth defined as anything that reuses"s blizzard"s ActionButton.lua code
--]]
local function Timer_Start(self, start, duration, modRate)
	-- disable on forbidden frame such as friendly nameplates
	if self:IsForbidden() then return end
	-- disable meaningless number on pvp honor frame
	if self.noCooldownCount or hideNumbers[self] then return end
	
	-- disable on weakauras
	local frameName = self.GetName and self:GetName() or ""
	if strfind(frameName, "WeakAuras") then
		self.noCooldownCount = true
		return
	end

    local parent = self:GetParent()
	start = tonumber(start) or 0
	duration = tonumber(duration) or 0
	modRate = tonumber(modRate) or 1

    if start > 0 and duration > MIN_DURATION then
        local timer = self.timer or Timer_Create(self)
        timer.start = start
        timer.duration = duration
        timer.modRate = modRate
        timer.enabled = true
        timer.nextUpdate = 0
		
		-- wait for blizz to fix itself
		local charge = parent and parent.chargeCooldown
		local chargeTimer = charge and charge.timer
		if chargeTimer and chargeTimer ~= timer then
			Timer_Stop(chargeTimer)
		end

        if timer.fontScale and timer.fontScale >= MIN_SCALE then 
            timer:Show() 
        end
    elseif self.timer then
        Timer_Stop(self.timer)
    end
	
	-- hide cooldown flash if barFader enabled
	if self:GetParent().__faderParent then
		if self:GetEffectiveAlpha() > 0 then
			self:Show()
		else
			self:Hide()
		end
	end

    -- Disable blizzard cooldown numbers
	if self.SetHideCountdownNumbers then self:SetHideCountdownNumbers(true) end
end

--=============================================================--
-----------------    [[ Cooldown Function ]]    -----------------
--=============================================================--

local function Cooldown_HideNumbers(self)
	hideNumbers[self] = true
	if self.timer then Timer_Stop(self.timer) end
end

local function Cooldown_OnShow(self)
	active[self] = true
end

local function Cooldown_OnHide(self)
	active[self] = nil
end

local function Cooldown_ShouldUpdateTimer(self, start)
	local timer = self.timer
	if not timer then
		return true
	end
	return timer.start ~= start
end

local function Cooldown_Update(self)
	local button = self:GetParent()
	local start, duration, _, modRate = GetActionCooldown(button.action)

	if Cooldown_ShouldUpdateTimer(self, start) then
		Timer_Start(self, start, duration, modRate)
	end
end

local function Cooldown_SetHideCountdownNumbers(hide)
    local disable = not (hide or self.noCooldownCount or self:IsForbidden())
	if disable then
		self:SetHideCountdownNumbers(true)
	end
end
--[[
function OmniCC.Cooldown.SetNoCooldownCount(cooldown, disable, owner)
    owner = (owner ~= nil) and owner or true

    if disable then
        -- 尚未停用則標記並關閉計時器
        if cooldown.noCooldownCount ~= owner then
            cooldown.noCooldownCount = owner
            if cooldown.timer then Timer_Stop(cooldown.timer) end
        end
    -- 由相同 owner 解除 → 清除標記並強制更新
    elseif cooldown.noCooldownCount == owner then
        cooldown.noCooldownCount = nil
        if cooldown.timer then Timer_ForceUpdate(cooldown.timer) end
    end
end
]]--
--===============================================================--
-----------------    [[ Action bar Function ]]    -----------------
--===============================================================--

-- action bar cooldown active
local function Cooldown_UpdateActionbar(self)
	for cooldown in pairs(active) do
		Cooldown_Update(cooldown)
	end
end

local function ActionButton_Register(frame)
	local cooldown = frame.cooldown
	
	if not hooked[cooldown] then
		cooldown:HookScript("OnShow", Cooldown_OnShow)
		cooldown:HookScript("OnHide", Cooldown_OnHide)
		
		hooked[cooldown] = true
	end
end

--===================================================--
-----------------    [[ Updates ]]    -----------------
--===================================================--

local function OnLoginEvent(self)
	local cooldownIndex = getmetatable(ActionButton1Cooldown).__index
	hooksecurefunc(cooldownIndex, "SetCooldown", Timer_Start)

	hooksecurefunc(cooldownIndex, "SetHideCountdownNumbers", Cooldown_SetHideCountdownNumbers)
	hooksecurefunc("CooldownFrame_SetDisplayAsPercentage", Cooldown_HideNumbers)

    --[[if _G["ActionBarButtonEventsFrame"].frames then
		for i, frame in pairs(_G["ActionBarButtonEventsFrame"].frames) do
			ActionButton_Register(frame)
		end
	end

	hooksecurefunc(ActionBarButtonEventsFrameMixin, "RegisterFrame", ActionButton_Register)]]--

    SetCVar("countdownForCooldowns", 0)
end

local function OnEvent(self, event, ...)
	if event == "ACTIONBAR_UPDATE_COOLDOWN" then
		Cooldown_UpdateActionbar(self)
	else
		OnLoginEvent(self)
	end
end

--===================================================--
-----------------    [[ Scripts ]]    -----------------
--===================================================--

local EventWatcher = CreateFrame("Frame")
	EventWatcher:RegisterEvent("PLAYER_LOGIN")
	EventWatcher:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
	EventWatcher:SetScript("OnEvent", OnEvent)
