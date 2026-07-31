local addon, ns = ...
local C, F, G, L = unpack(ns)

-- [[ Fix action bar row order ]] --

local ipairs = ipairs
local ceil, max, min = math.ceil, math.max, math.min
local tinsert, wipe = table.insert, table.wipe
local AnchorUtil, CreateFrame, GridLayoutUtil = AnchorUtil, CreateFrame, GridLayoutUtil
local InCombatLockdown = InCombatLockdown

local layoutButtons = {}
local pendingUpdate

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

local function ApplyActionBarRowOrder(bar)
	if not ShouldFixRowOrder(bar) then return end

	-- 戰鬥中延遲
	if InCombatLockdown() then pendingUpdate = true return end

	local containers = bar.shownButtonContainers
	local numButtons = #containers
	local numRows = bar.numRows
	local stride = ceil(numButtons / numRows)
	local rowCount = ceil(numButtons / stride)

	wipe(layoutButtons)

	-- 只改顯示順序：原生是由下往上增長，插件慣例是由上往下增長
	for row = rowCount, 1, -1 do
		local firstButton = (row - 1) * stride + 1
		local lastButton = min(row * stride, numButtons)

		for i = firstButton, lastButton do
			tinsert(layoutButtons, containers[i])
		end
	end

	local buttonPadding = max(bar.minButtonPadding, bar.buttonPadding)
	local xMultiplier = bar.addButtonsToRight and 1 or -1
	local layout = GridLayoutUtil.CreateStandardGridLayout(stride, buttonPadding, buttonPadding, xMultiplier, 1)
	local anchorPoint = bar.addButtonsToRight and "BOTTOMLEFT" or "BOTTOMRIGHT"

	GridLayoutUtil.ApplyGridLayout(layoutButtons, AnchorUtil.CreateAnchor(anchorPoint, bar, anchorPoint), layout)
	bar:Layout()
	bar:UpdateSpellFlyoutDirection()
end

local function ApplyRegisteredActionBars()
	if not EditModeManagerFrame or not EditModeManagerFrame.registeredSystemFrames then return end

	for _, bar in ipairs(EditModeManagerFrame.registeredSystemFrames) do
		ApplyActionBarRowOrder(bar)
	end
end

local function SetupActionBarRowOrder()
	if not ActionBarMixin then return end

	hooksecurefunc(ActionBarMixin, "UpdateGridLayout", ApplyActionBarRowOrder)
	ApplyRegisteredActionBars()
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:SetScript("OnEvent", function(_, event)
	if event == "PLAYER_LOGIN" then
		SetupActionBarRowOrder()
	elseif pendingUpdate then
		pendingUpdate = nil
		ApplyRegisteredActionBars()
	end
end)
