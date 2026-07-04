local addon, ns = ... 
local C, F, G, L = unpack(ns)
if not C.AutoShot then return end

local CreateFrame, Screenshot = CreateFrame, Screenshot
local delay = 1	-- 延遲一秒
local time = 0	-- Reset screenshot delay timer

local function autoShot(self, elapsed)
	time = time + elapsed
	
	if time >= delay then
		Screenshot()
		time = 0
		self:SetScript("OnUpdate", nil)
	end
end

local function OnEvent(self, event, difficultyID)
	if event == "ENCOUNTER_END" then
		-- only shot heroic and mythic raid
		if (difficultyID == 15 or difficultyID == 16) then
			self:SetScript("OnUpdate", autoShot)
		end
	else
		self:SetScript("OnUpdate", autoShot)
	end
end

local frame = CreateFrame("Frame")
	frame:RegisterEvent("ACHIEVEMENT_EARNED")
	frame:RegisterEvent("PLAYER_DEAD")
	frame:RegisterEvent("PLAYER_LEVEL_UP")
	frame:RegisterEvent("CHALLENGE_MODE_COMPLETED") 
	frame:RegisterEvent("ENCOUNTER_END") 
	frame:SetScript("OnEvent", OnEvent)