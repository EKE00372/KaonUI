local _, ns = ...
local F = ns[2]
local M = F.RegisterModule("TalkingHead", "TalkingHeadMode")

local C_AddOns_IsAddOnLoaded, hooksecurefunc = C_AddOns.IsAddOnLoaded, hooksecurefunc

local MODE_SCALE, MODE_HIDE, FRAME_SCALE = 1, 2, 0.6

-- 修改對話頭像
local function ApplyTalkingHeadMode(frame)
	local mode = F.GetSetting("TalkingHeadMode")

	if mode == MODE_HIDE then
		frame:CloseImmediately()	-- 隱藏框體 + 停止語音
	elseif mode == MODE_SCALE then
		frame:SetScale(FRAME_SCALE)
	end
end

-- 套用修改
local function SetupTalkingHead()
	ApplyTalkingHeadMode(TalkingHeadFrame)
	hooksecurefunc(TalkingHeadFrame, "PlayCurrent", ApplyTalkingHeadMode)
end

-- Blizzard_TalkingHeadUI 是按需載入
local function OnAddonLoaded(event, loadedAddon)
	if loadedAddon ~= "Blizzard_TalkingHeadUI" then return end

	SetupTalkingHead()
	F.UnregisterEvent(event, OnAddonLoaded)
end

function M:OnEnable()
	if C_AddOns_IsAddOnLoaded("Blizzard_TalkingHeadUI") then
		SetupTalkingHead()
	else
		F.RegisterEvent("ADDON_LOADED", OnAddonLoaded)
	end
end
