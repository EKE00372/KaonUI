local addon, ns = ...
local C, F, G, L = unpack(ns)
local M = F.RegisterModule("ActionbarStyle", "ActionbarStyle")

-- [[ Action bar style ]] --

local pairs, ipairs = pairs, ipairs
local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local gsub = string.gsub

local TEXTURE_PATH = "Interface\\AddOns\\!Anyon\\Media\\Actionbar\\"
local BUTTON_TEXTURE = TEXTURE_PATH.."button-normal.tga"
local PROC_TEXTURE = TEXTURE_PATH.."button-proc.tga"
local CAST_TEXTURE = TEXTURE_PATH.."button-cast.tga"

local SKIN_INSET = 3
local SHADOW_SIZE = 5
local EFFECT_SIZE = 10
local COOLDOWN_OUTSET = 1
local ICON_INSET = 0
local ICON_TEXCOORD_LEFT = 0.08
local ICON_TEXCOORD_RIGHT = 0.92
local ICON_TEXCOORD_TOP = 0.08
local ICON_TEXCOORD_BOTTOM = 0.92
local SKIN_FRAME_LEVEL_OFFSET = 0
local BORDER_FRAME_LEVEL_OFFSET = 2
local NATIVE_ANIMATION_FRAME_LEVEL_OFFSET = 6
local EFFECT_FRAME_LEVEL_OFFSET = 7
local NATIVE_OVERLAY_FRAME_LEVEL_OFFSET = 8
local TEXT_FRAME_LEVEL_OFFSET = 10
local CAST_GLOW_FRAME_LEVEL_OFFSET = 1
local CAST_TYPE_CHANNEL = 2
local CAST_GLOW_SIZE = 4
local CAST_GLOW_ALPHA = 1
local ACTIVE_BACKGROUND_ALPHA = 0
local EMPTY_BACKGROUND_ALPHA = 0.08
local ACTIVE_BORDER_ALPHA = 1
local EMPTY_BORDER_ALPHA = 0.45
local TEXT_DRAW_SUBLEVEL = 7
local HOTKEY_TEXT_WIDTH = 32
local HOTKEY_TEXT_MIN_FONT_SIZE = 8
local MACRO_TEXT_WIDTH = 36
local MACRO_TEXT_HEIGHT = 12
local MACRO_TEXT_Y_OFFSET = 2
local MACRO_TEXT_MIN_FONT_SIZE = 8
local HOTKEY_TEXT_COLOR = { 1, 1, 1 }
local COUNT_TEXT_COLOR = { 1, 0.74, 0.2 }
local MACRO_TEXT_COLOR = { 0.72, 0.72, 0.72 }
local MAX_STANCE_BUTTONS = 10

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

local fullHookMethods = {
	"Update",
}

local artHookMethods = {
	"UpdateButtonArt",
	"SetNormalTexture",
	"SetNormalAtlas",
}

local textHookMethods = {
	"UpdateHotkeys",
}

local overlayHookMethods = {
	"UpdateProfessionQuality",
	"UpdateTypeOverlay",
	"UpdateHighlightMark",
	"UpdateSpellHighlightMark",
}

local nativeOverlayFrameKeys = {
	"ProfessionQualityOverlayFrame",
	"TypeIconOverlayFrame",
	"AutoCastOverlay",
	"FlyoutArrowContainer",
}

local nativeAnimationFrameKeys = {
	"InterruptDisplay",
	"SpellCastAnimFrame",
	"CastingAnimFrame",
	"TargetReticleAnimFrame",
	"AssistedCombatRotationFrame",
}

local nativeOverlayTextureKeys = {
	"LevelLinkLockIcon",
}

local cooldownFrameKeys = {
	"cooldown",
	"Cooldown",
	"lossOfControlCooldown",
	"chargeCooldown",
}

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

local function SetInside(region, anchor, inset)
	region:ClearAllPoints()
	region:SetPoint("TOPLEFT", anchor, "TOPLEFT", inset, -inset)
	region:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", -inset, inset)
end

local function GetRelativeFrameLevel(anchor, offset)
	local level = anchor and anchor.GetFrameLevel and anchor:GetFrameLevel() or 0
	level = level + offset

	return level > 0 and level or 0
