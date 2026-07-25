local _, ns = ...
local C, F, G = unpack(ns)
local M = F.RegisterModule("AuraFrames", "AuraFrames")

local _G = getfenv(0)
local ipairs, unpack = ipairs, unpack
local CreateFrame, RegisterStateDriver = CreateFrame, RegisterStateDriver
local UnitHasVehicleUI, UIParent = UnitHasVehicleUI, UIParent

local AURA_BORDER_PADDING = 1
local auraContainers = {}
local builtFrames

------------------------------
-- Hide blizzard aura frame --
------------------------------

-- 隱藏原生框體

local HiddenFrame = CreateFrame("Frame")
HiddenFrame:Hide()

local function HideObject(frame)
	if not frame then return end

	frame:Hide()
	frame:SetParent(HiddenFrame)

	if frame.UnregisterAllEvents then
		frame:UnregisterAllEvents()
	end
end

-- 關閉原生光環
local function HideBlizzardAuraFrames()
	if _G.BuffFrame then
		HideObject(_G.BuffFrame)
		_G.BuffFrame.numHideableBuffs = 0
	end

	if _G.DebuffFrame then
		HideObject(_G.DebuffFrame)
	end
end

-----------------
-- Text format --
-----------------

-- 倒數文字格式
local durationFormatter
local function GetDurationFormatter()
	if durationFormatter then return durationFormatter end

	local rounding = Enum.NumericRuleFormatRounding.Up

	durationFormatter = C_StringUtil.CreateNumericRuleFormatter()
	durationFormatter:SetBreakpoints({
		{
			threshold = 0,
			format = "%dS",
			rounding = rounding,
			step = 1,
		},
		{
			threshold = 60,
			format = "%dM",
			components = { { div = 60, rounding = rounding, step = 1 } },
		},
		{
			threshold = 3600,
			format = "%dH",
			components = { { div = 3600, rounding = rounding, step = 1 } },
		},
		{
			threshold = 86400,
			format = "%dD",
			components = { { div = 86400, rounding = rounding, step = 1 } },
		},
	})

	return durationFormatter
end

-- 倒數文字樣式
local function SetFont(fontString, size)
	if not fontString then return end

	fontString:SetFont(STANDARD_TEXT_FONT, size, "OUTLINE")
	fontString:SetShadowColor(0, 0, 0, 0)
	fontString:SetWordWrap(false)
end

-------------
-- Vehicle --
-------------

-- 載具判斷
local function GetUnitToken()
	return UnitHasVehicleUI("player") and "vehicle" or "player"
end

-- 載具狀態改變時切換 AuraContainer 的獲取對象
local function UpdateContainerUnits()
	local unit = GetUnitToken()

	for _, container in ipairs(auraContainers) do
		container:SetUnit(unit)
	end
end

----------
-- core --
----------

-- 計算每行光環的圖示與間距加總寬度
local function GetRowWidth(cfg)
	return (cfg.size * cfg.wrapAfter) + (C.Auras.Margin * (cfg.wrapAfter - 1))
end

-- holder 寬度做為定位基準
local function GetHolderWidth(cfg)
	return (cfg.size + C.Auras.Margin) * cfg.wrapAfter
end

-- holder 高度包含文字占用的空間
local function GetHolderHeight(cfg)
	return (cfg.size + cfg.offset) * cfg.maxWraps
end

-- 減益類型邊框染色
local function SetDefaultDebuffBorderColor(texture)
	local color = AuraUtil and AuraUtil.GetAuraBorderColor and AuraUtil.GetAuraBorderColor()
	if color and color.GetRGBA then
		texture:SetVertexColor(color:GetRGBA())
	else
		texture:SetVertexColor(.8, 0, 0, 1)
	end
end

-- 減益驅散邊框
local function AddDispelBorder(button, texture)
	button:AddDispelTypeTexture(texture, {
		showWhenHelpful = false,
		showWhenHarmful = true,
		style = Enum.CustomAuraButtonDispelTypeTextureStyle.PreserveAsset,
	})
end

-- 永久光環不顯示倒數文字
local function SetDurationText(button, fontString)
	local binding = C_DurationUtil.CreateDurationTextBinding()
	binding:SetFormatter(GetDurationFormatter())
	binding:SetExpiredText("")
	binding:SetZeroDurationText("")
	button:SetDurationText(fontString, { binding = binding, })
