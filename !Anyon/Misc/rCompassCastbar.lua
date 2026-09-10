local _, ns = ...
local F = ns[2]
local M = F.RegisterModule("CompassCastbar", "CompassCastbar")

-- rCompassCastbar by zork

local ipairs, pairs, select, unpack = ipairs, pairs, select, unpack
local pi = math.pi

local C_Spell_GetSpellCooldown = C_Spell.GetSpellCooldown
local C_Spell_GetSpellCooldownDuration = C_Spell.GetSpellCooldownDuration
local CreateFrame, GetCursorPosition = CreateFrame, GetCursorPosition
local UnitCastingInfo, UnitChannelInfo = UnitCastingInfo, UnitChannelInfo
local UnitCastingDuration, UnitChannelDuration = UnitCastingDuration, UnitChannelDuration
local UnitEmpoweredChannelDuration = UnitEmpoweredChannelDuration

local leftCurve, rightCurve, sparkCurve

------------
-- config --
------------

local TEXTURE_PATH = "Interface\\AddOns\\!Anyon\\Media\\rCompassCastbar\\"
local RING_SIZE = 512
local GCD_SPELL_ID = 61304

local CAST_EVENTS = {
	"UNIT_SPELLCAST_START",
	"UNIT_SPELLCAST_SUCCEEDED",
	"UNIT_SPELLCAST_DELAYED",
	"UNIT_SPELLCAST_CHANNEL_START",
	"UNIT_SPELLCAST_CHANNEL_UPDATE",
	"UNIT_SPELLCAST_EMPOWER_START",
	"UNIT_SPELLCAST_EMPOWER_UPDATE",
}

-- 各事件的公開 castBarID 位置
local STOP_EVENTS = {
	UNIT_SPELLCAST_FAILED = 4,
	UNIT_SPELLCAST_STOP = 4,
	UNIT_SPELLCAST_INTERRUPTED = 5,
	UNIT_SPELLCAST_CHANNEL_STOP = 5,
	UNIT_SPELLCAST_EMPOWER_STOP = 6,
}

-- 可加 point = {"CENTER", 0, 0} 固定位置；未設定時跟隨游標
local RING_CONFIG = {
	player = {
		enabled = true,
		scale = 0.34,
		background = {
			enabled = true,
			color = {0.4, 0.3, 0, 1},
			blendMode = "ADD",
			texture = TEXTURE_PATH.."compass-rose.tga",
		},
		ring = {
			color = {1, 0.8, 0, 1},
			blendMode = "ADD",
			texture = TEXTURE_PATH.."compass-rose-ring-bright.tga",
		},
		spark = {
			enabled = true,
			color = {1, 1, 1},
			blendMode = "ADD",
			texture = TEXTURE_PATH.."compass-rose-spark.tga",
		},
	},
	target = {
		enabled = true,
		scale = 0.2,
		background = {
			enabled = false,
			color = {0.4, 0.3, 0, 0.8},
			blendMode = "ADD",
			texture = TEXTURE_PATH.."compass-rose-bright.tga",
		},
		ring = {
			color = {1, 0, 0, 1},
			blendMode = "ADD",
			texture = TEXTURE_PATH.."compass-rose-ring-bright.tga",
		},
		spark = {
			enabled = true,
			color = {1, 1, 1},
			blendMode = "ADD",
			texture = TEXTURE_PATH.."compass-rose-spark.tga",
		},
	},
	gcd = {
		enabled = true,
		scale = 0.26,
		background = {
			enabled = false,
			color = {0.5, 0.4, 0, 1},
			blendMode = "ADD",
			texture = TEXTURE_PATH.."compass-rose.tga",
		},
		ring = {
			color = {0.5, 0.5, 0.5, 1},
			blendMode = "ADD",
			texture = TEXTURE_PATH.."compass-rose-ring-bright.tga",
		},
		spark = {
			enabled = true,
			color = {1, 1, 1},
			blendMode = "ADD",
			texture = TEXTURE_PATH.."compass-rose-spark.tga",
		},
	},
	focus = {
		enabled = true,
		scale = 0.15,
		background = {
			enabled = false,
			color = {0.4, 0.3, 0, 0.8},
			blendMode = "ADD",
			texture = TEXTURE_PATH.."compass-rose-bright.tga",
		},
		ring = {
			color = {0, 0.5, 1, 1},
			blendMode = "ADD",
			texture = TEXTURE_PATH.."compass-rose-ring-bright.tga",
		},
		spark = {
			enabled = true,
			color = {1, 1, 1},
			blendMode = "ADD",
			texture = TEXTURE_PATH.."compass-rose-spark.tga",
		},
	},
}

