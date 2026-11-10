local _, ns = ...
local F, G = ns[2], ns[3]
local M = F.RegisterModule("Nougat", "Nougat")

local floor = math.floor
local GetTime, UnitAffectingCombat = GetTime, UnitAffectingCombat
local GetUnitSpeed, IsSwimming, IsFlying = GetUnitSpeed, IsSwimming, IsFlying
local AbbreviateNumbers = AbbreviateNumbers

local FONT_SIZE, UPDATE_INTERVAL = 16, .2
local CELL_HEIGHT, CELL_BORDER, CELL_PADDING, CELL_GAP, ROW_STEP = 26, 1, 8, 2, 28
local CELL_GLOW_SIZE = 2
local CELL_EDGES = {
	{"TOPLEFT", "TOPRIGHT", true},
	{"BOTTOMLEFT", "BOTTOMRIGHT", true},
	{"TOPLEFT", "BOTTOMLEFT", false},
	{"TOPRIGHT", "BOTTOMRIGHT", false},
}
-- glow.tga 的八格切片各內縮一個材質像素；橫邊以固定 UV 旋轉，不依字寬計算重複次數。
local CELL_GLOW_EDGES = {
	{0, 1, 33/128, 15/16, 47/128, 15/16, 33/128, 1/16, 47/128, 1/16},
	{0, -1, 49/128, 15/16, 63/128, 15/16, 49/128, 1/16, 63/128, 1/16},
	{-1, 0, 1/128, 15/128, 1/16, 15/16},
	{1, 0, 17/128, 31/128, 1/16, 15/16},
}
local CELL_GLOW_CORNERS = {
	{"TOPLEFT", -1, 1, 65/128, 79/128},
	{"TOPRIGHT", 1, 1, 81/128, 95/128},
	{"BOTTOMLEFT", -1, -1, 97/128, 111/128},
	{"BOTTOMRIGHT", 1, -1, 113/128, 127/128},
}
local speedOptions = {
	breakpointData = {
		{
			breakpoint = 0,
			abbreviation = "",
			fractionDivisor = 1,
			-- 比 .07 低一個浮點刻度，避免 7 / .07 被截成 99；Secret 換算交給原生。
			significandDivisor = .06999999999999999,
			abbreviationIsGlobal = false,
		},
	},
}

local frame, fadeGroup, fadeAlpha
local armorText, speedText, timerText
local secondaryRow, masteryRow, defenseRow, speedRow, timerRow
local statsDirty, specializationDirty
local showDefense
local updateElapsed
local combatStart, combatDuration, timerHideAt, displayedSecond

local function CreateText(parent, r, g, b)
	local text = parent:CreateFontString(nil, "OVERLAY")
	text:SetFont(G.Font, FONT_SIZE, G.FontFlag)
	text:SetShadowOffset(0, 0)
	text:SetWordWrap(false)
	text:SetJustifyH("RIGHT")
	text:SetTextColor(r, g, b)
	return text
end

local function CreateGlowTexture(parent, r, g, b)
	local glow = parent:CreateTexture(nil, "BACKGROUND", nil, -1)
	glow:SetTexture(G.GlowTex)
	glow:SetVertexColor(r, g, b, .4)
	return glow
end

local function CreateCell(parent, text, color)
	local r, g, b = color[1] * 248 / 255, color[2] * 252 / 255, color[3] * 248 / 255
	local background = parent:CreateTexture(nil, "BACKGROUND")
	background:SetColorTexture(r, g, b, 84 / 255)
	background:SetHeight(CELL_HEIGHT)
	-- 自然寬完全交給文字兩端的錨點，邊框不讀回受限尺寸。
	background:SetPoint("LEFT", text, "LEFT", -CELL_PADDING, 0)
	background:SetPoint("RIGHT", text, "RIGHT", CELL_PADDING, 0)
	for _, points in ipairs(CELL_EDGES) do
		local edge = parent:CreateTexture(nil, "BORDER")
		edge:SetColorTexture(r, g, b, .65)
		if points[3] then edge:SetHeight(CELL_BORDER) else edge:SetWidth(CELL_BORDER) end
		edge:SetPoint(points[1], background, points[1], 0, 0)
		edge:SetPoint(points[2], background, points[2], 0, 0)
	end
	for index, points in ipairs(CELL_EDGES) do
		local piece = CELL_GLOW_EDGES[index]
		local glow = CreateGlowTexture(parent, r, g, b)
		glow:SetTexCoord(unpack(piece, 3))
		if points[3] then glow:SetHeight(CELL_GLOW_SIZE) else glow:SetWidth(CELL_GLOW_SIZE) end
		glow:SetPoint(points[1], background, points[1], piece[1] * CELL_GLOW_SIZE, piece[2] * CELL_GLOW_SIZE)
		glow:SetPoint(points[2], background, points[2], piece[1] * CELL_GLOW_SIZE, piece[2] * CELL_GLOW_SIZE)
	end
	for _, piece in ipairs(CELL_GLOW_CORNERS) do
		local glow = CreateGlowTexture(parent, r, g, b)
		glow:SetTexCoord(piece[4], piece[5], 1/16, 15/16)
		glow:SetSize(CELL_GLOW_SIZE, CELL_GLOW_SIZE)
		glow:SetPoint(piece[1], background, piece[1], piece[2] * CELL_GLOW_SIZE, piece[3] * CELL_GLOW_SIZE)
	end
