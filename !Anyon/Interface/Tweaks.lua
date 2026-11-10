local CinematicFrame = CinematicFrame
local DELETE_ITEM_CONFIRM_STRING = DELETE_ITEM_CONFIRM_STRING

-- [[ Hide talent alerts ]]--

do
	-- Function to hide talent alerts
	local function HideAlert(microButton)
		-- Only hide alerts for the PlayerSpellsMicroButton
		if microButton == PlayerSpellsMicroButton then
			MainMenuMicroButton_HideAlert(microButton)
		end
	end

	-- Function to stop pulse animations on the talent button
	local function HidePulse(microButton)
		-- Only stop pulse for the PlayerSpellsMicroButton
		if microButton == PlayerSpellsMicroButton then
			MicroButtonPulseStop(microButton)
		end
	end

	-- Hook the alert and pulse functions securely to avoid taint
	hooksecurefunc("MainMenuMicroButton_ShowAlert", HideAlert)
	hooksecurefunc("MicroButtonPulse", HidePulse)
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
	local function FillDeleteConfirmText(dialog)
		-- SetText 會經由原生 OnTextChanged 執行確認檢查。
		dialog:GetEditBox():SetText(DELETE_ITEM_CONFIRM_STRING)
	end

	local function HookDeleteDialog(dialogKey)
		hooksecurefunc(StaticPopupDialogs[dialogKey], "OnShow", FillDeleteConfirmText)
	end

	HookDeleteDialog("DELETE_GOOD_ITEM")
	HookDeleteDialog("DELETE_GOOD_QUEST_ITEM")
end
