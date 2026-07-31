local addon, ns = ...
local C, F, G, L = unpack(ns)
local M = F.RegisterModule("tullaRange", "tullaRange")

-- Pure version for tullaRange: https://github.com/tullamods/tullaRange

-- Colors
local COLORS = {
	normal = { 1, 1, 1, 1, desaturate = false },
	oor = { 1, 0.3, 0.1, 1, desaturate = true },
	oom = { 0.1, 0.3, 1, 1, desaturate = true },
	unusable = { 0.4, 0.4, 0.4, 1, desaturate = false },
}

local UPDATE_DELAY = 1 / 30

function M:OnEnable()
	if not ActionBarButtonRangeCheckFrame or not ActionBarButtonEventsFrame or not ActionButton_UpdateRangeIndicator then return end
	if not C_ActionBar or not C_ActionBar.IsUsableAction or not C_ActionBar.IsActionInRange then return end

	local states = {}
	local registered = {}
	local updateRequested

	local function ApplyIconColor(icon, state)
		local color = COLORS[state] or COLORS.normal
		if not icon then return end

		icon:SetVertexColor(color[1], color[2], color[3], color[4])
		icon:SetDesaturated(color.desaturate)
	end

	local function ApplyHotKeyColor(hotkey, state)
		local color = COLORS[state] or COLORS.normal
		if not hotkey then return end

		hotkey:SetVertexColor(color[1], color[2], color[3])
	end

	local function GetActionState(slot)
		local actionType, id = GetActionInfo(slot)
		local isUsable, notEnoughMana

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

		if isUsable == nil then
			isUsable, notEnoughMana = C_ActionBar.IsUsableAction(slot)
		end

		local outOfRange = C_ActionBar.IsActionInRange(slot) == false
		if isUsable then
			return outOfRange and "oor" or "normal", outOfRange
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
			notEnoughMana = false
		end

		if isUsable then
			return outOfRange and "oor" or "normal", outOfRange
		end

		return notEnoughMana and "oom" or "unusable", outOfRange
	end

	local function ActionButton_Update(button)
		if not button or not button.action or not button.icon then return end

		local iconState, outOfRange = GetActionState(button.action)
		states[button.icon] = iconState
		ApplyIconColor(button.icon, iconState)

		local hotkeyState = outOfRange and "oor" or "normal"
		states[button.HotKey] = hotkeyState
		ApplyHotKeyColor(button.HotKey, hotkeyState)
	end

	local function ActionButton_UpdateRange(button, checksRange, inRange)
		if not registered[button] then return end

		local outOfRange = checksRange and not inRange
		local icon = button.icon
		local iconState = states[icon]
		local newIconState

		if iconState == "normal" and outOfRange then
			newIconState = "oor"
		elseif iconState == "oor" and not outOfRange then
			newIconState = "normal"
		end

		if newIconState then
			states[icon] = newIconState
			ApplyIconColor(icon, newIconState)
		end

		local hotkey = button.HotKey
		local hotkeyState = states[hotkey]
		local newHotKeyState

		if hotkeyState == "normal" and outOfRange then
			newHotKeyState = "oor"
		elseif hotkeyState == "oor" and not outOfRange then
			newHotKeyState = "normal"
		end

		if newHotKeyState then
			states[hotkey] = newHotKeyState
			ApplyHotKeyColor(hotkey, newHotKeyState)
		end
	end

	local function ActionButton_Register(button)
		if not button or registered[button] then return end

		hooksecurefunc(button, "UpdateUsable", ActionButton_Update)
		registered[button] = true
		ActionButton_Update(button)
	end

	local function PetButton_Register(button)
		if button then
			registered[button] = true
		end
	end

	local function PetBar_Update(bar)
		if not bar or not bar.actionButtons or not PetHasActionBar() then return end

		for index, button in pairs(bar.actionButtons) do
			local icon = button.icon
			if icon and icon:IsVisible() then
				local iconState = GetPetActionState(index)
				states[icon] = iconState
				ApplyIconColor(icon, iconState)
			end
		end
	end

	local function RequestUpdate()
		if updateRequested then return end

		C_Timer.After(UPDATE_DELAY, function()
			ActionBarButtonEventsFrame:ForEachFrame(ActionButton_Update)

			if PetActionBar then
				PetBar_Update(PetActionBar)
			end

			updateRequested = nil
		end)

		updateRequested = true
	end

	ActionBarButtonEventsFrame:ForEachFrame(ActionButton_Register)
	hooksecurefunc(ActionBarButtonEventsFrame, "RegisterFrame", function(_, button)
		ActionButton_Register(button)
	end)

	-- ACTION_RANGE_CHECK_UPDATE 最後會走到這個共享函數
	hooksecurefunc("ActionButton_UpdateRangeIndicator", ActionButton_UpdateRange)

	if PetActionBar and PetActionBar.actionButtons then
		for _, button in pairs(PetActionBar.actionButtons) do
			PetButton_Register(button)
		end

		hooksecurefunc(PetActionBar, "Update", PetBar_Update)

		local eventFrame = CreateFrame("Frame")
		eventFrame:RegisterUnitEvent("UNIT_POWER_UPDATE", "pet")
		eventFrame:SetScript("OnEvent", function()
			PetBar_Update(PetActionBar)
		end)
		self.eventFrame = eventFrame
	end

	RequestUpdate()
end
