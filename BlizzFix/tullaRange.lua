--==================================================--
-----------------    [[ Config ]]    -----------------
--==================================================--

local colors = { --  R, G, B, A, Desaturate
    normal   = { 1, 1, 1, 1, false },
    oor      = { .8, .1, .1, 1, true },  -- Out of Range 1, 0.3, 0.1
    oom      = { .5, .5, 1, 1, true },  -- Out of Mana 0.1, 0.3, 1
    unusable = { 0.4, 0.4, 0.4, 1, true }-- Unusable
}

--====================================================--
-----------------    [[ Function ]]    -----------------
--====================================================--

local states = {}
local registered = {}

-- 玩家技能按鈕狀態
local function GetActionState(slot)
    local actionType, id = GetActionInfo(slot)
    local isUsable, notEnoughMana

    -- 巨集特別處理
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
        isUsable, notEnoughMana = IsUsableAction(slot)
    end

    local outOfRange = IsActionInRange(slot) == false
    if isUsable then
        return outOfRange and "oor" or "normal", outOfRange
    end

    return notEnoughMana and "oom" or "unusable", outOfRange
end

-- 寵物技能按鈕狀態
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

-- 套用顏色
local function ApplyColor(texture, state)
    local c = colors[state]
    if texture and c then
        texture:SetVertexColor(c[1], c[2], c[3], c[4])
        if texture.SetDesaturated then
            texture:SetDesaturated(c[5])
        end
    end
end

--==================================================--
-----------------    [[ Update ]]    -----------------
--==================================================--

local function actionButton_Update(button)
    local iconState, outOfRange = GetActionState(button.action)
    states[button.icon] = iconState
    ApplyColor(button.icon, iconState)

    local hotkeyState = outOfRange and "oor" or "normal"
    states[button.HotKey] = hotkeyState
    ApplyColor(button.HotKey, hotkeyState)
end

local function actionButton_UpdateRange(button, checksRange, inRange)
    if not registered[button] then return end

    local oor = checksRange and not inRange

    -- 更新圖示
    local icon = button.icon
    local iconState = states[icon]
    local newIconState

    if iconState == "normal" and oor then
        newIconState = "oor"
    elseif iconState == "oor" and not oor then
        newIconState = "normal"
    end

    if newIconState then
        states[icon] = newIconState
        ApplyColor(icon, newIconState)
    end

    -- 更新快捷鍵文字
    local hotkey = button.HotKey
    local hotkeyState = states[hotkey]
    local newHotkeyState

    if hotkeyState == "normal" and oor then
        newHotkeyState = "oor"
    elseif hotkeyState == "oor" and not oor then
        newHotkeyState = "normal"
    end

    if newHotkeyState then
        states[hotkey] = newHotkeyState
        ApplyColor(hotkey, newHotkeyState)
    end
end

local function actionButton_Register(button)
    if not registered[button] then
        hooksecurefunc(button, "UpdateUsable", actionButton_Update)
        registered[button] = true
    end
end

local function petBar_Update(bar)
    if not PetHasActionBar() then return end

    for index, button in pairs(bar.actionButtons) do
        if button.icon:IsVisible() then
            local iconState = GetPetActionState(index)
            states[button.icon] = iconState
            ApplyColor(button.icon, iconState)
        end
    end
end

--=========================================================--
-----------------    [[ Event Handler ]]    -----------------
--=========================================================--

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        -- 註冊並 Hook 玩家快捷列
        if ActionBarButtonEventsFrame then
            ActionBarButtonEventsFrame:ForEachFrame(actionButton_Register)
            hooksecurefunc(ActionBarButtonEventsFrame, "RegisterFrame", function(_, button)
                actionButton_Register(button)
            end)
        end

        -- 原生距離更新 Hook
        hooksecurefunc("ActionButton_UpdateRangeIndicator", actionButton_UpdateRange)

        -- 停用暴雪預設的距離檢測
        if ActionBarButtonUpdateFrame then
            ActionBarButtonUpdateFrame:SetScript("OnUpdate", nil)
        end

        -- 註冊寵物快捷列
        hooksecurefunc(PetActionBar, "Update", petBar_Update)
        self:RegisterUnitEvent("UNIT_POWER_UPDATE", "pet")

        -- 初次載入強制更新一次
        C_Timer.After(0.1, function()
            if ActionBarButtonEventsFrame then
                ActionBarButtonEventsFrame:ForEachFrame(actionButton_Update)
            end
            petBar_Update(PetActionBar)
        end)

    elseif event == "UNIT_POWER_UPDATE" then
        petBar_Update(PetActionBar)
    end
end)