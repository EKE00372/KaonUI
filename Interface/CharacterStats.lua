--[[ 裝備/狀態/屬性 ]]--

local _G = _G
-- 數值
_G.ITEM_LEVEL_AND_MIN = "等級%d (min: %d)"
_G.ITEM_LEVEL_RANGE = "等級%d - %d"
_G.ITEM_LEVEL_RANGE_CURRENT = "等級%d - %d (%d)"
_G.ITEM_LIMIT_CATEGORY_MULTIPLE = "裝備唯一: %s (%d)"
_G.ITEM_MOD_CRIT_RATING = "+%s爆擊"
_G.ITEM_MOD_CRIT_RATING_SHORT = "爆擊"
_G.ITEM_MOD_VERSATILITY = "全能"
_G.ITEM_MOD_EXTRA_ARMOR = "+%s護甲"
_G.ITEM_MOD_EXTRA_ARMOR_SHORT = "護甲"
_G.ITEM_SOCKETABLE = ""			--SHIFT+右鍵插寶石
_G.ITEM_ARTIFACT_VIEWABLE = ""	--SHIFT+右鍵看神器
_G.ARMOR_TEMPLATE = "%s護甲"
_G.DAMAGE_TEMPLATE = "%s - %s"
_G.DPS_TEMPLATE = "%s DPS"
-- 角色面板戰鬥等級
_G.STAT_CRITICAL_STRIKE = "爆擊"
_G.STAT_VERSATILITY = "全能"
-- 附魔
_G.ENCHANTED_TOOLTIP_LINE = "|cff00ffff%s|r"
-- 塑形
_G.TRANSMOGRIFIED = "塑形：%s"
_G.TRANSMOGRIFIED_HEADER = ""
-- 插槽
_G.EMPTY_SOCKET_RED = "紅"
_G.EMPTY_SOCKET_YELLOW = "黃"
_G.EMPTY_SOCKET_BLUE = "藍"
_G.EMPTY_SOCKET_META = "變換"
_G.EMPTY_SOCKET_NO_COLOR = "無"
_G.EMPTY_SOCKET_PRISMATIC = "無"
_G.ITEM_SOCKET_BONUS = "獎勵: %s"


-- 小數點
local t = { 
	[STAT_CRITICAL_STRIKE] = true,
	[STAT_MASTERY] = true, 
	[STAT_HASTE] = true, 
	[STAT_VERSATILITY] = true, 
	[STAT_LIFESTEAL] = true, 
	[STAT_AVOIDANCE] = true, 
	[STAT_DODGE] = true, 
	[STAT_BLOCK] = true, 
	[STAT_PARRY] = true, } 
	
function PaperDollFrame_SetLabelAndText(statFrame, label, text, isPercentage, numericValue) 
	if statFrame.Label then
		statFrame.Label:SetText(format(STAT_FORMAT, label))
	end
	if isPercentage then
		text = format("%d%%", numericValue + 0.5)
	end
	if t[label] then
		text = format("%.2F%%", numericValue) 
	end
	statFrame.Value:SetText(text)
	statFrame.numericValue = numericValue
end

