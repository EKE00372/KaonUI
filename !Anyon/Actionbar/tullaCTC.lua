local addon, ns = ...
local C, F, G, L = unpack(ns)
local M = F.RegisterModule("tullaCTC", "tullaCTC")

-- Pure version for tullaCTC: https://github.com/tullamods/tullaCTC

--===================================================--
-----------------    [[ Configs ]]    -----------------
--===================================================--

local FONT_NAME, FONT_FACE = "tullaCTCfont", G.CTCFont
local FONT_FLAGS, FONT_SIZE = "OUTLINE", 18

-- 時間格式：
-- 小於 2.5 秒顯示小數；小於 90 秒顯示秒數；90 秒以上顯示分:秒；5 分鐘以上顯示分鐘。
local TENTHS_THRESHOLD, MMSS_THRESHOLD = 2.5, 90
local MINUTES_THRESHOLD, HOURS_THRESHOLD = 300.5, 3600
local DAYS_THRESHOLD, ROUNDING_MODE = 86400, "Nearest"

-- 文字顏色，threshold 是該顏色區間的結束秒數。
local TEXT_COLORS = {
	{ threshold = 5, color = "FF6347FF" },
	{ threshold = 60, color = "FFFF00FF" },
	{ threshold = 3600, color = "FFFFFFFF" },
}
local DEFAULT_TEXT_COLOR = "AAAAAAFF"

local MINUTE = 60
local HOUR = MINUTE * 60
local DAY = HOUR * 24

--===================================================--
-----------------    [[ Utilities ]]    ---------------
--===================================================--

local createColor = setmetatable({}, {
	__mode = "v",
	__call = function(self, hex)
		if type(hex) ~= "string" or (#hex ~= 8 and #hex ~= 6) then return nil end

		local color = self[hex]
		if not color then
			color = #hex == 8 and CreateColorFromRGBAHexString(hex) or CreateColorFromHexString(hex)
			self[hex] = color
		end

		return color
	end,
})

local function thresholdComparer(a, b)
	return a.threshold < b.threshold
end

--==================================================--
-----------------    [[ Format ]]    -----------------
--==================================================--

local function getFormatBreakpoints()
	local roundingMode = Enum.NumericRuleFormatRounding[ROUNDING_MODE] or Enum.NumericRuleFormatRounding.Nearest
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
		format = "%d",
		components = { { div = MINUTE, rounding = roundingMode, step = 1 } },
	})

	if HOURS_THRESHOLD > MINUTES_THRESHOLD then
		tinsert(points, {
			threshold = HOURS_THRESHOLD,
			format = "%d",
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

	-- 原版設定的 threshold 是結束點；formatter 需要起始點。
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
			state.min = f.min
			state.max = f.max
			state.format = f.format
			state.components = f.components
			j = j + 1
		end

		tinsert(breakpoints, {
			threshold = threshold,
			step = state.step,
			rounding = state.rounding,
			min = state.min,
			max = state.max,
			format = state.color and state.color:WrapTextInColorCode(state.format) or state.format,
			components = state.components,
		})
	end

	return breakpoints
end

local function createFormatter()
	local formatter = C_StringUtil.CreateNumericRuleFormatter()
	formatter:SetBreakpoints(createBreakpoints(getColorBreakpoints(), getFormatBreakpoints()))

	return formatter
end

--===================================================--
-----------------    [[ Module ]]    ------------------
--===================================================--

function M:OnEnable()
	-- Init.lua 會在 AnyonDB 同步後依 tullaCTC 設定呼叫這裡。
	if not C_StringUtil or not C_StringUtil.CreateNumericRuleFormatter then return end

	local font = CreateFont(FONT_NAME)
	font:SetFont(FONT_FACE, FONT_SIZE, FONT_FLAGS)
	font:SetShadowColor(1, 1, 1, 0)
	font:SetShadowOffset(0, 0)

	local active = {}
	local textContainers = {}
	local formatter
	local loaded

	local function getFormatter()
		if not formatter then
			formatter = createFormatter()
		end

		return formatter
	end

	local function styleCooldown(cooldown)
		if cooldown.noCooldownCount then return end
		if cooldown.IsForbidden and cooldown:IsForbidden() then return end

		local text = cooldown:GetCountdownFontString()
		if not text then return end

		cooldown:SetCountdownFormatter(getFormatter())
		cooldown:SetCountdownFont(FONT_NAME)

		text:ClearAllPoints()
		text:SetPoint("TOPLEFT", 1, -1)
		text:SetJustifyH("LEFT")
		text:SetJustifyV("TOP")
		text:SetShadowColor(1, 1, 1, 0)
		text:SetShadowOffset(0, 0)
	end

	local nextid
	do
		local id = 0
		nextid = function()
			id = id + 1
			return id
		end
	end

	local function onCooldownStop(cooldown)
		local cooldownID = cooldown.tullaCTC
		if cooldownID then
			active[cooldownID] = nil
		end
	end

	local function raiseCooldownText(cooldown, cooldownID)
		if InCombatLockdown() then return end

		local parent = cooldown:GetParent()
		if parent and parent.TextOverlayContainer then
			local container = textContainers[cooldownID]
			if not container then
				container = CreateFrame("Frame", nil, cooldown)
				container:SetAllPoints(cooldown)
				container:SetFrameLevel(777)

				local text = cooldown:GetCountdownFontString()
				if text then
					text:SetParent(container)
				end

				textContainers[cooldownID] = container
			end
		end
	end

	local function onCooldownStart(cooldown)
		if cooldown.noCooldownCount then
			onCooldownStop(cooldown)
			return
		end
		if cooldown.IsForbidden and cooldown:IsForbidden() then return end

		local cooldownID = cooldown.tullaCTC
		if cooldownID == nil then
			cooldownID = nextid()
			cooldown.tullaCTC = cooldownID
			cooldown:HookScript("OnCooldownDone", onCooldownStop)
		end

		raiseCooldownText(cooldown, cooldownID)
		styleCooldown(cooldown)
		active[cooldownID] = cooldown
	end

	local function initialize()
		if loaded then return end
		if not ActionButton1Cooldown then return end
		loaded = true

		local cooldownIndex = getmetatable(ActionButton1Cooldown).__index
		hooksecurefunc(cooldownIndex, "SetCooldown", onCooldownStart)
		hooksecurefunc(cooldownIndex, "SetCooldownDuration", onCooldownStart)
		hooksecurefunc(cooldownIndex, "SetCooldownFromDurationObject", onCooldownStart)
		hooksecurefunc(cooldownIndex, "SetCooldownFromExpirationTime", onCooldownStart)
		hooksecurefunc(cooldownIndex, "SetCooldownUNIX", onCooldownStart)
		hooksecurefunc(cooldownIndex, "Clear", onCooldownStop)

		if CooldownFrame_SetDisplayAsPercentage then
			hooksecurefunc("CooldownFrame_SetDisplayAsPercentage", function(cooldown)
				if cooldown.noCooldownCount then return end

				cooldown.noCooldownCount = true
				cooldown:SetHideCountdownNumbers(true)
			end)
		end
	end

	-- Init.lua 已經統一在 PLAYER_LOGIN 啟用模組，這裡直接初始化冷卻文字。
	initialize()
end
