local _, ns = ...
local F, G = ns[2], ns[3]
local M = F.RegisterModule("tullaCTC", "tullaCTC")

-- Pure version for tullaCTC: https://github.com/tullamods/tullaCTC

--===================================================--
-----------------    [[ Configs ]]    -----------------
--===================================================--

local FONT_NAME, FONT_FACE = "tullaCTCfont", G.CTCFont
local FONT_FLAGS, FONT_SIZE = "OUTLINE", 20

-- 時間格式
local TENTHS_THRESHOLD, MMSS_THRESHOLD = 2.5, 90 -- 小於 2.5 秒顯示小數，小於 90 秒顯示秒數，90 秒以上顯示分:秒
local MINUTES_THRESHOLD, HOURS_THRESHOLD = 180.5, 3600 -- 超過 3 分鐘顯示分鐘
local DAYS_THRESHOLD, ROUNDING_MODE = 86400, "Nearest"

-- 文字顏色
local TEXT_COLORS = {
	{ threshold = 5, color = "FF6347FF" },
	{ threshold = 60, color = "FFFF00FF" },
	{ threshold = 3600, color = "FFFFFFFF" },
}
local DEFAULT_TEXT_COLOR = "AAAAAAFF"

local MINUTE = 60
local HOUR = MINUTE * 60
local DAY = HOUR * 24

local chargeCooldowns
local formatter

--===================================================--
-----------------    [[ Utilities ]]    ---------------
--===================================================--

