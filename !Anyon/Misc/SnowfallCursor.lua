local addon, ns = ... 
local C, F, G, L = unpack(ns)
if not C.SnowfallCursor then return end

local CreateFrame = CreateFrame
local GetCursorPosition, GetEffectiveScale = GetCursorPosition, GetEffectiveScale
local min, sqrt = math.min, math.sqrt

local x = 0
local y = 0
local speed = 0

local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetFrameStrata("TOOLTIP")

local texture = frame:CreateTexture()
	texture:SetTexture([[Interface\Cooldown\star4]])
	texture:SetVertexColor(1, 1,.8)	-- default no color setting
	texture:SetBlendMode("ADD")
	texture:SetAlpha(0.8)

local function OnUpdate(self, elapsed)
	self.timer = (self.timer or 0) + elapsed
	
	if self.timer > .05 then		-- default no limit update timer
		local dX = x
		local dY = y
		x, y = GetCursorPosition()
		dX = x - dX
		dY = y - dY
		
		local weight = 2048 ^ - elapsed
		speed = min(weight * speed + (1 - weight) * sqrt(dX * dX + dY * dY) / elapsed, 1024)
		
		local size = speed / 6 - 12	-- default: 6-16
		if size > 0 then
			local scale = UIParent:GetEffectiveScale()
			texture:SetHeight(size)
			texture:SetWidth(size)
			texture:SetPoint("CENTER", UIParent, "BOTTOMLEFT", (x + 0.5 * dX) / scale, (y + 0.5 * dY) / scale)
			texture:Show()
		else
			texture:Hide()
		end
		
		self.timer = 0
	end
end

	frame:SetScript("OnUpdate", OnUpdate)