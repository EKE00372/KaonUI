-- Config start
local anchor = "TOPLEFT"
local x, y = 10, -320
local width, height = 146, 20
local spacing = 3
local icon_size = 20
local font = GameFontHighlight:GetFont()
local font_size = 12
local font_style = "OUTLINE"
local backdrop_color = {0, 0, 0, 0.4}
local border_color = {0, 0, 0, 1}
local show_icon = true
local texture = "Interface\\TargetingFrame\\UI-StatusBar"
local show = {
	raid = true,
	party = true,
	arena = true,
	--none = true,
}
-- Config end

local spells = {
	--群疗
	[740]    = 180,  -- 宁静
	[115310] = 180,  -- 还魂
	[64843]  = 180,  -- 神圣赞美诗
	[108280] = 180,  -- 奶潮
	[15286]  = 180,  -- 吸血鬼拥抱
	
	-- 群体减伤
	[51052] = 120,  -- 反魔法领域
	[31821] = 180,  -- 光环掌握
	[62618] = 180,  -- 真言术: 障
	[98008] = 180,  -- 灵魂链接图腾
	[97462] = 180,  -- 集结呐喊
	
	-- 单体减伤
	[116849] = 120, -- 氣繭護體
	[633] = 600, -- 圣疗
	[6940] = 120, -- 牺牲
	[33206] = 180, -- 痛苦压制
	[47788] = 180, -- 守護聖靈
	
	-- 战术技能
	[106898] = 120,  --豹奔
	[1022]   = 300,	   -- 保護聖禦
	
	-- 战复(非首领战)
	[20484] = 600,	-- 复生
	[61999] = 600,	-- 复活盟友
	[20707] = 600,	-- 灵魂石复活
	[126393] = 600, -- 永恒守护者
	
	-- 其他
	[32182] = 300,	-- 英勇
	[2825] = 300,	-- 嗜血
	[80353] = 300,	-- 时间扭曲
	[90355] = 300,	-- 远古狂乱
	[29166] = 180,	-- 激活
	
	[16190] = 180,  --潮汐
	[115213] = 180,	-- 慈悲庇护
	--[133] = 180, --测试
	
}

local cfg = {}

local filter = COMBATLOG_OBJECT_AFFILIATION_RAID + COMBATLOG_OBJECT_AFFILIATION_PARTY + COMBATLOG_OBJECT_AFFILIATION_MINE
local band = bit.band
local sformat = string.format
local floor = math.floor
local currentNumResses = 0
local charges = nil
local inBossCombat = nil

local backdrop = {
	bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
	edgeFile = [=[Interface\ChatFrame\ChatFrameBackground]=], edgeSize = 1,
	insets = {top = 0, left = 0, bottom = 0, right = 0},
}

local bars = {}
local Ressesbars = {}
local anchorframe = CreateFrame("Frame", "RaidCD", UIParent)
anchorframe:SetSize(width, height)
anchorframe:SetPoint(anchor, x, y)
if UIMovableFrames then tinsert(UIMovableFrames, anchorframe) end

local FormatTime = function(time)
	if time >= 60 then
		return sformat('%.2d:%.2d', floor(time / 60), time % 60)
	else
		return sformat('%.2d', time)
	end
end

local CreateFS = CreateFS or function(frame)
	local fstring = frame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
	fstring:SetFont(font, font_size, font_style)
	fstring:SetShadowColor(0, 0, 0, 1)
	fstring:SetShadowOffset(0, 0)
	return fstring
end

local CreateBG = CreateBG or function(parent)
	local bg = CreateFrame("Frame", nil, parent)
	bg:SetPoint("TOPLEFT", parent, "TOPLEFT", -1, 1)
	bg:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 1, -1)
	bg:SetFrameStrata("LOW")
	bg:SetBackdrop(backdrop)
	bg:SetBackdropColor(unpack(backdrop_color))
	bg:SetBackdropBorderColor(unpack(border_color))
	return bg
end

local UpdatePositions = function()
	if charges and Ressesbars[1] then
		Ressesbars[1]:SetPoint("TOPLEFT", anchorframe, 0, 0)
		Ressesbars[1].id = 1
		for i = 1, #bars do
			bars[i]:ClearAllPoints()
			if i == 1 then
				bars[i]:SetPoint("TOPLEFT", Ressesbars[1], "BOTTOMLEFT", 0, -spacing)
			else
				bars[i]:SetPoint("TOPLEFT", bars[i-1], "BOTTOMLEFT", 0, -spacing)
			end
			bars[i].id = i
		end
	else
		for i = 1, #bars do
			bars[i]:ClearAllPoints()
			if i == 1 then
				bars[i]:SetPoint("TOPLEFT", anchorframe, 0, 0)
			else
				bars[i]:SetPoint("TOPLEFT", bars[i-1], "BOTTOMLEFT", 0, -spacing)
			end
			bars[i].id = i
		end	
	end
