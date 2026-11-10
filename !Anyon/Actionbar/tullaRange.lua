local _, ns = ...
local F = ns[2]
local M = F.RegisterModule("tullaRange", "tullaRange")

-- Pure version for tullaRange: https://github.com/tullamods/tullaRange

-- Colors
local COLORS = {
	normal = { 1, 1, 1, 1, desaturate = false },
	oor = { 1, 0.3, 0.1, 1, desaturate = true },
	oom = { 0.1, 0.3, 1, 1, desaturate = true },
	unusable = { 0.4, 0.4, 0.4, 1, desaturate = false },
}

-- 分開保存可用性與已套用顏色
local usableStates, iconStates, registered

local function ApplyIconColor(icon, state)
	local color = COLORS[state]

	icon:SetVertexColor(color[1], color[2], color[3], color[4])
	icon:SetDesaturated(color.desaturate)
end

local function ApplyHotKeyColor(hotkey, state)
	local color = COLORS[state]

	hotkey:SetVertexColor(color[1], color[2], color[3])
end

local function GetActionState(slot, isUsable, notEnoughMana)
	local actionType, id = GetActionInfo(slot)

	-- 以 # 開頭的巨集優先用綁定法術判斷資源
	if actionType == "macro" then
		local name = GetMacroInfo(id)
		if name and name:sub(1, 1) == "#" then
			local spellID = GetMacroSpell(id)
			if spellID then
				isUsable, notEnoughMana = C_Spell.IsSpellUsable(spellID)
			end
		end
	end

	if isUsable == nil or notEnoughMana == nil then
		isUsable, notEnoughMana = C_ActionBar.IsUsableAction(slot)
	end

	local outOfRange = C_ActionBar.IsActionInRange(slot) == false
	if isUsable then
		return "normal", outOfRange
	end

	return notEnoughMana and "oom" or "unusable", outOfRange
end

local function GetPetActionState(index)
	local _, _, _, _, _, _, spellID, checksRange, inRange = GetPetActionInfo(index)
	local outOfRange = checksRange and not inRange
	local isUsable, notEnoughMana

	if spellID then
		isUsable, notEnoughMana = C_Spell.IsSpellUsable(spellID)
	else
		isUsable = GetPetActionSlotUsable(index)
	end

	if isUsable then
		return "normal", outOfRange
	end

	return notEnoughMana and "oom" or "unusable", outOfRange
end

local function ActionButton_Update(button, _, isUsable, notEnoughMana)
	if not button.action then return end

	local usableState, outOfRange = GetActionState(button.action, isUsable, notEnoughMana)
	usableStates[button.icon] = usableState
	local iconState = outOfRange and "oor" or usableState
	iconStates[button.icon] = iconState
	ApplyIconColor(button.icon, iconState)

	ApplyHotKeyColor(button.HotKey, outOfRange and "oor" or "normal")
end

local function ActionButton_UpdateRange(button, checksRange, inRange)
	if not registered[button] then return end

	local outOfRange = checksRange and not inRange
	local icon = button.icon
	local newIconState = outOfRange and "oor" or usableStates[icon]

	if newIconState and iconStates[icon] ~= newIconState then
		iconStates[icon] = newIconState
		ApplyIconColor(icon, newIconState)
	end

	-- 狀態更新後重新染色快捷鍵文字
	ApplyHotKeyColor(button.HotKey, outOfRange and "oor" or "normal")
end

local function ActionButton_Register(button)
	if registered[button] then return end

	hooksecurefunc(button, "UpdateUsable", ActionButton_Update)
	registered[button] = true
	ActionButton_Update(button)
end

local function PetBar_Update(bar, force)
	if not PetHasActionBar() then return end

	for index, button in pairs(bar.actionButtons) do
		local icon = button.icon
		local usableState, outOfRange = GetPetActionState(index)
		usableStates[icon] = usableState
		if icon:IsVisible() then
			local iconState = outOfRange and "oor" or usableState
			-- 原生刷新後補染
			if force or iconStates[icon] ~= iconState then
				iconStates[icon] = iconState
				ApplyIconColor(icon, iconState)
			end
			ApplyHotKeyColor(button.HotKey, outOfRange and "oor" or "normal")
		else
			iconStates[icon] = nil
		end
	end
end

function M:OnEnable()
	usableStates = {}
	iconStates = {}
	registered = {}

	ActionBarButtonEventsFrame:ForEachFrame(ActionButton_Register)
	hooksecurefunc(ActionBarButtonEventsFrame, "RegisterFrame", function(_, button)
		ActionButton_Register(button)
	end)

	-- ACTION_RANGE_CHECK_UPDATE 最後會走到這個共享函數
	hooksecurefunc("ActionButton_UpdateRangeIndicator", ActionButton_UpdateRange)

	for _, button in pairs(PetActionBar.actionButtons) do
		registered[button] = true
	end

	hooksecurefunc(PetActionBar, "Update", function(bar)
		PetBar_Update(bar, true)
	end)

	local eventFrame = CreateFrame("Frame")
	eventFrame:RegisterUnitEvent("UNIT_POWER_UPDATE", "pet")
	eventFrame:SetScript("OnEvent", function()
		PetBar_Update(PetActionBar)
	end)

	-- 初始化後更新一次
	C_Timer.After(1 / 30, function()
		ActionBarButtonEventsFrame:ForEachFrame(ActionButton_Update)
		PetBar_Update(PetActionBar, true)
	end)
end