end

local function SetRelativeFrameLevel(frame, anchor, offset, onlyRaise)
	if not frame or not frame.SetFrameLevel then return end

	local level = GetRelativeFrameLevel(anchor, offset)
	local currentLevel = frame.GetFrameLevel and frame:GetFrameLevel()
	if onlyRaise and currentLevel and currentLevel >= level then return end
	if currentLevel == level then return end

	frame:SetFrameLevel(level)
end

local function GetSkinFrame(button)
	return button.AnyonActionbarSkinFrame or button
end

local function HideTexture(texture)
	if not texture then return end

	if texture.SetTexture then
		texture:SetTexture()
	end

	if texture.SetAlpha then
		texture:SetAlpha(0)
	end

	if texture.Hide then
		texture:Hide()
	end
end

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

	HideTexture(mask)
end

local function HasButtonAction(button)
	if button.HasAction then
		return button:HasAction()
	end

	local icon = GetButtonIcon(button)
	return icon and icon.GetTexture and icon:GetTexture()
end

local function SetFrameShown(frame, shown)
	if not frame then return end

	if shown then
		if not frame.IsShown or not frame:IsShown() then
			frame:Show()
		end
	else
		if not frame.IsShown or frame:IsShown() then
			frame:Hide()
		end
	end
end

local function SetTextureAlpha(texture, alpha)
	if texture and texture.SetAlpha and (not texture.GetAlpha or texture:GetAlpha() ~= alpha) then
		texture:SetAlpha(alpha)
	end
end

local function StyleNativeOverlayFrames(button)
	if not button then return end

	for _, key in ipairs(nativeAnimationFrameKeys) do
		SetRelativeFrameLevel(button[key], button, NATIVE_ANIMATION_FRAME_LEVEL_OFFSET, true)
	end

	for _, key in ipairs(nativeOverlayFrameKeys) do
		SetRelativeFrameLevel(button[key], button, NATIVE_OVERLAY_FRAME_LEVEL_OFFSET, true)
	end

	local textOverlay = button.TextOverlayContainer or button.AnyonActionbarTextOverlay
	if not textOverlay then return end

	for _, key in ipairs(nativeOverlayTextureKeys) do
		local texture = button[key]
		if texture then
			if texture.SetParent and texture.GetParent and texture:GetParent() ~= textOverlay and not InCombatLockdown() then
				texture:SetParent(textOverlay)
			end

			if texture.SetDrawLayer then
				texture:SetDrawLayer("OVERLAY", TEXT_DRAW_SUBLEVEL - 1)
			end
		end
	end
end

local function UpdateStyleFrameLevels(button)
	if not button then return end

	SetRelativeFrameLevel(button.AnyonActionbarSkinFrame, button, SKIN_FRAME_LEVEL_OFFSET)
	StyleNativeOverlayFrames(button)

	local textOverlay = button.TextOverlayContainer or button.AnyonActionbarTextOverlay
	if textOverlay and not InCombatLockdown() then
		SetRelativeFrameLevel(textOverlay, button, TEXT_FRAME_LEVEL_OFFSET, true)
	end
end

local function AddFontOutline(fontString, sizeOverride)
	if not fontString or not fontString.GetFont or not fontString.SetFont then return end

	local font, size = fontString:GetFont()
	if font and size then
		fontString.AnyonActionbarBaseFont = fontString.AnyonActionbarBaseFont or font
		fontString.AnyonActionbarBaseSize = sizeOverride or fontString.AnyonActionbarBaseSize or size
		fontString:SetFont(font, sizeOverride or size, "OUTLINE")
	end
end

local function SetFontStringColor(fontString, color)
	if fontString and color and fontString.SetTextColor then
		fontString:SetTextColor(color[1], color[2], color[3])
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

local function StyleMacroFont(name)
	AddFontOutline(name)

	local text = name.GetText and name:GetText()
	if name.AnyonActionbarLastMacroText ~= text then
		FitFontStringWidth(name, MACRO_TEXT_WIDTH, MACRO_TEXT_MIN_FONT_SIZE)
		name.AnyonActionbarLastMacroText = text
	end

	SetFontStringColor(name, MACRO_TEXT_COLOR)
end

