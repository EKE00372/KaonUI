local addon, ns = ...
local F, G, L = ns[2], ns[3], ns[4]

local type, ipairs = type, ipairs
local tinsert, wipe, floor = table.insert, wipe, math.floor
local MainFrame

-- 外觀常數
local THEME_R, THEME_G, THEME_B = 0, .85, .85
local DISABLED_TEXT_R, DISABLED_TEXT_G, DISABLED_TEXT_B = .45, .5, .5

local PANEL_ALPHA, BUTTON_ALPHA = .82, .35
local BREATH_MIN_ALPHA, BREATH_MAX_ALPHA = .25, .75
local BREATH_IN_DURATION, BREATH_OUT_DURATION = 5, 7
local BREATH_MAIN_SIZE, BREATH_TAB_SIZE = 12, 10

local MAIN_WIDTH, MAIN_HEIGHT = 500, 428
local PAGE_HORIZONTAL_INSET, PAGE_TOP_INSET = 26, 32
local COLUMN_WIDTH, COLUMN_GAP = 215, 18
local SECTION_HEIGHT, SECTION_GAP = 24, 8
local OPTION_HEIGHT, OPTION_GAP = 26, 2
local TAB_WIDTH, TAB_HEIGHT, TAB_GAP = 130, 32, 10
local TITLE_Y_OFFSET = 14

-----------
-- Reset --
-----------

-- 與 Ruri 相同，清空整份存檔；按鈕隨即重載，由 Init.lua 重新補齊預設值。
local function ResetDB()
	if type(AnyonDB) == "table" then
		wipe(AnyonDB)
	else
		AnyonDB = {}
	end
end

--------------
-- Template --
--------------

-- 建立選項與按鈕文字；字型沿用 Config.lua。
local function CreateText(parent, text, size, justify)
	local fontString = parent:CreateFontString(nil, "OVERLAY")
	fontString:SetFont(G.Font, size or G.FontSize, G.FontFlag)
	fontString:SetShadowOffset(0, 0)
	fontString:SetWordWrap(false)
	fontString:SetJustifyH(justify)
	fontString:SetText(text)
	return fontString
end

-- 視窗、分頁和操作按鈕共用黑底青框。
local function SetPanelBackdrop(frame, alpha)
	frame:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8x8",
		edgeFile = "Interface\\Buttons\\WHITE8x8",
		edgeSize = 1,
		tile = false,
		insets = {left = 1, right = 1, top = 1, bottom = 1},
	})
	frame:SetBackdropColor(0, 0, 0, alpha or .75)
	frame:SetBackdropBorderColor(THEME_R, THEME_G, THEME_B, 1)
end

-- 用原生 Alpha 動畫播放框體外側的呼吸光。
local function CreateBreathGlow(parent, size)
	local glow = F.CreateSD(parent, parent, size, THEME_R, THEME_G, THEME_B, .65)
	glow:SetAlpha(BREATH_MIN_ALPHA)

	local animation = glow:CreateAnimationGroup()
	animation:SetLooping("REPEAT")

	local fadeIn = animation:CreateAnimation("Alpha")
	fadeIn:SetFromAlpha(BREATH_MIN_ALPHA)
	fadeIn:SetToAlpha(BREATH_MAX_ALPHA)
	fadeIn:SetDuration(BREATH_IN_DURATION)
	fadeIn:SetSmoothing("IN_OUT")
	fadeIn:SetOrder(1)

	local fadeOut = animation:CreateAnimation("Alpha")
	fadeOut:SetFromAlpha(BREATH_MAX_ALPHA)
	fadeOut:SetToAlpha(BREATH_MIN_ALPHA)
	fadeOut:SetDuration(BREATH_OUT_DURATION)
	fadeOut:SetSmoothing("IN_OUT")
	fadeOut:SetOrder(2)

	animation:Play()
end

-- 建立可點擊的文字按鈕，滑鼠指向時加亮底色。
local function CreateButton(parent, width, height, text)
	local button = CreateFrame("Button", nil, parent, "BackdropTemplate")
	button:SetSize(width, height)
	SetPanelBackdrop(button, BUTTON_ALPHA)

	button.Text = CreateText(button, text, G.FontSize, "CENTER")
	button.Text:SetPoint("CENTER")

	button:SetScript("OnEnter", function(self)
		self:SetBackdropColor(0, .45, .45, .65)
	end)
	button:SetScript("OnLeave", function(self)
		self:SetBackdropColor(0, 0, 0, BUTTON_ALPHA)
	end)

	return button
end

-- 在頁面內建立子分類標題。
local function CreateSectionTitle(parent, text, yOffset)
	local title = CreateText(parent, "|cff00d9d9"..(L[text] or text).."|r", G.FontSize + 2, "LEFT")
	title:SetPoint("TOPLEFT", 0, yOffset)
end