local function createColor(hex)
	if type(hex) ~= "string" or (#hex ~= 8 and #hex ~= 6) then return nil end

	return #hex == 8 and CreateColorFromRGBAHexString(hex) or CreateColorFromHexString(hex)
end

local function thresholdComparer(a, b)
	return a.threshold < b.threshold
end

--==================================================--
-----------------    [[ Format ]]    -----------------
--==================================================--

local function getFormatBreakpoints()
	local roundingMode = Enum.NumericRuleFormatRounding[ROUNDING_MODE]
	local points = {}

	if TENTHS_THRESHOLD > 0 then
		tinsert(points, {
			threshold = 0,
			format = "%.1f",
			rounding = roundingMode,
			step = 0.1,
		})

		tinsert(points, {
			threshold = TENTHS_THRESHOLD,
			format = "%d",
			rounding = roundingMode,
			step = 1,
		})
	else
		tinsert(points, {
			threshold = 0,
			format = "%d",
			rounding = roundingMode,
			step = 1,
		})
	end

	tinsert(points, {
		threshold = MMSS_THRESHOLD,
		format = "%d:%02d",
		rounding = roundingMode,
		step = 1,
		components = { { div = MINUTE }, { mod = MINUTE } },
	})

	tinsert(points, {
		threshold = MINUTES_THRESHOLD,
		format = "%dm",
		components = { { div = MINUTE, rounding = roundingMode, step = 1 } },
	})

	if HOURS_THRESHOLD > MINUTES_THRESHOLD then
		tinsert(points, {
			threshold = HOURS_THRESHOLD,
			format = "%dh",
			components = { { div = HOUR, rounding = roundingMode, step = 1 } },
		})
	end

	if DAYS_THRESHOLD > HOURS_THRESHOLD then
		tinsert(points, {
			threshold = DAYS_THRESHOLD,
			format = "%dd",
			components = { { div = DAY, rounding = roundingMode, step = 1 } },
		})
	end

	return points
end

local function getColorBreakpoints()
	local points = {}

	for i = 1, #TEXT_COLORS do
		local entry = TEXT_COLORS[i]
		points[i] = {
			threshold = entry.threshold,
			color = createColor(entry.color),
		}
	end

	points[#points + 1] = {
		threshold = math.huge,
		color = createColor(DEFAULT_TEXT_COLOR),
	}

	table.sort(points, thresholdComparer)

	-- threshold 是結束點；formatter 需要起始點
	for i = #points, 2, -1 do
		points[i].threshold = points[i - 1].threshold
	end
	points[1].threshold = 0

	return points
end

local function createBreakpoints(colors, formats)
	local breakpoints = {}
	local i, j = 1, 1
	local state = {}

	while colors[i] or formats[j] do
		local c, f = colors[i], formats[j]
		local threshold

		if c and (not f or c.threshold <= f.threshold) then
			threshold = c.threshold
			state.color = c.color
			i = i + 1
		end

		if f and (not threshold or f.threshold <= threshold) then
			threshold = f.threshold
			state.step = f.step
			state.rounding = f.rounding
			state.format = f.format
			state.components = f.components
			j = j + 1
		end

		tinsert(breakpoints, {
			threshold = threshold,
			step = state.step,
			rounding = state.rounding,
			format = state.color and state.color:WrapTextInColorCode(state.format) or state.format,
			components = state.components,
		})
	end

	return breakpoints
end

--===================================================--
-----------------    [[ Module ]]    ------------------
--===================================================--

local function getFormatter()
	if not formatter then
		formatter = C_StringUtil.CreateNumericRuleFormatter()
		formatter:SetBreakpoints(createBreakpoints(getColorBreakpoints(), getFormatBreakpoints()))
	end

	return formatter
end

local function onCooldownStart(cooldown)
	if cooldown.noCooldownCount then return end
	if cooldown.tullaCTCStyled then return end
	if cooldown:IsForbidden() then return end

	local text = cooldown:GetCountdownFontString()

	cooldown:SetCountdownFormatter(getFormatter())
	cooldown:SetCountdownFont(FONT_NAME)

	text:ClearAllPoints()
	text:SetPoint("TOPLEFT", 1, -1)
	text:SetJustifyH("LEFT")
	text:SetJustifyV("TOP")
	text:SetShadowColor(1, 1, 1, 0)
	text:SetShadowOffset(0, 0)
	cooldown.tullaCTCStyled = true
end

-- 正在恢復充能時，顯示充能倒數
local function updateChargeCountdown(normalCooldown)
	local state = chargeCooldowns[normalCooldown]
	if not state then return end

	local chargeCooldown = state.cooldown
	local showNumbers = CVarCallbackRegistry:GetCVarValueBool("countdownForCooldowns") == true
	local showCharge = state.recharging and not chargeCooldown.noCooldownCount
	local showNormal = not showCharge and not normalCooldown.noCooldownCount
	local hideNormal = not showNumbers or not showNormal
	local hideCharge = not showNumbers or not showCharge
	if normalCooldown.tullaCTCHideNumbers ~= hideNormal then
		normalCooldown:SetHideCountdownNumbers(hideNormal)
		normalCooldown.tullaCTCHideNumbers = hideNormal
	end
	if chargeCooldown.tullaCTCHideNumbers ~= hideCharge then
		chargeCooldown:SetHideCountdownNumbers(hideCharge)
		chargeCooldown.tullaCTCHideNumbers = hideCharge
	end
end

local function onApplyCooldown(normalCooldown, _, chargeCooldown, chargeInfo, _, lossOfControlInfo)
	local state = chargeCooldowns[normalCooldown]
	if not state then
		state = { cooldown = chargeCooldown }
		chargeCooldowns[normalCooldown] = state
	end

	state.recharging = chargeInfo and chargeInfo.isActive
		and not (lossOfControlInfo and lossOfControlInfo.shouldReplaceNormalCooldown) or false
	updateChargeCountdown(normalCooldown)
end

function M:OnEnable()
	local font = CreateFont(FONT_NAME)
	font:SetFont(FONT_FACE, FONT_SIZE, FONT_FLAGS)
	font:SetShadowColor(1, 1, 1, 0)
	font:SetShadowOffset(0, 0)

	chargeCooldowns = {}

	local cooldownIndex = getmetatable(ActionButton1Cooldown).__index
	hooksecurefunc(cooldownIndex, "SetCooldown", onCooldownStart)
	hooksecurefunc(cooldownIndex, "SetCooldownDuration", onCooldownStart)
	hooksecurefunc(cooldownIndex, "SetCooldownFromDurationObject", onCooldownStart)
	hooksecurefunc(cooldownIndex, "SetCooldownFromExpirationTime", onCooldownStart)
	hooksecurefunc(cooldownIndex, "SetCooldownUNIX", onCooldownStart)

	hooksecurefunc("ActionButton_ApplyCooldown", onApplyCooldown)

	hooksecurefunc("ActionButton_UpdateCooldownNumberHidden", function(button)
		-- 原生剛覆寫普通冷卻的顯隱，必須重新套用。
		local cooldown = button.cooldown
		cooldown.tullaCTCHideNumbers = nil
		updateChargeCountdown(cooldown)
	end)

	CVarCallbackRegistry:RegisterCallback("countdownForCooldowns", function()
		for normalCooldown in pairs(chargeCooldowns) do
			updateChargeCountdown(normalCooldown)
		end
	end)

	hooksecurefunc("CooldownFrame_SetDisplayAsPercentage", function(cooldown)
		if cooldown.noCooldownCount then return end

		cooldown.noCooldownCount = true
		cooldown:SetHideCountdownNumbers(true)
		cooldown.tullaCTCHideNumbers = true
	end)
end
