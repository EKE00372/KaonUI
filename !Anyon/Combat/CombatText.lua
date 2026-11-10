local _, ns = ...
local F, G = ns[2], ns[3]
local M = F.RegisterModule("CombatText", "CombatText")

local AbbreviateNumbers, CreateFrame, CreateFramePool, GetTime = AbbreviateNumbers, CreateFrame, CreateFramePool, GetTime
local issecretvalue = issecretvalue
local band = bit.band

-- 預留文字可重用；尖峰只擴充不足的槽位，不截斷仍在播放的訊息。
local INITIAL_MESSAGES_PER_COLUMN = 10
local FONT_SIZE, LINE_HEIGHT = 22, 20
local SPAWN_ROWS, SPAWN_GAP = 4, 10
local SCROLL_DISTANCE, SCROLL_DURATION = 180, 1.5
local HEAL_MERGE_WINDOW = .2
local DAMAGE_MERGE_WINDOW = .2
local DAMAGE_COLOR, HEAL_COLOR, RESULT_COLOR = {1, .3, .3}, {.2, 1, .35}, {.8, .85, .95}

local schoolColors = {}
local columns, abbreviationOptions
local healFlush, healDeadline, pendingHeal, pendingCriticalHeal
local damageFlush, damageDeadline
local damageFlags = {false, "CRITICAL", "ABSORB", "BLOCK", "RESIST", "BLOCK_REDUCED"}
local damageKinds = {CRITICAL = 2, ABSORB = 3, BLOCK = 4, RESIST = 5, BLOCK_REDUCED = 6}
local DAMAGE_KIND_COUNT = #damageFlags
local pendingIncoming, incomingOrder, incomingCount = {}, {}, 0

local function OnMessageHidden(frame)
	if not frame.active then return end
	-- 先解除活動狀態，避免 pool reset 再次 Hide 時重複回收。
	frame.active = false
	frame.scroll:Stop()
	frame.critical:Stop()
	frame.column.pool:Release(frame)
end

local function OnScrollFinished(animation)
	animation:GetParent():Hide()
end

local function InitializeMessage(frame)
	frame:SetSize(300, LINE_HEIGHT)
	frame:Hide()

	local text = frame:CreateFontString(nil, "OVERLAY")
	text:SetPoint("RIGHT", frame, "CENTER", 0, 0)
	text:SetJustifyH("RIGHT")
	text:SetFont(G.Font, FONT_SIZE, G.FontFlag)
	text:SetShadowOffset(0, 0)
	text:SetWordWrap(false)
	frame.text = text

	local scroll = frame:CreateAnimationGroup()
	frame.scroll = scroll
	local move = scroll:CreateAnimation("Translation")
	move:SetOffset(0, SCROLL_DISTANCE)
	move:SetDuration(SCROLL_DURATION)
	move:SetOrder(1)

	local appear = scroll:CreateAnimation("Alpha")
	appear:SetFromAlpha(0)
	appear:SetToAlpha(1)
	appear:SetDuration(.08)
	appear:SetOrder(1)

	local fade = scroll:CreateAnimation("Alpha")
	fade:SetFromAlpha(1)
	fade:SetToAlpha(0)
	fade:SetStartDelay(1)
	fade:SetDuration(SCROLL_DURATION - 1)
	fade:SetOrder(1)
	scroll:SetScript("OnFinished", OnScrollFinished)

	local critical = frame:CreateAnimationGroup()
	frame.critical = critical
	local grow = critical:CreateAnimation("Scale")
	grow:SetOrigin("CENTER", 0, 0)
	grow:SetScaleFrom(1, 1)
	grow:SetScaleTo(1.35, 1.35)
	grow:SetDuration(.07)
	grow:SetSmoothing("OUT")
	grow:SetOrder(1)

	local settle = critical:CreateAnimation("Scale")
	settle:SetOrigin("CENTER", 0, 0)
	settle:SetScaleFrom(1.35, 1.35)
	settle:SetScaleTo(1, 1)
	settle:SetDuration(.16)
	settle:SetSmoothing("OUT")
	settle:SetOrder(2)

	frame:SetScript("OnHide", OnMessageHidden)
end

local function ShowMessage(column, color, critical, formatString, ...)
	local now = GetTime()
	-- 同幀出生只在有限高度內錯開；後續輸出不再改動既有文字。
	if column.spawnTime == now then
		column.spawnRow = (column.spawnRow + 1) % SPAWN_ROWS
	else
		column.spawnTime, column.spawnRow = now, 0
	end

	local frame = column.pool:Acquire()
	frame.column, frame.active = column, true
	frame:SetPoint("CENTER", column.anchor, "CENTER", 0, column.spawnRow * SPAWN_GAP)
	frame:SetAlpha(1)
	frame.text:SetTextColor(color[1], color[2], color[3])
	frame.text:SetFormattedText(formatString, ...)
	frame:Show()
	frame.scroll:Play()
	if critical then frame.critical:Play() end
