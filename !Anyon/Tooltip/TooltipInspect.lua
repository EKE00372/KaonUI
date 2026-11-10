local _, ns = ...
local F = ns[2]
local M = F.RegisterModule("TooltipInspect", "TooltipDetails")

local REQUEST_INTERVAL, CACHE_DURATION = 2, 600
local RESPONSE_TIMEOUT, FAILURE_DELAY, FOREIGN_DELAY = 5, 10, 3

local cache, retryAt, pruneAt
local wantedUnit, wantedGUID, wantedCallback, wantedCheck
local pendingGUID, timer, sending
local lastRequestAt, lastForeignAt
local OnInspectReady, Drive

function M:IsRestricted(unit)
	if issecretvalue(unit) then return true end
	local kind = Enum.AddOnRestrictionType
	local inactive = Enum.AddOnRestrictionState.Inactive
	if InCombatLockdown()
		or C_RestrictedActions.GetAddOnRestrictionState(kind.Combat) ~= inactive
		or C_RestrictedActions.GetAddOnRestrictionState(kind.Encounter) ~= inactive
		or C_RestrictedActions.GetAddOnRestrictionState(kind.ChallengeMode) ~= inactive
		or C_RestrictedActions.GetAddOnRestrictionState(kind.PvPMatch) ~= inactive
		or C_RestrictedActions.GetAddOnRestrictionState(kind.Map) ~= inactive then
		return true
	end
	return unit and C_Secrets.ShouldUnitIdentityBeSecret(unit) or false
end

local function IsCurrentUnit(unit, guid)
	if M:IsRestricted(unit) or issecretvalue(guid) or not unit or not guid or not UnitExists(unit) then return false end
	local currentGUID = UnitGUID(unit)
	return not issecretvalue(currentGUID) and currentGUID == guid
end

local function InspectIsBusy()
	if InspectFrame and InspectFrame:IsShown() then return true end
	return PlayerSpellsFrame and PlayerSpellsFrame:IsInspecting()
end

local function StopTimer()
	if timer then
		timer:Cancel()
		timer = nil
	end
end

local function DropPending()
	if pendingGUID then
		pendingGUID = nil
		F.UnregisterEvent("INSPECT_READY", OnInspectReady)
	end
end

function M:Cancel()
	StopTimer()
	DropPending()
	wantedUnit, wantedGUID, wantedCallback, wantedCheck = nil, nil, nil, nil
end

local function ValidateWanted()
	if not wantedGUID or not wantedCheck(wantedGUID) or not IsCurrentUnit(wantedUnit, wantedGUID) then
		M:Cancel()
		return false
	end
	return true
end

local function Arm(delay)
	StopTimer()
	timer = C_Timer.NewTimer(delay, Drive)
end

local function GetCachedItemLevel(guid, now)
	local entry = cache[guid]
	if not entry then return end
	if (now or GetTime()) - entry.time < CACHE_DURATION then return entry.level end
	cache[guid] = nil
end

local function PruneExpired(now)
	if now < pruneAt then return end
	pruneAt = now + CACHE_DURATION
	for guid, entry in pairs(cache) do
		if now - entry.time >= CACHE_DURATION then cache[guid] = nil end
	end
	for guid, deadline in pairs(retryAt) do
		if deadline <= now then retryAt[guid] = nil end
	end
end

function M:GetItemLevel(unit, guid)
	if not IsCurrentUnit(unit, guid) then return end
	local playerGUID = UnitGUID("player")
	if not issecretvalue(playerGUID) and guid == playerGUID then
		local _, equipped = GetAverageItemLevel()
		if not issecretvalue(equipped) and equipped and equipped > 0 then return equipped end
		return
	end
	return GetCachedItemLevel(guid)
end

local function FailedRequest()
	DropPending()
	retryAt[wantedGUID] = GetTime() + FAILURE_DELAY
	Arm(FAILURE_DELAY)
end