-- 整列與勾選框共用說明；函數型詞條在滑鼠指向時才取最新內容。
local function SetupOptionTooltip(row, check, tooltip)
	local function ShowTooltip(self)
		local text = type(tooltip) == "function" and tooltip() or tooltip
		GameTooltip:ClearLines()
		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		GameTooltip:ClearAllPoints()
		GameTooltip:SetPoint("BOTTOM", row, "TOP", 0, 4)
		GameTooltip:AddLine(text, 1, 1, 1, true)
		GameTooltip:Show()
	end
	local function HideTooltip(self)
		if GameTooltip:IsOwned(self) then GameTooltip:Hide() end
	end

	for _, frame in ipairs({row, check}) do
		frame:SetMotionScriptsWhileDisabled(true)
		frame:SetScript("OnEnter", ShowTooltip)
		frame:SetScript("OnLeave", HideTooltip)
		frame:SetScript("OnHide", HideTooltip)
	end
end

---------------
-- Functions --
---------------

-- 檢查選項本身及各層依賴，判斷是否允許編輯
local function CanEditOption(option, group, section)
	-- 檢查選項本身是否被禁用
	if option.disabled then return false end

	-- 依序檢查頁面、子分類與選項本身的依賴條件
	for _, setting in ipairs({group, section, option}) do
		local requiredAny = setting.requiresAny
		if requiredAny then
			local matched
			for _, key in ipairs(requiredAny) do
				if F.GetSetting(key) == true then
					matched = true
					break
				end
			end
			if not matched then return false end
		end
	end

	return true
end

-- 同步選項狀態
local function RefreshOptionControls()
	if not MainFrame then return end

	for _, row in ipairs(MainFrame.OptionRows) do
		row:RefreshState()
	end
	MainFrame.StatusText:SetText(F.HasPendingSettings() and "|cffffd100"..L.StatusChanged.."|r" or "")
end

-- 寫入設定值
local function SetOptionValue(option, value)
	-- 禁用選項不寫入設定值
	if option.disabled then return end
	-- 寫入設定值
	F.SetSetting(option.key, value)
	-- 更新
	RefreshOptionControls()
end

-- 將選項綁定至設定值，並處理點擊與更新
local function SetupOptionRow(row, check, label, option, group, section)
	local tooltip = option.tooltip and L[option.tooltip]
	if tooltip then SetupOptionTooltip(row, check, tooltip) end

	-- 開關
	local function ToggleValue()
		if not CanEditOption(option, group, section) then
			check:SetChecked(F.GetSetting(option.key) == true)
			return
		end

		SetOptionValue(option, check:GetChecked() == true)
	end
	-- 選項方塊=開關
	check:SetScript("OnClick", ToggleValue)
	-- 選項詞條=開關
	row:SetScript("OnClick", function()
		check:SetChecked(not check:GetChecked())
		ToggleValue()
	end)

	-- 同步選項狀態
	row.RefreshState = function(self)
		local available = CanEditOption(option, group, section)
		check:SetChecked(F.GetSetting(option.key) == true)
		if available then
			self:Enable()
			check:Enable()
			if tooltip then
				label:SetTextColor(230 / 255, 199 / 255, 122 / 255, 1)
			else
				label:SetTextColor(1, 1, 1, 1)
			end
		else
			self:Disable()
			check:Disable()
			label:SetTextColor(DISABLED_TEXT_R, DISABLED_TEXT_G, DISABLED_TEXT_B, 1)
		end
	end

	tinsert(MainFrame.OptionRows, row)
end

-- 每頁用兩欄排列勾選項目，名稱顏色標示是否有說明。
local function CreateCheckOption(parent, option, index, yBase, group, section)
	local column = (index - 1) % 2
	local rowIndex = floor((index - 1) / 2)
	local xOffset = column * (COLUMN_WIDTH + COLUMN_GAP)
	local yOffset = yBase - rowIndex * (OPTION_HEIGHT + OPTION_GAP)

	local row = CreateFrame("Button", nil, parent)
	row:SetSize(COLUMN_WIDTH, OPTION_HEIGHT)
	row:SetPoint("TOPLEFT", xOffset, yOffset)

	local check = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
	check:SetPoint("LEFT", -4, 0)

	local label = CreateText(row, L[option.label] or option.label, G.FontSize, "LEFT")
	label:SetPoint("LEFT", check, "RIGHT", 2, 0)
	label:SetPoint("RIGHT", row, "RIGHT", 0, 0)

	SetupOptionRow(row, check, label, option, group, section)
end

-- 依 Init.lua 的 groups／sections 建立頁面；沒有子分類就直接排列選項。
local function CreatePage(parent, group)
	local page = CreateFrame("Frame", nil, parent)
	page:SetPoint("TOPLEFT", PAGE_HORIZONTAL_INSET, -PAGE_TOP_INSET)
	page:SetPoint("BOTTOMRIGHT", -PAGE_HORIZONTAL_INSET, 54)
	page:Hide()

	local yOffset = 0
	local function AddSection(section)
		if section.name then
			CreateSectionTitle(page, section.name, yOffset)
			yOffset = yOffset - SECTION_HEIGHT
		end

		local optionIndex = 0
		for _, option in ipairs(section.options or {}) do
			if option.type == "toggle" then
				optionIndex = optionIndex + 1
				CreateCheckOption(page, option, optionIndex, yOffset, group, section)
			end
		end

		if optionIndex > 0 then
			local rows = floor((optionIndex + 1) / 2)
			yOffset = yOffset - rows * (OPTION_HEIGHT + OPTION_GAP) - SECTION_GAP
		end
	end

	if group.sections then
		for _, section in ipairs(group.sections) do
			AddSection(section)
		end
	else
		AddSection({ options = group.options })
	end

	return page