end

local function CreateRow(index, colors)
	local row = CreateFrame("Frame", nil, frame, "DisableUntrustedLayoutScriptsTemplate")
	row:SetSize(1, CELL_HEIGHT)
	row:SetPoint("RIGHT", frame, "LEFT", 0, -ROW_STEP * index)
	row.texts = {}
	local anchor, point, gap = row, "RIGHT", CELL_PADDING
	for i = #colors, 1, -1 do
		local color = colors[i]
		local text = CreateText(row, color[1], color[2], color[3])
		text:SetPoint("RIGHT", anchor, point, -gap, 0)
		CreateCell(row, text, color)
		row.texts[i] = text
		anchor, point, gap = text, "LEFT", CELL_PADDING * 2 + CELL_GAP
	end
	return row
end

local function UpdateStats()
	statsDirty = false
	if specializationDirty then
		specializationDirty = false
		local spec = C_SpecializationInfo.GetSpecialization()
		local isTank = false
		if spec then
			isTank = (select(5, C_SpecializationInfo.GetSpecializationInfo(spec)) == "TANK")
		end
		if isTank ~= showDefense then
			showDefense = isTank
			defenseRow:SetShown(isTank)
			local speedIndex = isTank and 4 or 3
			speedRow:SetPoint("RIGHT", frame, "LEFT", 0, -ROW_STEP * speedIndex)
			timerRow:SetPoint("RIGHT", frame, "LEFT", 0, -ROW_STEP * (speedIndex + 1))
		end
	end
	local _, armor = UnitArmor("player")
	-- 屬性可能是 Secret；只格式化顯示，不拿數值或呈現文字作比較與計算。
	armorText:SetFormattedText("%d Ac", armor)
	secondaryRow.texts[1]:SetFormattedText("%.0f", GetHaste())
	secondaryRow.texts[2]:SetFormattedText("%.0f", GetCritChance())
	masteryRow.texts[1]:SetFormattedText("%.0f", (GetMasteryEffect()))
	-- 全能沿用舊版的等級換算部分，不合計額外百分比。
	masteryRow.texts[2]:SetFormattedText("%.0f", GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE))
	if showDefense then
		defenseRow.texts[1]:SetFormattedText("%.0f", GetDodgeChance())
		defenseRow.texts[2]:SetFormattedText("%.0f", GetParryChance())
		defenseRow.texts[3]:SetFormattedText("%.0f", GetBlockChance())
	end
end

local function UpdateSpeed()
	local _, runSpeed, flightSpeed, swimSpeed = GetUnitSpeed("player")
	local speed
	if IsSwimming("player") then
		speed = swimSpeed
	elseif IsFlying("player") then
		speed = flightSpeed
	else
		speed = runSpeed
	end
	speedText:SetFormattedText("%s%%", AbbreviateNumbers(speed, speedOptions))
end

local function UpdateTimer(now)
	if timerHideAt and now >= timerHideAt then
		timerHideAt = nil
		timerRow:Hide()
		return
	end
	if not combatStart and not timerHideAt then return end

	local seconds = floor(combatStart and now - combatStart or combatDuration)
	if seconds ~= displayedSecond then
		displayedSecond = seconds
		timerText:SetFormattedText("%02d:%02d", floor(seconds / 60), seconds % 60)
	end
end

