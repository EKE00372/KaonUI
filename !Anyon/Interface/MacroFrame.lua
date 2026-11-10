local _, ns = ...
local F = ns[2]
local M = F.RegisterModule("MacroFrame", "MacroFrame")

local function WidenMacroFrame()
	if InCombatLockdown() then
		F.RegisterEvent("PLAYER_REGEN_ENABLED", WidenMacroFrame)
		return
	end
	F.UnregisterEvent("PLAYER_REGEN_ENABLED", WidenMacroFrame)

	local frame = MacroFrame
	local selector = frame.MacroSelector
	local columns = 10
	local horizontalSpacing = select(5, selector:GetPadding())
	local extraWidth = (columns - selector:GetStride()) * (selector:GetButtonWidth() + horizontalSpacing)
	selector:SetCustomStride(columns)
	-- 先更新已建立的 view，再由改寬觸發原生 ScrollBox 重新排列。
	if selector.initialized then
		selector.ScrollBox:GetView():SetStride(columns)
	end
	frame:SetSize(frame:GetWidth() + extraWidth, frame:GetHeight() + 100)
	for _, region in ipairs({ selector, MacroHorizontalBarLeft, MacroFrameTextBackground,
		MacroFrameScrollFrame, MacroFrameText, MacroFrameTextButton }) do
		region:SetWidth(region:GetWidth() + extraWidth)
	end
	for _, region in ipairs({ MacroFrameTextBackground, MacroFrameScrollFrame, MacroFrameTextButton }) do
		region:SetHeight(region:GetHeight() + 100)
	end
	MacroPopupFrame:UpdateMacroFramePanelWidth(MacroPopupFrame:IsShown())
end

function M:OnEnable()
	EventUtil.ContinueOnAddOnLoaded("Blizzard_MacroUI", WidenMacroFrame)
end
