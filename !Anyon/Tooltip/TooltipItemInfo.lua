local _, ns = ...
local F, L = ns[2], ns[4]
local M = F.RegisterModule("TooltipItemInfo", "TooltipItemInfo")

local waitingInfo, waitingData, waitingID

local function IsPublicTable(value)
	return not issecretvalue(value) and type(value) == "table" and canaccesstable(value) and not issecrettable(value)
end

local function ClearWaiting()
	waitingInfo, waitingData, waitingID = nil, nil, nil
end

local function AddItemInfo(tooltip, id)
	local _, _, _, _, _, itemType, subType, stack = C_Item.GetItemInfo(id)
	if not canaccessallvalues(itemType, subType, stack) then return end
	if not itemType then return false end

	F.AddTooltipSeparator(tooltip)
	tooltip:AddDoubleLine(itemType, subType or "", nil, nil, nil, 1, 1, 1)
	if stack and stack > 1 then
		tooltip:AddDoubleLine(L.TooltipStack, string.format("%d", stack), nil, nil, nil, 1, 1, 1)
	end
	return true
end

local function OnTooltipPostCall(tooltip, data)
	if tooltip ~= GameTooltip or tooltip:IsForbidden() or not IsPublicTable(data)
		or issecretvalue(data.type) or data.type ~= Enum.TooltipDataType.Item then return end
	local id = data.id
	if issecretvalue(id) or not id then return end
	if AddItemInfo(tooltip, id) ~= false then return end

	local primary, processing = tooltip:GetPrimaryTooltipInfo(), tooltip:GetProcessingTooltipInfo()
	if not IsPublicTable(primary) or not IsPublicTable(processing) or primary ~= processing
		or not IsPublicTable(primary.tooltipData) or primary.tooltipData ~= data then return end
	waitingInfo, waitingData, waitingID = primary, data, id
end

local function OnItemInfoReceived(_, id, success)
	if not waitingID or not canaccessallvalues(id, success) or not success or id ~= waitingID then return end
	local info, data, itemID = waitingInfo, waitingData, waitingID
	ClearWaiting()
	if GameTooltip:IsForbidden() or not GameTooltip:IsShown() then return end
	local primary = GameTooltip:GetPrimaryTooltipInfo()
	if not IsPublicTable(primary) or primary ~= info then return end
	local currentData = primary.tooltipData
	if not IsPublicTable(currentData) or currentData ~= data
		or not canaccessallvalues(currentData.type, currentData.id)
		or currentData.type ~= Enum.TooltipDataType.Item or currentData.id ~= itemID then return end
	-- 只補仍對應原主物品的附加行，不重播可能含受限資料的 getter。
	if AddItemInfo(GameTooltip, itemID) then GameTooltip:Show() end
end

function M:OnEnable()
	-- 與 idTip 同用 AllTypes，依模組載入順序先追加分類，再追加 ID。
	TooltipDataProcessor.AddTooltipPostCall(TooltipDataProcessor.AllTypes, OnTooltipPostCall)
	GameTooltip:HookScript("OnTooltipCleared", ClearWaiting)
	GameTooltip:HookScript("OnHide", ClearWaiting)
	F.RegisterEvent("GET_ITEM_INFO_RECEIVED", OnItemInfoReceived)
end