end

-- 初始化每個光環的外觀
local function CreateAuraButtonInitializer(cfg, canCancelAura, showDefaultDebuffBorder)
	return function(button)
		local size = cfg.size
		local fullHeight = cfg.size + cfg.offset

		button:SetSize(size, fullHeight)

		local iconFrame = CreateFrame("Frame", nil, button, "BackdropTemplate")
		iconFrame:SetSize(size, size)
		iconFrame:SetPoint("TOP", button, "TOP")
		button.IconFrame = iconFrame

		if showDefaultDebuffBorder then
			-- 無類型減益顯示紅框
			local defaultBorder = iconFrame:CreateTexture(nil, "OVERLAY", nil, 0)
			defaultBorder:SetTexture(G.BorderTex)
			defaultBorder:SetPoint("TOPLEFT", iconFrame, -AURA_BORDER_PADDING, AURA_BORDER_PADDING)
			defaultBorder:SetPoint("BOTTOMRIGHT", iconFrame, AURA_BORDER_PADDING, -AURA_BORDER_PADDING)
			SetDefaultDebuffBorderColor(defaultBorder)
		end

		local dispelBorder = iconFrame:CreateTexture(nil, "OVERLAY", nil, 1)
		dispelBorder:SetTexture(G.BorderTex)
		dispelBorder:SetPoint("TOPLEFT", iconFrame, -AURA_BORDER_PADDING, AURA_BORDER_PADDING)
		dispelBorder:SetPoint("BOTTOMRIGHT", iconFrame, AURA_BORDER_PADDING, -AURA_BORDER_PADDING)
		dispelBorder:Hide()
		AddDispelBorder(button, dispelBorder)

		local icon = iconFrame:CreateTexture(nil, "ARTWORK")
		icon:SetPoint("TOPLEFT", iconFrame, 1, -1)
		icon:SetPoint("BOTTOMRIGHT", iconFrame, -1, 1)
		icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		button:SetIcon(icon)

		local count = iconFrame:CreateFontString(nil, "OVERLAY")
		count:SetDrawLayer("OVERLAY", 3)
		count:SetPoint("BOTTOMRIGHT", iconFrame, 1, -5)
		count:SetTextColor(1, 1, 0)
		SetFont(count, C.Auras.CountFontSize)
		button:SetApplicationCount(count)

		local duration = button:CreateFontString(nil, "OVERLAY")
		duration:SetPoint("TOP", iconFrame, "BOTTOM", 1, 2)
		SetFont(duration, C.Auras.TimerFontSize)
		SetDurationText(button, duration)

		local highlight = button:CreateTexture(nil, "HIGHLIGHT")
		highlight:SetColorTexture(1, 1, 1, 0.25)
		highlight:SetAllPoints(iconFrame)

		local border = F.CreateBD(iconFrame, iconFrame, 1, .1, .1, .1, 1)
		local shadow = F.CreateSD(iconFrame, iconFrame, 4)
		border:EnableMouse(false)
		shadow:EnableMouse(false)

		-- 右鍵取消光環仍由 Blizzard AuraButton 處理
		button:SetCancelAuraButtons(canCancelAura and "RightButtonUp" or nil)
	end
end

-- 錨點、位置與增長方向
local function ConfigureAuraContainer(container, cfg)
	container:SetFlowLayoutAxis(AnchorUtil.FlowLayoutAxis.Horizontal)
	container:SetFlowLayoutAnchorPoint("TOPRIGHT")
	container:SetFlowLayoutGrowthDirection(AnchorUtil.FlowDirection.Left, AnchorUtil.FlowDirection.Down)
	container:SetFlowLayoutPadding(0, 0, 0, 0)
	container:SetFlowLayoutMaximumLineSize(GetRowWidth(cfg))
end

local function GetLayoutOptions(cfg)
	return {
		elementSpacing = C.Auras.Margin,
		lineSpacing = 0,
		-- 前一組最後一顆已保留 elementSpacing，這裡避免附魔組和 aura 組多一段間距。
		groupSpacing = 0,
		groupLineSpacing = 0,
		elementWidth = cfg.size,
		elementHeight = cfg.size + cfg.offset,
	}
end

