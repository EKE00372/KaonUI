local _, ns = ...
local F, G = ns[2], ns[3]
local M = F.RegisterModule("CharacterStats", "CharacterStats")

local slotNames = {
	"Head", "Neck", "Shoulder", "Chest", "Waist", "Legs", "Feet", "Wrist",
	"Hands", "Finger0", "Finger1", "Trinket0", "Trinket1", "Back", "MainHand", "SecondaryHand",
}

local equipment = {}
local slotButtons = {}
local enchantPattern = ENCHANTED_TOOLTIP_LINE:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
enchantPattern = "^"..enchantPattern:gsub("%%%%s", "(.+)").."$"

local function ClearEnchant(entry)
	entry.enchantLink = nil
	entry.tooltipID = nil
	entry.tooltipPending = nil
	entry.enchant:SetText("")
end

local function UpdateEnchant(button, entry)
	local link = entry.item:GetItemLink()
	if not issecretvalue(link) and link and link == entry.enchantLink then return end
	ClearEnchant(entry)

	local data = C_TooltipInfo.GetInventoryItem("player", button:GetID())
	if issecretvalue(data) then return end
	if not data then entry.tooltipPending = true; return end
	if not canaccesstable(data) then return end

	local id = data.dataInstanceID
	if not issecretvalue(id) then
		entry.tooltipID = id
		entry.tooltipPending = (id == nil)
	end
	local lines = data.lines
	if issecretvalue(lines) then return end
	if not lines then entry.tooltipPending = true; return end
	if not canaccesstable(lines) then return end
	local cacheable = true
	for _, line in ipairs(lines) do
		if issecretvalue(line) or not canaccesstable(line) then
			cacheable = false
		elseif issecretvalue(line.type) then
			cacheable = false
		elseif line.type == Enum.TooltipDataLineType.ItemEnchantmentPermanent then
			local text = line.leftText
			-- 公開文字去除本地化提示與「部位 - 」前綴，受限文字原樣交給 setter。
			if not issecretvalue(text) and text then
				text = text:match(enchantPattern) or text
				text = text:match("^.-%s%-%s(.+)$") or text
			end
			entry.enchant:SetText(text)
			break
		end
	end
	if cacheable and entry.tooltipID and not issecretvalue(link) then entry.enchantLink = link end
end

local function FormatStat(statFrame, label, _, isPercentage, numericValue)
	if statFrame:GetParent() ~= CharacterStatsPane or not (isPercentage or label == STAT_HASTE) then return end

	local format = "%.1f%%"
	-- 受限數值只交給原生文字 setter；負加速的附加紅字僅在數值公開時判斷。
	if label == STAT_HASTE and not issecretvalue(numericValue)
		and numericValue < 0 and not GetPVPGearStatRules() then
		format = RED_FONT_COLOR_CODE..format..FONT_COLOR_CODE_CLOSE
	end
	statFrame.Value:SetFormattedText(format, numericValue)
end

local function CancelPending(entry)
	if entry.cancel then
		entry.cancel()
		entry.cancel = nil
	end
end

local function UpdateItemInfo(button)
	local entry = equipment[button]
	if not entry then return end
	CancelPending(entry)
	entry.text:SetText("")
	if not button:IsVisible() or entry.item:IsItemEmpty() then ClearEnchant(entry); return end

	if entry.item:IsItemDataCached() then
		local level = entry.item:GetCurrentItemLevel()
		if level then
			local quality = entry.item:GetItemQuality()
			local color = ColorManager.GetColorDataForItemQuality(quality or Enum.ItemQuality.Common)
			entry.text:SetTextColor(color.r, color.g, color.b)
			entry.text:SetFormattedText("%d", level)
		end
		UpdateEnchant(button, entry)
	else
		ClearEnchant(entry)
		entry.cancel = entry.item:ContinueWithCancelOnItemLoad(entry.onLoad)
	end
end

