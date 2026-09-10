local _, ns = ...
local C, F, G = unpack(ns)
local M = F.RegisterModule("AuraFrames", "AuraFrames")

local _G = getfenv(0)
local ceil = math.ceil
local ipairs, unpack = ipairs, unpack
local CreateFrame, RegisterStateDriver = CreateFrame, RegisterStateDriver
local UnitHasVehiclePlayerFrameUI, UIParent = UnitHasVehiclePlayerFrameUI, UIParent
local GetTemporaryEnchantmentInfo = C_PaperDollInfo.GetTemporaryEnchantmentInfo

local MAX_PLAYER_BUFFS, MAX_PLAYER_DEBUFFS = 32, 24
local BUFF_GROUP_KEY = "Buffs"
local ITEM_ENCHANTMENT_SLOTS = { INVSLOT_MAINHAND, INVSLOT_OFFHAND, INVSLOT_RANGED }
local buffContainer
local auraContainers = {}

------------------------------
-- Hide blizzard aura frame --
------------------------------

-- 隱藏原生框體
local HiddenFrame = CreateFrame("Frame")
HiddenFrame:Hide()

local function HideObject(frame)
	frame:Hide()
	frame:SetParent(HiddenFrame)
	frame:UnregisterAllEvents()
end

-- 關閉原生光環
local function HideBlizzardAura()
	HideObject(_G.BuffFrame)
	_G.BuffFrame.numHideableBuffs = 0

	-- 直接幹掉原生減益會使致命減益提示消失，因此只隱藏減益圖示並關閉滑鼠互動
	local frame = _G.DebuffFrame
	frame:SetAlpha(0)
	frame:EnableMouse(false)
	frame.AuraContainer:Hide()

	for _, anchor in ipairs(frame.PrivateAuraAnchors) do
		anchor:Hide()
	end

	frame:Show()
end

-----------------
-- Text format --
-----------------

-- 倒數文字格式
local durationBinding
local function GetDurationBinding()
	if durationBinding then return durationBinding end

	local rounding = Enum.NumericRuleFormatRounding.Up
	local formatter = C_StringUtil.CreateNumericRuleFormatter()
	formatter:SetBreakpoints({
		{
			threshold = 0,
			format = "%d",
			rounding = rounding,
			step = 1,
		},
		{
			threshold = 60,
			format = "%d:%02d",
			rounding = rounding,
			step = 1,
			components = { { div = 60 }, { mod = 60 } },
		},
		{
			threshold = 300,
			format = "%dm",
			components = { { div = 60, rounding = rounding, step = 1 } },
		},
		{
			threshold = 3600,
			format = "%dh",
			components = { { div = 3600, rounding = rounding, step = 1 } },
		},
		{
			threshold = 86400,
			format = "%dd",
			components = { { div = 86400, rounding = rounding, step = 1 } },
		},
	})

	-- 永久光環不顯示倒數文字
	durationBinding = C_DurationUtil.CreateDurationTextBinding()
	durationBinding:SetFormatter(formatter)
	durationBinding:SetExpiredText("")
	durationBinding:SetZeroDurationText("")

	return durationBinding
end

-- 倒數文字樣式
local function SetFont(fontString, size)
	fontString:SetFont(STANDARD_TEXT_FONT, size, "OUTLINE")
	fontString:SetShadowColor(0, 0, 0, 0)
	fontString:SetWordWrap(false)
end

--------------
-- Function --
--------------

-- 載具判斷
local function GetUnitToken()
	return UnitHasVehiclePlayerFrameUI("player") and "vehicle" or "player"
end

-- 載具狀態改變時切換 AuraContainer 的獲取對象
local function UpdateUnits()
	local unit = GetUnitToken()
	for _, container in ipairs(auraContainers) do
		container:SetUnit(unit)
	end
end

-- 將臨時附魔數量計入增益光環總數
local function UpdateBuffLimit()
	local activeEnchantments = 0
	for _, slot in ipairs(ITEM_ENCHANTMENT_SLOTS) do
		local enchantmentInfo = GetTemporaryEnchantmentInfo(slot)
		if enchantmentInfo and enchantmentInfo.hasExpirationTime then
			activeEnchantments = activeEnchantments + 1
		end
	end

	buffContainer:SetAuraGroupMaxFrameCount(BUFF_GROUP_KEY, MAX_PLAYER_BUFFS - activeEnchantments)
end

----------
-- Core --
----------

