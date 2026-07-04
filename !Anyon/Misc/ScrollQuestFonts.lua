local QuestMapDetailsScrollFrame, QuestFrame, GossipFrame = QuestMapDetailsScrollFrame, QuestFrame, GossipFrame
local font, size, style = QuestFont:GetFont()
local font2, size2, style2 = QuestFontNormalSmall:GetFont()

local function Scroll(self, button)
	if IsControlKeyDown() and (button == -1 or button == 1) then
		size = size + (-1 * button)
		size2 = size2 + (-1 * button)
		QuestFont:SetFont(ChatFontNormal:GetFont(), size, style)
		QuestFontNormalSmall:SetFont(ChatFontNormal:GetFont(), size2, style2)
	end
end

QuestMapDetailsScrollFrame:SetScript("OnMouseWheel", Scroll)
--QuestFrame.NineSlice:SetScript("OnMouseWheel", Scroll)
_G["QuestFrame"]:SetScript("OnMouseWheel", Scroll)
_G["GossipFrame"]:SetScript("OnMouseWheel", Scroll)
--GossipFrame.NineSlice:SetScript("OnMouseWheel", Scroll)
