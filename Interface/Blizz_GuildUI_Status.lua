-- To show online/offline icons, set ShowAllIcons from "false" to "true"
local ShowAllIcons = false

-- ------------------------------------------------------------------
-- DO NOT EDIT BELOW UNLESS YOU KNOW WHAT YOU ARE DOING -------------
-- ------------------------------------------------------------------

local MOBILE_AWAY_ICON = "|TInterface\\ChatFrame\\UI-ChatIcon-ArmoryChat-AwayMobile:14:14:0:0:16:16:0:16:0:16|t"
local MOBILE_BUSY_ICON = "|TInterface\\ChatFrame\\UI-ChatIcon-ArmoryChat-BusyMobile:14:14:0:0:16:16:0:16:0:16|t"

local addon = CreateFrame("Frame")
local view, lastView
local elapsed = 0

local function OnUpdate(addon, elapse)
	elapsed = elapsed + elapse
	if elapsed > .25 then
		elapsed = 0
		view = GetCVar("guildRosterView") -- update our cache with the selected view
		if view ~= lastView then
			lastView = view
			GuildRoster_Update()
		else
			addon:SetScript("OnUpdate", nil)
		end
	end
end

local function GuildRosterUpdate()
	elapsed = 0
	addon:SetScript("OnUpdate", OnUpdate)
end

local function SetStringText(btn, text, online, class)
	local parent = btn:GetParent()
	local index = parent.guildIndex
	if index then
		local name, _, _, _, _, _, _, _, _, status, _, _, _, mobile, _, _ = GetGuildRosterInfo(index)
		if name then
			local cb = GetCVar("colorblindMode") == "1"
			local temp
			if mobile then
				if status == 2 then
					temp = cb and CHAT_FLAG_DND:sub(0, 2)..">" or MOBILE_BUSY_ICON
				elseif status == 1 then
					temp = cb and CHAT_FLAG_AFK:sub(0, 2)..">" or MOBILE_AWAY_ICON
				else
					temp = ChatFrame_GetMobileEmbeddedTexture(73/255, 177/255, 73/255)
				end
				name = temp.." "..name
			else
				if status == 2 then
					temp = cb and CHAT_FLAG_DND:sub(0, 2)..">" or format("|T%s:20:20:-2:0|t", FRIENDS_TEXTURE_DND)
				elseif status == 1 then
					temp = cb and CHAT_FLAG_AFK:sub(0, 2)..">" or format("|T%s:20:20:-2:0|t", FRIENDS_TEXTURE_AFK)
				elseif ShowAllIcons then
					if online then
						temp = cb and "<O>" or format("|T%s:20:20:-2:0|t", FRIENDS_TEXTURE_ONLINE)
					else
						temp = cb and "<F>" or format("|T%s:20:20:-2:0|t", FRIENDS_TEXTURE_OFFLINE)
					end
				end
				name = (temp or "")..name
			end
			local fontString = parent.string2 -- name is second column (most of the time, exceptions below)
			if view == "guildStatus" or view == "tradeskill" then
				fontString = parent.string1 -- name is first column
			end
			fontString:SetText(name)
		end
	end
end
	
local function init()
	view = GetCVar("guildRosterView") -- cache this when available
	lastView = view -- we haven't yet changed anything
	hooksecurefunc("GuildRosterButton_SetStringText", SetStringText)
	hooksecurefunc("GuildRoster_Update", GuildRosterUpdate)
end

if not IsAddOnLoaded("Blizzard_GuildUI") then
	addon:RegisterEvent("ADDON_LOADED")
	addon:SetScript("OnEvent", function(addon, event, name)
		if name == "Blizzard_GuildUI" then
			addon:UnregisterEvent(event)
			addon:SetScript("OnEvent", nil)
			init()
		end
	end)
else
	init()
end