-- 初始化每個光環的外觀
local function CreateAuraButton(cfg, canCancelAura, isDebuff, isItemEnchantment)
	return function(button)
		local size = cfg.size
		local fullHeight = cfg.size + cfg.offset

		button:SetSize(size, fullHeight)

		local iconFrame = CreateFrame("Frame", nil, button)
		iconFrame:SetSize(size, size)
		iconFrame:SetPoint("TOP", button, "TOP")

		-- 圖示與高亮放在同一個按鈕
		local icon = button:CreateTexture(nil, "ARTWORK")
		icon:SetPoint("TOPLEFT", iconFrame, 1, -1)
		icon:SetPoint("BOTTOMRIGHT", iconFrame, -1, 1)
		icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

		-- 深灰色背景
		local background = button:CreateTexture(nil, "BACKGROUND")
		background:SetColorTexture(.1, .1, .1, 1)
		background:SetAllPoints(icon)

		-- 底層陰影
		local shadow = button:CreateTexture(nil, "BACKGROUND", nil, -2)
		shadow:SetTexture(G.IconBorderTex)
		shadow:SetVertexColor(0, 0, 0, 1)
		shadow:SetBlendMode("BLEND")
		shadow:SetPoint("TOPLEFT", icon, "TOPLEFT", -6, 6)
		shadow:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 6, -6)

		-- 1px 邊框
		local border = button:CreateTexture(nil, "BACKGROUND", nil, -1)
		border:SetColorTexture(1, 1, 1, 1)
		border:SetPoint("TOPLEFT", icon, "TOPLEFT", -1, 1)
		border:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 1, -1)
		if isDebuff then
			-- 邊框類型染色，無類型減益也顯示紅框
			button:AddDispelTypeTexture(border, {
				showWhenHelpful = false,
				showWhenHarmful = true,
				showWithoutDispelType = true,
				style = Enum.CustomAuraButtonDispelTypeTextureStyle.PreserveAsset,
			})
		elseif isItemEnchantment then
			border:SetVertexColor(.64, .21, .93, 1)
		else
			border:SetVertexColor(.05, .05, .05, 1)
		end

		local count = iconFrame:CreateFontString(nil, "OVERLAY")
		count:SetDrawLayer("OVERLAY", 3)
		count:SetPoint("BOTTOMRIGHT", iconFrame, 1, -5)
		count:SetTextColor(1, 1, 0)
		SetFont(count, C.Auras.CountFontSize)
		button:SetApplicationCount(count)

		local duration = iconFrame:CreateFontString(nil, "OVERLAY")
		duration:SetDrawLayer("OVERLAY", 3)
		duration:SetPoint("TOP", iconFrame, "BOTTOM", 1, 4)
		SetFont(duration, C.Auras.TimerFontSize)
		button:SetDurationText(duration, { binding = GetDurationBinding(), })

		-- 高亮只覆蓋圖示
		local highlight = button:CreateTexture(nil, "HIGHLIGHT")
		highlight:SetColorTexture(1, 1, 1, 0.25)
		highlight:SetAllPoints(icon)

		button:SetIcon(icon)

		-- 保留右鍵取消光環
		button:SetCancelAuraButtons(canCancelAura and "RightButtonUp" or nil)
	end
end

-- 取得布局設定
local function GetLayoutOptions(cfg)
	return {
		elementSpacing = C.Auras.Margin,	-- 同組光環相鄰間距
		lineSpacing = 0,
		groupSpacing = 0,	-- 跨組光環額外間距，臨時附魔與增益不增加額外間距故為0
		groupLineSpacing = 0,
		elementWidth = cfg.size,
		elementHeight = cfg.size + cfg.offset,
	}
end

------------------
-- Build frames --
------------------

