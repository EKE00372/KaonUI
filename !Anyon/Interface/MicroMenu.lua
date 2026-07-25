local _, ns = ...
local F = ns[2]
local M = F.RegisterModule("MicroMenu", "MicroMenu")

local _G = _G
local ipairs, select = ipairs, select

local C_Timer_After = C_Timer.After
local UIFrameFadeIn, UIFrameFadeOut = UIFrameFadeIn, UIFrameFadeOut
local UIFrameFadeRemoveFrame, UIFrameIsFading = UIFrameFadeRemoveFrame, UIFrameIsFading

local MICRO_TEXTURE = [[Interface\AddOns\!Anyon\Media\UIMicroMenu2x.blp]]
local INIT_DELAY = 3
local FADE_IN_DURATION = 0.1
local FADE_OUT_DURATION, HOVER_CHECK_DELAY = 3, 0.05

local COLORS = {
	Character = {0.35, 0.65, 1},
	Profession = {0.1, 0.9, 0.9},
	Spellbook = {1, 0.58, 0.65},
	Achievement = {1, 0.62, 0.1},
	QuestLog = {0.96, 1, 0},
	Housing = {0.75, 0.55, 1},
	Guild = {0, 1, 0.1},
	LFD = {0.7, 0.7, 1},
	EJ = {1, 1, 1},
	Collections = {1, 0.7, 0.58},
	Store = {1, 0.83, 0.5},
	MainMenu = {1, 0.4, 0.4},
	Help = {1, 1, 1},
}

local MICRO_BUTTONS = {
	{"CharacterMicroButton", COLORS.Character},
	{"ProfessionMicroButton", COLORS.Profession},
	{"PlayerSpellsMicroButton", COLORS.Spellbook},
	{"AchievementMicroButton", COLORS.Achievement},
	{"QuestLogMicroButton", COLORS.QuestLog},
	{"HousingMicroButton", COLORS.Housing},
	{"GuildMicroButton", COLORS.Guild},
	{"LFDMicroButton", COLORS.LFD},
	{"EJMicroButton", COLORS.EJ},
	{"CollectionsMicroButton", COLORS.Collections},
	{"StoreMicroButton", COLORS.Store},
	{"HelpMicroButton", COLORS.Help},
	{"MainMenuMicroButton", COLORS.MainMenu},
}

local ATLAS_METHODS = {
	"SetNormalAtlas",
	"SetPushedAtlas",
	"SetDisabledAtlas",
	"SetHighlightAtlas",
}

