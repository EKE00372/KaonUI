local _, ns = ...
local F = ns[2]
local M = F.RegisterModule("BRSound", "SpellAnnouncer")

local registrations = {}
local registrationWarningShown = false

local function RefreshSounds()
	local wanted = {}
	if IsInRaid() then
		for index = 1, GetNumGroupMembers() do
			wanted["raid"..index] = true
		end
	else
		wanted.player = true
		for index = 1, GetNumSubgroupMembers() do
			wanted["party"..index] = true
		end
	end

	-- 只增減需要變動的 token，避免每次名單刷新都重新註冊。
	for unit, handle in pairs(registrations) do
		if not wanted[unit] then
			C_UnitAuras.RemoveAuraSound(handle)
			registrations[unit] = nil
		end
	end

	-- 受限期間只延後新增；解除限制的事件會補齊，不輪詢光環或解讀 Secret。
	local restriction = Enum.AddOnRestrictionType
	local inactive = Enum.AddOnRestrictionState.Inactive
	if InCombatLockdown()
		or C_RestrictedActions.GetAddOnRestrictionState(restriction.Combat) ~= inactive
		or C_RestrictedActions.GetAddOnRestrictionState(restriction.Encounter) ~= inactive
		or C_RestrictedActions.GetAddOnRestrictionState(restriction.PvPMatch) ~= inactive then
		return
	end

	for unit in pairs(wanted) do
		if not registrations[unit] then
			local handle = C_UnitAuras.AddAuraSound(Enum.UnitAuraSoundTrigger.Added, {
				unitToken = unit,
				spellID = 160029,
				soundFileID = 567458,
				outputChannel = "Master",
				throttleSeconds = 0,
			})
			if not handle then
				if not registrationWarningShown then
					print("|cff00ffffAnyon|r：戰復音效（160029）未能完成註冊，將在下次隊伍或限制狀態更新時重試。")
					registrationWarningShown = true
				end
				return
			end
			registrations[unit] = handle
		end
	end
end

local function OnRestrictionChanged(_, _, state)
	if state == Enum.AddOnRestrictionState.Inactive then
		RefreshSounds()
	end
end

function M:OnEnable()
	F.RegisterEvent("PLAYER_ENTERING_WORLD", RefreshSounds)
	F.RegisterEvent("GROUP_ROSTER_UPDATE", RefreshSounds)
	F.RegisterEvent("PLAYER_REGEN_ENABLED", RefreshSounds)
	F.RegisterEvent("ADDON_RESTRICTION_STATE_CHANGED", OnRestrictionChanged)
	RefreshSounds()
end