--------------
-- Function --
--------------

local function OnCooldownDone(frame)
	frame:SetScript("OnUpdate", nil)
	frame.duration = nil
	frame.evaluatePercent = nil
	frame.castBarID = nil
	frame:Hide()
end

local function DisableRing(frame)
	frame:Clear()
	OnCooldownDone(frame)
end

local function UpdateCursorPosition(frame)
	local x, y = GetCursorPosition()
	local uiScale = UIParent:GetEffectiveScale()

	frame:ClearAllPoints()
	frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x / uiScale / frame.ringScale - frame.ringWidth / 2, y / uiScale / frame.ringScale - frame.ringHeight / 2)
end

local function OnUpdate(frame)
	if frame.followCursor then
		UpdateCursorPosition(frame)
	end

	-- 原生 curve 處理分段角度；secret value 直接交給 Texture:SetRotation
	local duration, evaluatePercent = frame.duration, frame.evaluatePercent
	frame.leftRingTexture:SetRotation(evaluatePercent(duration, leftCurve))
	frame.rightRingTexture:SetRotation(evaluatePercent(duration, rightCurve))
	if frame.leftRingSpark then
		local angle = evaluatePercent(duration, sparkCurve)
		frame.leftRingSpark:SetRotation(angle)
		frame.rightRingSpark:SetRotation(angle)
	end
end

local function StartRing(frame, duration, castBarID, reverse)
	frame.duration = duration
	frame.evaluatePercent = reverse and duration.EvaluateRemainingPercent or duration.EvaluateElapsedPercent
	frame.castBarID = castBarID
	OnUpdate(frame)
	frame:SetScript("OnUpdate", OnUpdate)
	frame:Show()
	frame:SetCooldownFromDurationObject(duration)
end

local function RefreshCast(frame)
	-- isTradeskill 為 NeverSecret；false 也代表有施法，nil 才表示沒有
	local _, _, _, _, _, isTradeskill, _, _, _, castBarID = UnitCastingInfo(frame.unit)
	if isTradeskill ~= nil then
		StartRing(frame, UnitCastingDuration(frame.unit), castBarID)
		return
	end

	local _, _, _, _, _, isChannelTradeskill, _, _, isEmpowered, _, channelBarID = UnitChannelInfo(frame.unit)
	if isChannelTradeskill ~= nil then
		if isEmpowered then
			StartRing(frame, UnitEmpoweredChannelDuration(frame.unit, true), channelBarID)
		else
			StartRing(frame, UnitChannelDuration(frame.unit), channelBarID, true)
		end
		return
	end

	DisableRing(frame)
end

local function RefreshGCD(frame)
	local cooldownInfo = C_Spell_GetSpellCooldown(GCD_SPELL_ID)
	if cooldownInfo and cooldownInfo.isActive then
		StartRing(frame, C_Spell_GetSpellCooldownDuration(GCD_SPELL_ID, false))
	else
		DisableRing(frame)
	end
end

local function OnEvent(frame, event, ...)
	if frame.unit == "gcd" then
		RefreshGCD(frame)
		return
	end

	local stopIndex = STOP_EVENTS[event]
	if stopIndex then
		local castBarID = select(stopIndex, ...)
		if castBarID and castBarID == frame.castBarID then
			DisableRing(frame)
			return
		end
	end

	RefreshCast(frame)
end

local function CreateTexture(parent, config, width, height, layer, subLevel)
	local texture = parent:CreateTexture(nil, layer, nil, subLevel)
	texture:SetTexture(config.texture)
	texture:SetSize(width, height)
	texture:SetPoint("CENTER")
	texture:SetVertexColor(unpack(config.color))
	texture:SetBlendMode(config.blendMode)
	return texture