-- 讓新增光環按指定規則初始化
local function AddAuraGroup(container, key, filter, cfg, canCancelAura)
	container:AddAuraGroup(key, filter, {
		maxFrameCount = cfg.wrapAfter * cfg.maxWraps,
		initializeFrame = CreateAuraButtonInitializer(cfg, canCancelAura, filter == "HARMFUL"),
		sortMethod = AuraContainerSortMethod.Default,
		sortDirection = AuraContainerSortDirection.Normal,
		layout = GetLayoutOptions(cfg),
	})
end

-- 臨時附魔前置，永久附魔隱藏
local function AddItemEnchantments(container, cfg)
	local options = {
		hidePermanent = true,
		initializeFrame = CreateAuraButtonInitializer(cfg, false),
	}

	container:AddItemEnchantment(AuraContainerItemEnchantmentSlot.MainHand, options)
	container:AddItemEnchantment(AuraContainerItemEnchantmentSlot.OffHand, options)
	container:AddItemEnchantment(AuraContainerItemEnchantmentSlot.Ranged, options)
	container:SetItemEnchantmentSortMethod(AuraContainerItemEnchantmentSortMethod.Slot, AuraContainerSortDirection.Normal)

	local layout = GetLayoutOptions(cfg)
	layout.placement = CustomAuraContainerItemEnchantmentPlacement.BeforeAuraGroups
	container:SetItemEnchantmentLayout(layout)
end

-- 建立框體
-- holder 負責框體定位，container 負責處理光環
local function CreateAuraContainer(name, groupKey, filter, cfg, canCancelAura, includeItemEnchantments)
	local holder = CreateFrame("Frame", name, UIParent)
	holder:SetClampedToScreen(true)
	holder:SetSize(GetHolderWidth(cfg), GetHolderHeight(cfg))

	if RegisterStateDriver then
		RegisterStateDriver(holder, "visibility", "[petbattle] hide; show")
	end

	local container = CreateFrame("AuraContainer", name.."Container", holder, "CustomAuraContainerTemplate")
	container:SetPoint("TOPRIGHT", holder, "TOPRIGHT", 0, 0)
	container:SetEnabled(false)
	ConfigureAuraContainer(container, cfg)

	if includeItemEnchantments then
		AddItemEnchantments(container, cfg)
	end

	AddAuraGroup(container, groupKey, filter, cfg, canCancelAura)
	container:SetUnit(GetUnitToken())
	container:SetEnabled(true)

	auraContainers[#auraContainers + 1] = container
	return holder, container
end

-- 建立
local function BuildAuraFrames()
	if builtFrames then
		return
	end

	builtFrames = true
	HideBlizzardAuraFrames()

	local buffCfg = {
		offset = 12,
		size = C.Auras.BuffSize,
		wrapAfter = C.Auras.BuffsPerRow,
		maxWraps = 3,
	}

	local debuffCfg = {
		offset = 12,
		size = C.Auras.DebuffSize,
		wrapAfter = C.Auras.DebuffsPerRow,
		maxWraps = 2,
	}

	local buffs = CreateAuraContainer("AnyonPlayerBuffs", "Buffs", "HELPFUL", buffCfg, true, true)
	buffs:ClearAllPoints()
	buffs:SetPoint(unpack(C.Auras.BuffPos))

	local debuffs = CreateAuraContainer("AnyonPlayerDebuffs", "Debuffs", "HARMFUL", debuffCfg, false, false)
	debuffs:ClearAllPoints()
	debuffs:SetPoint("TOPRIGHT", buffs, "BOTTOMRIGHT", 0, -12)

	UpdateContainerUnits()
end

-- 進入世界時隱藏原生框架，上下載具時切換顯示來源
local function OnEvent(_, event, unit)
	if event == "PLAYER_ENTERING_WORLD" then
		-- 避免暴雪框架重新顯示。
		BuildAuraFrames()
		if builtFrames then
			HideBlizzardAuraFrames()
			UpdateContainerUnits()
		end
	elseif unit == "player" and builtFrames then
		UpdateContainerUnits()
	end
end

function M:OnEnable()
	BuildAuraFrames()

	local loader = CreateFrame("Frame")
	loader:RegisterEvent("PLAYER_ENTERING_WORLD")
	loader:RegisterEvent("UNIT_ENTERED_VEHICLE")
	loader:RegisterEvent("UNIT_EXITED_VEHICLE")
	loader:SetScript("OnEvent", OnEvent)
end
