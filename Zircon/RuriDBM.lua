-- DBM timer bar skin.

local glowTex = "Interface\\AddOns\\RuriWigs\\Media\\glow"
local bgTex = "Interface\\Buttons\\WHITE8X8"
local iconSize = 24
local barHeight = iconSize
local barTextureHeight = iconSize / 2
-- DBM 的 BarYOffset/HugeBarYOffset 是計時條之間的垂直間距。
local barSpacing = barHeight / 4

-- Mainline vs Classic
local function IsAddOnReady(addonName)
	if C_AddOns and C_AddOns.IsAddOnLoaded then
		return C_AddOns.IsAddOnLoaded(addonName)
	end

	return IsAddOnLoaded(addonName)
end

-- Custom API
local function CreateSD(parent, anchor, size)
	if not parent or not anchor then return end

	local sd = CreateFrame("Frame", nil, parent, "BackdropTemplate")
	local frameLevel = parent:GetFrameLevel() or 0

	sd:ClearAllPoints()
	sd:SetPoint("TOPLEFT", anchor, -size, size)
	sd:SetPoint("BOTTOMRIGHT", anchor, size, -size)
	sd:SetFrameLevel(frameLevel == 0 and 0 or frameLevel - 1)
	sd:SetBackdrop({
		edgeFile = glowTex,
		edgeSize = size or 3,
	})
	sd:SetBackdropBorderColor(0, 0, 0, 1)

	return sd
end

-- Hide spark
local function HideSpark(bar)
	local frame = bar and bar.frame
	if not frame then return end

	local spark = _G[frame:GetName().."BarSpark"]
	if not spark then return end

	spark:SetAlpha(0)
	spark:SetTexture(nil)
end

-- DBM 的 icon 是 Texture 不能直接套 Backdrop，必需用 holder frame 承載陰影
local function SkinIcon(icon, tbar, point, relativePoint, xOffset)
	if not icon or not tbar then return end

	local holder = icon.RuriHolder
	if not holder then
		holder = CreateFrame("Frame", nil, tbar, "BackdropTemplate")
		holder:SetFrameStrata("BACKGROUND")
		holder:SetSize(iconSize, iconSize)
		icon.RuriHolder = holder
	end

	holder:ClearAllPoints()
	holder:SetPoint(point, tbar, relativePoint, xOffset, -2)
	holder:SetSize(iconSize, iconSize)

	icon:ClearAllPoints()
	icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	icon:SetPoint("TOPLEFT", holder, 2, -2)
	icon:SetPoint("BOTTOMRIGHT", holder, -2, 2)

	if not holder.Shadow then
		holder.Shadow = CreateSD(holder, icon, 3)
	end
end

-- 按 DBM 選項決定圖示位置並同步處理 holder
local function SetIconShown(icon, shown)
	if not icon then return end

	if shown then
		icon:Show()
		if icon.RuriHolder then
			icon.RuriHolder:Show()
		end
	else
		icon:Hide()
		if icon.RuriHolder then
			icon.RuriHolder:Hide()
		end
	end
end

-- 調整外觀與定位
local function ApplyRuriStyle(bar)
	local frame = bar and bar.frame
	if not frame then return end

	local frameName = frame:GetName()
	local opts = (bar.owner and bar.owner.Options) or DBT.Options
	if not opts then return end

	local tbar = _G[frameName.."Bar"]
	local icon1 = _G[frameName.."BarIcon1"]
	local icon2 = _G[frameName.."BarIcon2"]
	local name = _G[frameName.."BarName"]
	local timer = _G[frameName.."BarTimer"]
	if not tbar or not name or not timer then return end

	local width = bar.enlarged and opts.HugeWidth or opts.Width

	frame:SetScale(1)
	frame:SetSize(width, barHeight)

	tbar:ClearAllPoints()
	tbar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 2, 2)
	tbar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 2)
	tbar:SetHeight(barTextureHeight)
	tbar:SetStatusBarTexture(bgTex)

	if not tbar.RuriShadow then
		tbar.RuriShadow = CreateSD(tbar, tbar, 3)
	end

	SkinIcon(icon1, tbar, "BOTTOMRIGHT", "BOTTOMLEFT", -5)
	SkinIcon(icon2, tbar, "BOTTOMLEFT", "BOTTOMRIGHT", 5)
	SetIconShown(icon1, opts.IconLeft)
	SetIconShown(icon2, opts.IconRight)

	name:ClearAllPoints()
	name:SetPoint("BOTTOMLEFT", tbar, "TOPLEFT", 2, -iconSize / 4 + 2)
	name:SetWidth(165)
	name:SetShadowOffset(0, 0)
	name:SetJustifyH("LEFT")
	name:SetWordWrap(false)

	timer:ClearAllPoints()
	timer:SetPoint("BOTTOMRIGHT", tbar, "TOPRIGHT", -2, -iconSize / 4 + 2)
	timer:SetShadowOffset(0, 0)
	timer:SetJustifyH("RIGHT")

	HideSpark(bar)

	frame:SetAlpha(1)
	frame:Show()
end

-- 在 DBT:CreateBar 之後套用樣式，每個計時條只 hook 一次以避免重複
local function SkinBars(timerObject)
	for bar in timerObject:GetBarIterator() do
		if not bar.RuriInjected then
			hooksecurefunc(bar, "ApplyStyle", ApplyRuriStyle)
			hooksecurefunc(bar, "Update", HideSpark)
			bar.RuriInjected = true
		end

		ApplyRuriStyle(bar)
	end
end

-- DBM official skin API
local function RegisterRuriSkin()
	if not DBT or not DBT.RegisterSkin or not DBT.SetSkin then return end

	local skins = DBT.GetSkins and DBT:GetSkins()
	local skin = skins and skins.Ruri
	if not skin then
		skin = DBT:RegisterSkin("Ruri")
	end

	skin.Defaults.Height = barHeight
	skin.Defaults.HugeHeight = barHeight
	skin.Defaults.Texture = bgTex
	skin.Defaults.FontFlag = "OUTLINE"
	skin.Defaults.Spark = false
	skin.Defaults.BarYOffset = barSpacing
	skin.Defaults.HugeBarYOffset = barSpacing

	skin.Options.Height = barHeight
	skin.Options.HugeHeight = barHeight
	skin.Options.Texture = bgTex
	skin.Options.FontFlag = "OUTLINE"
	skin.Options.Spark = false
	skin.Options.IconLocked = true
	skin.Options.BarYOffset = barSpacing
	skin.Options.HugeBarYOffset = barSpacing
	skin.Options.Scale = 1
	skin.Options.HugeScale = 1

	DBT:SetSkin("Ruri")
	return true
end

local initialized
-- 等 DBM-Core 與 DBM-StatusBarTimers 載入後再註冊，並全局只初始化一次
local function EnableRuriDBM()
	if initialized then return end
	if not IsAddOnReady("DBM-Core") or not DBT then return end
	if not RegisterRuriSkin() then return end

	hooksecurefunc(DBT, "CreateBar", SkinBars)
	SkinBars(DBT)

	initialized = true
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", function(_, event, addonName)
	if event == "PLAYER_LOGIN" or addonName == "DBM-Core" or addonName == "DBM-StatusBarTimers" then
		EnableRuriDBM()
	end
end)

EnableRuriDBM()
