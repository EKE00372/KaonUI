-- idTip 12.1.1 (silverwind)
-- https://github.com/silverwind/idTip
--[[
Copyright (c) silverwind
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

local _, ns = ...
local F = ns[2]
local M = F.RegisterModule("idTip", {"idTip_Opt1", "idTip_Opt2", "idTip_Opt3"})

local kinds = {
	spell = "SpellID",
	item = "ItemID",
	unit = "NPC ID",
	quest = "QuestID",
	talent = "TalentID",
	achievement = "AchievementID",
	criteria = "CriteriaID",
	ability = "AbilityID",
	artifactpower = "ArtifactPowerID",
	currency = "CurrencyID",
	enchant = "EnchantID",
	bonus = "BonusID",
	gem = "GemID",
	mount = "MountID",
	macro = "MacroID",
	set = "SetID",
	visual = "VisualID",
	source = "SourceID",
	species = "SpeciesID",
	icon = "IconID",
	areapoi = "AreaPoiID",
	vignette = "VignetteID",
	expansion = "ExpansionID",
	object = "ObjectID",
	traitnode = "TraitNodeID",
	traitentry = "TraitEntryID",
	traitdef = "TraitDefinitionID",
}

local primaryKinds = {
	spell = true, item = true, unit = true, quest = true, achievement = true,
	currency = true, mount = true, macro = true, icon = true,
}
local bonusTraitKinds = {bonus = true, traitnode = true, traitentry = true, traitdef = true}

local kindsByID, pendingAddons

local function isEnabled(kind)
	if primaryKinds[kind] then return F.GetSetting("idTip_Opt1") end
	if bonusTraitKinds[kind] then return F.GetSetting("idTip_Opt3") end
	return F.GetSetting("idTip_Opt2")
end

local function isSecret(value)
	return issecretvalue(value) or (type(value) == "table" and issecrettable(value))
end

-- ID 為 secret 時略過
local function isValidId(id)
	if isSecret(id) then return false end
	return (type(id) == "string" or type(id) == "number") and id ~= ""
end

local function addUnique(list, value)
	if not isValidId(value) then return end
	for _, existing in ipairs(list) do
		if existing == value then return end
	end
	list[#list + 1] = value
end

local function cellText(name, side, index)
	local frame = _G[name .. "Text" .. side .. index]
	local text = frame and frame:GetText()
	if isSecret(text) then return nil end
	return text, frame
end

-- 合併完整相同的 ID 標籤
local function extendLine(tooltip, name, label, id)
	local plural = label .. "s"
	for index = tooltip:NumLines(), 1, -1 do
		local text, left = cellText(name, "Left", index)
		if text == label or text == plural then
			local joined, right = cellText(name, "Right", index)
			if not right then return true end

			local values = {}
			for value in string.gmatch(joined or "", "[^,]+") do
				values[#values + 1] = value
			end
			local count = #values
			if type(id) == "table" then
				for _, value in ipairs(id) do addUnique(values, tostring(value)) end
			else
				addUnique(values, tostring(id))
			end
			if #values > count then
				left:SetText(#values > 1 and plural or label)
				right:SetText(table.concat(values, ","))
				tooltip:Show()
			end
			return true
		end
	end
	return false
end

local function addLine(tooltip, id, kind)
	if not isEnabled(kind) or tooltip:IsForbidden() then return end
	local name = tooltip:GetName()
	if not name then return end

	local label = kinds[kind]
	if extendLine(tooltip, name, label, id) then return end

	local multiple = type(id) == "table"
	tooltip:AddDoubleLine(label .. (multiple and "s" or ""), multiple and table.concat(id, ",") or id,
		nil, nil, nil, WHITE_FONT_COLOR.r, WHITE_FONT_COLOR.g, WHITE_FONT_COLOR.b)
	tooltip:Show()
end

local function add(tooltip, id, kind)
	if type(id) == "table" then
		if isSecret(id) then return end
		if #id == 0 then return end
		for _, value in ipairs(id) do
			if not isValidId(value) then return end
		end
		if #id == 1 then id = id[1] end
	elseif not isValidId(id) then
		return
	end
	addLine(tooltip, id, kind)
	if type(id) == "table" then return end

	if kind == "spell" and isEnabled("icon") then
		add(tooltip, C_Spell.GetSpellTexture(id), "icon")
	elseif kind == "item" and isEnabled("item") then
		add(tooltip, C_Item.GetItemIconByID(id), "icon")
		add(tooltip, select(2, C_Item.GetItemSpell(id)), "spell")
	elseif kind == "species" and isEnabled("unit") then
		-- SpeciesID 與 NPC ID 屬於不同開關
		add(tooltip, select(4, C_PetJournal.GetPetInfoBySpeciesID(id)), "unit")
	end
end

local function addItemInfo(tooltip, link)
	if isSecret(link) or type(link) ~= "string" then return false end
	local itemString = string.match(link, "item:([%-?%d:]+)")
	if not itemString then return false end

	local itemSplit = {}
	-- 保留負數及空欄位的位置，避免 Lua 5.1 的空字串匹配令 BonusID 位移
	for value in string.gmatch(itemString .. ":", "([^:]*):") do
		itemSplit[#itemSplit + 1] = value
	end
	local itemId = string.match(link, "item:(%d*)")
	if not itemId or itemId == "" or itemId == "0" then return false end
	add(tooltip, itemId, "item")

	local enchantId = tonumber(itemSplit[2])
	if enchantId and enchantId ~= 0 then add(tooltip, itemSplit[2], "enchant") end

	if isEnabled("bonus") then
		local bonuses = {}
		for index = 1, math.min(tonumber(itemSplit[13]) or 0, #itemSplit - 13) do
			addUnique(bonuses, itemSplit[13 + index])
		end
		add(tooltip, bonuses, "bonus")
	end

	if isEnabled("gem") then
		local gems = {}
		for socket = 1, 4 do
			local gemLink = select(2, C_Item.GetItemGem(link, socket))
			if not isSecret(gemLink) and gemLink then
				addUnique(gems, string.match(gemLink, "item:(%d+):"))
			end
		end
		add(tooltip, gems, "gem")
	end

	if isEnabled("expansion") then
		local expansionId, setId = select(15, C_Item.GetItemInfo(itemId))
		add(tooltip, expansionId, "expansion")
		add(tooltip, setId, "set")
	end
	return true
end

-- 使用 TooltipDataHandler，不逐框掃描或重複 hook
local function onTooltipPostCall(tooltip, data)
	if isSecret(data) or not data or isSecret(data.type) then return end
	local kind = kindsByID[data.type]
	if not kind then return end

	if kind == "unit" then
		if C_PetBattles.IsInBattle() or isSecret(data.guid) then return end
		local guid = data.guid or ""
		local id = tonumber(guid:match("^%a+%-%d+%-%d+%-%d+%-%d+%-(%d+)%-%x+$"))
		add(tooltip, id or data.id, "unit")
	elseif kind == "item" then
		if isSecret(data.guid) then return end
		local link = data.guid and C_Item.GetItemLinkByGUID(data.guid)
		if not isSecret(link) and not link then link = data.hyperlink end
		if not addItemInfo(tooltip, link) then add(tooltip, data.id, "item") end
	else
		add(tooltip, data.id, kind)
	end
end

local function onTalentTooltipCreated(_, button, tooltip)
	add(tooltip, button.entryID, "traitentry")
	add(tooltip, button.definitionID, "traitdef")
	-- TalentDisplay 沒有節點；GetNodeInfo 只存在於節點按鈕
	if button.GetNodeInfo then
		local nodeInfo = button:GetNodeInfo()
		if not isSecret(nodeInfo) and nodeInfo then add(tooltip, nodeInfo.ID, "traitnode") end
	end
end

local function onAppearanceTooltip(tooltip, appearanceData)
	local visualIDs, sourceIDs, itemIDs = {}, {}, {}
	for _, source in ipairs(appearanceData.sources) do
		addUnique(visualIDs, source.visualID)
		addUnique(sourceIDs, source.sourceID)
		addUnique(itemIDs, source.itemID)
	end
	add(tooltip, visualIDs, "visual")
	add(tooltip, sourceIDs, "source")
	add(tooltip, itemIDs, "item")
end

-- 成就索引
local function criteriaIndex(achievementId, kind, poolIndex)
	for index = 1, GetAchievementNumCriteria(achievementId) do
		local _, criteriaType, _, _, _, _, flags, assetId = GetAchievementCriteriaInfo(achievementId, index)
		local frameKind = criteriaType == CRITERIA_TYPE_ACHIEVEMENT and assetId and "metas"
			or bit.band(flags, EVALUATION_TREE_FLAG_PROGRESS_BAR) ~= 0 and "progressBars"
			or "criterias"
		if frameKind == kind then
			poolIndex = poolIndex - 1
			if poolIndex == 0 then return index end
		end
	end
end

local function criteriaOnEnter(frame)
	if not isEnabled("achievement") and not isEnabled("criteria") then return end
	local button = frame:GetParent()
	while button and not button.id do button = button:GetParent() end
	if not button then return end
	local index = criteriaIndex(button.id, frame.idTipKind, frame.idTipIndex)
	if not index then return end -- 回收後的框體可能已不對應目前成就
	local criteriaId = select(10, GetAchievementCriteriaInfo(button.id, index))
	if not isValidId(criteriaId) then return end
	if not GameTooltip:IsVisible() then GameTooltip:SetOwner(button:GetParent(), "ANCHOR_NONE") end
	GameTooltip:SetPoint("TOPLEFT", button, "TOPRIGHT", 0, 0)
	add(GameTooltip, button.id, "achievement")
	add(GameTooltip, criteriaId, "criteria")
	GameTooltip:Show()
end

local function addPetBattleAbility(id)
	if not isEnabled("ability") or not isValidId(id) then return end
	local description = PetBattlePrimaryAbilityTooltip.Description
	local text = description:GetText()
	if isSecret(text) then return end
	description:SetText((text or "") .. "\r\r" .. kinds.ability .. "|cffffffff " .. id .. "|r")
end

local function setupAchievements()
	EventRegistry:RegisterCallback("AchievementFrameAchievement.OnEnter", function(_, button)
		if not isEnabled("achievement") or not isValidId(button.id) then return end
		GameTooltip:SetOwner(button, "ANCHOR_NONE")
		GameTooltip:SetPoint("TOPLEFT", button, "TOPRIGHT", 0, 0)
		add(GameTooltip, button.id, "achievement")
	end, M)
	EventRegistry:RegisterCallback("AchievementFrameAchievement.OnLeave", GameTooltip_Hide, M)

	local objectives = AchievementTemplateMixin:GetObjectiveFrame()
	for method, kind in pairs({GetCriteria = "criterias", GetMeta = "metas", GetProgressBar = "progressBars"}) do
		hooksecurefunc(objectives, method, function(self, index)
			local frame = self[kind][index]
			local target = kind == "criterias" and frame.Name or frame
			target.idTipIndex = index
			target.idTipKind = kind
			if not target.idTipHooked then
				target:SetMouseMotionEnabled(true)
				target:HookScript("OnEnter", criteriaOnEnter)
				target:HookScript("OnLeave", GameTooltip_Hide)
				target.idTipHooked = true
			end
		end)
	end
end

local function setupMapPins()
	hooksecurefunc(AreaPOIPinMixin, "TryShowTooltip", function(pin)
		if GameTooltip:IsShown() and GameTooltip:IsOwned(pin) then
			add(GameTooltip, pin.poiInfo.areaPoiID, "areapoi")
		end
	end)
	hooksecurefunc(VignettePinMixin, "OnMouseEnter", function(pin)
		if GameTooltip:IsShown() and GameTooltip:IsOwned(pin) then
			add(GameTooltip, pin.vignetteInfo.vignetteID, "vignette")
		end
	end)
end

local function setupGarrisonTooltip()
	hooksecurefunc("AddAutoCombatSpellToTooltip", function(tooltip, info)
		add(tooltip, info.autoCombatSpellID, "ability")
	end)
end

local function onAddonLoaded(self, _, addonName)
	local setup = pendingAddons[addonName]
	if not setup then return end
	setup()
	pendingAddons[addonName] = nil
	if not next(pendingAddons) then self:UnregisterEvent("ADDON_LOADED") end
end

-- 三選項全關時 Init 不啟用模組
function M:OnEnable()
	local tooltipType = Enum.TooltipDataType
	kindsByID = {
		[tooltipType.Item] = "item",
		[tooltipType.Spell] = "spell",
		[tooltipType.Unit] = "unit",
		[tooltipType.Corpse] = "unit",
		[tooltipType.Object] = "object",
		[tooltipType.Currency] = "currency",
		[tooltipType.UnitAura] = "spell",
		[tooltipType.AzeriteEssence] = "spell",
		[tooltipType.CompanionPet] = "species",
		[tooltipType.Mount] = "mount",
		[tooltipType.PetAction] = "spell",
		[tooltipType.Achievement] = "achievement",
		[tooltipType.EnhancedConduit] = "spell",
		[tooltipType.EquipmentSet] = "set",
		[tooltipType.RecipeRankInfo] = "spell",
		[tooltipType.Totem] = "spell",
		[tooltipType.Toy] = "item",
		[tooltipType.Quest] = "quest",
		[tooltipType.QuestPartyProgress] = "quest",
		[tooltipType.Macro] = "macro",
	}

	TooltipDataProcessor.AddTooltipPostCall(TooltipDataProcessor.AllTypes, onTooltipPostCall)

	-- 這三種額外 ID 不在各自的 TooltipData.id 內
	hooksecurefunc(GameTooltip, "SetRecipeResultItem", function(tooltip, id)
		add(tooltip, id, "spell")
	end)
	hooksecurefunc(GameTooltip, "SetArtifactPowerByID", function(tooltip, id)
		add(tooltip, id, "artifactpower")
	end)
	hooksecurefunc(GameTooltip, "SetPvpTalent", function(tooltip, id)
		add(tooltip, id, "talent")
	end)

	EventRegistry:RegisterCallback("TalentDisplay.TooltipCreated", onTalentTooltipCreated, M)

	hooksecurefunc("TaskPOI_OnEnter", function(button)
		add(GameTooltip, button.questID, "quest")
	end)
	hooksecurefunc("QuestMapLogTitleButton_OnEnter", function(button)
		add(GameTooltip, button.info.questID, "quest")
	end)

	hooksecurefunc(CollectionWardrobeUtil, "SetAppearanceTooltip", onAppearanceTooltip)

	hooksecurefunc("PetBattleAbilityButton_OnEnter", function(button)
		if button:GetEffectiveAlpha() > 0 then
			local ally = Enum.BattlePetOwner.Ally
			addPetBattleAbility(C_PetBattles.GetAbilityInfo(ally, C_PetBattles.GetActivePet(ally), button:GetID()))
		end
	end)
	hooksecurefunc("PetBattleAura_OnEnter", function(frame)
		local parent = frame:GetParent()
		addPetBattleAbility(C_PetBattles.GetAuraInfo(parent.petOwner, parent.petIndex, frame.auraIndex))
	end)

	pendingAddons = {
		Blizzard_AchievementUI = setupAchievements,
		Blizzard_SharedMapDataProviders = setupMapPins,
		Blizzard_GarrisonTemplates = setupGarrisonTooltip,
	}

	local eventFrame = CreateFrame("Frame")
	eventFrame:RegisterEvent("ADDON_LOADED")
	eventFrame:SetScript("OnEvent", onAddonLoaded)
	for addonName in pairs(pendingAddons) do
		if C_AddOns.IsAddOnLoaded(addonName) then onAddonLoaded(eventFrame, nil, addonName) end
	end
end
