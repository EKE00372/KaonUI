local _, ns = ...
local F = ns[2]
local M = F.RegisterModule("AutoLog", "AutoLog")

local CreateFrame, GetInstanceInfo, GetTime = CreateFrame, GetInstanceInfo, GetTime
local LoggingCombat = LoggingCombat
local print = print

local GetCVar, SetCVar = C_CVar.GetCVar, C_CVar.SetCVar

local expirationTime

local function autoLog()
	-- 強制開啟進階戰鬥紀錄
	if GetCVar("advancedCombatLogging") ~= "1" then SetCVar("advancedCombatLogging", "1") end

	-- 不要連續重試
	if GetTime() - (expirationTime or 0) <= 0 then return end
	-- 檢查紀錄是否開啟
	local logging = LoggingCombat()
	if logging == nil then
		expirationTime = GetTime() + 10
		return
	end

	local _, instanceType, difficultyID = GetInstanceInfo()
	local shouldLog = instanceType == "raid" or difficultyID == 8 or difficultyID == 23

	if shouldLog and (not logging) then
		LoggingCombat(true)
		print("|cff00FF00"..COMBATLOGENABLED.."|r")
	elseif not shouldLog and logging then
		LoggingCombat(false)
		print("|cffFF0000"..COMBATLOGDISABLED.."|r")
	end
end

function M:OnEnable()
	local frame = CreateFrame("Frame")
	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	frame:RegisterEvent("CHALLENGE_MODE_START")
	frame:SetScript("OnEvent", autoLog)
end
