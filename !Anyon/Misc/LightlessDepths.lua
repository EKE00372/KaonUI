local LD = CreateFrame("Frame")  --Lightless Depths

local insID   = 2651
local subName = {
    ["無光深淵"] = true,
    ["无光深渊"] = true,
    ["Lightless Depths"] = true,
    ["Lichtlose Kluft"] = true,
    ["Profundidades Lóbregas"] = true,
    ["Profundidades Penumbrosas"] = true,
    ["Profondeurs Enténébrées"] = true,
    ["Profondità Senza Luce"] = true,
    ["빛이 들지 않는 심연"] = true,
    ["Profundezas Sem Luz"] = true,
    ["Беспросветные глубины"] = true,
    }

-- 減益對應數值 亮度 / 對比 / Gamma
local spellCVar = {
    [422806] = {Brightness = 60, Contrast = 75, Gamma = 2.0},
    [420307] = {Brightness = 60, Contrast = 70, Gamma = 1.5},
    [420807] = {Brightness = 60, Contrast = 70, Gamma = 1.5},
    }

local defaultCVar = {
    Brightness = GetCVar("Brightness") or 50,
    Contrast   = GetCVar("Contrast") or 50,
    Gamma      = GetCVar("Gamma") or 1.2,
    }

local curSpell -- nil 代表目前用的就是預設
local function setCVar(cfg)
    if not cfg then
        -- 還原
        if curSpell then
            for k, v in pairs(defaultCVar) do
                SetCVar(k, v) -- 轉回首字大寫的 CVar 名
            end
            curSpell = nil
        end
        return
    end
    
    if curSpell ~= cfg.id then
        SetCVar("Brightness", cfg.Brightness)
        SetCVar("Contrast",   cfg.Contrast)
        SetCVar("Gamma",      cfg.Gamma)
        curSpell = cfg.id
    end
end

local function checkAura()
    local matched

    for spellID, cfg in next, spellCVar do
        if C_UnitAuras.GetPlayerAuraBySpellID(spellID) then
            matched = cfg
            matched.id = spellID
            break
        end
    end

    setCVar(matched)
end

local function zoneCheck()
    local instanceID = select(8, GetInstanceInfo())
    local name = GetSubZoneText()
    local inDepths = (insID == instanceID) and subName[name]

    if inDepths then
        LD:RegisterUnitEvent("UNIT_AURA", "player")
        checkAura()
        C_Timer.After(1, checkAura)
    else
        LD:UnregisterEvent("UNIT_AURA")
        setCVar(nil)
    end
end

local function OnEvent(self, event)
    if event == "UNIT_AURA" then
        checkAura()
    else
        zoneCheck()
    end
end

LD:SetScript("OnEvent", OnEvent)
LD:RegisterEvent("PLAYER_ENTERING_WORLD")
LD:RegisterEvent("ZONE_CHANGED_NEW_AREA")
LD:RegisterEvent("ZONE_CHANGED_INDOORS")
LD:RegisterEvent("ZONE_CHANGED")
LD:RegisterEvent("CVAR_UPDATE")
