local addon, ns = ...
local C, F, G, L = unpack(ns)
local M = F.RegisterModule("HideTutorial", "HideTutorial")
local C_CVar = C_CVar
local CreateFrame = CreateFrame

-- Fallback values are used only if Blizzard globals are unavailable.
local NUM_LE_FRAME_TUTORIALS = NUM_LE_FRAME_TUTORIALS or 163
local NUM_LE_FRAME_TUTORIAL_ACCCOUNTS = NUM_LE_FRAME_TUTORIAL_ACCCOUNTS or 49

function M:OnEnable()
	local function OnEvent()
		C_CVar.SetCVar("showTutorials", 0)
		C_CVar.SetCVar("showNPETutorials", 0)

		-- Avoid rewriting the whole bitfield if the last known tutorial is already closed.
		if not C_CVar.GetCVarBitfield("closedInfoFrames", NUM_LE_FRAME_TUTORIALS) then
			for i = 1, NUM_LE_FRAME_TUTORIALS do
				C_CVar.SetCVarBitfield("closedInfoFrames", i, true)
			end
		end

		if not C_CVar.GetCVarBitfield("closedInfoFramesAccountWide", NUM_LE_FRAME_TUTORIAL_ACCCOUNTS) then
			for i = 1, NUM_LE_FRAME_TUTORIAL_ACCCOUNTS do
				C_CVar.SetCVarBitfield("closedInfoFramesAccountWide", i, true)
			end
		end
	end

	local f = CreateFrame("Frame")
	f:RegisterEvent("VARIABLES_LOADED")
	f:SetScript("OnEvent", OnEvent)
end