local function StyleHotKeyFont(hotkey)
	AddFontOutline(hotkey)

	local text = hotkey.GetText and hotkey:GetText()
	if hotkey.AnyonActionbarLastHotKeyText ~= text then
		FitFontStringWidth(hotkey, HOTKEY_TEXT_WIDTH, HOTKEY_TEXT_MIN_FONT_SIZE)
		hotkey.AnyonActionbarLastHotKeyText = text
	end

	SetFontStringColor(hotkey, HOTKEY_TEXT_COLOR)
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

local function StyleHotKeyText(hotkey)
	if not hotkey or hotkey.AnyonActionbarHotKeyUpdating then return end

	local text = hotkey:GetText()
	local shortText = ShortenHotKeyText(text)
	if not shortText or shortText == text then return end

	hotkey.AnyonActionbarHotKeyUpdating = true
	hotkey:SetText(shortText)
	hotkey.AnyonActionbarHotKeyUpdating = nil
end

local function HookHotKeyText(hotkey)
	if not hotkey or hotkey.AnyonActionbarHotKeyHooked then return end

	hooksecurefunc(hotkey, "SetText", StyleHotKeyText)
	hotkey.AnyonActionbarHotKeyHooked = true
end

local function GetTextOverlayFrame(button)
	local overlay = button.TextOverlayContainer or button.AnyonActionbarTextOverlay
	if not overlay then
		if InCombatLockdown() then return end

		overlay = CreateFrame("Frame", nil, button)
		overlay:SetAllPoints(button)
		button.AnyonActionbarTextOverlay = overlay
	end

	if not InCombatLockdown() then
		SetRelativeFrameLevel(overlay, button, TEXT_FRAME_LEVEL_OFFSET, true)
	end

	return overlay
end

local function StyleMacroText(button)
	local name = button and button.Name
	if not name then return end

	local inCombat = InCombatLockdown()
	if inCombat and not name.AnyonActionbarTextStyled then
		StyleMacroFont(name)
		return
	end

	local overlay = GetTextOverlayFrame(button)
	if not overlay then
		StyleMacroFont(name)
		return
	end

	if overlay and name.SetParent and name:GetParent() ~= overlay then
		if inCombat then
			StyleMacroFont(name)
			return
		end

		name:SetParent(overlay)
	end

	if inCombat then
		StyleMacroFont(name)
		return
	end

	name:ClearAllPoints()
	name:SetPoint("BOTTOM", GetSkinFrame(button), "BOTTOM", 0, MACRO_TEXT_Y_OFFSET)
	name:SetSize(MACRO_TEXT_WIDTH, MACRO_TEXT_HEIGHT)
	if name.SetDrawLayer then
		name:SetDrawLayer("OVERLAY", TEXT_DRAW_SUBLEVEL)
	end
	name.AnyonActionbarTextStyled = true
	StyleMacroFont(name)
end

local function StyleButtonText(button)
	if button.HotKey then
		HookHotKeyText(button.HotKey)
		StyleHotKeyText(button.HotKey)
		StyleHotKeyFont(button.HotKey)
	end

	if button.Count then
		AddFontOutline(button.Count)
		SetFontStringColor(button.Count, COUNT_TEXT_COLOR)
	end

	StyleMacroText(button)
end

local function StyleIcon(button)
	local icon = GetButtonIcon(button)
	if not icon then return end

	RemoveIconMask(button)
	SetInside(icon, GetSkinFrame(button), ICON_INSET)
	icon:SetTexCoord(ICON_TEXCOORD_LEFT, ICON_TEXCOORD_RIGHT, ICON_TEXCOORD_TOP, ICON_TEXCOORD_BOTTOM)
	icon:SetDrawLayer("BACKGROUND", 0)
end

local function StyleCooldownSize(button)
	local anchor = GetButtonIcon(button)
	if not anchor then return end

	for _, key in ipairs(cooldownFrameKeys) do
		local cooldown = button[key]
		if cooldown and cooldown.ClearAllPoints and not cooldown.AnyonActionbarSizeStyled then
			cooldown:ClearAllPoints()
			cooldown:SetPoint("TOPLEFT", anchor, "TOPLEFT", -COOLDOWN_OUTSET, COOLDOWN_OUTSET)
			cooldown:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", COOLDOWN_OUTSET, -COOLDOWN_OUTSET)
			cooldown.AnyonActionbarSizeStyled = true
		end
	end
