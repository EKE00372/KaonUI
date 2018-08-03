--[[ 聊天設定，輸入/setchat載入，用於拖動後恢復原位 ]]--

local AutoApply = true			-- 每次登入自動套用
local chat_height = 200			-- 聊天框高度
local chat_width = 480			-- 聊天框寬度
local fontsize = 18				-- 字體大小

local SetChat = function()
	for i = 1, NUM_CHAT_WINDOWS do
		local frame = _G[format("ChatFrame%s", i)]
		if i == 1 then
			frame:SetUserPlaced(true)
			frame:ClearAllPoints()
			frame:SetWidth(chat_width)
			frame:SetHeight(chat_height)
			frame:SetPoint("BOTTOMLEFT",UIParent,"BOTTOMLEFT",10,20)
		end
		FCF_SavePositionAndDimensions(frame)
		FCF_SetChatWindowFontSize(self, frame, fontsize)
	end
end
SlashCmdList["SETCHAT"] = SetChat
SLASH_SETCHAT1 = "/setchat"

--[[ 自動套用 ]]--

local AA = CreateFrame("Frame", nil, UIParent)
AA:RegisterEvent("PLAYER_ENTERING_WORLD")
AA:SetScript("OnEvent", function()
	if AutoApply then
		SetChat()
	end
end)

--[[ 私人預設頻道 ]]--

--暗影之月
local Gchat = function()
	JoinTemporaryChannel("組隊頻道")
	ChatFrame_AddChannel(ChatFrame3, "組隊頻道")
	JoinTemporaryChannel("Gruul")
	ChatFrame_AddChannel(ChatFrame1, "Gruul")
	ChatFrame_AddChannel(ChatFrame3, "Gruul")
end
SlashCmdList["GCHAT"] = Gchat
SLASH_GCHAT1 = "/gchat"

--大腳世界頻道(並不用它)
local Dchat = function()
	JoinTemporaryChannel("大腳世界頻道")
	ChatFrame_AddChannel(ChatFrame3, "大腳世界頻道")
end
SlashCmdList["DCHAT"] = Dchat
SLASH_DCHAT1 = "/dchat"