end

local StopTimer = function(bar)
	bar:SetScript("OnUpdate", nil)
	bar:Hide()
	if bar.isResses then
		tremove(Ressesbars, bar.id)
	else
		tremove(bars, bar.id)
	end
	UpdatePositions()
end

local UpdateCharges = function(bar)
	local curCharges, maxCharges, start, duration = GetSpellCharges(20484)
	if curCharges == maxCharges then
		bar.startTime = 0
		bar.endTime = GetTime()
	else
		bar.startTime = start
		bar.endTime = start + duration
	end
	if curCharges ~= currentNumResses then
		currentNumResses = curCharges
		bar.left:SetText(bar.name.." : "..currentNumResses)
	end
end

local BarUpdate = function(self, elapsed)
	local curTime = GetTime()
	if self.endTime < curTime then
		if self.isResses then
			UpdateCharges(self)
		else
			StopTimer(self)
			return
		end
	end
	self.status:SetValue(100 - (curTime - self.startTime) / (self.endTime - self.startTime) * 100)
	self.right:SetText(FormatTime(self.endTime - curTime))
end

local OnEnter = function(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:AddLine(self.spell)
	GameTooltip:SetClampedToScreen(true)
	GameTooltip:Show()
end

local OnLeave = function(self)
	GameTooltip:Hide()
end

local OnMouseDown = function(self, button)
	if button == "LeftButton" then
		if self.isResses then
		  if IsInRaid() then
			  SendChatMessage(sformat("Battle Res: %d; Next: %s", currentNumResses, self.right:GetText()), "RAID")
		  elseif IsInGroup() then
			  SendChatMessage(sformat("Battle Res: %d; Next: %s", currentNumResses, self.right:GetText()), "PARTY")
		  elseif IsInInstance() then
			  SendChatMessage(sformat("Battle Res: %d; Next: %s", currentNumResses, self.right:GetText()), "INSTANCE")
		  else
			  SendChatMessage(sformat("Battle Res: %d; Next: %s", currentNumResses, self.right:GetText()), "SAY")
		  end	
		else
		  if IsInRaid() then
			  SendChatMessage(sformat("Cooldown %s %s: %s", self.left:GetText(), self.spell, self.right:GetText()), "RAID")
		  elseif IsInGroup() then
			  SendChatMessage(sformat("Cooldown %s %s: %s", self.left:GetText(), self.spell, self.right:GetText()), "PARTY")
		  elseif IsInInstance() then
			  SendChatMessage(sformat("Cooldown %s %s: %s", self.left:GetText(), self.spell, self.right:GetText()), "INSTANCE")
		  else
			  SendChatMessage(sformat("Cooldown %s %s: %s", self.left:GetText(), self.spell, self.right:GetText()), "SAY")
		  end		
		end
	elseif button == "RightButton" then
		StopTimer(self)
	end
end

local CreateBar = function()
	local bar = CreateFrame("Frame", nil, UIParent)
	bar:SetSize(width, height)
	bar.status = CreateFrame("Statusbar", nil, bar)
	bar.icon = CreateFrame("button", nil, bar)
	bar.icon:SetSize(icon_size, icon_size)
	bar.icon:SetPoint("LEFT", 0, 0)
	bar.status:SetPoint("BOTTOMLEFT", bar.icon, "BOTTOMRIGHT", 3, 0)
	bar.status:SetPoint("BOTTOMRIGHT", 0, 0)
	bar.status:SetHeight(height/2.4)
	bar.status:SetStatusBarTexture(texture)
	bar.status:SetMinMaxValues(0, 100)
	bar.status:SetFrameLevel(bar:GetFrameLevel()-1)
	bar.left = CreateFS(bar)
	bar.left:SetPoint('LEFT', bar.status, 2, 5)
	bar.left:SetJustifyH('LEFT')
	bar.right = CreateFS(bar)
	bar.right:SetPoint('RIGHT', bar.status, -2, 5)
	bar.right:SetJustifyH('RIGHT')
	CreateBG(bar.icon)
	CreateBG(bar.status)
	return bar
end

local StartTimer = function(name, spellId)
	local spell, rank, icon = GetSpellInfo(spellId)
	if charges and spellId == 20484 then
		--团队首领战中战复技能计时特殊处理
		for _, v in pairs(Ressesbars) do
			UpdateCharges(v)
			return
		end
	end
	for _, v in pairs(bars) do
		if v.name == name and v.spell == spell then
			--发现重复计时事件时重置计时条,适应战复以外充能技能
			StopTimer(v)
		end
	end
	local bar = CreateBar()
	local color
	if charges and spellId == 20484 then
		--初始化战复技能计时条
		local curCharges, _, _, duration = GetSpellCharges(20484)
		currentNumResses = curCharges
		bar.endTime = GetTime() + duration
		bar.left:SetText(name.." : "..curCharges)
		bar.right:SetText(FormatTime(duration))
		bar.isResses = true
		color = RAID_CLASS_COLORS[select(2, UnitClass("player"))]
		bar.startTime = GetTime()
		bar.name = name
		bar.spell = spell
		bar.spellId = spellId
		if icon and bar.icon then
			bar.icon:SetNormalTexture(icon)
			bar.icon:GetNormalTexture():SetTexCoord(0.07, 0.93, 0.07, 0.93)
		end
		bar:Show()
		bar.status:SetStatusBarColor(color.r, color.g, color.b)
		bar:SetScript("OnUpdate", BarUpdate)
		bar:EnableMouse(true)
		bar:SetScript("OnEnter", OnEnter)
		bar:SetScript("OnLeave", OnLeave)
		bar:SetScript("OnMouseDown", OnMouseDown)
		tinsert(Ressesbars, bar)
	else
		bar.endTime = GetTime() + spells[spellId]
		bar.left:SetText(name)
		bar.right:SetText(FormatTime(spells[spellId]))
		bar.isResses = false
		color = RAID_CLASS_COLORS[select(2, UnitClass(name))]
		bar.startTime = GetTime()
		bar.name = name
		bar.spell = spell
		bar.spellId = spellId
		if icon and bar.icon then
			bar.icon:SetNormalTexture(icon)
			bar.icon:GetNormalTexture():SetTexCoord(0.07, 0.93, 0.07, 0.93)
		end
		bar:Show()
		bar.status:SetStatusBarColor(color.r, color.g, color.b)
		bar:SetScript("OnUpdate", BarUpdate)
		bar:EnableMouse(true)
		bar:SetScript("OnEnter", OnEnter)
		bar:SetScript("OnLeave", OnLeave)
		bar:SetScript("OnMouseDown", OnMouseDown)
		tinsert(bars, bar)
	end
	UpdatePositions()
end

local OnEvent = function(self, event, ...)
	if event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
		if select(2, IsInInstance()) == "raid" then
			self:RegisterEvent("SPELL_UPDATE_CHARGES")
		else
			self:UnregisterEvent("SPELL_UPDATE_CHARGES")
			charges = nil
			inBossCombat = nil
			currentNumResses = 0
			Ressesbars = {}
		end
	end
	if event == "SPELL_UPDATE_CHARGES" then
		charges = select(1, GetSpellCharges(20484))
		if charges then
			if not inBossCombat then
				for _, v in pairs(bars) do
					StopTimer(v)
				end
				inBossCombat = true
			end
			StartTimer("戰復", 20484)
		elseif not charges and inBossCombat then
			inBossCombat = nil
			currentNumResses = 0
			for _, v in pairs(Ressesbars) do
				StopTimer(v)
			end
		end
	end
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local timestamp, eventType, _, sourceGUID, sourceName, sourceFlags = ...
		if band(sourceFlags, filter) == 0 then return end
		if (eventType == "SPELL_RESURRECT" and not charges) or eventType == "SPELL_CAST_SUCCESS" or eventType == "SPELL_AURA_APPLIED" then
			local spellId = select(12, ...)
			if sourceName then
				sourceName = sourceName:gsub("-.+", "")
			else
				return
			end
			if spells[spellId] and show[select(2, IsInInstance())] then
				StartTimer(sourceName, spellId)
			end
		end
	elseif event == "ZONE_CHANGED_NEW_AREA" and select(2, IsInInstance()) == "arena" then
		for _, v in pairs(Ressesbars) do
			StopTimer(v)
		end
		for _, v in pairs(bars) do
			StopTimer(v)
		end
	end
end

local addon = CreateFrame("frame")
addon:SetScript('OnEvent', OnEvent)
addon:RegisterEvent("PLAYER_ENTERING_WORLD")
addon:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
addon:RegisterEvent("ZONE_CHANGED_NEW_AREA")

SlashCmdList["RaidCD"] = function(msg) 
	StartTimer(UnitName('player'), 20484)
	StartTimer(UnitName('player'), 740)
	StartTimer(UnitName('player'), 20707)
end
SLASH_RaidCD1 = "/raidcd"