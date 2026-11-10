local _, ns = ...
local F = ns[2]
local M = F.RegisterModule("ShiftRight", "ShiftRight")

local pairs, type = pairs, type

local C_Timer_After = C_Timer.After

local C_Container_GetContainerItemInfo = C_Container.GetContainerItemInfo
local C_Container_GetContainerNumSlots = C_Container.GetContainerNumSlots
local C_Container_UseContainerItem = C_Container.UseContainerItem

local CursorHasItem, ItemLocation = CursorHasItem, ItemLocation
local IsShiftKeyDown = IsShiftKeyDown
local hooksecurefunc = hooksecurefunc

local BACKPACK, REAGENT_BAG = Enum.BagIndex.Backpack, Enum.BagIndex.ReagentBag
local CHARACTER_BANK_FIRST = Enum.BagIndex.CharacterBankTab_1
local CHARACTER_BANK_LAST = Enum.BagIndex.CharacterBankTab_6
local ACCOUNT_BANK_FIRST = Enum.BagIndex.AccountBankTab_1
local ACCOUNT_BANK_LAST = Enum.BagIndex.AccountBankTab_5

local hookDelayPending
local containerButtonOriginals = {}
local bankButtonOriginals = {}

-- 只接管 Shift + 右鍵
local function IsShiftRightClick(button)
	return F.GetSetting("ShiftRight") and button == "RightButton" and IsShiftKeyDown() and not CursorHasItem()
end

-- 只處理背包格、角色銀行 tab、戰隊銀行 tab
local function IsPlayerBag(containerID)
	return containerID and containerID >= BACKPACK and containerID <= REAGENT_BAG
end

local function IsAccountBankTab(containerID)
	return containerID and containerID >= ACCOUNT_BANK_FIRST and containerID <= ACCOUNT_BANK_LAST
end

-- 排除被鎖住的格子
local function GetUnlockedItemID(containerID, slotID)
	local info = C_Container_GetContainerItemInfo(containerID, slotID)
	if info and not info.isLocked then
		return info.itemID
	end
end

local function UseContainerItem(containerID, slotID, bankType)
	if bankType then
		-- 從背包放入銀行
		C_Container_UseContainerItem(containerID, slotID, nil, bankType, false)
	else
		-- 從銀行取回背包
		C_Container_UseContainerItem(containerID, slotID)
	end
end

local function IsAccountBankDepositRefundable(containerID, slotID)
	local itemLocation = ItemLocation:CreateFromBagAndSlot(containerID, slotID)
	return BankUtil_IsAccountBankDepositRefundable(itemLocation)
end

local function UseMatchingItemsInContainer(containerID, itemID, bankType)
	local numSlots = C_Container_GetContainerNumSlots(containerID)
	for slotID = 1, numSlots do
		if GetUnlockedItemID(containerID, slotID) == itemID then
			-- 存入戰隊銀行時跳過可退款物品
			if bankType ~= Enum.BankType.Account or not IsAccountBankDepositRefundable(containerID, slotID) then
				UseContainerItem(containerID, slotID, bankType)
			end
		end
	end
end

local function UseMatchingItemsInRange(firstContainerID, lastContainerID, itemID, bankType)
	for containerID = firstContainerID, lastContainerID do
		UseMatchingItemsInContainer(containerID, itemID, bankType)
	end
end

-- 判斷要存入哪種銀行
local function GetActiveBankType()
	if BankFrame:IsShown() then
		return BankFrame:GetActiveBankType()
	end
end

-- 從背包存入銀行
local function MoveMatchingItemsFromBags(button, mouseButton)
	if not IsShiftRightClick(mouseButton) then return false end

	local bankType = GetActiveBankType()
	if not bankType then return false end

	local bagID = button:GetBagID()
	local slotID = button:GetID()
	if not IsPlayerBag(bagID) then return false end

	local itemID = GetUnlockedItemID(bagID, slotID)
	if not itemID then return false end

	UseMatchingItemsInRange(BACKPACK, REAGENT_BAG, itemID, bankType)
	return true
end

-- 判斷從哪個銀行分頁提取
local function GetBankTabRange(bankType, bankTabID)
	if bankType == Enum.BankType.Account or IsAccountBankTab(bankTabID) then
		return ACCOUNT_BANK_FIRST, ACCOUNT_BANK_LAST
	end

	return CHARACTER_BANK_FIRST, CHARACTER_BANK_LAST
end

-- 從銀行提取至背包
local function MoveMatchingItemsFromBank(button, mouseButton)
	if not IsShiftRightClick(mouseButton) then return false end

	local bankTabID = button:GetBankTabID()
	local slotID = button:GetContainerSlotID()
	local itemID = GetUnlockedItemID(bankTabID, slotID)
	if not itemID then return false end

	local firstContainerID, lastContainerID = GetBankTabRange(button:GetBankType(), bankTabID)
	UseMatchingItemsInRange(firstContainerID, lastContainerID, itemID)
	return true
end

local function ContainerOnModifiedClick(self, button)
	if MoveMatchingItemsFromBags(self, button) then return end

	local original = containerButtonOriginals[self] or ContainerFrameItemButtonMixin.OnModifiedClick
	if original then
		return original(self, button)
	end
end

local function BankOnModifiedClick(self, button)
	if MoveMatchingItemsFromBank(self, button) then return end

	local original = bankButtonOriginals[self] or BankPanelItemButtonMixin.OnModifiedClick
	if original then
		return original(self, button)
	end
end

local function HookButton(button, originals, handler)
	if not button or originals[button] then return end
	if type(button.OnModifiedClick) ~= "function" then return end

	originals[button] = button.OnModifiedClick
	button.OnModifiedClick = handler
end

local function RestoreButtons(originals, handler)
	for button, original in pairs(originals) do
		if button.OnModifiedClick == handler then
			button.OnModifiedClick = original
		end
		originals[button] = nil
	end
end

local function HookContainerButtons()
	-- 整合背包仍有獨立材料袋，需枚舉全部容器而非只有主背包框體。
	for _, containerFrame in ContainerFrameUtil_EnumerateContainerFrames() do
		if IsPlayerBag(containerFrame:GetBagID()) then
			for _, itemButton in containerFrame:EnumerateValidItems() do
				HookButton(itemButton, containerButtonOriginals, ContainerOnModifiedClick)
			end
		end
	end
end

local function HookBankButtons()
	for itemButton in BankFrame.BankPanel:EnumerateValidItems() do
		HookButton(itemButton, bankButtonOriginals, BankOnModifiedClick)
	end
end

-- 銀行顯示、切換分頁或開背包時，等原生建立物品按鈕後再合併補掛。
local function QueueHookDelay()
	if not BankFrame:IsShown() or hookDelayPending then return end
	hookDelayPending = true

	C_Timer_After(0.1, function()
		hookDelayPending = false
		if BankFrame:IsShown() then
			HookContainerButtons()
			HookBankButtons()
		end
	end)
end

local function DisableHooks()
	RestoreButtons(containerButtonOriginals, ContainerOnModifiedClick)
	RestoreButtons(bankButtonOriginals, BankOnModifiedClick)
end

function M:OnEnable()
	QueueHookDelay()

	BankFrame:HookScript("OnShow", QueueHookDelay)
	BankFrame:HookScript("OnHide", DisableHooks)

	EventRegistry:RegisterCallback("ContainerFrame.OpenBag", QueueHookDelay, self)

	hooksecurefunc(BankPanelMixin, "GenerateItemSlotsForSelectedTab", QueueHookDelay)
end