-- MicroMenu 的 atlas: Interface/HUD/UIMicroMenu2x
local MICRO_ATLAS_COORDS = {
	["UI-HUD-MicroMenu-Achievements-Disabled"] = {0.000976562, 0.0634766, 0.00195312, 0.162109},
	["UI-HUD-MicroMenu-Achievements-Down"] = {0.000976562, 0.0634766, 0.166016, 0.326172},
	["UI-HUD-MicroMenu-Achievements-Mouseover"] = {0.000976562, 0.0634766, 0.330078, 0.490234},
	["UI-HUD-MicroMenu-Achievements-Up"] = {0.000976562, 0.0634766, 0.494141, 0.654297},
	["UI-HUD-MicroMenu-AdventureGuide-Disabled"] = {0.000976562, 0.0634766, 0.658203, 0.818359},
	["UI-HUD-MicroMenu-AdventureGuide-Down"] = {0.000976562, 0.0634766, 0.822266, 0.982422},
	["UI-HUD-MicroMenu-AdventureGuide-Mouseover"] = {0.0654297, 0.12793, 0.00195312, 0.162109},
	["UI-HUD-MicroMenu-AdventureGuide-Up"] = {0.0654297, 0.12793, 0.166016, 0.326172},
	["UI-HUD-MicroMenu-Collections-Disabled"] = {0.0654297, 0.12793, 0.658203, 0.818359},
	["UI-HUD-MicroMenu-Collections-Down"] = {0.0654297, 0.12793, 0.822266, 0.982422},
	["UI-HUD-MicroMenu-Collections-Mouseover"] = {0.129883, 0.192383, 0.00195312, 0.162109},
	["UI-HUD-MicroMenu-Collections-Up"] = {0.129883, 0.192383, 0.166016, 0.326172},
	["UI-HUD-MicroMenu-Communities-Icon-Notification"] = {0.838867, 0.875977, 0.00195312, 0.0761719},
	["UI-HUD-MicroMenu-GameMenu-Disabled"] = {0.129883, 0.192383, 0.330078, 0.490234},
	["UI-HUD-MicroMenu-GameMenu-Down"] = {0.129883, 0.192383, 0.494141, 0.654297},
	["UI-HUD-MicroMenu-GameMenu-Mouseover"] = {0.129883, 0.192383, 0.658203, 0.818359},
	["UI-HUD-MicroMenu-GameMenu-Up"] = {0.129883, 0.192383, 0.822266, 0.982422},
	["UI-HUD-MicroMenu-Groupfinder-Disabled"] = {0.194336, 0.256836, 0.00195312, 0.162109},
	["UI-HUD-MicroMenu-Groupfinder-Down"] = {0.194336, 0.256836, 0.166016, 0.326172},
	["UI-HUD-MicroMenu-Groupfinder-Mouseover"] = {0.194336, 0.256836, 0.330078, 0.490234},
	["UI-HUD-MicroMenu-Groupfinder-Up"] = {0.194336, 0.256836, 0.494141, 0.654297},
	["UI-HUD-MicroMenu-GuildCommunities-Disabled"] = {0.194336, 0.256836, 0.658203, 0.818359},
	["UI-HUD-MicroMenu-GuildCommunities-Down"] = {0.194336, 0.256836, 0.822266, 0.982422},
	["UI-HUD-MicroMenu-GuildCommunities-Mouseover"] = {0.258789, 0.321289, 0.658203, 0.818359},
	["UI-HUD-MicroMenu-GuildCommunities-Up"] = {0.258789, 0.321289, 0.822266, 0.982422},
	["UI-HUD-MicroMenu-Highlightalert"] = {0.323242, 0.385742, 0.00195312, 0.162109},
	["UI-HUD-MicroMenu-Questlog-Disabled"] = {0.387695, 0.450195, 0.822266, 0.982422},
	["UI-HUD-MicroMenu-Questlog-Down"] = {0.452148, 0.514648, 0.00195312, 0.162109},
	["UI-HUD-MicroMenu-Questlog-Mouseover"] = {0.452148, 0.514648, 0.166016, 0.326172},
	["UI-HUD-MicroMenu-Questlog-Up"] = {0.452148, 0.514648, 0.330078, 0.490234},
	["UI-HUD-MicroMenu-Shop-Disabled"] = {0.452148, 0.514648, 0.494141, 0.654297},
	["UI-HUD-MicroMenu-Shop-Mouseover"] = {0.452148, 0.514648, 0.658203, 0.818359},
	["UI-HUD-MicroMenu-Shop-Down"] = {0.452148, 0.514648, 0.822266, 0.982422},
	["UI-HUD-MicroMenu-Shop-Up"] = {0.516602, 0.579102, 0.00195312, 0.162109},
	["UI-HUD-MicroMenu-SpecTalents-Disabled"] = {0.516602, 0.579102, 0.166016, 0.326172},
	["UI-HUD-MicroMenu-SpecTalents-Down"] = {0.516602, 0.579102, 0.330078, 0.490234},
	["UI-HUD-MicroMenu-SpecTalents-Mouseover"] = {0.516602, 0.579102, 0.494141, 0.654297},
	["UI-HUD-MicroMenu-SpecTalents-Up"] = {0.516602, 0.579102, 0.658203, 0.818359},
	["UI-HUD-MicroMenu-SpellbookAbilities-Disabled"] = {0.516602, 0.579102, 0.822266, 0.982422},
	["UI-HUD-MicroMenu-SpellbookAbilities-Down"] = {0.581055, 0.643555, 0.00195312, 0.162109},
	["UI-HUD-MicroMenu-SpellbookAbilities-Mouseover"] = {0.581055, 0.643555, 0.166016, 0.326172},
	["UI-HUD-MicroMenu-SpellbookAbilities-Up"] = {0.581055, 0.643555, 0.330078, 0.490234},
	["UI-HUD-MicroMenu-StreamDLGreen-Down"] = {0.581055, 0.643555, 0.494141, 0.654297},
	["UI-HUD-MicroMenu-StreamDLGreen-Up"] = {0.581055, 0.643555, 0.658203, 0.818359},
	["UI-HUD-MicroMenu-StreamDLRed-Down"] = {0.581055, 0.643555, 0.822266, 0.982422},
	["UI-HUD-MicroMenu-StreamDLRed-Up"] = {0.645508, 0.708008, 0.00195312, 0.162109},
	["UI-HUD-MicroMenu-StreamDLYellow-Down"] = {0.709961, 0.772461, 0.00195312, 0.162109},
	["UI-HUD-MicroMenu-StreamDLYellow-Up"] = {0.774414, 0.836914, 0.00195312, 0.162109},
	["UI-HUD-MicroMenu-ButtonBG-Down"] = {0.0654297, 0.12793, 0.330078, 0.490234},
	["UI-HUD-MicroMenu-ButtonBG-Up"] = {0.0654297, 0.12793, 0.494141, 0.654297},
	["UI-HUD-MicroMenu-Portrait-Shadow"] = {0.387695, 0.450195, 0.00195312, 0.162109},
	["UI-HUD-MicroMenu-Portrait-Down"] = {0.323242, 0.385742, 0.822266, 0.982422},
	["UI-HUD-MicroMenu-GuildCommunities-GuildColor-Disabled"] = {0.258789, 0.321289, 0.00195312, 0.162109},
	["UI-HUD-MicroMenu-GuildCommunities-GuildColor-Down"] = {0.258789, 0.321289, 0.166016, 0.326172},
	["UI-HUD-MicroMenu-GuildCommunities-GuildColor-Mouseover"] = {0.258789, 0.321289, 0.330078, 0.490234},
	["UI-HUD-MicroMenu-GuildCommunities-GuildColor-Up"] = {0.258789, 0.321289, 0.494141, 0.654297},
	["UI-HUD-MicroMenu-Professions-Disabled"] = {0.387695, 0.450195, 0.166016, 0.326172},
	["UI-HUD-MicroMenu-Professions-Down"] = {0.387695, 0.450195, 0.330078, 0.490234},
	["UI-HUD-MicroMenu-Professions-Mouseover"] = {0.387695, 0.450195, 0.494141, 0.654297},
	["UI-HUD-MicroMenu-Professions-Up"] = {0.387695, 0.450195, 0.658203, 0.818359},
	["UI-HUD-MicroMenu-Housing-Disabled"] = {0.323242, 0.385742, 0.166016, 0.326172},
	["UI-HUD-MicroMenu-Housing-Down"] = {0.323242, 0.385742, 0.330078, 0.490234},
	["UI-HUD-MicroMenu-Housing-Mouseover"] = {0.323242, 0.385742, 0.494141, 0.654297},
	["UI-HUD-MicroMenu-Housing-Up"] = {0.323242, 0.385742, 0.658203, 0.818359},
}

