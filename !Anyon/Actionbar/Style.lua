local addon, ns = ...
local C, F, G, L = unpack(ns)
local M = F.RegisterModule("ActionbarStyle", "ActionbarStyle")

-- [[ Action bar style ]] --

local pairs, ipairs = pairs, ipairs
local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local gsub = string.gsub
local min, max = math.min, math.max

local ANIMATION_FRAMELEVEL_OFFSET, OVERLAY_FRAMELEVEL_OFFSET = 6, 8 -- 施法動畫層級，flyout箭頭層級
local TEXT_FRAMELEVEL_OFFSET, TEXT_DRAW_SUBLEVEL = 10, 7 -- 文字層級
local MACRO_TEXT_WIDTH = 36

local styledButtons = {}
local pendingButtons = {}
local spellAlertHooked
local castAnimHooked

local blizzardArtKeys = {
	"SlotArt",
	"SlotBackground",
	"FloatingBG",
	"Border",
	"IconBorder",
	"IconMask",
}

local nativeOverlayFrameKeys = {
	"AutoCastOverlay",
	"FlyoutArrowContainer",
}

local nativeAnimationFrameKeys = {
	"InterruptDisplay",
	"SpellCastAnimFrame",
	"CastingAnimFrame",
	"TargetReticleAnimFrame",
}

local cooldownFrameKeys = {
	"cooldown",
	"Cooldown",
	"lossOfControlCooldown",
	"chargeCooldown",
	"ChargeCooldown", -- 區域技能按鈕的充能冷卻
}

--===================================================--
-----------------    [[ Hotkeys ]]    -----------------
--===================================================--