-- 核心
local statPanel = CreateFrame("Frame", nil, CharacterFrameInsetRight)
	statPanel:SetSize(200, 350)
	statPanel:SetPoint("TOP", 0, -5)
	local scrollFrame = CreateFrame("ScrollFrame", nil, statPanel, "UIPanelScrollFrameTemplate")
	scrollFrame:SetAllPoints()
	scrollFrame.ScrollBar:Hide()
	scrollFrame.ScrollBar.Show = function() end
	local stat = CreateFrame("Frame", nil, scrollFrame)
	stat:SetSize(200, 1)
	scrollFrame:SetScrollChild(stat)
	CharacterStatsPane:ClearAllPoints()
	CharacterStatsPane:SetParent(stat)
	CharacterStatsPane:SetAllPoints(stat)
	hooksecurefunc("PaperDollFrame_UpdateSidebarTabs", function()
		if (not _G[PAPERDOLL_SIDEBARS[1].frame]:IsShown()) then
			statPanel:Hide()
		else
			statPanel:Show()
		end	
	end)

	-- Change default data
	PAPERDOLL_STATCATEGORIES = {
		[1] = {
			categoryFrame = "AttributesCategory",
			stats = {
				[1] = { stat = "STRENGTH", primary = LE_UNIT_STAT_STRENGTH },
				[2] = { stat = "AGILITY", primary = LE_UNIT_STAT_AGILITY },
				[3] = { stat = "INTELLECT", primary = LE_UNIT_STAT_INTELLECT },
				[4] = { stat = "STAMINA" },
				[5] = { stat = "ARMOR" },
				[6] = { stat = "ATTACK_DAMAGE", primary = LE_UNIT_STAT_STRENGTH, roles =  { "TANK", "DAMAGER" } },
				[7] = { stat = "ATTACK_AP", hideAt = 0, primary = LE_UNIT_STAT_STRENGTH, roles =  { "TANK", "DAMAGER" } },
				[8] = { stat = "ATTACK_ATTACKSPEED", primary = LE_UNIT_STAT_STRENGTH, roles =  { "TANK", "DAMAGER" } },
				[9] = { stat = "ATTACK_DAMAGE", primary = LE_UNIT_STAT_AGILITY, roles =  { "TANK", "DAMAGER" } },
				[10] = { stat = "ATTACK_AP", hideAt = 0, primary = LE_UNIT_STAT_AGILITY, roles =  { "TANK", "DAMAGER" } },
				[11] = { stat = "ATTACK_ATTACKSPEED", primary = LE_UNIT_STAT_AGILITY, roles =  { "TANK", "DAMAGER" } },
				[12] = { stat = "SPELLPOWER", hideAt = 0, primary = LE_UNIT_STAT_INTELLECT },
				[13] = { stat = "MANAREGEN", hideAt = 0, primary = LE_UNIT_STAT_INTELLECT },
				[14] = { stat = "ENERGY_REGEN", hideAt = 0, primary = LE_UNIT_STAT_AGILITY },
				[15] = { stat = "RUNE_REGEN", hideAt = 0, primary = LE_UNIT_STAT_STRENGTH },
				[16] = { stat = "FOCUS_REGEN", hideAt = 0, primary = LE_UNIT_STAT_AGILITY },
				[17] = { stat = "MOVESPEED" },
			},
		},
		[2] = {
			categoryFrame = "EnhancementsCategory",
			stats = {
				[1] = { stat = "CRITCHANCE", hideAt = 0 },
				[2] = { stat = "HASTE", hideAt = 0 },
				[3] = { stat = "MASTERY", hideAt = 0 },
				[4] = { stat = "VERSATILITY", hideAt = 0 },
				[5] = { stat = "LIFESTEAL", hideAt = 0 },
				[6] = { stat = "AVOIDANCE", hideAt = 0 },
				[7] = { stat = "DODGE", hideAt = 0, roles =  { "TANK" } },
				[8] = { stat = "PARRY", hideAt = 0, roles =  { "TANK" } },
				[9] = { stat = "BLOCK", hideAt = 0, roles =  { "TANK" } },
			},
		},
	}

	PAPERDOLL_STATINFO["ENERGY_REGEN"].updateFunc = function(statFrame, unit)
		statFrame.numericValue = 0
		PaperDollFrame_SetEnergyRegen(statFrame, unit)
	end

	PAPERDOLL_STATINFO["RUNE_REGEN"].updateFunc = function(statFrame, unit)
		statFrame.numericValue = 0
		PaperDollFrame_SetRuneRegen(statFrame, unit)
	end

	PAPERDOLL_STATINFO["FOCUS_REGEN"].updateFunc = function(statFrame, unit)
		statFrame.numericValue = 0
		PaperDollFrame_SetFocusRegen(statFrame, unit)
	end

	-- Fix Movespeed
	PAPERDOLL_STATINFO["MOVESPEED"].updateFunc = function(statFrame, unit)
		PaperDollFrame_SetMovementSpeed(statFrame, unit)
	end

	function MovementSpeed_OnEnter(statFrame)
		GameTooltip:SetOwner(statFrame, "ANCHOR_RIGHT")
		GameTooltip:SetText(HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_MOVEMENT_SPEED).." "..format("%d%%", statFrame.speed + .5)..FONT_COLOR_CODE_CLOSE)
		GameTooltip:AddLine(format(STAT_MOVEMENT_GROUND_TOOLTIP, statFrame.runSpeed + .5))
		if statFrame.unit ~= "pet" then
			GameTooltip:AddLine(format(STAT_MOVEMENT_FLIGHT_TOOLTIP, statFrame.flightSpeed + .5))
		end
		GameTooltip:AddLine(format(STAT_MOVEMENT_SWIM_TOOLTIP, statFrame.swimSpeed + .5))
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(format(CR_SPEED_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(CR_SPEED)), GetCombatRatingBonus(CR_SPEED)))
		GameTooltip:Show()
	end

	function PaperDollFrame_SetMovementSpeed(statFrame, unit)
		statFrame.wasSwimming = nil
		statFrame.unit = unit
		MovementSpeed_OnUpdate(statFrame)
		statFrame.onEnterFunc = MovementSpeed_OnEnter
		statFrame:Show()
	end