-- 替換按鈕材質並套用顏色
local function StyleTexture(texture, color)
	if not texture or not texture.GetObjectType or texture:GetObjectType() ~= "Texture" then return end
	if texture.IsForbidden and texture:IsForbidden() then return end

	local atlas = texture.GetAtlas and texture:GetAtlas()
	local coords = atlas and MICRO_ATLAS_COORDS[atlas]
	if coords then
		texture.AnyonMicroMenuAtlas = atlas

		local width, height = texture:GetSize()
		texture:SetTexture(MICRO_TEXTURE)
		texture:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
		if width and height and width > 0 and height > 0 then
			texture:SetSize(width, height)
		end
	end

	-- 替換後 GetAtlas() 會變成 nil，因此用 AnyonMicroMenuAtlas 判斷材質是否仍屬於 micromenu
	if texture.AnyonMicroMenuAtlas then
		texture:SetVertexColor(color[1], color[2], color[3])
	end
end

-- 將樣式套用到按鈕的所有狀態
local function StyleButton(button)
	if not button then return end

	local color = button.AnyonMicroMenuColor or COLORS.Help
	if button.GetNormalTexture then StyleTexture(button:GetNormalTexture(), color) end
	if button.GetPushedTexture then StyleTexture(button:GetPushedTexture(), color) end
	if button.GetDisabledTexture then StyleTexture(button:GetDisabledTexture(), color) end
	if button.GetHighlightTexture then StyleTexture(button:GetHighlightTexture(), color) end

	for i = 1, select("#", button:GetRegions()) do
		StyleTexture(select(i, button:GetRegions()), color)
	end
end