local function EscapePattern(text)
	return text and gsub(text, "([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
end

local KEY_BUTTON_PREFIX = EscapePattern(gsub(KEY_BUTTON4 or "BUTTON", "%d", ""))
local KEY_NUMPAD_PREFIX = EscapePattern(gsub(KEY_NUMPAD1 or "NUMPAD", "%d", ""))

local hotKeyReplacements = {
	{EscapePattern(KEY_MOUSEWHEELUP), "MWU"},
	{EscapePattern(KEY_MOUSEWHEELDOWN), "MWD"},
	{EscapePattern(KEY_BUTTON3), "M3"},
	{KEY_BUTTON_PREFIX, "M"},
	{KEY_NUMPAD_PREFIX, "N"},
	{"MOUSEWHEELUP", "MWU"},
	{"MOUSEWHEELDOWN", "MWD"},
	{"MOUSE BUTTON ", "M"},
	{"Mouse Wheel Up", "MWU"},
	{"Mouse Wheel Down", "MWD"},
	{"Mouse Button ", "M"},
	{"BUTTON", "M"},
	{"NUMPAD", "N"},
	{"Caps Lock", "Cap"},
	{"Capslock", "Cap"},
	{"CAPS LOCK", "Cap"},
	{"CAPSLOCK", "Cap"},
	{"SPACE", "Sp"},
	{"Space", "Sp"},
	{"LALT%-", "A-"},
	{"RALT%-", "A-"},
	{"ALT%-", "A-"},
	{"Alt%-", "A-"},
	{"LCTRL%-", "C-"},
	{"RCTRL%-", "C-"},
	{"CTRL%-", "C-"},
	{"Ctrl%-", "C-"},
	{"LSHIFT%-", "S-"},
	{"RSHIFT%-", "S-"},
	{"SHIFT%-", "S-"},
	{"Shift%-", "S-"},
	{"META%-", "Meta-"},
	{"Meta%-", "Meta-"},
}

--=====================================================--
-----------------    [[ Functions ]]    -----------------
--=====================================================--

local function SetInside(region, anchor, inset)
	region:ClearAllPoints()
	region:SetPoint("TOPLEFT", anchor, "TOPLEFT", inset, -inset)
	region:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", -inset, inset)
end

-- 計算層級
local function GetRelativeFrameLevel(anchor, offset)
	local level = anchor and anchor.GetFrameLevel and anchor:GetFrameLevel() or 0
	level = level + offset

	return level > 0 and level or 0
end

-- 設定層級
local function SetRelativeFrameLevel(frame, anchor, offset, onlyRaise)
	if not frame or not frame.SetFrameLevel then return end

	local level = GetRelativeFrameLevel(anchor, offset)
	local currentLevel = frame.GetFrameLevel and frame:GetFrameLevel()
	if not (onlyRaise and currentLevel and currentLevel >= level) and currentLevel ~= level then
		frame:SetFrameLevel(level)
	end
end

-- 獲取要美化的按鈕，之後的美化都是套用到這個框體
local function GetSkinFrame(button)
	return button.AnyonActionbarSkinFrame or button
end

local function HideTexture(texture)
	if not texture then return end

	if texture.SetTexture then texture:SetTexture() end
	if texture.SetAlpha then texture:SetAlpha(0) end
	if texture.Hide then texture:Hide() end
end

-- 獲取要美化的按鈕其上的技能圖示
local function GetButtonIcon(button)
	return button.icon or button.Icon
end

local function RemoveIconMask(button)
	local icon = GetButtonIcon(button)
	local mask = button.IconMask
	if not icon or not mask then return end

	if icon.RemoveMaskTexture then
		icon:RemoveMaskTexture(mask)
	end
end

-- 判斷空按鈕
local function HasButtonAction(button)
	if button.HasAction then
		return button:HasAction()
	end

	local icon = GetButtonIcon(button)
	return icon and icon.GetTexture and icon:GetTexture()
end

-- 按鈕上元素的層級
local function StyleNativeOverlayFrames(button)
	if not button then return end

	-- 施法動畫
	for _, key in ipairs(nativeAnimationFrameKeys) do
		SetRelativeFrameLevel(button[key], button, ANIMATION_FRAMELEVEL_OFFSET, true)
	end

	-- 自動施法提示和flyout的箭頭
	for _, key in ipairs(nativeOverlayFrameKeys) do
		SetRelativeFrameLevel(button[key], button, OVERLAY_FRAMELEVEL_OFFSET, true)
	end

	local textOverlay = button.TextOverlayContainer or button.AnyonActionbarTextOverlay
	if not textOverlay then return end

	local texture = button.LevelLinkLockIcon
	if texture then
		if texture.SetParent and texture.GetParent and texture:GetParent() ~= textOverlay then
			texture:SetParent(textOverlay)
		end

		if texture.SetDrawLayer then
			texture:SetDrawLayer("OVERLAY", TEXT_DRAW_SUBLEVEL - 1)
		end
	end
end

local function UpdateStyleFrameLevels(button)
	if not button then return end

	SetRelativeFrameLevel(button.AnyonActionbarSkinFrame, button, 0)
	StyleNativeOverlayFrames(button)

	local textOverlay = button.TextOverlayContainer or button.AnyonActionbarTextOverlay
	if textOverlay then
		SetRelativeFrameLevel(textOverlay, button, TEXT_FRAMELEVEL_OFFSET, true)
	end
end

local function AddFontOutline(fontString)
	if not fontString or fontString.AnyonActionbarFontStyled then return end

	local font, size = fontString:GetFont()
	if font and size then
		fontString.AnyonActionbarBaseFont = font
		fontString.AnyonActionbarBaseSize = size
		fontString:SetFont(font, size, "OUTLINE")
		fontString.AnyonActionbarFontStyled = true
	end
end

local function StyleProfessionQualityOverlay(button)
	local frame = button.ProfessionQualityOverlayFrame
	if not frame or frame.AnyonActionbarFrameLevelStyled then return end

	SetRelativeFrameLevel(frame, button, OVERLAY_FRAMELEVEL_OFFSET, true)
	frame.AnyonActionbarFrameLevelStyled = true
end

local function RestoreAssistedCombatOverlayLevel(frame, event)
	if event ~= "PLAYER_ENTERING_WORLD" then return end

	SetRelativeFrameLevel(frame, frame:GetParent(), ANIMATION_FRAMELEVEL_OFFSET, true)
end

local function StyleAssistedCombatOverlay(button)
	local frame = button.AssistedCombatRotationFrame
	if not frame or frame.AnyonActionbarFrameLevelHooked then return end

	SetRelativeFrameLevel(frame, button, ANIMATION_FRAMELEVEL_OFFSET, true)
	frame:HookScript("OnEvent", RestoreAssistedCombatOverlayLevel)
	frame.AnyonActionbarFrameLevelHooked = true
end

local function SetFontStringColor(fontString, r, g, b)
	if fontString and fontString.SetTextColor then
		fontString:SetTextColor(r, g, b)
	end
end

local function GetFontStringWidth(fontString)
	if fontString.GetUnboundedStringWidth then
		return fontString:GetUnboundedStringWidth()
	end

	if fontString.GetStringWidth then
		return fontString:GetStringWidth()
	end

	return 0
end

-- 處理按鈕上的文字
local function FitFontStringWidth(fontString, maxWidth, minSize)
	if not fontString or not fontString.SetFont then return end

	local font = fontString.AnyonActionbarBaseFont
	local baseSize = fontString.AnyonActionbarBaseSize
	if not font or not baseSize then
		font, baseSize = fontString:GetFont()
		fontString.AnyonActionbarBaseFont = font
		fontString.AnyonActionbarBaseSize = baseSize
	end

	if not font or not baseSize then return end

	fontString:SetFont(font, baseSize, "OUTLINE")
	if GetFontStringWidth(fontString) <= maxWidth then return end

	local size = baseSize - 1
	while size >= minSize do
		fontString:SetFont(font, size, "OUTLINE")
		if GetFontStringWidth(fontString) <= maxWidth then return end

		size = size - 1
	end

	fontString:SetFont(font, minSize, "OUTLINE")
end

local function RefreshMacroText(name)
	local text = name:GetText()
	if name.AnyonActionbarLastMacroText ~= text then
		FitFontStringWidth(name, MACRO_TEXT_WIDTH, 8)
		name.AnyonActionbarLastMacroText = text
	end
end

local function StyleMacroFont(name)
	AddFontOutline(name)
	SetFontStringColor(name, 0.72, 0.72, 0.72)
	RefreshMacroText(name)
end

local function ShortenHotKeyText(text)
	if not text or text == "" or text == RANGE_INDICATOR then return text end

	for _, value in ipairs(hotKeyReplacements) do
		if value[1] then
			text = gsub(text, value[1], value[2])
		end
	end

	return text
end

local function RefreshHotKeyText(hotkey)
	if not hotkey or hotkey.AnyonActionbarHotKeyUpdating then return end

	local text = hotkey:GetText()
	local shortText = ShortenHotKeyText(text)
	if shortText and shortText ~= text then
		hotkey.AnyonActionbarHotKeyUpdating = true
		hotkey:SetText(shortText)
		hotkey.AnyonActionbarHotKeyUpdating = nil
		text = shortText
	end

	if hotkey.AnyonActionbarLastHotKeyText ~= text then
		FitFontStringWidth(hotkey, 32, 8)
		hotkey.AnyonActionbarLastHotKeyText = text
	end
end

local function StyleHotKeyFont(hotkey)
	AddFontOutline(hotkey)
	SetFontStringColor(hotkey, 1, 1, 1)
	RefreshHotKeyText(hotkey)
end

local function HookHotKeyText(hotkey)
	if not hotkey or hotkey.AnyonActionbarHotKeyHooked then return end

	hooksecurefunc(hotkey, "SetText", RefreshHotKeyText)
	hotkey.AnyonActionbarHotKeyHooked = true
end

local function HookMacroText(name)
	if name.AnyonActionbarTextHooked then return end

	hooksecurefunc(name, "SetText", RefreshMacroText)
	name.AnyonActionbarTextHooked = true
end

local function GetTextOverlayFrame(button)
	local overlay = button.TextOverlayContainer or button.AnyonActionbarTextOverlay
	if not overlay then
		overlay = CreateFrame("Frame", nil, button)
		overlay:SetAllPoints(button)
		button.AnyonActionbarTextOverlay = overlay
	end

	SetRelativeFrameLevel(overlay, button, TEXT_FRAMELEVEL_OFFSET, true)

	return overlay
end

local function StyleMacroText(button)
	local name = button and button.Name
	if not name or name.AnyonActionbarTextStyled then return end

	local overlay = GetTextOverlayFrame(button)
	if name:GetParent() ~= overlay then
		name:SetParent(overlay)
	end

	name:ClearAllPoints()
	name:SetPoint("BOTTOM", GetSkinFrame(button), "BOTTOM", 0, 2)
	name:SetSize(MACRO_TEXT_WIDTH, 12)
	name:SetDrawLayer("OVERLAY", TEXT_DRAW_SUBLEVEL)
	name.AnyonActionbarTextStyled = true
	HookMacroText(name)
	StyleMacroFont(name)
end

local function StyleButtonText(button)
	if button.HotKey then
		HookHotKeyText(button.HotKey)
		StyleHotKeyFont(button.HotKey)
	end

	if button.Count then
		AddFontOutline(button.Count)
		SetFontStringColor(button.Count, 1, 0.74, 0.2)
	end

	StyleMacroText(button)
end

local function StyleIcon(button)
	local icon = GetButtonIcon(button)
	if not icon then return end

	RemoveIconMask(button)
	SetInside(icon, GetSkinFrame(button), 0)
	icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	icon:SetSnapToPixelGrid(false)	-- 使圖示和邊框可以貼齊
	icon:SetTexelSnappingBias(0)
	icon:SetDrawLayer("BACKGROUND", 0)
end

local function StyleCooldownSize(button)
	local anchor = GetButtonIcon(button)
	if not anchor then return end

	for _, key in ipairs(cooldownFrameKeys) do
		local cooldown = button[key]
		if cooldown and cooldown.ClearAllPoints and not cooldown.AnyonActionbarSizeStyled then
			cooldown:ClearAllPoints()
			cooldown:SetPoint("TOPLEFT", anchor, "TOPLEFT", -1, 1)
			cooldown:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", 1, -1)
			cooldown.AnyonActionbarSizeStyled = true
		end
	end
end

local function StyleStateTexture(texture, button, r, g, b, a, blendMode)
	if not texture then return end

	texture:SetColorTexture(r, g, b, a)
	texture:SetBlendMode(blendMode or "BLEND")
	SetInside(texture, GetSkinFrame(button), 0)
end

local function HideBlizzardArt(button)
	for _, key in ipairs(blizzardArtKeys) do
		HideTexture(button[key])
	end

	if button.GetNormalTexture then
		HideTexture(button:GetNormalTexture())
	end
end

local function StyleStateTextures(button)
	if button.GetPushedTexture then
		StyleStateTexture(button:GetPushedTexture(), button, 0, 0, 0, 0.35)
	end

	if button.GetCheckedTexture then
		StyleStateTexture(button:GetCheckedTexture(), button, 1, 0.82, 0.24, 0.28, "ADD")
	end

	if button.GetHighlightTexture then
		StyleStateTexture(button:GetHighlightTexture(), button, 1, 1, 1, 0.20, "ADD")
	end

	StyleStateTexture(button.Flash, button, 1, 0.78, 0.32, 0.25, "ADD")
	StyleStateTexture(button.NewActionTexture, button, 0.65, 1, 1, 0.45, "ADD")
	StyleStateTexture(button.SpellHighlightTexture, button, 0.65, 1, 1, 0.44, "ADD")
	StyleStateTexture(button.QuickKeybindHighlightTexture, button, 0.45, 0.80, 1, 0.42, "ADD")
end

local function GetEffectPadding(button, small, regular, extra)
	if button.SmallActionButtonMixin_OnLoad then return small end
	if button == ExtraActionButton1 or button.Icon then return extra end
	return regular
end

local function ClearSpellAlertTexture(texture)
	if not texture then return end

	if texture.SetColorTexture then
		texture:SetColorTexture(0, 0, 0, 0)
	elseif texture.SetTexture then
		texture:SetTexture()
	end
end

local function StyleSpellAlertFrame(frame)
	if not frame or frame.AnyonActionbarStyleApplied then return end

	ClearSpellAlertTexture(frame.ProcStartFlipbook)
	ClearSpellAlertTexture(frame.ProcLoopFlipbook)
	ClearSpellAlertTexture(frame.ProcAltGlow)
	frame.AnyonActionbarStyleApplied = true
end

local function StyleSpellAlertFrames(button)
	if not button then return end

	StyleSpellAlertFrame(button.SpellActivationAlert)

	local assistedCombatFrame = button.AssistedCombatRotationFrame
	if assistedCombatFrame then
		StyleSpellAlertFrame(assistedCombatFrame.SpellActivationAlert)
	end
end

local function StyleCastAnimFrame(castFrame, actionButtonCastType)
	local glow = castFrame.AnyonActionbarCastGlow
	if not glow then return end

	if actionButtonCastType == 2 then -- 引導
		glow:SetVertexColor(0.35, 0.72, 1, 1)
	else
		glow:SetVertexColor(1, 0.82, 0.28, 1)
	end

	glow:Show()
end

-- 處理空按鈕
local function UpdateSkinVisibility(button)
	local hasAction = not not HasButtonAction(button)
	if button.AnyonActionbarHasAction == hasAction then return end

	button.AnyonActionbarHasAction = hasAction
	local effectAlpha = hasAction and 1 or 0
	button.AnyonActionbarShadow:SetAlpha(effectAlpha)
	button.AnyonActionbarIconBackground:SetAlpha(effectAlpha)
	button.AnyonActionbarProcGlow:SetAlpha(effectAlpha)
	local castFrame = button.SpellCastAnimFrame
	if castFrame then
		castFrame.AnyonActionbarCastGlow:SetAlpha(effectAlpha)
	end
	local alpha = hasAction and 1 or 0.45
	for _, border in ipairs(button.AnyonActionbarBorders) do
		border:SetAlpha(alpha)
	end
end

-- 套用按鈕美化
local function ApplyButtonStyle(button)
	HideBlizzardArt(button)
	StyleIcon(button)
	StyleCooldownSize(button)
	StyleStateTextures(button)
	UpdateSkinVisibility(button)
	StyleButtonText(button)
end

local function RestoreButtonArt(button)
	HideBlizzardArt(button)
	if button.GetPushedTexture then
		StyleStateTexture(button:GetPushedTexture(), button, 0, 0, 0, 0.35)
	end
end

-- 創建美化
local function CreateStyleFrames(button)
	if button.AnyonActionbarFramesCreated then return end

	local skinFrame = button.AnyonActionbarSkinFrame
	if not skinFrame then
		skinFrame = CreateFrame("Frame", nil, button)
		SetInside(skinFrame, button, 3)
		skinFrame:EnableMouse(false)
		button.AnyonActionbarSkinFrame = skinFrame
	end

	local padding = button.SmallActionButtonMixin_OnLoad and 5 or 7 -- 普通陰影：小按鈕外擴5，普通和額外技能7
	local shadow = button:CreateTexture(nil, "BACKGROUND", nil, -4)
	shadow:SetTexture(G.IconBorderTex)
	shadow:SetVertexColor(0, 0, 0, 1)
	shadow:SetSnapToPixelGrid(false)
	shadow:SetTexelSnappingBias(0)
	shadow:SetBlendMode("BLEND")
	shadow:SetPoint("TOPLEFT", skinFrame, "TOPLEFT", -padding, padding)
	shadow:SetPoint("BOTTOMRIGHT", skinFrame, "BOTTOMRIGHT", padding, -padding)
	button.AnyonActionbarShadow = shadow

	-- 有技能時遮住光暈內框，空格時透明
	local background = button:CreateTexture(nil, "BACKGROUND", nil, -1)
	background:SetColorTexture(0.05, 0.05, 0.05, 1)
	background:SetSnapToPixelGrid(false)
	background:SetTexelSnappingBias(0)
	SetInside(background, skinFrame, 0)
	button.AnyonActionbarIconBackground = background

	-- 1px邊框
	local borders = {}
	for i = 1, 4 do
		local border = button:CreateTexture(nil, "BACKGROUND", nil, -1)
		border:SetColorTexture(0.05, 0.05, 0.05, 1)
		border:SetSnapToPixelGrid(false)
		border:SetTexelSnappingBias(0)
		borders[i] = border
	end
	borders[1]:SetHeight(1)
	borders[1]:SetPoint("TOPLEFT", skinFrame, "TOPLEFT", -1, 1)
	borders[1]:SetPoint("TOPRIGHT", skinFrame, "TOPRIGHT", 1, 1)
	borders[2]:SetHeight(1)
	borders[2]:SetPoint("BOTTOMLEFT", skinFrame, "BOTTOMLEFT", -1, -1)
	borders[2]:SetPoint("BOTTOMRIGHT", skinFrame, "BOTTOMRIGHT", 1, -1)
	borders[3]:SetWidth(1)
	borders[3]:SetPoint("TOPLEFT", skinFrame, "TOPLEFT", -1, 0)
	borders[3]:SetPoint("BOTTOMLEFT", skinFrame, "BOTTOMLEFT", -1, 0)
	borders[4]:SetWidth(1)
	borders[4]:SetPoint("TOPRIGHT", skinFrame, "TOPRIGHT", 1, 0)
	borders[4]:SetPoint("BOTTOMRIGHT", skinFrame, "BOTTOMRIGHT", 1, 0)
	button.AnyonActionbarBorders = borders

	local procPadding = GetEffectPadding(button, 9, 14, 16) -- 高亮陰影：小按鈕外擴9，普通14，額外技能16
	local proc = button:CreateTexture(nil, "BACKGROUND", nil, -3)
	proc:SetTexture(G.ButtonProcTex)
	proc:SetSnapToPixelGrid(false)
	proc:SetTexelSnappingBias(0)
	proc:SetBlendMode("BLEND")
	proc:SetPoint("TOPLEFT", skinFrame, "TOPLEFT", -procPadding, procPadding)
	proc:SetPoint("BOTTOMRIGHT", skinFrame, "BOTTOMRIGHT", procPadding, -procPadding)
	proc:Hide()
	button.AnyonActionbarProcGlow = proc

	local castFrame = button.SpellCastAnimFrame
	if castFrame then
		castFrame.Fill.InnerGlowTexture:SetAlpha(0)
		local castPadding = GetEffectPadding(button, 4, 6, 7) -- 施法光暈外擴
		local cast = button:CreateTexture(nil, "BACKGROUND", nil, -2)
		cast:SetTexture(G.ButtonCastTex)
		cast:SetSnapToPixelGrid(false)
		cast:SetTexelSnappingBias(0)
		cast:SetBlendMode("BLEND")
		cast:SetPoint("TOPLEFT", skinFrame, "TOPLEFT", -castPadding, castPadding)
		cast:SetPoint("BOTTOMRIGHT", skinFrame, "BOTTOMRIGHT", castPadding, -castPadding)
		cast:Hide()
		castFrame.AnyonActionbarCastGlow = cast
		-- 材質跟隨原生顯隱，不改其動畫或事件
		castFrame:HookScript("OnShow", function() cast:Show() end)
		castFrame:HookScript("OnHide", function() cast:Hide() end)
	end
	StyleProfessionQualityOverlay(button)
	StyleAssistedCombatOverlay(button)
	UpdateStyleFrameLevels(button)
	button.AnyonActionbarFramesCreated = true
end

local function ShowSpellAlert(button)
	if not button then return end

	if not button.AnyonActionbarProcGlow then
		if InCombatLockdown() then return end

		CreateStyleFrames(button)
		UpdateSkinVisibility(button)
	end

	StyleSpellAlertFrames(button)
	button.AnyonActionbarProcGlow:Show()
end

local function HideSpellAlert(button)
	local glow = button and button.AnyonActionbarProcGlow
	if glow then glow:Hide() end
end

local function HookSpellAlertManager()
	if spellAlertHooked or not ActionButtonSpellAlertManager then return end

	hooksecurefunc(ActionButtonSpellAlertManager, "ShowAlert", function(_, button)
		ShowSpellAlert(button)
	end)

	hooksecurefunc(ActionButtonSpellAlertManager, "HideAlert", function(_, button)
		HideSpellAlert(button)
	end)

	if ActionButtonSpellAlertManager.activeAlerts then
		for button in pairs(ActionButtonSpellAlertManager.activeAlerts) do
			ShowSpellAlert(button)
		end
	end

	spellAlertHooked = true
end

local function HookButton(button)
	if button.AnyonActionbarStyleHooked then return end

	if button.Update then
		hooksecurefunc(button, "Update", UpdateSkinVisibility)
	end

	if button.UpdateButtonArt then
		hooksecurefunc(button, "UpdateButtonArt", RestoreButtonArt)
	end

	if button.SetNormalAtlas then
		hooksecurefunc(button, "SetNormalAtlas", HideBlizzardArt)
	end

	if button.UpdateProfessionQuality then
		hooksecurefunc(button, "UpdateProfessionQuality", StyleProfessionQualityOverlay)
	end

	if button.UpdateAssistedCombatRotationFrame then
		hooksecurefunc(button, "UpdateAssistedCombatRotationFrame", StyleAssistedCombatOverlay)
	end

	button:HookScript("OnHide", HideSpellAlert)
	button.AnyonActionbarStyleHooked = true
end

-- 套用美化到按鈕
local function StyleButton(button)
	if not button then return end

	if styledButtons[button] then
		UpdateSkinVisibility(button)
		return
	end

	if InCombatLockdown() then
		pendingButtons[button] = true
		return
	end

	CreateStyleFrames(button)
	HookButton(button)
	ApplyButtonStyle(button)
	styledButtons[button] = true
	pendingButtons[button] = nil
end

-- 套用美化到寵物列按鈕
local function StylePetButtons()
	if not PetActionBar or not PetActionBar.actionButtons then return end

	for _, button in pairs(PetActionBar.actionButtons) do
		StyleButton(button)
	end
end

-- 套用美化到姿態列按鈕
local function StyleStanceButtons()
	if not StanceBar or not StanceBar.actionButtons then return end

	for _, button in pairs(StanceBar.actionButtons) do
		StyleButton(button)
	end
end

local function StyleRegisteredButtons()
	if ActionBarButtonEventsFrame then
		ActionBarButtonEventsFrame:ForEachFrame(StyleButton)
	end

	StylePetButtons()
	StyleStanceButtons()
end

local function HookCastAnimations()
	if castAnimHooked or not ActionButtonCastingAnimFrameMixin then return end

	hooksecurefunc(ActionButtonCastingAnimFrameMixin, "Setup", StyleCastAnimFrame)
	castAnimHooked = true
end

local function FlushPendingButtons()
	for button in pairs(pendingButtons) do
		StyleButton(button)
	end
end

-- 額外技能：區域技能不在一般快捷列的按鈕清單中，需要單獨套用外觀
local function StyleZoneAbilityButtons()
	for button in ZoneAbilityFrame.SpellButtonContainer:EnumerateActive() do
		StyleButton(button)
	end
end

-- 額外技能：把框體四邊換成相同的畫面座標，避免 UI 或按鈕縮放造成選框偏移
local function GetExtraFrameBounds(frame)
	if frame:IsForbidden() then return end

	local left, bottom, width, height = frame:GetRect()
	local scale = frame:GetEffectiveScale()
	if not canaccessallvalues(left, bottom, width, height, scale) or not left then return end

	return left * scale, (left + width) * scale, (bottom + height) * scale, bottom * scale, scale
end

-- 額外技能：只縮小編輯模式選擇框的尺寸
local function UpdateExtraAbilitySelection()
	if InCombatLockdown() then return end

	local container = ExtraAbilityContainer
	local selection = container.Selection
	if not C_RestrictedActions.CheckAllowProtectedFunctions(container, true)
		or not C_RestrictedActions.CheckAllowProtectedFunctions(selection, true) then return end

	local frameLeft, frameRight, frameTop, frameBottom, scale = GetExtraFrameBounds(container)
	if not frameLeft then return end

	local left, right, top, bottom
	for _, entry in ipairs(container.frames) do
		local frame = entry.frame == ExtraActionBarFrame and ExtraActionButton1 or ZoneAbilityFrame.SpellButtonContainer
		local x1, x2, y1, y2 = GetExtraFrameBounds(frame)
		if not x1 then return end

		left = left and min(left, x1) or x1
		right = right and max(right, x2) or x2
		top = top and max(top, y1) or y1
		bottom = bottom and min(bottom, y2) or y2
	end

	if not left then
		-- 沒有額外技能時，仍保留 52x52 的可拖動小選框
		local halfSize = 52 * scale / 2
		local centerX, centerY = (frameLeft + frameRight) / 2, (frameTop + frameBottom) / 2
		left, right = centerX - halfSize, centerX + halfSize
		top, bottom = centerY + halfSize, centerY - halfSize
	end

	local padding = 2 -- 選框四周留白
	left = (left - frameLeft) / scale - padding
	right = (right - frameRight) / scale + padding
	top = (top - frameTop) / scale + padding
	bottom = (bottom - frameBottom) / scale - padding

	-- 吸附會讀取這兩個錨點的偏移，必須相對容器設定，不能直接 SetAllPoints 到按鈕
	selection:ClearAllPoints()
	selection:SetPoint("TOPLEFT", container, "TOPLEFT", left, top)
	selection:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", right, bottom)
	container:SetClampRectInsets(left, right, top, bottom)
end

function M:OnEnable()
	-- 去除兩套額外技能的大型裝飾
	ExtraActionButton1.style:SetAlpha(0)
	ZoneAbilityFrame.Style:SetAlpha(0)
	StyleZoneAbilityButtons()
	hooksecurefunc(ZoneAbilityFrame, "UpdateDisplayedZoneAbilities", StyleZoneAbilityButtons)

	-- 出現兩個額外技能或開啟編輯模式時刷新
	hooksecurefunc(ExtraAbilityContainer, "Layout", UpdateExtraAbilitySelection)
	hooksecurefunc(ZoneAbilityFrame.SpellButtonContainer, "Layout", UpdateExtraAbilitySelection)
	hooksecurefunc(ExtraAbilityContainer, "AnchorSelectionFrame", UpdateExtraAbilitySelection)
	UpdateExtraAbilitySelection()

	StyleRegisteredButtons()

	if ActionBarButtonEventsFrame then
		hooksecurefunc(ActionBarButtonEventsFrame, "RegisterFrame", function(_, button)
			if not styledButtons[button] then
				StyleButton(button)
			end
		end)
	end

	HookSpellAlertManager()
	HookCastAnimations()

	if PetActionBar then
		hooksecurefunc(PetActionBar, "Update", StylePetButtons)
	end

	if StanceBar and StanceBar.Update then
		hooksecurefunc(StanceBar, "Update", StyleStanceButtons)
	end

	F.RegisterEvent("PLAYER_REGEN_ENABLED", function()
		FlushPendingButtons()
		UpdateExtraAbilitySelection()
	end)
end
