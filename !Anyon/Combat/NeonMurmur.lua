local default_color = {
	["SAY"] = {1, 1, 1},
	["YELL"] = {1, 0, 0}
}

local encounter_color = {
	--[encounterID] = { ["SAY"] = {sr, sg, sb}, ["YELL"] = {yr, yg, yb} }
	--[首領戰id] = {}
	--[1443] = { ["SAY"] = {1, 1, .2}, ["YELL"] = {1, .75, .75} } -- test
}

local function OnEvent(_, event, ...)
	if event == "ENCOUNTER_START" then
		local id = ...
		local color = encounter_color[id] or default_color
		
		for k, v in pairs(color) do
			ChangeChatColor(k, unpack(v))
		end
	elseif event == "ENCOUNTER_END" then
		for k, v in pairs(default_color) do
			ChangeChatColor(k, unpack(v))
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		if not InCombatLockdown() then
			for k, v in pairs(default_color) do
				ChangeChatColor(k, unpack(v))
			end
		end
	else
		return
	end
end

local frame = CreateFrame("Frame")
	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	frame:RegisterEvent("ENCOUNTER_START")
	frame:RegisterEvent("ENCOUNTER_END")
	frame:SetScript("OnEvent", OnEvent)