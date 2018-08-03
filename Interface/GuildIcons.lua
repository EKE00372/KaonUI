--[[

	GuildIcons
	by Ailae of Emeriss-EU
	
]]
if not IsAddOnLoaded("Blizzard_GuildUI") then LoadAddOn("Blizzard_GuildUI") end

local addon, GuildIcons = ...

local categories = { "playerStatus", "guildStatus", "achievement", "tradeskill", "reputation" }
local icons = {
	"Interface\\ICONS\\ACHIEVEMENT_GUILDPERK_FASTTRACK",
	"Interface\\COMMON\\icon-"..strlower(UnitFactionGroup("player")),
	"Interface\\ICONS\\Achievement_Quests_Completed_06",
	"Interface\\SPELLBOOK\\Spellbook-Icon",
	"Interface\\ICONS\\Achievement_Reputation_01",
}
local headers = { PLAYER_STATUS, GUILD_STATUS, ACHIEVEMENT_POINTS, TRADE_SKILLS, GUILD_REPUTATION }
local BUTTONS = {}
local size = 26
GuildRosterViewDropdown:Hide()

local function onEnter(f)
	GameTooltip:SetOwner(f, "ANCHOR_RIGHT", f:GetWidth()/-2, 5)
	GameTooltip:AddLine(f.header)
	GameTooltip:Show()	
end

local function onLeave(f)
	GameTooltip:Hide()
end

local function onClick(f)
	SetCVar("guildRosterView", f.page)
	GuildRoster_SetView(f.page)
	GuildRoster()
	GuildRoster_Update()
	
	for i=1, #BUTTONS do
		BUTTONS[i]:SetChecked(BUTTONS[i] == f and true or false)
	end
end

for i=1, #categories do 
	local t = CreateFrame("CheckButton", nil, GuildRosterFrame)
	t:SetSize(size, size)
	t:RegisterForClicks("anyUp")
	t:EnableMouse(true)

	local normal = t:CreateTexture()
	normal:SetTexture("Interface\\Buttons\\UI-Quickslot2")
	normal:SetWidth(64 * size/36)
	normal:SetHeight(64 * size/36)
	normal:SetPoint("CENTER", 0, -1)
	t:SetNormalTexture(normal)
	
	local pushed = t:CreateTexture()
	pushed:SetTexture("Interface\\Buttons\\UI-Quickslot-Depress")
	pushed:SetAllPoints(t)
	t:SetPushedTexture(pushed)

	local highlight = t:CreateTexture()
	highlight:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
	highlight:SetAllPoints(t)
	t:SetHighlightTexture(highlight)

	local checked = t:CreateTexture()
	checked:SetTexture("Interface\\Buttons\\CheckButtonHilight")
	checked:SetAllPoints(t)
	checked:SetBlendMode("ADD")
	t:SetCheckedTexture(checked)
	
	local icon = t:CreateTexture()
	icon:SetAllPoints(t)
	icon:SetTexCoord(4/64, 60/64, 4/64, 60/64)
	icon:SetTexture(icons[i])
	
	t.header = headers[i]
	t.page = categories[i]
	
	t:SetChecked(GetCVar("guildRosterView") == t.page and true or false)
	t:SetScript("OnEnter", onEnter)
	t:SetScript("OnLeave", onLeave)
	t:SetScript("OnClick", onClick)
	
	table.insert(BUTTONS, t)
	
	if i == 1 then
		t:SetPoint("LEFT", GuildFrame.portrait, "BOTTOMRIGHT", 35, 7)
	else
		t:SetPoint("LEFT", BUTTONS[i-1], "RIGHT", 6, 0)
	end
end

GuildRosterShowOfflineButton:SetSize(26, 26)
GuildRosterShowOfflineButton:ClearAllPoints()
GuildRosterShowOfflineButton:SetPoint("LEFT", BUTTONS[#BUTTONS], "RIGHT", 8, 0)
GuildRosterShowOfflineButton.header = SHOW_OFFLINE_MEMBERS
GuildRosterShowOfflineButton:SetScript("OnEnter", onEnter)
GuildRosterShowOfflineButton:SetScript("OnLeave", onLeave)
local t = GuildRosterShowOfflineButton:GetRegions()
t:SetText("")