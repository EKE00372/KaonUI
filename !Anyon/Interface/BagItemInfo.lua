local _, ns = ...
local F, G = ns[2], ns[3]
local M = F.RegisterModule("BagItemInfo", "BagItemInfo")

local GetContainerItemInfo = C_Container.GetContainerItemInfo
local GetItemInfo = C_Item.GetItemInfo
local GetColorDataForItemQuality = ColorManager.GetColorDataForItemQuality
local GetCurrentItemLevel = C_Item.GetCurrentItemLevel
local IsBoundToAccountUntilEquip = C_Item.IsBoundToAccountUntilEquip
local ItemBind = Enum.ItemBind

local labels = {}
local bankHooks, bankLoads = {}, {}
local bankHookPending
local itemLocation

local function CreateLabels(button)
	-- 留在原生搜尋遮罩下方，搜尋不符的物品會連同文字一起變暗。
	local binding = button:CreateFontString(nil, "OVERLAY")
	binding:SetFont(G.Font, 12, G.FontFlag)
	binding:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 2, 2)

	local level = button:CreateFontString(nil, "OVERLAY")
	level:SetFont(G.Font, 14, G.FontFlag)
	level:SetPoint("TOPRIGHT", button, "TOPRIGHT", -1, -1)

	local text = { binding = binding, level = level }
	labels[button] = text
	return text
end

local function ClearLabels(button)
	local text = labels[button]
	if text then
		text.binding:SetText("")
		text.level:SetText("")
	end
end

local function UpdateButtonLabels(button, bagID, slotID, info)
	local binding, level
	local waitingForData = false
	if info then
		local _, _, _, _, _, _, _, _, equipLoc, _, _, _, _, bindType = GetItemInfo(info.hyperlink)
		waitingForData = (equipLoc == nil)
		-- 非裝備也會回傳非空的分類字串，不能只排除空字串。
		if equipLoc and equipLoc ~= "" and equipLoc ~= "INVTYPE_NON_EQUIP_IGNORE"
			and equipLoc ~= "INVTYPE_BAG" and equipLoc ~= "INVTYPE_QUIVER" then
			itemLocation:SetBagAndSlot(bagID, slotID)
			if bindType == ItemBind.ToWoWAccount or bindType == ItemBind.ToBnetAccount
				or IsBoundToAccountUntilEquip(itemLocation) then
				binding = "BoA"
			elseif bindType == ItemBind.OnEquip and not info.isBound then
				binding = "BoE"
			end
			level = GetCurrentItemLevel(itemLocation)
		end
	end

	local text = labels[button]
	if not text and (binding or level) then
		text = CreateLabels(button)
	end
	if text then
		if binding or level then
			local color = GetColorDataForItemQuality(info.quality or Enum.ItemQuality.Common)
			text.binding:SetTextColor(color.r, color.g, color.b)
			text.level:SetTextColor(color.r, color.g, color.b)
		end
		text.binding:SetText(binding or "")
		if level then
			text.level:SetFormattedText("%d", level)
		else
			text.level:SetText("")
		end
	end
	return waitingForData
end

local function UpdateLabels(container)
	for _, button in container:EnumerateItems() do
		local bagID, slotID = button:GetBagID(), button:GetID()
		UpdateButtonLabels(button, bagID, slotID, GetContainerItemInfo(bagID, slotID))
	end
end

local function ClearPendingLabels(container)
	-- 快取命中時，原生已同步完成 UpdateItems；只有仍在等待資料時才清字。
	if not container.refresh then return end
	for _, button in container:EnumerateItems() do
		ClearLabels(button)
	end
end

local function HookContainer(container)
	hooksecurefunc(container, "UpdateItems", UpdateLabels)
	hooksecurefunc(container, "AddItemsForRefresh", ClearPendingLabels)
	if container:IsShown() and not container.refresh then
		UpdateLabels(container)
	end
end

local function CancelBankLoad(button)
	local cancel = bankLoads[button]
	if cancel then
		bankLoads[button] = nil
		cancel()
	end
end

local function ClearBankLabels(button)
	CancelBankLoad(button)
	ClearLabels(button)
end

local function UpdateBankLabels(button)
	CancelBankLoad(button)
	local bagID, slotID = button:GetBankTabID(), button:GetContainerSlotID()
	local info = button.itemInfo
	if not UpdateButtonLabels(button, bagID, slotID, info) then return end

	-- 銀行沒有背包的載入完成刷新；只在資料未齊時等待，完成後重讀目前格子。
	local completed = false
	local cancel = Item:CreateFromItemID(info.itemID):ContinueWithCancelOnItemLoad(function()
		completed = true
		bankLoads[button] = nil
		-- Init 會在 Show 前刷新，不能用按鈕可見性擋掉同步完成。
		if button.isInitialized and BankFrame:IsShown() then
			local currentBag, currentSlot = button:GetBankTabID(), button:GetContainerSlotID()
			UpdateButtonLabels(button, currentBag, currentSlot, GetContainerItemInfo(currentBag, currentSlot))
		end
	end)
	if not completed then bankLoads[button] = cancel end
end

local function HookBankButtons(panel)
	for button in panel:EnumerateValidItems() do
		if not bankHooks[button] then
			bankHooks[button] = true
			hooksecurefunc(button, "Refresh", UpdateBankLabels)
			button:HookScript("OnHide", ClearBankLabels)
			UpdateBankLabels(button)
		end
	end
end

local function QueueBankHooks()
	if not BankFrame:IsShown() or bankHookPending then return end
	bankHookPending = true

	-- 首開與分頁生成可能連續觸發，等原生建立完成後只補掛一次。
	C_Timer.After(0.1, function()
		bankHookPending = nil
		if BankFrame:IsShown() then
			HookBankButtons(BankFrame.BankPanel)
		end
	end)
end

function M:OnEnable()
	itemLocation = ItemLocation:CreateEmpty()
	-- 兩種背包模式的實例都要掛上；之後切換模式不需重載。
	for index = 1, NUM_CONTAINER_FRAMES do
		HookContainer(_G["ContainerFrame" .. index])
	end
	HookContainer(ContainerFrameCombinedBags)
	local bankPanel = BankFrame.BankPanel
	hooksecurefunc(bankPanel, "GenerateItemSlotsForSelectedTab", QueueBankHooks)
	BankFrame:HookScript("OnShow", QueueBankHooks)
	QueueBankHooks()
end
