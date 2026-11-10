local _, ns = ...
local F = ns[2]
local M = F.RegisterModule("QuickMark", "QuickMark")

local CreateFrame = CreateFrame
local BUTTON_SIZE, GAP = 32, 2

-- credits: DejaMark（Dejablue、Baudzila、Ro、Choonster、Phanx）
local MARKERS = {
	{ "TOPLEFT", 5 },		-- 星星
	{ "TOP", 6 },			-- 圓圈
	{ "TOPRIGHT", 3 },		-- 菱形
	{ "LEFT", 2 },			-- 三角
	{ "BOTTOM", 7 },		-- 月亮
	{ "RIGHT", 1 },			-- 方塊
	{ "BOTTOMLEFT", 4 },	-- 十字
	{ "CENTER", 8 },		-- 骷髏
	{ "BOTTOMRIGHT" },		-- 清除全部
}

-- 沿用原版的綁定識別字與按鈕名稱，讓玩家原有的按鍵設定繼續生效
-- 按鍵列表的名稱固定顯示 dejamark，不另外建立分類或指定預設按鍵
_G["BINDING_NAME_CLICK DejaMark:LeftButton"] = "dejamark"

function M:OnEnable()
	local menu = CreateFrame("Frame", nil, UIParent)
	local size = BUTTON_SIZE * 3 + GAP * 2
	menu:SetSize(size, size)
	menu:SetFrameStrata("DIALOG")
	menu:SetClampedToScreen(true)
	menu:SetMovable(true)
	menu:EnableMouse(true)
	menu:Hide()

	local background = menu:CreateTexture(nil, "BACKGROUND")
	background:SetAllPoints()
	background:SetColorTexture(0, 0, 0, 0.8)

	for index, marker in ipairs(MARKERS) do
		local button = CreateFrame("Button", nil, menu, "SecureActionButtonTemplate")
		button:SetSize(BUTTON_SIZE, BUTTON_SIZE)
		button:SetPoint(marker[1])
		button:RegisterForClicks("AnyDown", "AnyUp") -- 同時接收按下與放開
		button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")

		local icon = button:CreateTexture(nil, "ARTWORK")
		icon:SetAllPoints()

		button:SetAttribute("*type1", "raidtarget")
		if index == 9 then
			icon:SetTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
			button:SetAttribute("*action1", "clear-all")
			button:SetAttribute("*type2", "worldmarker")
			button:SetAttribute("*action2", "clear")
		else
			icon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_"..index)
			button:SetAttribute("*marker1", index)
			button:SetAttribute("*type2", "macro")
			button:SetAttribute("*macrotext2", "/wm "..marker[2].."\n/cwm "..marker[2])
		end
	end

	-- 按住綁定鍵時在游標位置顯示，放開時隱藏
	local opener = CreateFrame("Button", "DejaMark", UIParent, "SecureHandlerClickTemplate")
	opener:RegisterForClicks("AnyDown", "AnyUp")
	opener:SetFrameRef("Menu", menu)
	opener:SetAttribute("_onclick", [[
		local menu = self:GetFrameRef("Menu")
		if down then
			menu:ClearAllPoints()
			menu:SetPoint("CENTER", "$cursor")
			menu:Show()
		else
			menu:Hide()
		end
	]])
end
