local _, ns = ...
local F = ns[2]
local M = F.RegisterModule("Order", "ActionbarOrder")

-- [[ Fix action bar row order ]] --

local ipairs = ipairs
local ceil, max = math.ceil, math.max
local AnchorUtil, GridLayoutUtil = AnchorUtil, GridLayoutUtil
local InCombatLockdown = InCombatLockdown

local pendingUpdate

-- 只處理水平多列的普通快捷列；單列、直列保持原樣
local function ShouldFixRowOrder(bar)
	return bar
		and bar.isNormalBar
		and bar.isHorizontal
		and bar.addButtonsToTop
		and bar.numRows
		and bar.numRows > 1
		and bar.shownButtonContainers
		and #bar.shownButtonContainers > 0
end

-- 重新排列按鈕容器
local function ApplyActionBarRowOrder(bar)
	if not ShouldFixRowOrder(bar) then return end

	-- 戰鬥中延遲載入
	if InCombatLockdown() then pendingUpdate = true return end

	local containers = bar.shownButtonContainers
	local stride = ceil(#containers / bar.numRows)
	local buttonPadding = max(bar.minButtonPadding, bar.buttonPadding)
	local xMultiplier = bar.addButtonsToRight and 1 or -1
	-- 保留按鈕順序，從頂端逐列向下排
	local layout = GridLayoutUtil.CreateStandardGridLayout(stride, buttonPadding, buttonPadding, xMultiplier, -1)
	local anchorPoint = bar.addButtonsToRight and "TOPLEFT" or "TOPRIGHT"

	GridLayoutUtil.ApplyGridLayout(containers, AnchorUtil.CreateAnchor(anchorPoint, bar, anchorPoint), layout)
	bar:Layout()
	bar:UpdateSpellFlyoutDirection()
end

-- 延遲載入
local function ApplyRegisteredActionBars()
	if not EditModeManagerFrame or not EditModeManagerFrame.registeredSystemFrames then return end

	for _, bar in ipairs(EditModeManagerFrame.registeredSystemFrames) do
		ApplyActionBarRowOrder(bar)
	end
end

function M:OnEnable()
	if not ActionBarMixin then return end

	hooksecurefunc(ActionBarMixin, "UpdateGridLayout", ApplyActionBarRowOrder)
	ApplyRegisteredActionBars()

	F.RegisterEvent("PLAYER_REGEN_ENABLED", function()
		if pendingUpdate then
			pendingUpdate = nil
			ApplyRegisteredActionBars()
		end
	end)
end