-- 建立光環容器
-- holder 負責框體定位，container 負責處理光環
local function CreateAuraContainer(name, groupKey, filter, cfg, canCancelAura, includeItemEnchantments)
	local holder = CreateFrame("Frame", name, UIParent)
	local holderWidth = (cfg.size + C.Auras.Margin) * cfg.wrapAfter
	local holderHeight = (cfg.size + cfg.offset) * cfg.maxWraps

	holder:SetClampedToScreen(true)
	holder:SetSize(holderWidth, holderHeight)

	RegisterStateDriver(holder, "visibility", "[petbattle] hide; show")

	local container = CreateFrame("AuraContainer", name.."Container", holder, "CustomAuraContainerTemplate")
	container:SetPoint("TOPRIGHT", holder, "TOPRIGHT", 0, 0)
	container:SetEnabled(false)

	-- 錨點、位置與增長方向
	local rowWidth = (cfg.size * cfg.wrapAfter) + (C.Auras.Margin * (cfg.wrapAfter - 1))
	container:SetFlowLayoutAxis(AnchorUtil.FlowLayoutAxis.Horizontal)
	container:SetFlowLayoutAnchorPoint("TOPRIGHT")
	container:SetFlowLayoutGrowthDirection(AnchorUtil.FlowDirection.Left, AnchorUtil.FlowDirection.Down)
	container:SetFlowLayoutPadding(0, 0, 0, 0)
	container:SetFlowLayoutMaximumLineSize(rowWidth)

	if includeItemEnchantments then
		-- 臨時附魔前置，永久附魔隱藏
		local options = {
			hidePermanent = true,
			initializeFrame = CreateAuraButton(cfg, true, false, true),
		}

		container:AddItemEnchantment(AuraContainerItemEnchantmentSlot.MainHand, options)
		container:AddItemEnchantment(AuraContainerItemEnchantmentSlot.OffHand, options)
		container:AddItemEnchantment(AuraContainerItemEnchantmentSlot.Ranged, options)
		container:SetItemEnchantmentSortMethod(AuraContainerItemEnchantmentSortMethod.Slot, AuraContainerSortDirection.Normal)

		local layout = GetLayoutOptions(cfg)
		layout.placement = CustomAuraContainerItemEnchantmentPlacement.BeforeAuraGroups
		container:SetItemEnchantmentLayout(layout)
	end

	-- 讓新增光環按指定規則初始化
	container:AddAuraGroup(groupKey, filter, {
		maxFrameCount = cfg.maxFrameCount,
		initializeFrame = CreateAuraButton(cfg, canCancelAura, filter == "HARMFUL"),
		sortMethod = AuraContainerSortMethod.Default,
		sortDirection = AuraContainerSortDirection.Normal,
		layout = GetLayoutOptions(cfg),
	})
	container:SetUnit(GetUnitToken())
	container:SetEnabled(true)

	auraContainers[#auraContainers + 1] = container
	return holder, container
end

-- 建立光環框架
local function BuildAuraFrames()
	HideBlizzardAura()

	local buffCfg = {
		offset = 12,
		size = C.Auras.BuffSize,
		wrapAfter = C.Auras.BuffsPerRow,
		maxWraps = ceil(MAX_PLAYER_BUFFS / C.Auras.BuffsPerRow),
		maxFrameCount = MAX_PLAYER_BUFFS,
	}

	local debuffCfg = {
		offset = 12,
		size = C.Auras.DebuffSize,
		wrapAfter = C.Auras.DebuffsPerRow,
		maxWraps = ceil(MAX_PLAYER_DEBUFFS / C.Auras.DebuffsPerRow),
		maxFrameCount = MAX_PLAYER_DEBUFFS,
	}

	local buffs
	buffs, buffContainer = CreateAuraContainer("AnyonPlayerBuffs", BUFF_GROUP_KEY, "HELPFUL", buffCfg, true, true)
	UpdateBuffLimit()
	buffs:ClearAllPoints()
	buffs:SetPoint(unpack(C.Auras.BuffPos))

	local debuffs = CreateAuraContainer("AnyonPlayerDebuffs", "Debuffs", "HARMFUL", debuffCfg, false, false)
	debuffs:ClearAllPoints()
	debuffs:SetPoint("TOPRIGHT", buffs, "BOTTOMRIGHT", 0, -12)
end

-- 進入世界時隱藏原生框架，上下載具時切換顯示來源
local function OnEvent(_, event, unit)
	if event == "PLAYER_ENTERING_WORLD" then
		HideBlizzardAura()
		UpdateUnits()
		UpdateBuffLimit()
	elseif event == "WEAPON_ENCHANT_CHANGED" or event == "WEAPON_SLOT_CHANGED" then
		UpdateBuffLimit()
	elseif unit == "player" then
		UpdateUnits()
	end
end

function M:OnEnable()
	BuildAuraFrames()

	local loader = CreateFrame("Frame")
	loader:RegisterEvent("PLAYER_ENTERING_WORLD")
	loader:RegisterEvent("UNIT_ENTERED_VEHICLE")
	loader:RegisterEvent("UNIT_EXITING_VEHICLE")
	loader:RegisterEvent("UNIT_EXITED_VEHICLE")
	loader:RegisterEvent("WEAPON_ENCHANT_CHANGED")
	loader:RegisterEvent("WEAPON_SLOT_CHANGED")
	loader:SetScript("OnEvent", OnEvent)
end
