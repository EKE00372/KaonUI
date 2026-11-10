local _, ns = ...
local F = ns[2]
local M = F.RegisterModule("ProfessionTabs", "ProfessionTabs")

local panels = {}

local function UpdateCombatState(panel)
	local inCombat = InCombatLockdown()
	for _, tab in ipairs(panel.tabs) do
		tab.Icon:SetDesaturated(inCombat)
	end
end

local function OnCombatChanged()
	for _, panel in ipairs(panels) do
		if panel.frame:IsShown() then UpdateCombatState(panel) end
	end
end

local function UpdateSelection(panel)
	local professionID
	if panel.kind == "profession" then
		professionID = C_TradeSkillUI.GetBaseProfessionInfo().professionID
	end
	-- 原生 SetChecked 會改用 atlas，這裡只更新選中外框，保留專業圖示。
	for _, tab in ipairs(panel.tabs) do
		tab.SelectedTexture:SetShown(panel.kind == "archaeology" and tab.isArchaeology
			or panel.kind == "profession" and tab.skillLineID == professionID)
	end
end

local function UpdatePosition(panel)
	local firstTab = panel.tabs[1]
	if not firstTab then return end

	local anchor = panel.frame
	if panel.outputLogs then
		for _, log in ipairs(panel.outputLogs) do
			if log:IsVisible() then anchor = log; break end
		end
	end
	-- 結果框會在顯示後調整寬度，直接錨定右緣即可跟隨，不必讀寬或輪詢。
	firstTab:ClearAllPoints()
	firstTab:SetPoint("TOPLEFT", anchor, "TOPRIGHT", -3, -44)
end

local function OnTabClick(self, button, upInside)
	if button ~= "LeftButton" or not upInside or InCombatLockdown() then return end

	local professionFrame = ProfessionsFrame
	if professionFrame and professionFrame:IsShown()
		and professionFrame:GetTab() == professionFrame.specializationsTabID
		and C_Traits.ConfigHasStagedChanges(professionFrame.SpecPage:GetConfigID()) then
		-- 沿用原生確認；它只負責提交／關窗，本次不再繼續切換。
		professionFrame:CheckConfirmClose()
		return
	end

	local target
	if self.isArchaeology then
		if not ArchaeologyFrame_LoadUI() then return end
		target = ArchaeologyFrame
	else
		if not C_TradeSkillUI.OpenTradeSkill(self.skillLineID) then return end
		target = ProfessionsFrame
	end

	-- 不關閉剛開啟的 ProfessionsFrame：其 OnHide 會關掉目前的專業資料。
	for _, panel in ipairs(panels) do
		if panel.frame ~= target and panel.frame:IsShown() then
			HideUIPanel(panel.frame)
		end
	end
	if self.isArchaeology then ArchaeologyFrame_Show() end
end

local function OnTabHide(self)
	local tooltip = GetAppropriateTooltip()
	if tooltip:IsOwned(self) then tooltip:Hide() end
end

local function RefreshPanel(panel)
	local primary1, primary2, archaeology, fishing, cooking = GetProfessions()
	local professions = { primary1, primary2, cooking, fishing, archaeology }
	local count = 0
	-- 五個索引可能有空洞；未學主專業仍須顯示後面的副業。
	for index = 1, 5 do
		local profession = professions[index]
		if profession then
			local name, icon, _, _, _, _, skillLineID = GetProfessionInfo(profession)
			count = count + 1
			local tab = panel.tabs[count]
			if not tab then
				tab = CreateFrame("Frame", nil, panel.frame, "LargeSideTabButtonTemplate")
				tab:EnableMouse(true)
				tab.Icon:SetSize(32, 32)
				tab:SetCustomOnMouseUpHandler(OnTabClick)
				tab:SetScript("OnHide", OnTabHide)
				if count > 1 then tab:SetPoint("TOP", panel.tabs[count - 1], "BOTTOM", 0, 0) end
				panel.tabs[count] = tab
			end
			tab.skillLineID = skillLineID
			tab.isArchaeology = (index == 5)
			tab.tooltipText = name
			tab.Icon:SetTexture(icon)
			tab:Show()
		end
	end
	for index = count + 1, #panel.tabs do panel.tabs[index]:Hide() end
	UpdateCombatState(panel)
	UpdateSelection(panel)
	UpdatePosition(panel)
end

local function AttachPanel(frame, kind)
	local panel = { frame = frame, kind = kind, tabs = {} }
	panels[#panels + 1] = panel
	if kind == "profession" then
		panel.outputLogs = { frame.CraftingPage.CraftingOutputLog, frame.OrdersPage.OrderView.CraftingOutputLog }
		local function UpdateOutputPosition() UpdatePosition(panel) end
		for _, log in ipairs(panel.outputLogs) do
			log:HookScript("OnShow", UpdateOutputPosition)
			log:HookScript("OnHide", UpdateOutputPosition)
		end
	end
	frame:HookScript("OnShow", function() RefreshPanel(panel) end)
	if frame:IsShown() then RefreshPanel(panel) end
end

function M:OnEnable()
	F.RegisterEvent("PLAYER_REGEN_DISABLED", OnCombatChanged)
	F.RegisterEvent("PLAYER_REGEN_ENABLED", OnCombatChanged)
	EventUtil.ContinueOnAddOnLoaded("Blizzard_Professions", function()
		AttachPanel(ProfessionsFrame, "profession")
	end)
	EventUtil.ContinueOnAddOnLoaded("Blizzard_ArchaeologyUI", function()
		AttachPanel(ArchaeologyFrame, "archaeology")
	end)
	EventUtil.ContinueOnAddOnLoaded("Blizzard_ProfessionsBook", function()
		AttachPanel(ProfessionsBookFrame, "book")
	end)
	F.RegisterEvent("SKILL_LINES_CHANGED", function()
		for _, panel in ipairs(panels) do
			if panel.frame:IsShown() then RefreshPanel(panel) end
		end
	end)
	EventRegistry:RegisterCallback("Professions.ProfessionSelected", function()
		for _, panel in ipairs(panels) do
			if panel.frame:IsShown() then UpdateSelection(panel) end
		end
	end, self)
end