Drive = function()
	timer = nil
	if not ValidateWanted() then return end
	local now = GetTime()
	PruneExpired(now)
	if pendingGUID then
		FailedRequest()
		return
	end
	-- 已顯示的檢視交原生管理；關閉或結束檢視時再喚醒，不輪詢視窗。
	if InspectIsBusy() then return end

	local foreignDelay = FOREIGN_DELAY
	if InspectFrame then
		local unit = InspectFrame.unit
		-- 隱藏中的 unit 可能因目標消失而殘留；只等最後外部請求的回應期限。
		if issecretvalue(unit) or unit then foreignDelay = RESPONSE_TIMEOUT end
	end
	local readyAt = math.max(lastRequestAt + REQUEST_INTERVAL, lastForeignAt + foreignDelay, retryAt[wantedGUID] or 0)
	if readyAt > now then
		Arm(readyAt - now)
		return
	end
	if not CanInspect(wantedUnit) then
		FailedRequest()
		return
	end

	pendingGUID = wantedGUID
	F.RegisterEvent("INSPECT_READY", OnInspectReady)
	lastRequestAt = now
	sending = true
	NotifyInspect(wantedUnit)
	sending = false
	if pendingGUID then Arm(RESPONSE_TIMEOUT) end
end

OnInspectReady = function(_, guid)
	if issecretvalue(guid) or not pendingGUID or guid ~= pendingGUID then return end
	if not ValidateWanted() then return end
	local level = C_PaperDollInfo.GetInspectItemLevel(wantedUnit)
	if issecretvalue(level) or not level or level <= 0 then
		FailedRequest()
		return
	end

	local now = GetTime()
	cache[guid] = {level = level, time = now}
	retryAt[guid] = nil
	local callback = wantedCallback
	M:Cancel()
	callback(guid)
end

function M:Request(unit, guid, onReady, isWanted)
	if not IsCurrentUnit(unit, guid) then
		self:Cancel()
		return
	end
	local playerGUID = UnitGUID("player")
	if not issecretvalue(playerGUID) and guid == playerGUID then
		self:Cancel()
		return
	end
	local now = GetTime()
	-- 清理跟隨現有需求；連續失敗也會到期，不另設背景計時器。
	PruneExpired(now)
	if wantedGUID ~= guid then self:Cancel() end
	wantedUnit, wantedGUID, wantedCallback, wantedCheck = unit, guid, onReady, isWanted
	if GetCachedItemLevel(guid, now) then
		self:Cancel()
		return
	end
	if not timer and not InspectIsBusy() then Arm(0) end
end

local function OnExternalInspect()
	if sending then return end
	lastForeignAt = GetTime()
	-- 不清除共享檢視資料；外部接手後只撤回自己的 pending 與回呼。
	StopTimer()
	DropPending()
	if wantedGUID then
		if ValidateWanted() then Arm(FOREIGN_DELAY) end
	end
end

local function ResumeWanted()
	if wantedGUID and ValidateWanted() and not timer and not pendingGUID and not InspectIsBusy() then
		Arm(0)
	end
end

local function OnRestrictionChanged(_, kind, state)
	local restriction = Enum.AddOnRestrictionType
	if state ~= Enum.AddOnRestrictionState.Inactive
		and (kind == restriction.Combat or kind == restriction.Encounter
			or kind == restriction.ChallengeMode or kind == restriction.PvPMatch or kind == restriction.Map) then
		M:Cancel()
	end
end

local function OnCombatStarted()
	M:Cancel()
end

function M:OnEnable()
	cache, retryAt, pruneAt = {}, {}, 0
	lastRequestAt, lastForeignAt = -REQUEST_INTERVAL, -RESPONSE_TIMEOUT
	hooksecurefunc("NotifyInspect", OnExternalInspect)
	EventUtil.ContinueOnAddOnLoaded("Blizzard_InspectUI", function()
		InspectFrame:HookScript("OnHide", ResumeWanted)
	end)
	EventUtil.ContinueOnAddOnLoaded("Blizzard_PlayerSpells", function()
		-- 結束天賦檢視可以保留視窗；SetInspecting 也涵蓋 OnHide 的清理路徑。
		hooksecurefunc(PlayerSpellsFrame, "SetInspecting", ResumeWanted)
	end)
	F.RegisterEvent("ADDON_RESTRICTION_STATE_CHANGED", OnRestrictionChanged)
	F.RegisterEvent("PLAYER_REGEN_DISABLED", OnCombatStarted)
end
