local _, ns = ...
local F = ns[2]
local M = F.RegisterModule("ThreatSound", "ThreatSound")

-- 填入完整音檔路徑；不穩用單聲，丟怪用已合成兩聲的音檔，留空不播放。
local WARNING_SOUND = [[]]
local LOST_SOUND = [[]]
local SOUND_INTERVAL = .5

local threatStates = {}
local monitoring = false
local lastSoundTime, lastSoundSeverity

local function AddNameplate(_, unit)
	-- 只查 player 對原生 nameplate token 的 ThreatState，不擴到其他身份組合。
	if unit and unit:match("^nameplate%d+$") then
		threatStates[unit] = UnitThreatSituation("player", unit) or false
	end
end

local function RemoveNameplate(_, unit)
	threatStates[unit] = nil
end

local function UpdateThreat(unit)
	local previous = threatStates[unit]
	local status = UnitThreatSituation("player", unit)
	-- false 保留名條的追蹤資格；nil 只代表無資料，不當成仇恨 0。
	threatStates[unit] = status or false
	if not previous or not status then return 0 end
	if previous >= 2 and status < 2 then return 2 end
	if previous == 3 and status == 2 then return 1 end
	return 0
end

local function OnThreatUpdate(_, unit)
	local severity = 0
	if unit == "player" then
		for token in pairs(threatStates) do
			local result = UpdateThreat(token)
			if result > severity then severity = result end
		end
	elseif threatStates[unit] ~= nil then
		severity = UpdateThreat(unit)
	end
	if severity == 0 then return end

	local sound = severity == 2 and LOST_SOUND or WARNING_SOUND
	if sound == "" then return end

	local now = GetTime()
	-- 多怪共用間隔；丟怪可越過剛播放的不穩預警，不延後補播舊狀態。
	if now - lastSoundTime < SOUND_INTERVAL and severity <= lastSoundSeverity then return end
	local played = PlaySoundFile(sound, "Master")
	if played then
		lastSoundTime, lastSoundSeverity = now, severity
	end
end

local function RefreshMonitoring()
	local spec = C_SpecializationInfo.GetSpecialization()
	local isTank = false
	if spec then
		isTank = (select(5, C_SpecializationInfo.GetSpecializationInfo(spec)) == "TANK")
	end
	if isTank ~= monitoring then
		monitoring = isTank
		if isTank then
			F.RegisterEvent("NAME_PLATE_UNIT_ADDED", AddNameplate)
			F.RegisterEvent("NAME_PLATE_UNIT_REMOVED", RemoveNameplate)
			F.RegisterEvent("UNIT_THREAT_LIST_UPDATE", OnThreatUpdate)
			F.RegisterEvent("UNIT_THREAT_SITUATION_UPDATE", OnThreatUpdate)
		else
			F.UnregisterEvent("NAME_PLATE_UNIT_ADDED", AddNameplate)
			F.UnregisterEvent("NAME_PLATE_UNIT_REMOVED", RemoveNameplate)
			F.UnregisterEvent("UNIT_THREAT_LIST_UPDATE", OnThreatUpdate)
			F.UnregisterEvent("UNIT_THREAT_SITUATION_UPDATE", OnThreatUpdate)
		end
	end

	wipe(threatStates)
	lastSoundTime, lastSoundSeverity = -SOUND_INTERVAL, 0
	if monitoring then
		-- 登入／換區／切回坦克時靜默建立基線，不把首次看到的狀態當成丟怪。
		for _, plate in ipairs(C_NamePlate.GetNamePlates()) do
			AddNameplate(nil, plate:GetUnit())
		end
	end
end

function M:OnEnable()
	F.RegisterEvent("PLAYER_ENTERING_WORLD", RefreshMonitoring)
	F.RegisterEvent("ACTIVE_PLAYER_SPECIALIZATION_CHANGED", RefreshMonitoring)
	RefreshMonitoring()
end
