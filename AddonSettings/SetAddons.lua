-- Classic Quest Log
local function SetCQL()
	if not IsAddOnLoaded("Classic Quest Log") then return end
	if ClassicQuestLogSettings then table.wipe(ClassicQuestLogSettings) end
	ClassicQuestLogSettings = {
	["ShowTooltips"] = true,
	["UndockWindow"] = false,
	["Height"] = 496,
	["SolidBackground"] = true,
	["ShowLevels"] = true,
	}
end


local function SetAurora()
	if not IsAddOnLoaded("AuroraClassic") then return end
	if AuroraConfig then table.wipe(AuroraConfig) end
	AuroraConfig = {
		["useButtonGradientColour"] = true,
		["shadow"] = true,
		["fontScale"] = 1,
		["chatBubbles"] = true,
		["bags"] = true,
		["alpha"] = 0.7,
		["reskinFont"] = true,
		["buttonGradientColour"] = {
			0.3, -- [1]
			0.3, -- [2]
			0.3, -- [3]
			0.3, -- [4]
		},
		["loot"] = true,
		["tooltips"] = true,
		["useCustomColour"] = false,
		["customColour"] = {
			["b"] = 1,
			["g"] = 1,
			["r"] = 1,
		},
		["bubbleColor"] = false,
		["buttonSolidColour"] = {
			0.2, -- [1]
			0.2, -- [2]
			0.2, -- [3]
			1, -- [4]
		},
	}
end

-- Litebag
local function SetLiteBag()
	if not IsAddOnLoaded("LiteBag") then return end
	if LiteBag_OptionsDB then table.wipe(LiteBag_OptionsDB) end
	LiteBag_OptionsDB = {
		["Frame:LiteBagInventoryPanel"] = {
			["columns"] = 10,
		},
		["Frame:LiteBagBankPanel"] = {
			["columns"] = 14,
		},
		["NoConfirmSort"] = true,
	}
end

-- skada
--[[
local function ForceSkadaOptions()
	if not IsAddOnLoaded("Skada") then return end
	if(SkadaDB) then table.wipe(SkadaDB) end
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