end

-- 左側分頁按鈕只負責切換頁面顯示
local function SelectTab(frame, index)
	for tabIndex, tab in ipairs(frame.Tabs) do
		tab.Selected = tabIndex == index
		if tab.Selected then
			tab:SetBackdropColor(0, .35, .35, PANEL_ALPHA)
			frame.Pages[tabIndex]:Show()
		else
			tab:SetBackdropColor(0, 0, 0, PANEL_ALPHA)
			frame.Pages[tabIndex]:Hide()
		end
	end
end

-- 左側分頁沿用共用按鈕；目前頁面會保留亮色底。
local function CreateTab(parent, index, text)
	local tab = CreateButton(parent, TAB_WIDTH, TAB_HEIGHT, L[text] or text)
	tab:SetPoint("TOPRIGHT", parent, "TOPLEFT", -10, -48 - (index - 1) * (TAB_HEIGHT + TAB_GAP))
	tab:SetBackdropColor(0, 0, 0, PANEL_ALPHA)
	CreateBreathGlow(tab, BREATH_TAB_SIZE)

	tab:SetScript("OnEnter", function(self)
		self:SetBackdropColor(0, .45, .45, PANEL_ALPHA)
	end)
	tab:SetScript("OnLeave", function(self)
		if self.Selected then
			self:SetBackdropColor(0, .35, .35, PANEL_ALPHA)
		else
			self:SetBackdropColor(0, 0, 0, PANEL_ALPHA)
		end
	end)
	tab:SetScript("OnClick", function()
		SelectTab(parent, index)
	end)
	return tab
end

-----------
-- Build --
-----------

-- 首次開啟才建立視窗，重設與重載按鈕的行為與 Ruri 相同。
local function BuildGUI()
	local version = C_AddOns.GetAddOnMetadata(addon, "Version") or ""

	MainFrame = CreateFrame("Frame", "AnyonGUI", UIParent, "BackdropTemplate")
	tinsert(UISpecialFrames, MainFrame:GetName())
	MainFrame:SetFrameStrata("DIALOG")
	MainFrame:SetSize(MAIN_WIDTH, MAIN_HEIGHT)
	MainFrame:SetPoint("CENTER")
	MainFrame:SetMovable(true)
	MainFrame:EnableMouse(true)
	MainFrame:RegisterForDrag("LeftButton")
	MainFrame:SetClampedToScreen(true)
	MainFrame:SetScript("OnDragStart", MainFrame.StartMoving)
	MainFrame:SetScript("OnDragStop", MainFrame.StopMovingOrSizing)
	SetPanelBackdrop(MainFrame, PANEL_ALPHA)
	CreateBreathGlow(MainFrame, BREATH_MAIN_SIZE)

	local titleSize = G.FontSize + 4
	local title = CreateText(MainFrame, "|cff00ffff!Anyon|r "..version, titleSize, "CENTER")
	title:SetPoint("TOP", MainFrame, "TOP", 0, TITLE_Y_OFFSET)

	MainFrame.StatusText = CreateText(MainFrame, "", G.FontSize, "LEFT")
	MainFrame.StatusText:SetPoint("BOTTOMLEFT", 20, 22)

	MainFrame.Tabs = {}
	MainFrame.Pages = {}
	MainFrame.OptionRows = {}

	for index, group in ipairs(F.GUIOptionGroups) do
		MainFrame.Tabs[index] = CreateTab(MainFrame, index, group.name)
		MainFrame.Pages[index] = CreatePage(MainFrame, group)
	end

	local closeButton = CreateButton(MainFrame, 24, 24, "X")
	closeButton:SetPoint("TOPRIGHT", -12, -12)
	closeButton:SetScript("OnClick", function()
		MainFrame:Hide()
	end)

	local reloadButton = CreateButton(MainFrame, 88, 28, L.ReloadUI)
	reloadButton:SetPoint("BOTTOMRIGHT", -24, 18)
	reloadButton:SetScript("OnClick", ReloadUI)

	local resetButton = CreateButton(MainFrame, 88, 28, RESET)
	resetButton:SetPoint("RIGHT", reloadButton, "LEFT", -10, 0)
	resetButton:SetScript("OnClick", function()
		ResetDB()
		ReloadUI()
	end)

	SelectTab(MainFrame, 1)
	MainFrame:Hide()
end

-- /anyon 開關視窗；每次開啟前重新讀取設定，保留目前所選分頁。
F.CreateAnyonGUI = function()
	if not MainFrame then
		BuildGUI()
	end

	if MainFrame:IsShown() then
		MainFrame:Hide()
	else
		RefreshOptionControls()
		MainFrame:Show()
	end
end

SlashCmdList["ANYON"] = F.CreateAnyonGUI
SLASH_ANYON1 = "/anyon"
