local _, ns = ...
local F = ns[2]
local M = F.RegisterModule("SnowfallCursor", "SnowfallCursor")
local CreateFrame, GetCursorPosition, GetTimePreciseSec = CreateFrame, GetCursorPosition, GetTimePreciseSec
local min, sqrt = math.min, math.sqrt

local texture
local x, y, lastUpdate, scale
local speed, shown
local lastSize, lastPointX, lastPointY

local function UpdateCursor()
	local now = GetTimePreciseSec()
	local elapsed = now - lastUpdate
	if elapsed <= 0 then return end
	lastUpdate = now

	local oldX, oldY = x, y
	x, y = GetCursorPosition()
	local dX, dY = x - oldX, y - oldY
	if dX == 0 and dY == 0 and speed == 0 then return end

	local weight = 2048 ^ -elapsed
	if dX == 0 and dY == 0 then
		speed = weight * speed
	else
		speed = min(weight * speed + (1 - weight) * sqrt(dX * dX + dY * dY) / elapsed, 1024)
	end

	local size = speed / 6 - 12
	if size > 0 then
		if size ~= lastSize then
			texture:SetSize(size, size)
			lastSize = size
		end
		local pointX, pointY = (x + 0.5 * dX) / scale, (y + 0.5 * dY) / scale
		if pointX ~= lastPointX or pointY ~= lastPointY then
			texture:SetPoint("CENTER", UIParent, "BOTTOMLEFT", pointX, pointY)
			lastPointX, lastPointY = pointX, pointY
		end
		if not shown then
			texture:Show()
			shown = true
		end
	else
		if dX == 0 and dY == 0 then
			speed = 0
		end
		if shown then
			texture:Hide()
			shown = false
		end
	end
end

function M:OnEnable()
	x, y = GetCursorPosition()
	lastUpdate = GetTimePreciseSec()
	speed = 0
	shown = false
	scale = UIParent:GetEffectiveScale()

	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetFrameStrata("TOOLTIP")
	frame:RegisterEvent("UI_SCALE_CHANGED")
	frame:SetScript("OnEvent", function()
		scale = UIParent:GetEffectiveScale()
	end)

	texture = frame:CreateTexture()
	texture:SetTexture([[Interface\Cooldown\star4]])
	texture:SetVertexColor(1, 1, .8)	-- default no color setting
	texture:SetBlendMode("ADD")
	texture:SetAlpha(0.8)
	texture:Hide()

	frame.ticker = C_Timer.NewTicker(.05, UpdateCursor)
	frame:Show()
end
