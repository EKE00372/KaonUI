local _, ns = ...
local F, L = ns[2], ns[4]
local M = F.RegisterModule("Tooltip", {"TooltipColor", "TooltipDetails"})

local format = string.format
local lineTypes = Enum.TooltipDataLineType
local tooltipTypes = Enum.TooltipDataType
local Inspect, current, tracked, unitTooltip, refreshPending, refreshNeeded
local colorEnabled, detailsEnabled
local detailGUID, detailScore, detailMount, scoreTime, mountTime
local updatingHintLayout

local function IsPublicTable(value)
	return not issecretvalue(value) and type(value) == "table" and canaccesstable(value) and not issecrettable(value)
end

local function IsCurrentUnit()
	if not current or Inspect:IsRestricted(current.unit) then return false end
	local guid = UnitGUID(current.unit)
	return not issecretvalue(guid) and guid == current.guid
end

local function GetTooltipClassColor()
	if not unitTooltip then return end
	local info = GameTooltip:GetPrimaryTooltipInfo()
	if not IsPublicTable(info) then return end
	local unit
	if not issecretvalue(info.getterName) then
		if info.getterName == "GetUnit" and IsPublicTable(info.getterArgs) then
			unit = info.getterArgs[1]
		elseif info.getterName == "GetWorldCursor" then
			unit = "mouseover"
		end
	end
	if issecretvalue(unit) or type(unit) ~= "string" then
		local data = info.tooltipData
		if IsPublicTable(data) and IsPublicTable(data.lines) then
			for _, line in ipairs(data.lines) do
				if IsPublicTable(line) and not issecretvalue(line.type) and line.type == lineTypes.UnitName then
					unit = line.unitToken
					break
				end
			end
		end
	end
	if issecretvalue(unit) or type(unit) ~= "string" then return end
	local player = UnitIsPlayer(unit)
	if issecretvalue(player) or not player then return end
	local _, class = UnitClass(unit)
	-- 職業及 RGB 可以受限；交原生轉色與 setter，不用 Lua 色表或解析身份。
	if issecretvalue(class) or class then return C_ClassColor.GetClassColor(class) end
end

local function UpdateHealthColor(bar)
	if GameTooltip:IsForbidden() or bar:IsForbidden() then return end
	local color = GetTooltipClassColor()
	if color then
		bar:SetStatusBarColor(color:GetRGB())
	end
end

local function IsWantedUnit(guid)
	return current and current.guid == guid and GameTooltip:IsShown()
end

local function UpdateItemLevel(guid)
	if not current or current.guid ~= guid or not current.itemLevelLine then return end
	if not GameTooltip:IsShown() then return end
	local value = Inspect:GetItemLevel(current.unit, guid)
	if value then
		_G["GameTooltipTextLeft"..current.itemLevelLine]:SetFormattedText("%s %.1f", STAT_AVERAGE_ITEM_LEVEL, value)
		GameTooltip:Show()
	end
end

local function AddDetails(tooltip)
	if not detailsEnabled or not current.player or current.detailsAdded then return end
	current.detailsAdded = true
	local unit = current.unit
	local value = Inspect:GetItemLevel(unit, current.guid)
	tooltip:AddLine(value and format("%s %.1f", STAT_AVERAGE_ITEM_LEVEL, value) or (STAT_AVERAGE_ITEM_LEVEL.." —"), 1, 1, 1)
	current.itemLevelLine = tooltip:NumLines()
	if value then
		Inspect:Cancel()
	else
		Inspect:Request(unit, current.guid, UpdateItemLevel, IsWantedUnit)
	end
	if not current.shift then return end

	-- 只暫存目前這一人；坐騎因光環失效時，不連帶重查仍有效的分數。
	local now = GetTime()
	if detailGUID ~= current.guid then
		detailGUID, detailScore, detailMount, scoreTime, mountTime = current.guid, nil, nil, nil, nil
	end
	if not scoreTime or now - scoreTime >= 1 then
		scoreTime, detailScore = now, nil
		local summary = C_PlayerInfo.GetPlayerMythicPlusRatingSummary(unit)
		if IsPublicTable(summary) and not issecretvalue(summary.currentSeasonScore) then
			detailScore = summary.currentSeasonScore
		end
	end
	if not mountTime or now - mountTime >= 1 then
		mountTime, detailMount = now, nil
		if not C_Secrets.ShouldAurasBeSecret() then
			local index = 1
			while true do
				local aura = C_UnitAuras.GetAuraDataByIndex(unit, index, "HELPFUL")
				if not IsPublicTable(aura) then break end
				local spellID = aura.spellId
				if not issecretvalue(spellID) and spellID then
					local mountID = C_MountJournal.GetMountFromSpell(spellID)
					if not issecretvalue(mountID) and mountID then
						local name = C_MountJournal.GetMountInfoByID(mountID)
						if not issecretvalue(name) then detailMount = name end
						break
					end
				end
				index = index + 1
			end
		end
	end
	if type(detailScore) == "number" then
		tooltip:AddLine(format("M+ %d", detailScore), 1, 1, 1)
	end
	if detailMount then
		tooltip:AddLine(detailMount, 1, 1, 1)
	end
