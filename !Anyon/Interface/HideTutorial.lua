local _, ns = ...
local _, F = unpack(ns)
local M = F.RegisterModule("HideTutorial", "HideTutorial")
local C_CVar = C_CVar
local NUM_LE_FRAME_TUTORIALS = 163

function M:OnEnable()
	-- 關閉教學設定
	C_CVar.SetCVar("showTutorials", 0)
	C_CVar.SetCVar("showNPETutorials", 0)

	-- 將船塢、駐防與職業大廳任務教學標為已看過
	C_CVar.SetCVar("shipyardMissionTutorialFirst", 1)
	C_CVar.SetCVar("shipyardMissionTutorialBlockade", 1)
	C_CVar.SetCVar("shipyardMissionTutorialAreaBuff", 1)
	C_CVar.SetCVar("lastGarrisonMissionTutorial", 4294934528)
	C_CVar.SetCVar("orderHallMissionTutorial", 4294934528)

	-- 逐項補齊角色與帳號教學紀錄，已關閉的項目不重寫
	for i = 1, NUM_LE_FRAME_TUTORIALS do
		if not C_CVar.GetCVarBitfield("closedInfoFrames", i) then
			C_CVar.SetCVarBitfield("closedInfoFrames", i, true)
		end
	end

	for _, i in pairs(Enum.FrameTutorialAccount) do
		if not C_CVar.GetCVarBitfield("closedInfoFramesAccountWide", i) then
			C_CVar.SetCVarBitfield("closedInfoFramesAccountWide", i, true)
		end
	end
end
