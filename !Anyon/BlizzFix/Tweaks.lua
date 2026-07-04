local addon, ns = ... 
local C, F, G, L = unpack(ns)

local strfind = string.find
local ShouldShowName, GetUnitName, CompactPartyFrame = ShouldShowName, GetUnitName, CompactPartyFrame
local ScrollFrameTemplate, EnableMouseWheel = ScrollFrameTemplate, EnableMouseWheel
local CinematicFrame = CinematicFrame
local DELETE_GOOD_ITEM, DELETE_ITEM_CONFIRM_STRING = DELETE_GOOD_ITEM, DELETE_ITEM_CONFIRM_STRING
local MicroButtonAndBagsBar, CharacterMicroButton = MicroButtonAndBagsBar, CharacterMicroButton

-- [[ Better Compactraid / 暴雪團隊框架強化 ]] --

do
	if not C.BetterRaid then return end
	
	-- Change debuff icon size
	hooksecurefunc("CompactUnitFrame_UpdateAuras", function(frame)
		if frame:IsForbidden() or strfind(frame.unit, "nameplate") then return end
		
		if not frame.debuffFrames then return end
		for i = 1, #frame.debuffFrames do
			local debuff = frame.debuffFrames[i]
			
			if debuff and (debuff.SetScale or debuff.SetSize) and debuff:IsShown() then
				debuff.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
				debuff.baseSize = 20
				debuff:SetScale(1)
			end
		end
	end)
	
	-- Hide Compactraid Frame realm name
	hooksecurefunc("CompactUnitFrame_UpdateName", function(frame)
		--if frame:IsForbidden() or strfind(frame.unit, "nameplate") then return end
		if frame:IsForbidden() then return end
		
		if not ShouldShowName(frame) then
			frame.name:Hide()
		else
			local fontName, fontSize, fontFlags = frame.name:GetFont()
			
			frame.name:SetText(GetUnitName(frame.unit, false))
			frame.name:SetFont(fontName, fontSize, "OUTLINE")
			frame.name:SetShadowOffset(0, 0)
			frame.name:Show()
		end
	end)
	
	-- Hide Compactraid Frame raid group name
	hooksecurefunc("CompactRaidGroup_InitializeForGroup", function(frame)
        if frame then
            frame.title:Hide()
        end
    end)

	-- Hide Compactraid Frame party group name
    hooksecurefunc("CompactPartyFrame_OnLoad", function(frame)
        if frame and frame.title then
			frame.title:Hide()
        end
    end)
end

-- [[ Hide talent alerts ]]--

do
	function MainMenuMicroButton_AreAlertsEffectivelyEnabled()
		return false
	end
end

-- [[ Bypass the buggy cancel cinematic confirmation dialog ]] --

do
	hooksecurefunc(CinematicFrame.closeDialog, "Show", function()
		CinematicFrame.closeDialog:Hide()
		CinematicFrame_CancelCinematic()
	end)
end

-- [[ Auto type delete ]] --

do
	hooksecurefunc(StaticPopupDialogs["DELETE_GOOD_ITEM"], "OnShow", function(boxEditor)
		boxEditor.editBox:SetText(DELETE_ITEM_CONFIRM_STRING)
	end)
end

-- [[ hide bag bar and micro menu bar ]] --

do
	if not C.DummyBar then return end
	
	MicroButtonAndBagsBar:Hide()
	MicroButtonAndBagsBar:UnregisterAllEvents()
end