end

local function PrepareUnit(data)
	if not IsPublicTable(data.lines) then return end
	local guid = data.guid
	if issecretvalue(guid) or not guid then return end
	local unit = UnitTokenFromGUID(guid)
	if issecretvalue(unit) or not unit or C_Secrets.ShouldUnitIdentityBeSecret(unit) then return end
	local unitGUID = UnitGUID(unit)
	if issecretvalue(unitGUID) or unitGUID ~= guid then return end

	-- 重排前先核對全部原生行；受限時保留原文，名字與血條染色另走獨立流程。
	for _, line in ipairs(data.lines) do
		if not IsPublicTable(line) or not canaccessallvalues(line.type, line.leftText, line.rightText) then return end
	end
	local player = UnitIsPlayer(unit)
	local name, realm = UnitName(unit)
	local level = UnitLevel(unit)
	if not canaccessallvalues(player, name, realm, level) or not name then return end
	local state = { unit = unit, guid = guid, player = player, roles = {} }
	local class, guild, guildRealm, guildName, rank, race, creature, classification, faction
	if player then
		state.shift = (detailsEnabled and IsShiftKeyDown())
		local classFile, _
		class, classFile = UnitClass(unit)
		guild, rank, _, guildRealm = GetGuildInfo(unit)
		race = UnitRace(unit)
		_, faction = UnitFactionGroup(unit)
		if not canaccessallvalues(class, guild, guildRealm, race, faction) or not race then return end
		if (colorEnabled and issecretvalue(classFile)) or (state.shift and issecretvalue(rank)) then return end
		state.color = colorEnabled and classFile and C_ClassColor.GetClassColor(classFile)
		if not realm or realm == "" then realm = GetRealmName() end
		if state.shift then
			local titledName = UnitPVPName(unit)
			if issecretvalue(titledName) then return end
			name = titledName or name
		end
		state.name = realm and realm ~= "" and (name.."-"..realm) or name
		if guild then
			guildName = guildRealm and guildRealm ~= "" and (guild.."-"..guildRealm) or guild
			state.guild = state.shift and rank and (guildName.." ("..rank..")") or guildName
		end
		state.level = format("%s %s", level == -1 and "??" or level, race)
	else
		creature = UnitCreatureType(unit)
		classification = UnitClassification(unit)
		if not canaccessallvalues(creature, classification) then return end
		local suffix = ""
		if classification == "elite" then suffix = ELITE
		elseif classification == "rareelite" then suffix = L.TooltipRare.." "..ELITE
		elseif classification == "rare" then suffix = L.TooltipRare
		elseif classification == "worldboss" then suffix = BOSS end
		state.level = tostring(level == -1 and "??" or level)
		if suffix ~= "" then state.level = state.level.." "..suffix end
		if creature and creature ~= "" then state.level = state.level.." "..creature end
	end

	-- 原生未保證等級行都有專用類型；僅在姓名／公會後的標頭比對本地化等級前綴。
	local levelPrefix = format(TOOLTIP_UNIT_LEVEL, level == -1 and "??" or level):gsub("%s", "")
	local headerOpen, seenLevel, specCandidate
	for _, line in ipairs(data.lines) do
		local text = line.leftText
		local plain = type(text) == "string" and text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
		local isGuild = (player and not seenLevel and guild and (plain == guild or plain == guildName
			or plain == "<"..guild..">" or plain == "<"..guildName..">"))
		local isLevel = (line.type == lineTypes.UnitLevel)
		if not isLevel and not isGuild and headerOpen and line.type == lineTypes.None and plain then
			local compact = plain:gsub("%s", "")
			isLevel = (compact:sub(1, #levelPrefix) == levelPrefix and not compact:sub(#levelPrefix + 1, #levelPrefix + 1):match("%d"))
		end
		if line.type == lineTypes.UnitName then
			state.roles[line] = "name"
			headerOpen = true
		elseif isLevel then
			state.roles[line] = "level"
			state.lastInfo = line
			seenLevel, specCandidate = true, true
		elseif plain then
			if player and specCandidate and class and (plain == class or plain:sub(-#class - 1) == " "..class) then
				state.roles[line] = "spec"
				state.lastInfo = line
			elseif isGuild then
				state.roles[line] = "skip"
				if not colorEnabled and IsPublicTable(line.leftColor) then state.guildColor = line.leftColor end
			elseif player and (line.type == lineTypes.None or line.type == lineTypes.UnitType)
				and ((faction and plain == faction) or plain == PVP_ENABLED) then
				state.roles[line] = "skip"
			elseif not player and line.type == lineTypes.UnitType and text == creature then
				state.roles[line] = "skip"
			end
			if seenLevel and line.type ~= lineTypes.Blank then specCandidate = false end
		end
		if line.type ~= lineTypes.UnitName and line.type ~= lineTypes.Blank and not isGuild then headerOpen = false end
	end
	current = state
end

local function OnTooltipPreCall(tooltip, data)
	if tooltip ~= GameTooltip then return end
	current, tracked, unitTooltip = nil, nil, nil
	refreshNeeded = nil
	if tooltip:IsForbidden() or not IsPublicTable(data) or issecretvalue(data.type)
		or data.type ~= tooltipTypes.Unit or Inspect:IsRestricted() then
		if detailsEnabled then Inspect:Cancel() end
		return
	end
	PrepareUnit(data)
	if detailsEnabled and (not current or not current.player) then Inspect:Cancel() end
end

local function OnLinePreCall(tooltip, line)
	if tooltip ~= GameTooltip or not current then return end
	local role = current.roles[line]
	if role == "skip" then return true end
	if role == "name" and current.player then
		local color = current.color
		if not color then
			color = IsPublicTable(line.leftColor) and line.leftColor or WHITE_FONT_COLOR
		end
		tooltip:AddLine(current.name, color:GetRGB())
		if current.guild then
			if colorEnabled then
				tooltip:AddLine(current.guild, 0, 1, 0)
			else
				tooltip:AddLine(current.guild, (current.guildColor or WHITE_FONT_COLOR):GetRGB())
			end
		end
		return true
	elseif role == "level" then
		tooltip:AddLine(current.level, 1, 1, 1)
		if line == current.lastInfo then AddDetails(tooltip) end
		return true
	end
end

local function OnLinePostCall(tooltip, line)
	if tooltip ~= GameTooltip or not current or tooltip:IsForbidden() then return end
	if current.roles[line] == "spec" and current.color then
		local index = line.lineIndex
		if not issecretvalue(index) and index then
			_G["GameTooltipTextLeft"..index]:SetTextColor(current.color:GetRGB())
		end
	end
	if line == current.lastInfo then AddDetails(tooltip) end
end

local function OnTooltipPostCall(tooltip)
	if tooltip ~= GameTooltip or tooltip:IsForbidden() then return end
	if colorEnabled then
		local color
		if current then color = current.color else color = GetTooltipClassColor() end
		if color then
			-- 原生單位名字位於第一行；只套色，不讀姓名或受限的 lineIndex。
			if not current then GameTooltipTextLeft1:SetTextColor(color:GetRGB()) end
			if not tooltip.StatusBar:IsForbidden() then tooltip.StatusBar:SetStatusBarColor(color:GetRGB()) end
		end
	end
	if current then AddDetails(tooltip) end
end

local function HideRightClickHint()
	if updatingHintLayout or not current or GameTooltip:IsForbidden() then return end
	local count = GameTooltip:NumLines()
	if issecretvalue(count) or count < 2 then return end
	local last = _G["GameTooltipTextLeft"..count]
	local text = last:GetText()
	if issecretvalue(text) or text ~= UNIT_POPUP_RIGHT_CLICK then return end
	local previous = _G["GameTooltipTextLeft"..(count - 1)]
	local spacer = previous:GetText()
	if issecretvalue(spacer) or not IsCurrentUnit() then return end
	last:SetText(nil)
	last:Hide()
	if spacer == " " or spacer == "" then
		previous:SetText(nil)
		previous:Hide()
	end
	-- 清字發生在首次 Show 排版之後；再交原生重算，重入時不重複清理。
	updatingHintLayout = true
	GameTooltip:Show()
	updatingHintLayout = nil
end

local function RefreshTooltip()
	local needed = refreshNeeded
	refreshPending, refreshNeeded = nil, nil
	if not tracked or not GameTooltip:IsShown() or GameTooltip:IsForbidden() then return end
	-- 原生可能已先更新，Shift 也可能已回到畫面狀態；只處理尚未消耗的變更。
	if not needed and (not current or not current.player or current.shift == IsShiftKeyDown()) then return end
	-- 計時器執行前可能已進入限制；securecallfunction 不能保證重建 secret 行安全。
	if not unitTooltip or not IsCurrentUnit() then return end
	-- 不寫 refresh flags；標準單位框連同手加提示重建，世界指向保留原 getter 與淡出規則。
	local owner = GameTooltip:GetOwner()
	if not issecretvalue(owner) and owner and owner.UpdateTooltip == UnitFrame_UpdateTooltip then
		securecallfunction(UnitFrame_UpdateTooltip, owner)
	else
		securecallfunction(GameTooltip.RebuildFromTooltipInfo, GameTooltip)
	end
end

local function QueueRefresh(event, unit)
	if not detailsEnabled or not tracked or not current or not current.player then return end
	if event == "UNIT_AURA" then
		if issecretvalue(unit) or unit ~= current.unit then return end
		mountTime = nil
		if not current.shift then return end
	end
	if not refreshPending and Inspect:IsRestricted() then return end
	if event then refreshNeeded = true end
	if not refreshPending then
		refreshPending = true
		C_Timer.After(0, RefreshTooltip)
	end
end

function M:OnEnable()
	Inspect = F.GetModule("TooltipInspect")
	colorEnabled = F.GetSetting("TooltipColor")
	detailsEnabled = F.GetSetting("TooltipDetails")
	TooltipDataProcessor.AddTooltipPreCall(TooltipDataProcessor.AllTypes, OnTooltipPreCall)
	TooltipDataProcessor.AddTooltipPreCall(tooltipTypes.Unit, function(tooltip)
		if tooltip ~= GameTooltip or tooltip:IsForbidden() then return end
		tracked = true
		-- 類型由原生先分派；只認主提示，不再讀取可能受限的資料或行類型。
		local primary, processing = tooltip:GetPrimaryTooltipInfo(), tooltip:GetProcessingTooltipInfo()
		unitTooltip = IsPublicTable(primary) and IsPublicTable(processing) and primary == processing
	end)
	TooltipDataProcessor.AddLinePreCall(TooltipDataProcessor.AllTypes, OnLinePreCall)
	TooltipDataProcessor.AddLinePostCall(TooltipDataProcessor.AllTypes, OnLinePostCall)
	TooltipDataProcessor.AddTooltipPostCall(TooltipDataProcessor.AllTypes, OnTooltipPostCall)
	GameTooltip:HookScript("OnTooltipCleared", function()
		current, tracked, unitTooltip, refreshNeeded = nil, nil, nil, nil
	end)
	GameTooltip:HookScript("OnHide", function()
		current, tracked, unitTooltip, refreshNeeded = nil, nil, nil, nil
		if detailsEnabled then Inspect:Cancel() end
	end)
	if colorEnabled then GameTooltip.StatusBar:HookScript("OnValueChanged", UpdateHealthColor) end
	hooksecurefunc(GameTooltip, "Show", HideRightClickHint)
	if detailsEnabled then
		F.RegisterEvent("MODIFIER_STATE_CHANGED", function(_, key)
			if (key == "LSHIFT" or key == "RSHIFT") and current and current.player and current.shift ~= IsShiftKeyDown() then
				QueueRefresh()
			end
		end)
		F.RegisterEvent("UNIT_AURA", QueueRefresh)
		F.RegisterEvent("ADDON_RESTRICTION_STATE_CHANGED", QueueRefresh)
	end
end
