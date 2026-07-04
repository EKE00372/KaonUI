local addon, ns = ... 
local C, F, G, L = unpack(ns)
if not C.AutoTKH then return end

local function OnEvent(self, event, addon, ...)
	if addon == "Blizzard_TalkingHeadUI" then
		hooksecurefunc("TalkingHeadFrame_PlayCurrent", function()
			local TalkingHeadFrame = TalkingHeadFrame
			
			if C.TKHMode == 1 then
				TalkingHeadFrame_CloseImmediately()	-- 隱藏框體與聲音
			elseif C.TKHMode == 2 then
				TalkingHeadFrame:Hide()				-- 只隱藏框體
			else
				return
			end
		end)
		
		self:UnregisterEvent(event)
	end
end

local frame = CreateFrame("Frame")
	frame:RegisterEvent("ADDON_LOADED")
	frame:SetScript("OnEvent", OnEvent)