local _, ns = ...
local F = ns[2]
local M = F.RegisterModule("AutoShot", "AutoShot")
local CreateFrame, Screenshot = CreateFrame, Screenshot
local C_Timer_After = C_Timer.After

local DELAY = 1 -- 延遲一秒，讓成就、死亡或副本完成提示先顯示出來
local raidDifficulties = {
	[15] = true, -- Heroic
	[16] = true, -- Mythic
}

local pending = false

local function TakeDelayedScreenshot()
	-- 同一秒內可能連續觸發多個事件，只排一次截圖即可。
	if pending then return end
	pending = true

	C_Timer_After(DELAY, function()
		pending = false
		Screenshot()
	end)
end

local function OnEvent(self, event, ...)
	if event == "ENCOUNTER_END" then
		-- encounterID, encounterName, difficultyID, groupSize, success, encounterUnitStatus
		local _, _, difficultyID, _, success = ...
		if success == 1 and raidDifficulties[difficultyID] then
			TakeDelayedScreenshot()
		end
	else
		TakeDelayedScreenshot()
	end
end

function M:OnEnable()
	local frame = CreateFrame("Frame")
	frame:RegisterEvent("ACHIEVEMENT_EARNED")
	frame:RegisterEvent("PLAYER_DEAD")
	frame:RegisterEvent("PLAYER_LEVEL_UP")
	frame:RegisterEvent("CHALLENGE_MODE_COMPLETED")
	frame:RegisterEvent("ENCOUNTER_END")
	frame:SetScript("OnEvent", OnEvent)
end