end

local function CancelPendingHealing()
	healFlush:Stop()
	healDeadline, pendingHeal, pendingCriticalHeal = nil, nil, nil
end

local function FlushHealing()
	local healing, criticalHealing = pendingHeal, pendingCriticalHeal
	CancelPendingHealing()
	if not UIParent:IsShown() then return end
	if healing ~= nil then
		ShowMessage(columns[2], HEAL_COLOR, false, "+%s", AbbreviateNumbers(healing, abbreviationOptions))
	end
	if criticalHealing ~= nil then
		ShowMessage(columns[2], HEAL_COLOR, true, "+%s", AbbreviateNumbers(criticalHealing, abbreviationOptions))
	end
end

local function ShowDamage(color, flag, amount)
	local number = AbbreviateNumbers(amount, abbreviationOptions)
	local critical = (flag == "CRITICAL")
	if flag == "BLOCK_REDUCED" then
		-- 原生此旗標使用格擋格式；不能把同一 amount 再冒充實際扣血量。
		ShowMessage(columns[1], color, critical, COMBAT_TEXT_BLOCK_REDUCED, number)
	elseif flag == "ABSORB" or flag == "BLOCK" or flag == "RESIST" then
		ShowMessage(columns[1], color, critical, "-%s (%s)", number, CombatFeedbackText[flag])
	else
		ShowMessage(columns[1], color, critical, "-%s", number)
	end
end

local function CancelPendingIncoming()
	damageFlush:Stop()
	damageDeadline = nil
	for index = 1, incomingCount do
		pendingIncoming[incomingOrder[index]] = nil
		incomingOrder[index] = nil
	end
	incomingCount = 0
end

local function FlushIncoming()
	if not UIParent:IsShown() then
		CancelPendingIncoming()
		return
	end
	damageFlush:Stop()
	damageDeadline = nil
	local count = incomingCount
	incomingCount = 0
	-- 按各桶首次出現的順序輸出；金額用數字 key，結果計次用公開 action key。
	for index = 1, count do
		local key = incomingOrder[index]
		local value = pendingIncoming[key]
		incomingOrder[index], pendingIncoming[key] = nil, nil
		if type(key) == "number" then
			local kind = (key - 1) % DAMAGE_KIND_COUNT + 1
			local school = (key - kind) / DAMAGE_KIND_COUNT
			ShowDamage(schoolColors[school] or DAMAGE_COLOR, damageFlags[kind], value)
		elseif value > 1 then
			ShowMessage(columns[1], RESULT_COLOR, false, "%s x%d", CombatFeedbackText[key], value)
		else
			ShowMessage(columns[1], RESULT_COLOR, false, "%s", CombatFeedbackText[key])
		end
	end
end

local function QueueIncoming(key, value, now)
	if pendingIncoming[key] == nil then
		incomingCount = incomingCount + 1
		incomingOrder[incomingCount] = key
		pendingIncoming[key] = value
	else
		pendingIncoming[key] = pendingIncoming[key] + value
	end
	if not damageDeadline then
		damageDeadline = now + DAMAGE_MERGE_WINDOW
		damageFlush:Play()
	end
end

local function OnUnitCombat(_, _, unit, action, flag, amount, schoolMask)
	if unit ~= "player" or not UIParent:IsShown() then return end
	if action == "HEAL" then
		local now = GetTime()
		if healDeadline and now >= healDeadline then FlushHealing() end
		local flagIsSecret = issecretvalue(flag)
		local critical = (not flagIsSecret and flag == "CRITICAL")
		-- 只累加公開數值；無法判讀的治療仍逐筆顯示，保留受限戰鬥的數字。
		if issecretvalue(amount) or flagIsSecret then
			ShowMessage(columns[2], HEAL_COLOR, critical, "+%s", AbbreviateNumbers(amount, abbreviationOptions))
			return
		end
		if critical then
			pendingCriticalHeal = (pendingCriticalHeal or 0) + amount
		else
			pendingHeal = (pendingHeal or 0) + amount
		end
		-- 固定第一筆開始的合併窗；後續治療不延後輸出時間。
		if not healDeadline then
			healDeadline = now + HEAL_MERGE_WINDOW
			healFlush:Play()
		end
	elseif action == "WOUND" then
		local now = GetTime()
		if damageDeadline and now >= damageDeadline then FlushIncoming() end
		-- 旗標與學派只是附加樣式；不能讀取時仍保留 opaque 傷害數字。
		local flagIsSecret = issecretvalue(flag)
		local amountIsSecret = issecretvalue(amount)
		if flagIsSecret then flag = nil end
		if not flagIsSecret and not amountIsSecret and amount == 0 then
			local result = "MISS"
			if flag == "ABSORB" or flag == "BLOCK" or flag == "RESIST" then
				result = flag
			end
			QueueIncoming(result, 1, now)
			return
		end

		local schoolIsSecret = issecretvalue(schoolMask)
		local school = 0
		if not schoolIsSecret and schoolColors[schoolMask] then school = schoolMask end
		if amountIsSecret or flagIsSecret or schoolIsSecret then
			ShowDamage(schoolColors[school] or DAMAGE_COLOR, flag, amount)
			return
		end
		local kind = damageKinds[flag] or 1
		QueueIncoming(school * DAMAGE_KIND_COUNT + kind, amount, now)
	elseif action ~= "ENERGIZE" then
		-- 獨立防禦事件沒有分項減免量契約，沿原生回饋只顯示結果。
		local result = CombatFeedbackText[action]
		if result then
			local now = GetTime()
			if damageDeadline and now >= damageDeadline then FlushIncoming() end
			QueueIncoming(action, 1, now)
		end
	end
