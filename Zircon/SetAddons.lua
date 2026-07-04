-- Classic Quest Log
local function SetCQL()
	if not C_AddOns.IsAddOnLoaded("Classic Quest Log") then return end
	if ClassicQuestLogSettings then table.wipe(ClassicQuestLogSettings) end
	
	ClassicQuestLogSettings = {
		["ShowFromObjectiveTracker"] = true,
		["CustomScale"] = 100,
		["ShowResizeGrip"] = false,
		["TempScale"] = 100,
		["ShowTooltips"] = true,
		["LockWindow"] = false,
		["ShowMinimapButton"] = false,
		["ShowLevels"] = true,
		["DontOverrideBind"] = false,
		["UseCustomScale"] = false,
	}
end


local function SetAurora()
	if not C_AddOns.IsAddOnLoaded("AuroraClassic") then return end
	if AuroraClassicDB then table.wipe(AuroraClassicDB) end
	
	AuroraClassicDB = {
		["Shadow"] = true,
		["FlatMode"] = true,
		["ChatBubbles"] = true,
		["Bags"] = false,
		["Alpha"] = 0.6,
		["ObjectiveTracker"] = true,
		["Loot"] = true,
		["FontOutline"] = true,
		["UIScale"] = 0.5334,
		["Tooltips"] = true,
		["FontScale"] = 1,
	}
end

-- Litebag
local function SetLiteBag()
	if not C_AddOns.IsAddOnLoaded("LiteBag") then return end
	if LiteBag_OptionsDB then table.wipe(LiteBag_OptionsDB) end
	
	LiteBag_OptionsDB = {
		["profiles"] = {
			["Default"] = {
				["BANK"] = {
					["columns"] = 16,
				},
				["BACKPACK"] = {
					["columns"] = 12,
				},
			},
		},
	}
end

-- skada
--[[
local function ForceSkadaOptions()
	if not IsAddOnLoaded("Skada") then return end
	if SkadaDB then table.wipe(SkadaDB) end
	SkadaDB = {
	}
end]]--

local SetAddon = CreateFrame("Frame")
	SetAddon:RegisterEvent("PLAYER_LOGIN")
	SetAddon:RegisterEvent("PLAYER_ENTERING_WORLD")
	SetAddon:SetScript("OnEvent", function()
		SetLiteBag()
		SetCQL()
		SetAurora()
	end)
	