end

local function CreateRingHalf(parent, config, side)
	local scrollFrame = CreateFrame("ScrollFrame", nil, parent)
	scrollFrame:SetSize(parent.ringWidth / 2, parent.ringHeight)
	scrollFrame:SetPoint(side)

	local child = CreateFrame("Frame", nil, scrollFrame)
	child:SetSize(parent.ringWidth, parent.ringHeight)
	scrollFrame:SetScrollChild(child)

	if side == "RIGHT" then
		scrollFrame:SetHorizontalScroll(parent.ringWidth / 2)
	end

	local ring = CreateTexture(child, config.ring, parent.ringWidth, parent.ringHeight, "BACKGROUND", -6)

	if config.spark and config.spark.enabled then
		local spark = CreateTexture(child, config.spark, parent.ringWidth, parent.ringHeight, "BACKGROUND", -5)
		return ring, spark
	end

	return ring
end

local function CreateCompassCastbar(unit, config)
	local frame = CreateFrame("Cooldown", nil, UIParent)
	frame.noCooldownCount = true
	frame:SetDrawSwipe(false)
	frame:SetDrawEdge(false)
	frame:SetDrawBling(false)
	frame:SetHideCountdownNumbers(true)
	frame:SetSize(RING_SIZE, RING_SIZE)
	frame:SetScale(config.scale)
	frame:SetFrameStrata("DIALOG")
	frame:SetClampedToScreen(true)
	frame.unit = unit
	frame.ringScale = config.scale
	frame.ringWidth, frame.ringHeight = frame:GetSize()
	frame.followCursor = not config.point

	if config.point then
		frame:SetPoint(unpack(config.point))
	else
		frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0)
	end

	if config.background and config.background.enabled then
		local background = frame:CreateTexture(nil, "BACKGROUND", nil, -8)
		background:SetAllPoints()
		background:SetTexture(config.background.texture)
		background:SetVertexColor(unpack(config.background.color))
		background:SetBlendMode(config.background.blendMode)
	end

	frame.leftRingTexture, frame.leftRingSpark = CreateRingHalf(frame, config, "LEFT")
	frame.rightRingTexture, frame.rightRingSpark = CreateRingHalf(frame, config, "RIGHT")

	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	if unit == "gcd" then
		frame:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
		frame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
		frame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
		frame:RegisterUnitEvent("UNIT_SPELLCAST_START", "player")
	else
		for _, event in ipairs(CAST_EVENTS) do
			frame:RegisterUnitEvent(event, unit)
		end
		for event in pairs(STOP_EVENTS) do
			frame:RegisterUnitEvent(event, unit)
		end
		if unit == "target" then
			frame:RegisterEvent("PLAYER_TARGET_CHANGED")
		elseif unit == "focus" then
			frame:RegisterEvent("PLAYER_FOCUS_CHANGED")
		end
	end

	frame:SetScript("OnEvent", OnEvent)
	frame:SetScript("OnCooldownDone", OnCooldownDone)
	OnEvent(frame, "PLAYER_ENTERING_WORLD")
end

function M:OnEnable()
	-- 前半圈只轉右側，後半圈只轉左側；spark 持續轉一圈
	leftCurve = C_CurveUtil.CreateCurve()
	leftCurve:SetType(Enum.LuaCurveType.Linear)
	leftCurve:AddPoint(0, -pi)
	leftCurve:AddPoint(0.5, -pi)
	leftCurve:AddPoint(1, -2 * pi)

	rightCurve = C_CurveUtil.CreateCurve()
	rightCurve:SetType(Enum.LuaCurveType.Linear)
	rightCurve:AddPoint(0, 0)
	rightCurve:AddPoint(0.5, -pi)
	rightCurve:AddPoint(1, -pi)

	sparkCurve = C_CurveUtil.CreateCurve()
	sparkCurve:SetType(Enum.LuaCurveType.Linear)
	sparkCurve:AddPoint(0, 0)
	sparkCurve:AddPoint(1, -2 * pi)

	for unit, config in pairs(RING_CONFIG) do
		if config.enabled then
			CreateCompassCastbar(unit, config)
		end
	end
end
