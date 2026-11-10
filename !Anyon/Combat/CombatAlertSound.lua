local _, ns = ...
local F = ns[2]
local M = F.RegisterModule("CombatAlertSound", {"ReadyCheckSound", "AFKCombatSound"})

local afkSoundHandle

local function OnReadyCheck()
	-- 只使用事件通知，不讀可能受聊天限制影響的發起者資料。
	PlaySound(SOUNDKIT.READY_CHECK, "Master")
end

local function StopAFKSound()
	if afkSoundHandle then
		StopSound(afkSoundHandle)
		afkSoundHandle = nil
	end
end

local function OnEnterCombat()
	StopAFKSound()
	local _, instanceType = IsInInstance()
	if instanceType ~= "none" then return end

	local isAFK = UnitIsAFK("player")
	-- 這項警報允許略過受限 AFK 狀態；先查 Secret，再判斷布林值。
	if issecretvalue(isAFK) or not isAFK then return end

	local _, handle = PlaySoundFile(544715, "Master")
	afkSoundHandle = handle
end

function M:OnEnable()
	if F.GetSetting("ReadyCheckSound") then
		F.RegisterEvent("READY_CHECK", OnReadyCheck)
	end
	if F.GetSetting("AFKCombatSound") then
		F.RegisterEvent("PLAYER_REGEN_DISABLED", OnEnterCombat)
		-- 清理自己的音效時不再查 AFK，避免解除暫離或轉場後漏停。
		F.RegisterEvent("PLAYER_REGEN_ENABLED", StopAFKSound)
		F.RegisterEvent("PLAYER_LEAVING_WORLD", StopAFKSound)
	end
end