end

local function StyleStateTexture(texture, button, r, g, b, a, blendMode)
	if not texture then return end

	texture:SetColorTexture(r, g, b, a)
	texture:SetBlendMode(blendMode or "BLEND")
	SetInside(texture, GetSkinFrame(button), ICON_INSET)
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

local function CreateEffectGlow(button, key, size, r, g, b, a)
	local glow = button[key]
	if not glow then
		glow = button:CreateTexture(nil, "OVERLAY", nil, EFFECT_FRAME_LEVEL_OFFSET)
		glow:SetTexture(PROC_TEXTURE)
		glow:SetBlendMode("BLEND")
		glow:Hide()
		button[key] = glow
	end

	glow:ClearAllPoints()
	glow:SetPoint("TOPLEFT", GetSkinFrame(button), "TOPLEFT", -size, size)
	glow:SetPoint("BOTTOMRIGHT", GetSkinFrame(button), "BOTTOMRIGHT", size, -size)
	glow:SetVertexColor(r, g, b, a)
	glow:SetAlpha(1)

	return glow
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

local function ShowEffect(button, key)
	local glow = button and button[key]
	if not glow then return end

	glow:Show()
end

local function HideEffect(button, key)
	local glow = button and button[key]
	if not glow then return end

	glow:Hide()
end

local function HideButtonEffects(button)
	HideEffect(button, "AnyonActionbarProcGlow")
end

local function StyleCastAnimFrame(castFrame, actionButtonCastType)
	if not castFrame then return end

	local button = castFrame:GetParent()
	local anchor = button and GetSkinFrame(button)
	if not anchor then return end

	local fill = castFrame.Fill
	if fill and fill.InnerGlowTexture then
		fill.InnerGlowTexture:SetAlpha(0)
	end

	SetRelativeFrameLevel(castFrame, button, NATIVE_ANIMATION_FRAME_LEVEL_OFFSET, true)

	local glow = castFrame.AnyonActionbarCastGlow
	if not glow then
		glow = castFrame:CreateTexture(nil, "OVERLAY", nil, CAST_GLOW_FRAME_LEVEL_OFFSET)
		glow:SetTexture(CAST_TEXTURE)
		glow:SetBlendMode("BLEND")
		castFrame.AnyonActionbarCastGlow = glow
	end

	glow:ClearAllPoints()
	glow:SetPoint("TOPLEFT", anchor, "TOPLEFT", -CAST_GLOW_SIZE, CAST_GLOW_SIZE)
	glow:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", CAST_GLOW_SIZE, -CAST_GLOW_SIZE)

	if actionButtonCastType == CAST_TYPE_CHANNEL then
		glow:SetVertexColor(0.35, 0.72, 1, CAST_GLOW_ALPHA)
	else
		glow:SetVertexColor(1, 0.82, 0.28, CAST_GLOW_ALPHA)
	end

	glow:Show()
end

local function UpdateSkinVisibility(button)
	local hasAction = HasButtonAction(button)

	SetFrameShown(button.AnyonActionbarBackdrop, true)
	SetFrameShown(button.AnyonActionbarMaterial, true)

	if button.AnyonActionbarBackdrop and button.AnyonActionbarBackdrop.SetColorTexture then
		button.AnyonActionbarBackdrop:SetColorTexture(0, 0, 0, hasAction and ACTIVE_BACKGROUND_ALPHA or EMPTY_BACKGROUND_ALPHA)
	end

	SetTextureAlpha(button.AnyonActionbarMaterial, hasAction and ACTIVE_BORDER_ALPHA or EMPTY_BORDER_ALPHA)
end

local function ApplyButtonArt(button)
	HideBlizzardArt(button)
	StyleIcon(button)
	StyleCooldownSize(button)
	StyleStateTextures(button)
	UpdateStyleFrameLevels(button)
	UpdateSkinVisibility(button)
end

local function ApplyButtonStyle(button)
	ApplyButtonArt(button)
	StyleButtonText(button)
end

local function RefreshButtonText(button)
	StyleButtonText(button)
	UpdateStyleFrameLevels(button)
