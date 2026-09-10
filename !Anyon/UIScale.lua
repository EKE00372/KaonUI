local _, ns = ...
local F = ns[2]
local M = F.RegisterModule("UIScale", "UIScale")

--=================================================--
-----------------    [[ Scale ]]    -----------------
--=================================================--

-- [[ Set UI scale ]] --
-- https://www.wowinterface.com/forums/showthread.php?p=328597

local SetCVar = C_CVar.SetCVar

local frame
local pendingScale = false
local isScaling = false

-- 直接按螢幕高度計算縮放，不提前四捨五入或取整。
local function GetBasePixelScale()
	local _, height = GetPhysicalScreenSize()
	if not height or height == 0 then
		return UIParent and UIParent:GetScale() or 1
	end

	return 768 / height
end

-- 全局 API：為 GUI tooltip 顯示目前解析度的最適縮放比
F.GetUIScaleValue = function()
	local Scale = GetBasePixelScale()

	if Scale >= 1 then
		return 1
	elseif Scale >= 0.65 then
		return Scale
	elseif Scale > 0.5 then
		return Scale
	else
		return Scale*2
	end
end

local function SetUIScale()
	-- 戰鬥中延遲載入
	if InCombatLockdown() then
		pendingScale = true
		frame:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	end
	pendingScale = false
	frame:UnregisterEvent("PLAYER_REGEN_ENABLED")

	-- 取得縮放值
	local Scale = GetBasePixelScale()

	-- 縮放
	SetCVar("useUiScale", "1")
	if Scale >=1 then
		-- 大於1就固定1
		SetCVar("uiScale", 1)
	elseif Scale >= 0.65 then
		-- 使用 cvar 的區間
		SetCVar("uiScale", Scale)
	elseif Scale > 0.5 then
		-- 使用 UIParent 的區間： 小於0.65且大於0.5
		SetCVar("uiScale", 1)
		UIParent:SetScale(Scale)
	else
		-- 超高解析度：二倍縮放
		SetCVar("uiScale", Scale*2)
	end
end

-- 防止無限循環
local function UpdatePixelScale(self, event)
	if isScaling then return end

	if event == "PLAYER_REGEN_ENABLED" and not pendingScale then
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		return
	end

	isScaling = true
	SetUIScale()
	isScaling = false
end

function M:OnEnable()
	frame = CreateFrame("Frame")
	frame:RegisterEvent("UI_SCALE_CHANGED")
	--frame:RegisterEvent("DISPLAY_SIZE_CHANGED")
	frame:SetScript("OnEvent", UpdatePixelScale)

	-- Init.lua 已經統一在 PLAYER_LOGIN 啟用模組，這裡直接先套用一次。
	UpdatePixelScale(frame, "PLAYER_LOGIN")
end