local function UpdateCombatState(inCombat, instant)
	local now = GetTime()
	if inCombat then
		if not combatStart then
			combatStart = now
			timerHideAt = nil
			displayedSecond = nil
		end
	elseif combatStart then
		combatDuration = now - combatStart
		combatStart = nil
		timerHideAt = now + 3
	end
	if not frame:IsVisible() then return end

	timerRow:SetShown(combatStart ~= nil or timerHideAt ~= nil)
	UpdateTimer(now)

	-- 只讀寫自有框體的公開 Alpha；動畫由原生執行，不使用共用 FADEFRAMES。
	local alpha = frame:GetAlpha()
	fadeGroup:Stop()
	local target = inCombat and 1 or .4
	if instant then
		frame:SetAlpha(target)
	else
		frame:SetAlpha(alpha)
		fadeAlpha:SetFromAlpha(alpha)
		fadeAlpha:SetToAlpha(target)
		fadeAlpha:SetDuration(inCombat and .4 or .8)
		fadeGroup:Play()
	end
end

local function OnUpdate(_, elapsed)
	-- 同一幀的屬性事件只查一次；定時更新不重查整組屬性。
	if statsDirty then UpdateStats() end
	updateElapsed = updateElapsed + elapsed
	if updateElapsed < UPDATE_INTERVAL then return end
	updateElapsed = updateElapsed % UPDATE_INTERVAL

	UpdateSpeed()
	UpdateTimer(GetTime())
end

local function OnShow(self)
	updateElapsed = 0
	UpdateCombatState(UnitAffectingCombat("player"), true)
	specializationDirty = true
	UpdateStats()
	UpdateSpeed()
	self:SetScript("OnUpdate", OnUpdate)
end

local function OnHide(self)
	self:SetScript("OnUpdate", nil)
	fadeGroup:Stop()
end

local function OnEvent(_, event)
	if event == "PLAYER_REGEN_DISABLED" then
		UpdateCombatState(true)
	elseif event == "PLAYER_REGEN_ENABLED" then
		UpdateCombatState(false)
	elseif event == "PLAYER_ENTERING_WORLD" then
		UpdateCombatState(UnitAffectingCombat("player"), true)
		specializationDirty = true
		statsDirty = true
	else
		if event == "ACTIVE_PLAYER_SPECIALIZATION_CHANGED" then specializationDirty = true end
		-- 原生先過濾 player；不接收或解讀 UNIT_AURA 的受限 payload。
		statsDirty = true
	end
end

function M:OnEnable()
	frame = CreateFrame("Frame", "NougatFrame", UIParent)
	frame:Hide()
	frame:SetSize(100, 20)
	frame:SetAlpha(.4)
	frame:SetFrameStrata("BACKGROUND")
	frame:SetPoint("CENTER", UIParent, "CENTER", -320, -128)

	local armorRow = CreateRow(0, {{.9, .9, .9}})
	secondaryRow = CreateRow(1, {{1, 1, 0}, {1, .6, 0}})
	masteryRow = CreateRow(2, {{.7, .3, 1}, {.35, .7, 1}})
	defenseRow = CreateRow(3, {{.25, .9, .65}, {1, .45, .45}, {1, .82, .4}})
	speedRow = CreateRow(4, {{.8, .8, 1}})
	timerRow = CreateRow(5, {{1, 1, 1}})
	armorText, speedText, timerText = armorRow.texts[1], speedRow.texts[1], timerRow.texts[1]
	timerRow:Hide()

	fadeGroup = frame:CreateAnimationGroup()
	fadeGroup:SetToFinalAlpha(true)
	fadeAlpha = fadeGroup:CreateAnimation("Alpha")

	for _, event in ipairs({
		"PLAYER_ENTERING_WORLD", "PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED",
		"COMBAT_RATING_UPDATE", "MASTERY_UPDATE", "PLAYER_EQUIPMENT_CHANGED",
		"PLAYER_TALENT_UPDATE", "ACTIVE_PLAYER_SPECIALIZATION_CHANGED",
	}) do
		frame:RegisterEvent(event)
	end
	for _, event in ipairs({ "UNIT_AURA", "UNIT_STATS", "UNIT_SPELL_HASTE", "UNIT_RESISTANCES" }) do
		frame:RegisterUnitEvent(event, "player")
	end
	frame:SetScript("OnEvent", OnEvent)
	frame:SetScript("OnShow", OnShow)
	frame:SetScript("OnHide", OnHide)
	UpdateCombatState(UnitAffectingCombat("player"), true)
	frame:Show()
end
