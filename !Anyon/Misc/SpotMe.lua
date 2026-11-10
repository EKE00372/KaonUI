local _, ns = ...
local F, G, L = ns[2], ns[3], ns[4]
local M = F.RegisterModule("SpotMe", "SpotMe")

-- 模組關閉時仍保留按鍵名稱，沿用既有 SPOTME 綁定。
BINDING_NAME_SPOTME = L.SpotMe

function M:OnEnable()
	local frame = CreateFrame("Frame", "SpotMe", UIParent)
	frame:SetSize(100, 100)
	frame:SetPoint("CENTER", UIParent, "CENTER", 0, -90)
	frame:SetFrameStrata("LOW")
	frame:Hide()

	local texture = frame:CreateTexture(nil, "BACKGROUND")
	texture:SetAllPoints()
	texture:SetTexture(G.SpotMe)
	texture:SetVertexColor(1, 1, 1, .8)

	function frame:ToggleVisibility()
		self:SetShown(not self:IsShown())
	end
end
