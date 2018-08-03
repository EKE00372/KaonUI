local frame = CreateFrame("Frame")
local addonName = ...

BetterBlizzOptionsResizeGrip = BetterBlizzOptionsResizeGrip or CreateFrame("Frame", "BetterBlizzOptionsResizeGrip", InterfaceOptionsFrame)
BetterBlizzOptionsResizeGrip:Hide()
BetterBlizzOptionsResizeGrip.Show = function() end

local HandleBase = {}
function HandleBase:OnUpdate()
	local uiScale = UIParent:GetScale()
	local frame = self:GetParent()
	local cursorX, cursorY = GetCursorPosition(UIParent)

	-- calculate new scale
	local newXScale = frame.oldScale * (cursorX/uiScale - frame.oldX*frame.oldScale) / (self.oldCursorX/uiScale - frame.oldX*frame.oldScale)
	local newYScale = frame.oldScale * (cursorY/uiScale - frame.oldY*frame.oldScale) / (self.oldCursorY/uiScale - frame.oldY*frame.oldScale)
	local newScale = min(2, max(0.4, newXScale, newYScale))
	frame:SetScale(newScale)
	ImprovedOptionsFramesDB[frame:GetName()] = newScale

	-- calculate new frame position
	local newX = frame.oldX * frame.oldScale / newScale
	local newY = frame.oldY * frame.oldScale / newScale
	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", newX, newY)
end
function HandleBase:OnMouseDown()
	local frame = self:GetParent()
	frame.oldScale = frame:GetScale()
	self.oldCursorX, self.oldCursorY = GetCursorPosition(UIParent)
	frame.oldX = frame:GetLeft()
	frame.oldY = frame:GetTop()
	self:SetScript("OnUpdate", HandleBase.OnUpdate)
end
function HandleBase:OnMouseUp()
	self:SetScript("OnUpdate", nil)
end
function HandleBase:OnEnter()
	self.tex:SetVertexColor(1, 1, 1)
end
function HandleBase:OnLeave()
	self.tex:SetVertexColor(0.6, 0.6, 0.6)
end


local function MakeFrameScalable(parent, x, y)
	local handle = CreateFrame("Frame", nil, parent)
	handle:EnableMouse(true)
	handle:SetSize(25, 25)
	handle:SetPoint("BOTTOMRIGHT", parent, x, y)
	frame.SetScale = handle.SetScale -- MoveAnything might be locking this down if the user has scaled the frame with MoveAnything. It only hooks in the metatable, though, so this should always work.

	handle.tex = handle:CreateTexture()
	handle.tex:SetTexture("Interface\\AddOns\\EKCore\\Media\\Resize")
	handle.tex:SetVertexColor(0.6, 0.6, 0.6)
	handle.tex:SetAllPoints()

	for k, v in pairs(HandleBase) do
		handle:SetScript(k, v)
	end
	handle:SetScript("OnUpdate", nil)
end

local function MakeFrameMovable(f)
	if not f then return end
	f:EnableMouse(true)
	f:SetMovable(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", function() f:StartMoving() end)
	f:SetScript("OnDragStop", function() 
		f:StopMovingOrSizing() 
	end)
	if ImprovedOptionsFramesDB[f:GetName()] then
		f:SetScale(ImprovedOptionsFramesDB[f:GetName()])
	end
end

local wow_600 = select(4, GetBuildInfo()) >= 60000
frame:RegisterEvent("ADDON_LOADED")
function frame:OnEvent(event, addon)
	if addon == addonName then
		ImprovedOptionsFramesDB = ImprovedOptionsFramesDB or {}
		
		MakeFrameScalable(InterfaceOptionsFrame)
		MakeFrameMovable(InterfaceOptionsFrame)
		
		MakeFrameScalable(VideoOptionsFrame)
		MakeFrameMovable(VideoOptionsFrame)
		
		MakeFrameScalable(HelpFrame)
		MakeFrameMovable(HelpFrame)
		
		if wow_600 then
			MakeFrameScalable(AddonList, 4, -4)
			MakeFrameMovable(AddonList)
		end
		
		if IsAddOnLoaded("Blizzard_BindingUI") then
			self:OnEvent(event, "Blizzard_BindingUI")
		end
	elseif addon == "Blizzard_BindingUI" then
		if wow_600 then
			MakeFrameScalable(KeyBindingFrame)
		else
			MakeFrameScalable(KeyBindingFrame, -42, 10)
		end
		MakeFrameMovable(KeyBindingFrame)
	end
end
frame:SetScript("OnEvent", frame.OnEvent)




if not InterfaceOptionsFrameAddOns:IsMouseWheelEnabled() then
	local ScrollBar = InterfaceOptionsFrameAddOnsListScrollBar
	InterfaceOptionsFrameAddOns:EnableMouseWheel(true)
	InterfaceOptionsFrameAddOns:SetScript("OnMouseWheel", function(self, dir)
		ScrollBar:SetValue(ScrollBar:GetValue() - (dir * InterfaceOptionsFrameAddOnsButton1:GetHeight()))
	end)
end
