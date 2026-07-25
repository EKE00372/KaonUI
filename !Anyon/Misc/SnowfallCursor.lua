local addon, ns = ... 
local C, F, G, L = unpack(ns)
local M = F.RegisterModule("SnowfallCursor", "SnowfallCursor")
local CreateFrame, GetCursorPosition = CreateFrame, GetCursorPosition
local min, sqrt = math.min, math.sqrt

function M:OnEnable()
	-- Init.lua 會在 AnyonDB 同步後依 SnowfallCursor 設定呼叫這裡。

	local x, y = GetCursorPosition()
	local speed = 0

	local frame = CreateFrame("Frame", nil, UIParent)
		frame:SetFrameStrata("TOOLTIP")

	local texture = frame:CreateTexture()
		texture:SetTexture([[Interface\Cooldown\star4]])
		texture:SetVertexColor(1, 1,.8)	-- default no color setting
		texture:SetBlendMode("ADD")
		texture:SetAlpha(0.8)
		texture:Hide()

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
				-- 移動貼圖前先清掉上一個錨點，避免 SetPoint 疊加造成位置異常。
				texture:ClearAllPoints()
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
	frame:Show()
end
