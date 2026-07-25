local _, ns = ...
local F = ns[2]
local M = F.RegisterModule("CompassCastbar", "CompassCastbar")

-- rCompassCastbar by zork

local ipairs, pairs, unpack = ipairs, pairs, unpack
local math_min, math_rad = math.min, math.rad

local C_Spell_GetSpellCooldown = C_Spell.GetSpellCooldown
local CreateFrame, GetCursorPosition, GetTime = CreateFrame, GetCursorPosition, GetTime
local UnitCastingInfo, UnitChannelInfo = UnitCastingInfo, UnitChannelInfo

local TEXTURE_PATH = "Interface\\AddOns\\!Anyon\\Media\\"
local RING_SIZE = 512
local GCD_SPELL_ID = 61304

local CAST_EVENTS = {
	"UNIT_SPELLCAST_START",
	"UNIT_SPELLCAST_DELAYED",
	"UNIT_SPELLCAST_CHANNEL_START",
	"UNIT_SPELLCAST_CHANNEL_UPDATE",
	"UNIT_SPELLCAST_EMPOWER_START",
	"UNIT_SPELLCAST_EMPOWER_UPDATE",
}

local STOP_EVENTS = {
	UNIT_SPELLCAST_FAILED = true,
	UNIT_SPELLCAST_STOP = true,
	UNIT_SPELLCAST_INTERRUPTED = true,
	UNIT_SPELLCAST_CHANNEL_STOP = true,
	UNIT_SPELLCAST_EMPOWER_STOP = true,
}

local RING_CONFIG = {
	player = {
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
	gcd = {
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
}

local function DisableRing(frame)
	frame:SetScript("OnUpdate", nil)
	frame.startTime = nil
	frame.duration = nil
	frame:Hide()
end

local function RefreshPlayerCast(frame)
	local name, _, _, startTimeMS, endTimeMS = UnitCastingInfo("player")
	if not name then
		name, _, _, startTimeMS, endTimeMS = UnitChannelInfo("player")
	end

	if not name or not startTimeMS or not endTimeMS or endTimeMS <= startTimeMS then
		return false
	end

	frame.startTime = startTimeMS / 1000
	frame.duration = (endTimeMS - startTimeMS) / 1000
	return true
end

local function RefreshGCD(frame)
	local cooldownInfo = C_Spell_GetSpellCooldown(GCD_SPELL_ID)
	if not cooldownInfo or not cooldownInfo.startTime or not cooldownInfo.duration then
		return false
	end

	if cooldownInfo.duration <= 0 then
		return false
	end

	frame.startTime = cooldownInfo.startTime
	frame.duration = cooldownInfo.duration
	return true
end

local function RefreshRing(frame)
	if frame.unit == "gcd" then
		return RefreshGCD(frame)
	end

	return RefreshPlayerCast(frame)
end

local function UpdateCursorPosition(frame)
	local x, y = GetCursorPosition()
	local uiScale = UIParent:GetEffectiveScale()

	frame:ClearAllPoints()
	frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x / uiScale / frame.ringScale - frame.ringWidth / 2, y / uiScale / frame.ringScale - frame.ringHeight / 2)
end

local function SetRingProgress(frame, progress)
	if progress > 0.5 then
		frame.leftRingTexture:SetRotation(math_rad(frame.leftRingTexture.baseDeg - 180 * (progress * 2 - 1)))
		frame.rightRingTexture:SetRotation(math_rad(frame.rightRingTexture.baseDeg - 180))
	else
		frame.leftRingTexture:SetRotation(math_rad(frame.leftRingTexture.baseDeg))
		frame.rightRingTexture:SetRotation(math_rad(frame.rightRingTexture.baseDeg - 180 * (progress * 2)))
	end

	if frame.rightRingSpark then
		frame.rightRingSpark:SetRotation(math_rad(frame.rightRingSpark.baseDeg - 180 * (progress * 2)))
	end

	if frame.leftRingSpark then
		frame.leftRingSpark:SetRotation(math_rad(frame.leftRingSpark.baseDeg - 180 * (progress * 2 - 1)))
	end
end

local function OnUpdate(frame)
	if not frame.startTime or not frame.duration or frame.duration <= 0 then
		DisableRing(frame)
		return
	end

	local elapsed = GetTime() - frame.startTime
	if elapsed >= frame.duration then
		DisableRing(frame)
		return
	end

	if frame.followCursor then
		UpdateCursorPosition(frame)
	end

	SetRingProgress(frame, math_min(elapsed / frame.duration, 1))
end

local function StartRing(frame)
	if not RefreshRing(frame) then
		DisableRing(frame)
		return
	end

	if frame.followCursor then
		UpdateCursorPosition(frame)
	end

	SetRingProgress(frame, 0)	-- 先歸零
	frame:Show()
	frame:SetScript("OnUpdate", OnUpdate)
end

local function OnEvent(frame, event)
	if frame.unit ~= "gcd" and STOP_EVENTS[event] then
		DisableRing(frame)
		return
	end

	StartRing(frame)
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
	ring.baseDeg = side == "LEFT" and -180 or 0

	if config.spark and config.spark.enabled then
		local spark = CreateTexture(child, config.spark, parent.ringWidth, parent.ringHeight, "BACKGROUND", -5)
		spark.baseDeg = ring.baseDeg
		return ring, spark
	end

	return ring
end

local function RegisterPlayerEvents(frame)
	for _, event in ipairs(CAST_EVENTS) do
		frame:RegisterUnitEvent(event, "player")
	end

	for event in pairs(STOP_EVENTS) do
		frame:RegisterUnitEvent(event, "player")
	end
end

local function RegisterGCDEvents(frame)
	frame:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
	frame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
	frame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
	frame:RegisterUnitEvent("UNIT_SPELLCAST_START", "player")
end

local function CreateCompassCastbar(unit, config)
	local frame = CreateFrame("Frame", nil, UIParent)
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

	if unit == "gcd" then
		RegisterGCDEvents(frame)
	else
		RegisterPlayerEvents(frame)
	end

	frame:SetScript("OnEvent", OnEvent)
	DisableRing(frame)
end

function M:OnEnable()
	for unit, config in pairs(RING_CONFIG) do
		CreateCompassCastbar(unit, config)
	end
end