-- 依照 MICRO_BUTTONS 設定，將樣式套用到所有的按鈕
local function StyleAllButtons()
	for _, buttonInfo in ipairs(MICRO_BUTTONS) do
		local button = _G[buttonInfo[1]]
		if button then
			button.AnyonMicroMenuColor = buttonInfo[2]
			StyleButton(button)
		end
	end
end

-- 淡入淡出 API
local function FadeMicroMenu(targetAlpha, duration)
	if MicroMenu.AnyonMicroMenuFadeTarget == targetAlpha and UIFrameIsFading(MicroMenu) then return end

	UIFrameFadeRemoveFrame(MicroMenu)
	MicroMenu.AnyonMicroMenuFadeTarget = targetAlpha

	local startAlpha = MicroMenu:GetAlpha() or 0
	if startAlpha == targetAlpha then
		MicroMenu:SetAlpha(targetAlpha)
		return
	end

	if targetAlpha > startAlpha then
		UIFrameFadeIn(MicroMenu, duration, startAlpha, targetAlpha)
	else
		UIFrameFadeOut(MicroMenu, duration, startAlpha, targetAlpha)
	end
end

-- 淡入
local function FadeIn()
	FadeMicroMenu(1, FADE_IN_DURATION)
end

-- 淡出
local function FadeOut()
	-- 編輯模式中保持顯示
	if EditModeManagerFrame and EditModeManagerFrame:IsShown() then return end
	-- 延遲淡出，防止滑鼠在按鈕之間移動時閃爍
	if MicroMenu:IsMouseOver() then return end

	FadeMicroMenu(0, FADE_OUT_DURATION)
end

-- 淡出延遲
local function QueueFadeOut()
	C_Timer_After(HOVER_CHECK_DELAY, FadeOut)
end

-- 暴雪會在 UpdateMicroButtons、SetNormal、SetPushed、MainMenuMicroButton:OnUpdate 等流程重設 atlas
-- hook 這幾個按鈕方法後，每次暴雪換回原 atlas 插件就換回去
local function HookButton(button)
	if not button or button.AnyonMicroMenuHooked then return end
	button.AnyonMicroMenuHooked = true

	for _, method in ipairs(ATLAS_METHODS) do
		if button[method] then
			hooksecurefunc(button, method, StyleButton)
		end
	end

	button:HookScript("OnEnter", FadeIn)
	button:HookScript("OnLeave", QueueFadeOut)
	button:HookScript("OnShow", StyleButton)
end

-- Hook 所有已知的按鈕
local function HookAllButtons()
	for _, buttonInfo in ipairs(MICRO_BUTTONS) do
		local button = _G[buttonInfo[1]]
		if button then
			button.AnyonMicroMenuColor = buttonInfo[2]
			HookButton(button)
		end
	end
end

-- Hook 編輯模式以強制顯示
local function HookEditMode()
	if not EditModeManagerFrame or EditModeManagerFrame.AnyonMicroMenuHooked then return end
	EditModeManagerFrame.AnyonMicroMenuHooked = true

	EditModeManagerFrame:HookScript("OnShow", FadeIn)
	EditModeManagerFrame:HookScript("OnHide", QueueFadeOut)
end

-- 初始化
local function SetupMicroMenu()
	HookAllButtons()
	HookEditMode()

	if UpdateMicroButtons then
		hooksecurefunc("UpdateMicroButtons", StyleAllButtons)
	end

	hooksecurefunc("LoadMicroButtonTextures", StyleButton)

	StyleAllButtons()

	-- 初始固定透明；之後由滑鼠移入/移出控制淡入淡出。
	UIFrameFadeRemoveFrame(MicroMenu)
	MicroMenu.AnyonMicroMenuFadeTarget = 0
	MicroMenu:SetAlpha(0)
end

-- 模組啟用入口：隱藏背包列，並初始化 MicroMenu 外觀。
function M:OnEnable()
	-- 隱藏背包欄
	BagsBar:UnregisterAllEvents()
	BagsBar:Hide()
	BagsBar:HookScript("OnShow", BagsBar.Hide)

	MicroMenu.AnyonMicroMenuFadeTarget = 0
	MicroMenu:SetAlpha(0)

	-- PLAYER_LOGIN 後等一秒再處理 MicroMenu，讓暴雪自己的初始化先跑完。
	C_Timer_After(INIT_DELAY, SetupMicroMenu)
end
