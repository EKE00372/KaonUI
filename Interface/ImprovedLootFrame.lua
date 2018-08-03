
-- --------------------------
-- Improved Loot Frame
-- By Cybeloras of Detheroc/Mal'Ganis
-- --------------------------

local LovelyLootLoaded = IsAddOnLoaded("LovelyLoot")
local ISMOP = select(4, GetBuildInfo()) >= 50000
local ISWOD = select(4, GetBuildInfo()) >= 60000


if ISWOD then
	LOOTFRAME_AUTOLOOT_DELAY = 0.5;
	LOOTFRAME_AUTOLOOT_RATE = 0.1;
end

if not LovelyLootLoaded then

	-- Woah, nice coding, blizz.
	-- Anchor something positioned at the top of the frame to the center of the frame instead,
	-- and make it an anonymous font string so I have to work to find it
	local i, t = 1, "Interface\\LootFrame\\UI-LootPanel"

	while true do
		local r = select(i, LootFrame:GetRegions())
		if not r then break end
		if r.GetText and r:GetText() == ITEMS then
			r:ClearAllPoints()
			r:SetPoint("TOP", ISMOP and 12 or -12, ISMOP and -5 or -19.5)
		elseif not ISMOP and r.GetTexture and r:GetTexture() == t then
			r:Hide()
		end
		i = i + 1
	end

	if not ISMOP then
		local top = LootFrame:CreateTexture("LootFrameBackdropTop")
		top:SetTexture(t)
		top:SetTexCoord(0, 1, 0, 0.3046875)
		top:SetPoint("TOP")
		top:SetHeight(78)

		local bottom = LootFrame:CreateTexture("LootFrameBackdropBottom")
		bottom:SetTexture(t)
		bottom:SetTexCoord(0, 1, 0.9296875, 1)
		bottom:SetPoint("BOTTOM")
		bottom:SetHeight(18)

		local mid = LootFrame:CreateTexture("LootFrameBackdropMiddle")
		mid:SetTexture(t)
		mid:SetTexCoord(0, 1, 0.3046875, 0.9296875)
		mid:SetPoint("TOP", top, "BOTTOM")
		mid:SetPoint("BOTTOM", bottom, "TOP")
	end
end

-- Calculate base height of the loot frame
local p, r, x, y = "TOP", "BOTTOM", 0, -4
local buttonHeight = LootButton1:GetHeight() + abs(y)
local baseHeight = LootFrame:GetHeight() - (buttonHeight * LOOTFRAME_NUMBUTTONS)
if ISMOP and not LovelyLootLoaded then
	baseHeight = baseHeight - 5
end

LootFrame.OverflowText = LootFrame:CreateFontString(nil, "OVERLAY", "GameFontRedSmall")
local OverflowText = LootFrame.OverflowText

OverflowText:SetPoint("TOP", LootFrame, "TOP", 0, -26)
OverflowText:SetPoint("LEFT", LootFrame, "LEFT", 60, 0)
OverflowText:SetPoint("RIGHT", LootFrame, "RIGHT", -8, 0)
OverflowText:SetPoint("BOTTOM", LootFrame, "TOP", 0, -65)

if LovelyLootLoaded then
	OverflowText:SetPoint("LEFT", LootFrame, "RIGHT", 10, 0)
	OverflowText:SetPoint("RIGHT", LootFrame, "RIGHT", -10 + LootFrame:GetWidth(), 0)
end

OverflowText:SetSize(1, 1)

OverflowText:SetJustifyH("LEFT")
OverflowText:SetJustifyV("TOP")

OverflowText:SetText("Hit 50-mob limit! Take some, then re-loot for more.")

OverflowText:Hide()

local t = {}
local function CalculateNumMobsLooted()
	wipe(t)

	for i = 1, GetNumLootItems() do
		for n = 1, select("#", GetLootSourceInfo(i)), 2 do
			local GUID, num = select(n, GetLootSourceInfo(i))
			t[GUID] = true
		end
	end

	local n = 0
	for k, v in pairs(t) do
		n = n + 1
	end

	return n
end


local old_LootFrame_Show = LootFrame_Show
function LootFrame_Show(self, ...)
	local maxButtons = floor(UIParent:GetHeight()/LootButton1:GetHeight() * 0.7)
	
	local num = GetNumLootItems()

	if ISWOD then
		if self.AutoLootTable then
			num = #self.AutoLootTable
		end

		self.AutoLootDelay = 0.4 + (num * 0.05)
	end

	num = min(num, maxButtons)

	LootFrame:SetHeight(baseHeight + (num * buttonHeight))
	for i = 1, num do
		if i > LOOTFRAME_NUMBUTTONS then
			local button = _G["LootButton"..i]
			if not button then
				button = CreateFrame("Button", "LootButton"..i, LootFrame, "LootButtonTemplate", i)
			end
			LOOTFRAME_NUMBUTTONS = i
		end
		if i > 1 then
			local button = _G["LootButton"..i]
			button:ClearAllPoints()
			button:SetPoint(p, "LootButton"..(i-1), r, x, y)
		end
	end

	if CalculateNumMobsLooted() >= 50 then
		OverflowText:Show()
	else
		OverflowText:Hide()
	end

	
	return old_LootFrame_Show(self, ...)
end



-- It seems the the taint is no longer an issue, so this code has been commented out.

-- the following is inspired by http://us.battle.net/wow/en/forum/topic/2353268564 and is hacktastic
-- local framesRegistered = {}
-- local function populateframesRegistered(...)
-- 	wipe(framesRegistered)
-- 	for i = 1, select("#", ...) do
-- 		framesRegistered[i] = select(i, ...)
-- 	end
-- end

-- local old_LootButton_OnClick = LootButton_OnClick
-- function LootButton_OnClick(self, ...)
-- 	populateframesRegistered(GetFramesRegisteredForEvent("ADDON_ACTION_BLOCKED"))
	
-- 	-- Blizzard throws a false taint error when attemping to loot
-- 	-- coins from a mob when the coins are the only loot on the mob
-- 	for i, frame in pairs(framesRegistered) do
-- 		frame:UnregisterEvent("ADDON_ACTION_BLOCKED") 
-- 	end
	
-- 	old_LootButton_OnClick(self, ...)
	
-- 	for i, frame in pairs(framesRegistered) do
-- 		frame:RegisterEvent("ADDON_ACTION_BLOCKED")
-- 	end
-- end