end

local function RefreshButtonOverlays(button)
	StyleNativeOverlayFrames(button)
	UpdateSkinVisibility(button)
end

local function CreateBackdrop(button)
	local backdrop = button.AnyonActionbarBackdrop
	if not backdrop then
		backdrop = button:CreateTexture(nil, "BACKGROUND")
		button.AnyonActionbarBackdrop = backdrop
	end

	backdrop:ClearAllPoints()
	SetInside(backdrop, GetSkinFrame(button), 0)

	return backdrop
end

local function CreateButtonMaterial(button)
	local texture = button.AnyonActionbarMaterial
	if not texture then
		texture = button:CreateTexture(nil, "ARTWORK", nil, BORDER_FRAME_LEVEL_OFFSET)
		texture:SetTexture(BUTTON_TEXTURE)
		texture:SetBlendMode("BLEND")
		button.AnyonActionbarMaterial = texture
	end

	texture:ClearAllPoints()
	texture:SetPoint("TOPLEFT", GetSkinFrame(button), "TOPLEFT", -SHADOW_SIZE, SHADOW_SIZE)
	texture:SetPoint("BOTTOMRIGHT", GetSkinFrame(button), "BOTTOMRIGHT", SHADOW_SIZE, -SHADOW_SIZE)

	return texture
end

local function CreateStyleFrames(button)
	local skinFrame = button.AnyonActionbarSkinFrame
	if not skinFrame then
		skinFrame = CreateFrame("Frame", nil, button)
		SetInside(skinFrame, button, SKIN_INSET)
		skinFrame:EnableMouse(false)
		button.AnyonActionbarSkinFrame = skinFrame
	end

	CreateBackdrop(button)
	CreateButtonMaterial(button)
	CreateEffectGlow(button, "AnyonActionbarProcGlow", EFFECT_SIZE, 1, 1, 1, 1)
	UpdateStyleFrameLevels(button)
end

local function ShowSpellAlert(button)
	if not button then return end

	if not button.AnyonActionbarProcGlow then
		if InCombatLockdown() then return end

		CreateStyleFrames(button)
	end

	ApplyButtonStyle(button)
	StyleSpellAlertFrames(button)
	ShowEffect(button, "AnyonActionbarProcGlow")
end

local function HideSpellAlert(button)
	HideEffect(button, "AnyonActionbarProcGlow")
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

	for _, method in ipairs(fullHookMethods) do
		if button[method] then
			hooksecurefunc(button, method, ApplyButtonStyle)
		end
	end

	for _, method in ipairs(artHookMethods) do
		if button[method] then
			hooksecurefunc(button, method, ApplyButtonArt)
		end
	end

	for _, method in ipairs(textHookMethods) do
		if button[method] then
			hooksecurefunc(button, method, RefreshButtonText)
		end
	end

	for _, method in ipairs(overlayHookMethods) do
		if button[method] then
			hooksecurefunc(button, method, RefreshButtonOverlays)
		end
	end

	button:HookScript("OnHide", HideButtonEffects)
	button.AnyonActionbarStyleHooked = true
end

local function StyleButton(button)
	if not button then return end

	if styledButtons[button] then
		if InCombatLockdown() then
			pendingButtons[button] = true
			return
		end

		ApplyButtonStyle(button)
		pendingButtons[button] = nil
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

local function StylePetButtons()
	if not PetActionBar or not PetActionBar.actionButtons then return end

	for _, button in pairs(PetActionBar.actionButtons) do
		StyleButton(button)
	end
end

local function StyleStanceButtons()
	if StanceBar and StanceBar.actionButtons then
		for _, button in pairs(StanceBar.actionButtons) do
			StyleButton(button)
		end
	end

	for i = 1, MAX_STANCE_BUTTONS do
		StyleButton(_G["StanceButton"..i])
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

function M:OnEnable()
	if self.initialized then return end

	self.initialized = true
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
		StyleRegisteredButtons()
	end)

	F.RegisterEvent("PLAYER_ENTERING_WORLD", function()
		StyleRegisteredButtons()
	end)

	F.RegisterEvent("UPDATE_SHAPESHIFT_FORMS", function()
		StyleStanceButtons()
	end)
end