local function UpdateEquipment()
	if not PaperDollFrame:IsVisible() then return end
	for button in pairs(equipment) do UpdateItemInfo(button) end
end

local function OnTooltipUpdate(_, dataInstanceID)
	if not PaperDollFrame:IsVisible() then return end
	for button, entry in pairs(equipment) do
		if not dataInstanceID or dataInstanceID == entry.tooltipID or entry.tooltipPending then
			entry.enchantLink = nil
			UpdateItemInfo(button)
		end
	end
end

local function OnEnchantCompleted(_, successful, enchantedItem)
	if successful and enchantedItem and enchantedItem:IsValid() and enchantedItem:IsEquipmentSlot() then
		local button = slotButtons[enchantedItem:GetEquipmentSlot()]
		if button then
			equipment[button].enchantLink = nil
			UpdateItemInfo(button)
		end
	end
end

local function CollapseEnchant(self)
	local button = self:GetParent()
	local inset = CharacterFrame.Inset
	local slot = button:GetID()
	local width
	if slot == 16 then
		local inner, outer = button:GetLeft(), inset:GetLeft()
		if inner and outer then width = inner - outer - 4 end
	elseif slot == 17 then
		local inner, outer = button:GetRight(), inset:GetRight()
		if inner and outer then width = outer - inner - 4 end
	else
		-- 左右欄各到裝備區中央，保留圖示間距與中央留白。
		width = inset:GetWidth() / 2 - button:GetWidth() - 10
	end
	if width and width > 0 then self:SetWidth(width) end
end

function M:OnEnable()
	hooksecurefunc("PaperDollFrame_SetLabelAndText", FormatStat)
	for _, name in ipairs(slotNames) do
		local button = _G["Character"..name.."Slot"]
		local text = button:CreateFontString(nil, "OVERLAY")
		text:SetFont(G.Font, 14, G.FontFlag)
		text:SetPoint("TOPRIGHT", button, "TOPRIGHT", -1, -1)
		local slot = button:GetID()
		local enchant = button:CreateFontString(nil, "OVERLAY")
		enchant:SetFont(G.Font, 13, G.FontFlag)
		enchant:SetTextColor(0, 1, 0)
		enchant:SetWordWrap(false)
		enchant:SetWidth(112)
		if slot <= 5 or slot == 9 or slot == 15 or slot == 17 then
			enchant:SetPoint("BOTTOMLEFT", button, "BOTTOMRIGHT", 4, slot == 17 and 2 or 20)
			enchant:SetJustifyH("LEFT")
		else
			enchant:SetPoint("BOTTOMRIGHT", button, "BOTTOMLEFT", -4, slot == 16 and 2 or 20)
			enchant:SetJustifyH("RIGHT")
		end
		enchant:EnableMouse(true)
		enchant:HookScript("OnEnter", function(self) self:SetWidth(0) end)
		enchant:HookScript("OnLeave", CollapseEnchant)
		enchant:HookScript("OnShow", CollapseEnchant)
		local entry = { text = text, enchant = enchant, item = Item:CreateFromEquipmentSlot(slot) }
		equipment[button] = entry
		slotButtons[slot] = button
		entry.onLoad = function()
			entry.cancel = nil
			-- 物品載入期間可能已換裝，回呼只重讀目前槽位。
			UpdateItemInfo(button)
		end
		button:HookScript("OnHide", function()
			CancelPending(entry)
			ClearEnchant(entry)
		end)
	end
	hooksecurefunc("PaperDollItemSlotButton_Update", UpdateItemInfo)
	F.RegisterEvent("PLAYER_AVG_ITEM_LEVEL_UPDATE", UpdateEquipment)
	F.RegisterEvent("UNIT_INVENTORY_CHANGED", UpdateEquipment, "player")
	F.RegisterEvent("ENCHANT_SPELL_COMPLETED", OnEnchantCompleted)
	F.RegisterEvent("TOOLTIP_DATA_UPDATE", OnTooltipUpdate)
	UpdateEquipment()
end