end

function M:OnEnable()
	local singleSchoolColors = {
		[Enum.Damageclass.MaskPhysical] = {1, 1, 1},
		[Enum.Damageclass.MaskHoly] = {1, .9, .5},
		[Enum.Damageclass.MaskFire] = {1, .45, .15},
		[Enum.Damageclass.MaskNature] = {.4, 1, .35},
		[Enum.Damageclass.MaskFrost] = {.45, .8, 1},
		[Enum.Damageclass.MaskShadow] = {.7, .4, 1},
		[Enum.Damageclass.MaskArcane] = {1, .5, 1},
	}
	-- 混合學派只在初始化時計算固定混色，不拆分或運算任何傷害量。
	for mask = 1, Enum.Damageclass.All do
		local r, g, b, count = 0, 0, 0, 0
		for school, color in pairs(singleSchoolColors) do
			if band(mask, school) ~= 0 then
				r, g, b = r + color[1], g + color[2], b + color[3]
				count = count + 1
			end
		end
		schoolColors[mask] = {r / count, g / count, b / count}
	end

	-- 固定千／百萬的除數與原始 k/m 後綴，避免預設後綴查到本地化全域字串。
	abbreviationOptions = {
		locale = "enUS",
		config = CreateAbbreviateConfig({
			{
				breakpoint = 1e7,
				abbreviation = "m",
				significandDivisor = 1e6,
				fractionDivisor = 1,
				abbreviationIsGlobal = false,
			},
			{
				breakpoint = 1e6,
				abbreviation = "m",
				significandDivisor = 1e5,
				fractionDivisor = 10,
				abbreviationIsGlobal = false,
			},
			{
				breakpoint = 1e4,
				abbreviation = "k",
				significandDivisor = 1e3,
				fractionDivisor = 1,
				abbreviationIsGlobal = false,
			},
			{
				breakpoint = 1e3,
				abbreviation = "k",
				significandDivisor = 1e2,
				fractionDivisor = 10,
				abbreviationIsGlobal = false,
			},
		}),
	}
	columns = {}
	for index = 1, 2 do
		local anchor = CreateFrame("Frame", nil, UIParent)
		anchor:SetSize(300, LINE_HEIGHT)
		anchor:SetPoint("CENTER", UIParent, "CENTER", index == 1 and -520 or -460, -110)
		anchor:SetFrameStrata("HIGH")
		local column = {anchor = anchor, scheduler = CreateFrame("Frame", nil, anchor)}
		column.pool = CreateFramePool("Frame", anchor, nil, nil, nil, InitializeMessage)
		for _ = 1, INITIAL_MESSAGES_PER_COLUMN do
			column.pool:Acquire()
		end
		column.pool:ReleaseAll()
		columns[index] = column
	end

	-- 計時器與文字互為兄弟，避免在文字共同父層播放／停止動畫。
	healFlush = columns[2].scheduler:CreateAnimationGroup()
	healFlush:CreateAnimation():SetDuration(HEAL_MERGE_WINDOW)
	healFlush:SetScript("OnFinished", FlushHealing)
	columns[2].anchor:SetScript("OnHide", CancelPendingHealing)

	-- 左欄傷害與防禦計次共用固定窗，和右欄治療獨立運作。
	damageFlush = columns[1].scheduler:CreateAnimationGroup()
	damageFlush:CreateAnimation():SetDuration(DAMAGE_MERGE_WINDOW)
	damageFlush:SetScript("OnFinished", FlushIncoming)
	columns[1].anchor:SetScript("OnHide", CancelPendingIncoming)

	local events = CreateFrame("Frame")
	events:RegisterUnitEvent("UNIT_COMBAT", "player")
	events:SetScript("OnEvent", OnUnitCombat)
end
