--自定义体API，启用描边禁用阴影，可读性较佳
local function SetFont(obj, optSize)
	local fontName, _,fontFlags = obj:GetFont()
	obj:SetFont(fontName, optSize, "OUTLINE")
	obj:SetShadowOffset(0, 0)
end

local function default()
	--C_CVar.RegisterCVar("nameplateShowOnlyNames")
	--SetCVar("nameplateShowOnlyNames", 1)
	SetCVar("nameplateShowOnlyNameForFriendlyPlayerUnits", 1)
	SetCVar("nameplateUseClassColorForFriendlyPlayerUnitNames", 1)
	--SetCVar("nameplateShowFriendlyNPCs", 1)

	SetFont(SystemFont_LargeNamePlate, 12)
	SetFont(SystemFont_NamePlate, 12)
	SetFont(SystemFont_LargeNamePlateFixed, 12)
	SetFont(SystemFont_NamePlateFixed, 12)
	SetFont(SystemFont_NamePlateCastBar, 12)
	SetFont(SystemFont_NamePlate_Outlined, 12)
	
	--C_NamePlate.SetNamePlateFriendlySize(1, -25)
	--C_NamePlate.SetNamePlateFriendlyClickThrough(true)
end

--载入事件
local frame = CreateFrame("FRAME")
	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	frame:RegisterEvent("PLAYER_LOGIN")
	--frame:RegisterEvent("VARIABLES_LOADED")
	--frame:RegisterEvent("NAME_PLATE_CREATED")
	--frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
	--frame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
	--frame:RegisterEvent("CVAR_UPDATE")
	--frame:RegisterEvent("DISPLAY_SIZE_CHANGED")

	frame:SetScript("OnEvent", default)