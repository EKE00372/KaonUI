--==============================================--
---------------    [[ Notes ]]     ---------------
--==============================================--

-- Custom Bar Styles
-- https://github.com/BigWigsMods/BigWigs/wiki/Custom-Bar-Styles

--===============================================--
---------------    [[ config ]]     ---------------
--===============================================--

if not BigWigsAPI then return end

local glowTex = "Interface\\AddOns\\RuriWigs\\Media\\glow"
local bgTex = "Interface\\Buttons\\WHITE8X8"

local backdropBorder = {
	bgFile = bgTex,
	edgeFile = glowTex,
	tile = false, tileSize = 0, edgeSize = 3,
	insets = {left = 3, right = 3, top = 3, bottom = 3}
}

--==================================================--
---------------    [[ Functions ]]     ---------------
--==================================================--

local floor = floor

local function removeStyle(bar)
	local cbb = bar.candyBarBar

	bar.candyBarBackdrop:Hide()
	local height = bar:Get("bigwigs:restoreheight")
	if height then
		bar:SetHeight(height)
	end

	local tex = bar:Get("bigwigs:restoreicon")
	if tex then
		bar:SetIcon(tex)
		bar:Set("bigwigs:restoreicon", nil)
		bar.candyBarIconFrameBackdrop:Hide()
	end

	local timer = bar.candyBarDuration
	timer:ClearAllPoints()
	timer:SetPoint("TOPLEFT", cbb, "TOPLEFT", 2, 0)
	timer:SetPoint("BOTTOMRIGHT", cbb, "BOTTOMRIGHT", -2, 0)

	local label = bar.candyBarLabel
	label:ClearAllPoints()
	label:SetPoint("TOPLEFT", cbb, "TOPLEFT", 2, 0)
	label:SetPoint("BOTTOMRIGHT", cbb, "BOTTOMRIGHT", -2, 0)
end

local function styleBar(bar)
	local cbb = bar.candyBarBar

	local height = bar:GetHeight()
	bar:Set("bigwigs:restoreheight", height)
	bar:SetHeight(height/2)

	local bd = bar.candyBarBackdrop
	bd:SetBackdrop(backdropBorder)
	bd:SetBackdropColor(0, 0, 0, .4)
	bd:SetBackdropBorderColor(0, 0, 0, 1)
	bd:ClearAllPoints()
	bd:SetPoint("TOPLEFT", bar, "TOPLEFT", -3, 3)
	bd:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 3, -3)
	bd:Show()

	local tex = bar:GetIcon()
	if tex then
		local icon = bar.candyBarIconFrame
		bar:SetIcon(nil)
		icon:SetTexture(tex)
		icon:Show()
		if bar.iconPosition == "RIGHT" then
			icon:SetPoint("BOTTOMLEFT", bar, "BOTTOMRIGHT", 5, 0)
		else
			icon:SetPoint("BOTTOMRIGHT", bar, "BOTTOMLEFT", -5, 0)
		end
		icon:SetSize(height+2, height+2)
		bar:Set("bigwigs:restoreicon", tex)

		local iconBd = bar.candyBarIconFrameBackdrop
		iconBd:SetBackdrop(backdropBorder)
		iconBd:SetBackdropColor(.15, .15, .15, .4)
		iconBd:SetBackdropBorderColor(0, 0, 0, 1)
		iconBd:ClearAllPoints()
		iconBd:SetPoint("TOPLEFT", icon, "TOPLEFT", -3, 3)
		iconBd:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 3, -3)
		iconBd:Show()
	end
	
	local label = bar.candyBarLabel
	label:SetShadowOffset(0, 0)
	label:ClearAllPoints()
	label:SetPoint("BOTTOMLEFT", cbb, "TOPLEFT", 2, -height/4+2)

	local timer = bar.candyBarDuration
	timer:SetShadowOffset(0, 0)
	timer:ClearAllPoints()
	timer:SetPoint("BOTTOMRIGHT", cbb, "TOPRIGHT", -2, -height/4+2)
	
	bar:SetTexture(bgTex)
end

BigWigsAPI:RegisterBarStyle("Ruri", {
	apiVersion = 1,
	version = 11,
	barHeight = 24,
	GetSpacing = function(bar) return bar:GetHeight()+10 end,
	fontSizeNormal = 14,
	fontSizeEmphasized = 14,
	fontOutline = "OUTLINE",
	ApplyStyle = styleBar,
	BarStopped = removeStyle,
	GetStyleName = function() return "Ruri" end,
})