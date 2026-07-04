local addon, ns = ... 
local C, F, G, L = unpack(ns)

if not C.SetUIScale then return end
--=================================================--
-----------------    [[ Scale ]]    -----------------
--=================================================--

-- [[ Set UI scale ]] --
-- https://www.wowinterface.com/forums/showthread.php?p=328597

local ceil = math.ceil
local SetCVar = C_CVar.SetCVar

local function SetUIScale()
	local _, height = GetPhysicalScreenSize()
	--local scale = format("%.7f", 768/height)
	local Scale = ceil((768/height) * 10000 + 0.5) / 10000

	SetCVar("useUiScale", "1")
	if Scale >=1 or Scale == 0.5 then
		SetCVar("uiScale", 1)
	elseif (Scale >= 0.65) and (Scale < 1) then
		SetCVar("uiScale", Scale)
	elseif (Scale < 0.65) and (Scale > 0.5) then
		if not InCombatLockdown() then
			SetCVar("uiScale", 1)
			UIParent:SetScale(Scale)
		end
	else
		SetCVar("uiScale", Scale*2)
	end
end

local isScaling = false
local function UpdatePixelScale()
	if isScaling then return end
	
	isScaling = true
	SetUIScale()
	isScaling = false
end

local frame = CreateFrame("Frame")
	frame:RegisterEvent("PLAYER_LOGIN")
	frame:RegisterEvent("UI_SCALE_CHANGED")
	--frame:RegisterEvent("DISPLAY_SIZE_CHANGED")
	frame:SetScript("OnEvent", UpdatePixelScale)