-- [[ Unitframe ]] --
-- Hide
--[[
hooksecurefunc(	"PlayerFrame_UpdateStatus",	function()
		PlayerStatusTexture:Hide()
		PlayerRestGlow:Hide()
		PlayerStatusGlow:Hide()
		PlayerPrestigeBadge:SetAlpha(0)
		PlayerPrestigePortrait:SetAlpha(0)
		TargetFrameTextureFramePrestigeBadge:SetAlpha(0)
		TargetFrameTextureFramePrestigePortrait:SetAlpha(0)
		FocusFrameTextureFramePrestigeBadge:SetAlpha(0)
		FocusFrameTextureFramePrestigePortrait:SetAlpha(0)
	end
)
]]--

TargetFrame:ClearAllPoints()
TargetFrame:SetPoint("CENTER", UIParent, "CENTER", 350, -200)
TargetFrame.SetPoint = function() end
		
PlayerFrame:ClearAllPoints()
PlayerFrame:SetPoint("CENTER", UIParent, "CENTER", -350, -200)
PlayerFrame.SetPoint = function() end
		
PetFrame:ClearAllPoints()
PetFrame:SetPoint("BOTTOMLEFT", PlayerFrame,"BOTTOMLEFT" , -20, -22)
PetFrame.SetPoint = function() end

-- Bossframe

for i = 1, 5 do
    local BF = _G["Boss"..i.."TargetFrame"]
    BF:SetParent(UIParent)
    BF:SetScale(1.2)
end

for i = 2, 5 do
    _G["Boss"..i.."TargetFrame"]:SetPoint("TOPLEFT", _G["Boss"..(i-1).."TargetFrame"], "BOTTOMLEFT", 0, 0)
end

Boss1TargetFrame:ClearAllPoints() 
Boss1TargetFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 50, -200) 
Boss1TargetFrame.SetPoint = function() end

-- [[ hide bag bar and micro menu bar ]] --

local dummy = function() end
MicroButtonAndBagsBar:Hide()
MicroButtonAndBagsBar.Show = dummy
CharacterMicroButton:ClearAllPoints()
CharacterMicroButton:SetPoint("CENTER", UIParent,"BOTTOMRIGHT", -275, -20)
CharacterMicroButton.SetPoint = dummy

-- [[ achievement frame ]] --
--[[
test marco
/run GarrisonBuildingAlertSystem:AddAlert("miau")
/run GarrisonShipFollowerAlertSystem:AddAlert(592, "Test", "Transport", "GarrBuilding_Barracks_1_H", 3, 2, 1)
/run DigsiteCompleteAlertSystem:AddAlert(1)
/run GuildChallengeAlertSystem:AddAlert(3, 2, 3)
/run CriteriaAlertSystem:ShowAlert(80,1)
/run MoneyWonAlertSystem:AddAlert(815)
/run LootAlertSystem:AddAlert("|cff9d9d9d|Hitem:7073:0:0:0:0:0:0:0:80:0:0:0:0|h[Broken Fang]|h|r", 1, specID, 3, 1, 3, Awesome)
]]--
hooksecurefunc(AlertFrame,"UpdateAnchors", function(self, ...)
	AlertFrame:ClearAllPoints()
	AlertFrame:SetPoint("TOP", UIParent, "TOP", -500, -650)
	AlertFrame:SetScale(0.8)
end)

-- [[ talkinghead frame ]] --

local mode = 3
-- 對話框縮放/移動/隱藏
local frame = CreateFrame("Frame")
function frame:OnEvent(event, addon)
	if addon == "Blizzard_TalkingHeadUI" then
		hooksecurefunc("TalkingHeadFrame_PlayCurrent", function()
			local THF = TalkingHeadFrame
			if mode == 1 then
				THF_CloseImmediately()	-- 隱藏框體與聲音
			elseif mode == 2 then
				THF:Hide()	-- 只隱藏框體
			elseif mode == 3 then
				THF:SetScale(0.7)	-- 縮放和位置
				THF:SetClampedToScreen(true)
				THF.ignoreFramePositionManager = true
				THF:ClearAllPoints()
				THF:SetPoint("CENTER", UIParent, "LEFT", 0, 0)
				THF.TextFrame.Text:SetFont(GameFontNormal:GetFont(), 20, "THINOUTLINE")
				THF.NameFrame.Name:SetFont(GameFontNormal:GetFont(), 20, "THINOUTLINE")
			end
		end)
		self:UnregisterEvent(event)
	end
end
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("MODIFIER_STATE_CHANGED")
frame:SetScript("OnEvent", frame.OnEvent)

-- [[ 非隱藏時，將對話框錨點與alertframe分離 ]] --

hooksecurefunc(AlertFrame, "AddAlertFrameSubSystem", function(self, alertFrameSubSystem)
	if alertFrameSubSystem.anchorFrame == TalkingHeadFrame then
		for i, alertSubSystem in pairs(AlertFrame.alertFrameSubSystems) do
			if alertFrameSubSystem == alertSubSystem then
				tremove(AlertFrame.alertFrameSubSystems, i)
				return 
			end
		end
	end
end)