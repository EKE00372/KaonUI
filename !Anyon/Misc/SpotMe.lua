local addon, ns = ... 
local C, F, G, L = unpack(ns)
if not C.SpotMe then return end

local frame = CreateFrame("Frame", "SpotMe", UIParent)
	local texture = frame:CreateTexture(nil, "BACKGROUND")
	texture:SetAllPoints()
	texture:SetTexture(G.SpotMe)
	texture:SetVertexColor(1,1,1,.8)
	
	frame:SetWidth(100)
	frame:SetHeight(100)
	frame:SetPoint("CENTER", UIParent, 0, -90)
	frame:SetFrameStrata("LOW")

	frame:Hide()
	
	function frame:ToggleVisibility()
		frame:SetShown(not frame:IsShown())
	end

BINDING_NAME_SPOTME = binding_visibility
