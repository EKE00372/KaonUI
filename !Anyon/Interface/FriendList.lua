local _, ns = ...
local F = ns[2]
local M = F.RegisterModule("FriendList", "FriendList")

local classTokens = {}
local playerZone, socialScrollBox

local function GetGameAccountColor(gameAccountInfo)
	if not gameAccountInfo.isOnline or gameAccountInfo.clientProgram ~= BNET_CLIENT_WOW then return end
	return GetClassColorObj(classTokens[gameAccountInfo.className] or gameAccountInfo.classFilename)
end

local function UpdateFriendButton(button)
	local sameZone = false
	if button.buttonType == FRIENDS_BUTTON_TYPE_WOW then
		local info = C_FriendList.GetFriendInfoByIndex(button.id)
		if info and info.connected then
			local color = GetClassColorObj(classTokens[info.className])
			if color then
				button.name:SetFormattedText("%s, %s", color:WrapTextInColorCode(info.name),
					FRIENDS_LEVEL_TEMPLATE:format(info.level, info.className))
			end
			sameZone = (info.area ~= "" and info.area == playerZone)
		end
	elseif button.buttonType == FRIENDS_BUTTON_TYPE_BNET then
		local accountInfo = C_BattleNet.GetFriendAccountInfo(button.id)
		if accountInfo then
			local gameAccountInfo = accountInfo.gameAccountInfo
			local color = GetGameAccountColor(gameAccountInfo)
			if color and gameAccountInfo.characterName and gameAccountInfo.characterName ~= "" then
				local characterName = FriendsListUtil.GetFormattedCharacterName(accountInfo)
				-- 保留原生色盲模式的跨陣營提示。
				if CVarCallbackRegistry:GetCVarValueBool("colorblindMode") and not CanCooperateWithGameAccount(accountInfo) then
					characterName = gameAccountInfo.characterName..CANNOT_COOPERATE_LABEL
				end
				button.name:SetFormattedText("%s%s (%s)|r", color:GenerateHexColorMarkup(), BNet_GetBNetAccountName(accountInfo), characterName)
			end
			sameZone = (gameAccountInfo.isOnline and gameAccountInfo.clientProgram == BNET_CLIENT_WOW
				and gameAccountInfo.areaName ~= "" and gameAccountInfo.areaName == playerZone)
		end
	else
		return
	end

	-- 原生只重設 info 的文字；列重用或玩家換區時也要還原先前的綠色。
	local color = sameZone and GREEN_FONT_COLOR or FRIENDS_GRAY_COLOR
	button.info:SetTextColor(color:GetRGB())
end

local function UpdateSocialLocation(button, refresh)
	if refresh then button:RefreshLocationDisplayText() end
	local accountInfo = button.elementData.accountInfo
	local gameAccountInfo = accountInfo.gameAccountInfo
	if not gameAccountInfo.isOnline or gameAccountInfo.clientProgram ~= BNET_CLIENT_WOW
		or gameAccountInfo.areaName == "" or gameAccountInfo.areaName ~= playerZone then return end

	-- 只替換原生所在地文字最外層的色碼，保留其內容與格式。
	local text = FriendsListUtil.BuildLocationDisplayText(accountInfo)
	button.Location:SetText((text:gsub("^|c%x%x%x%x%x%x%x%x", GREEN_FONT_COLOR:GenerateHexColorMarkup(), 1)))
end

local function UpdateSocialCard(_, button)
	local accountInfo = button.elementData and button.elementData.accountInfo
	if not accountInfo then return end

	local gameAccountInfo = accountInfo.gameAccountInfo
	local color = GetGameAccountColor(gameAccountInfo)
	if color and gameAccountInfo.characterName and gameAccountInfo.characterName ~= "" then
		button.FriendName:SetText(color:WrapTextInColorCode(BNet_GetBNetAccountName(accountInfo)))
		button.Name:SetText(color:WrapTextInColorCode(FriendsListUtil.GetFormattedCharacterName(accountInfo)))
	end
	UpdateSocialLocation(button)
end

local function OnZoneChanged()
	local zone = GetRealZoneText()
	if zone == playerZone then return end
	playerZone = zone

	if FriendsListFrame:IsVisible() then
		for _, button in FriendsListFrame.ScrollBox:EnumerateFrames() do
			UpdateFriendButton(button)
		end
	end
	if socialScrollBox and socialScrollBox:IsVisible() then
		for _, button in socialScrollBox:EnumerateFrames() do
			if button.elementData and button.elementData.accountInfo then
				UpdateSocialLocation(button, true)
			end
		end
	end
end

function M:OnEnable()
	for token, name in pairs(LOCALIZED_CLASS_NAMES_MALE) do
		classTokens[name] = token
	end
	for token, name in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
		classTokens[name] = token
	end
	playerZone = GetRealZoneText()

	hooksecurefunc("FriendsFrame_UpdateFriendButton", UpdateFriendButton)
	local socialList = SocialUIFrame.FriendsList
	if socialList then
		socialScrollBox = socialList.ScrollBox
		ScrollUtil.AddInitializedFrameCallback(socialScrollBox, UpdateSocialCard, M)
		for _, button in socialScrollBox:EnumerateFrames() do
			UpdateSocialCard(nil, button)
		end
	end

	F.RegisterEvent("PLAYER_ENTERING_WORLD", OnZoneChanged)
	F.RegisterEvent("ZONE_CHANGED_NEW_AREA", OnZoneChanged)
	F.RegisterEvent("ZONE_CHANGED", OnZoneChanged)
	F.RegisterEvent("ZONE_CHANGED_INDOORS", OnZoneChanged)
end
