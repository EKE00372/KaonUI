--[[ 框體自由拖動 ]]--

--	heavy edit because author quit for years.
--	Credits:
--	Author@emelio: https://mods.curse.com/addons/wow/drag-em-all
--	reference@RayUI: https://github.com/fgprodigal/RayUI/blob/master/Interface/AddOns/RayUI/mini/DragEmAll/DragEmAll.lua
-- AltzUI: https://github.com/Paojy/Altz-UI/blob/master/Interface/AddOns/AltzUI/mods/tweaks/dragemall.lua

local addon = CreateFrame("Frame")

-- 測試服預留
--local PTR	= select(4, GetBuildInfo()) >= 90002

-- Based on the frame list from NDragIt by Nemes.
-- These frames are hooked on login.
local frames = {
	-- ["FrameName"] = true (the parent frame should be moved) or false (the frame itself should be moved)
	-- for child frames (i.e. frames that don't have a name, but only a parentKey="XX" use
	-- "ParentFrameName.XX" as frame name. more than one level is supported, e.g. "Foo.Bar.Baz")

	-- Blizzard Frames
	["SplashFrame"] = false,			-- ESC-新特色
	["HelpFrame"] = false,				-- ESC-說明
	["SettingsPanel"] = false,			-- ESC-選項
	["AddonList"] = false,				-- ESC-插件
	
	["ChannelFrame"] = false,			-- 頻道
	["ChatConfigFrame"] = false,		-- 聊天框設定
	["DressUpFrame"] = false,			-- 試衣間
	["FriendsFrame"] = false,			-- (O)好友
	["GossipFrame"] = false,			-- 對話
	["GuildInviteFrame"] = false,		-- 公會邀請
	["GuildRegistrarFrame"] = false,	-- 公會註冊
	
	["ItemTextFrame"] = false,
	["LootFrame"] = false,				-- 拾取介面
	["MailFrame"] = false,				-- 信箱
	["MerchantFrame"] = false,			-- 商人
	["ModelPreviewFrame"] = false,
	["OpenMailFrame"] = false,			-- 收信
	
	["PaperDollFrame"] = true,			-- (C)人物介面
	["PetitionFrame"] = false,
	["PetStableFrame"] = false,
	["ProfessionsFrame"] = false,		-- 專業
	["PVEFrame"] = false,				-- (I)尋求組隊
	["QuestFrame"] = false,				-- 交接任務介面
	["RaidParentFrame"] = false,
	["ReputationFrame"] = true,			-- 聲望
	
	["SendMailFrame"] = true,			-- 寄信
	["SpellBookFrame"] = false,			-- (P)法術書
	["StackSplitFrame"] = false,
	["TabardFrame"] = false,
	["TaxiFrame"] = false,
	["TradeFrame"] = false,				-- 交易介面
	["TokenFrame"] = true,				-- 兌換通貨
	["TutorialFrame"] = false,
	
	["WorldMapFrame"] = false,			-- 世界地圖
	["WorldMapTitleButton"] = true,		-- 世界地圖標題
	["QuestMapFrame"] = true,			-- 世界地圖任務介面

	--[[
	["GameMenuFrame"] = false,			-- 系統選項
	["PetPaperDollFrame"] = true,		-- 寵物介面*
	["PetPaperDollFrameCompanionFrame"] = "CharacterFrame",
	["PetPaperDollFramePetFrame"] = "CharacterFrame",
	["PVPFrame"] = false,				-- (i)PVP*
	["CollectionsJournal"] = false,		-- 收藏*
	["EncounterJournal"] = false,		-- 地城手冊*
	
	["BankFrame"] = false,				-- 銀行X
	["WorldStateScoreFrame"] = false,
	["BattlefieldFrame"] = false,
	["ArenaFrame"] = false,
	["SkillFrame"] = true,
	["MissingLootFrame"] = false,
	["ScrollOfResurrectionSelectionFrame"] = false,
	["PVPBannerFrame"] = false,
	["PVPBattlegroundFrame"] = true,]]--
	
	
	-- AddOns
	["LudwigFrame"] = false,
}

-- Frames provided by load on demand addons, hooked when the addon is loaded.
local loadFrames = {
	-- AddonName = { list of frames, same syntax as above }

	-- 成就
	Blizzard_AchievementUI	= {
		["AchievementFrame"] = false, 
		["AchievementFrameHeader"] = true, 
		["AchievementFrameCategoriesContainer"] = "AchievementFrame", 
		["AchievementFrame.searchResults"] = false 
	},
	-- 什麼地圖
	Blizzard_AdventureMap = { ["AdventureMapQuestChoiceDialog"] = false },
	-- 同盟
	Blizzard_AlliedRacesUI = { ["AlliedRacesFrame"] = false },
	-- 神器
	Blizzard_ArtifactUI			= { ["ArtifactFrame"] = false, ["ArtifactRelicForgeFrame"] = false },
	-- 考古
	Blizzard_ArchaeologyUI = { ["ArchaeologyFrame"] = false },
	-- 拍賣
	Blizzard_AuctionHouseUI = { ["AuctionHouseFrame"] = false },
	-- 艾澤萊
	Blizzard_AzeriteEssenceUI	= { ["AzeriteEssenceUI"] = false },
	Blizzard_AzeriteRespecUI	= { ["AzeriteRespecFrame"] = false },
	Blizzard_AzeriteUI			= { ["AzeriteEmpoweredItemUI"] = false },
	-- 按鍵綁定
	Blizzard_BindingUI = { ["KeyBindingFrame"] = false, ["QuickKeybindFrame"] = false },
	-- 黑市
	Blizzard_BlackMarketUI = { ["BlackMarketFrame"] = false },

	-- 行事曆
	Blizzard_Calendar = {
		["CalendarFrame"] = false,
		["CalendarCreateEventFrame"] = true,
		["CalendarEventPickerFrame"] = false
	},
	-- 挑戰
	Blizzard_ChallengesUI = { ["ChallengesKeystoneFrame"] = false },
	-- 天賦
	Blizzard_ClassTalentUI		= { ["ClassTalentFrame"] = false },
	-- 快速綁定
	Blizzard_ClickBindingUI		= { ["ClickBindingFrame"] = false },
	-- 收藏
	Blizzard_Collections		= { ["WardrobeFrame"] = false, ["WardrobeOutfitEditFrame"] = false },
	-- 盟約
	Blizzard_CovenantRenown		= { ["CovenantRenownFrame"] = false, },
	Blizzard_CovenantSanctum	= { ["CovenantSanctumFrame"] = false, },
	-- 社群
	Blizzard_Communities = {
		["CommunitiesFrame"] = false,
		["CommunitiesSettingsDialog"] = false,
		["CommunitiesGuildLogFrame"] = false,
		["CommunitiesTicketManagerDialog"] = false,
		["CommunitiesAvatarPickerDialog"] = false,
		["CommunitiesFrame.NotificationSettingsDialog"] = false,
		["ClubFinderCommunityAndGuildFinderFrame.RequestToJoinFrame"] = false
	},
	
	-- 飛行地圖
	Blizzard_FlightMap			= { ["FlightMapFrame"] = false },
	-- GM幫助
	Blizzard_GMSurveyUI			= { ["GMSurveyFrame"] = false },
	-- 公會
	Blizzard_GuildBankUI		= { ["GuildBankFrame"] = false, ["GuildBankEmblemFrame"] = true },
	Blizzard_GuildControlUI		= { ["GuildControlUI"] = false },
	Blizzard_GuildRecruitmentUI	= { ["CommunitiesGuildRecruitmentFrame"] = false },
	Blizzard_GuildUI = { ["GuildFrame"] = false, ["GuildRosterFrame"] = true, ["GuildFrame.TitleMouseover"] = true },
	
	-- 觀察
	Blizzard_InspectUI = { ["InspectFrame"] = false, ["InspectPVPFrame"] = true, ["InspectTalentFrame"] = true },
	-- 海島
	Blizzard_IslandsPartyPoseUI	= { ["IslandsPartyPoseFrame"] = false },
	Blizzard_IslandsQueueUI		= { ["IslandsQueueFrame"] = false },
	-- 物品堆疊
	Blizzard_ItemSocketingUI = { ["ItemSocketingFrame"] = false },
	-- 物品升級
	Blizzard_ItemUpgradeUI = { ["ItemUpgradeFrame"] = false, },
	-- 公會搜尋
	Blizzard_LookingForGuildUI	= { ["LookingForGuildFrame"] = false },
	-- 巨集設定
	Blizzard_MacroUI = { ["MacroFrame"] = false },
	
	-- 什麼熔爐
    Blizzard_ObliterumUI = { ["ObliterumForgeFrame"] = false},
	-- 職業大廳
	Blizzard_OrderHallUI		= { ["OrderHallTalentFrame"] = false, },
	-- 拆解機
	Blizzard_ScrappingMachineUI	= { ["ScrappingMachineFrame"] = false },
	-- 天賦
	Blizzard_TalentUI = { ["PlayerTalentFrame"] = false, ["PVPTalentPrestigeLevelDialog"] = false, },
	-- 碼錶
	Blizzard_TimeManager = { ["TimeManagerFrame"] = false },
	-- 兌換通貨
	--Blizzard_TokenUI = { ["TokenFrame"] = true },
	-- 專業
	Blizzard_TradeSkillUI = { ["TradeSkillFrame"] = false },
	-- 訓練師
	Blizzard_TrainerUI = { ["ClassTrainerFrame"] = false },
	-- 虛空倉庫
	Blizzard_VoidStorageUI = { ["VoidStorageFrame"] = false, ["VoidStorageBorderFrameMouseBlockFrame"] = "VoidStorageFrame" },
	-- 保底箱
	Blizzard_WeeklyRewards		= { ["WeeklyRewardsFrame"] = false },

	-- 塑形
	--Blizzard_ItemAlterationUI = { ["TransmogrifyFrame"] = false },
	--地城手冊
	--Blizzard_EncounterJournal = { ["EncounterJournal"] = false },
	--寵物手冊
	--Blizzard_PetJournal = { ["PetJournalParent"] = false },
	--要塞
	--Blizzard_GarrisonUI = { ["GarrisonMissionFrame"] = false, },
	--[[Blizzard_GarrisonUI = { 
		["GarrisonLandingPage"] = false,
		["GarrisonLandingPageReport"] = true,
		["GarrisonMissionFrame"] = false,
		["GarrisonMissionFrame.MissionTab"] = true,	
		["GarrisonBuildingFrame"] = false,
		GarrisonRecruiterFrame = false,
		GarrisonRecruitSelectFrame = false,
		GarrisonCapacitiveDisplayFrame = false,
		GarrisonShipyardFrame = false
	},]]--
	-- 劇情對話框體
    --Blizzard_TalkingHeadUI = { ["TalkingHeadFrame"] = false},
	-- 雕紋
	--Blizzard_GlyphUI = { ["GlyphFrame"] = true },
	-- 理髮廳
	--Blizzard_BarbershopUI = { ["BarberShopFrame"] = false },
	-- 重鑄
	--Blizzard_ReforgingUI = { ["ReforgingFrame"] = false, ["ReforgingFrameInvisibleButton"] = true, ["ReforgingFrame.InvisibleButton"] = true },
}

local parentFrame = {}
local hooked = {}

local function print(msg)
	DEFAULT_CHAT_FRAME:AddMessage("DragEmAll: " .. msg)
end

function addon:PLAYER_LOGIN()
	self:HookFrames(frames)
end

function addon:ADDON_LOADED(name)
	local frameList = loadFrames[name]
	if frameList then
		self:HookFrames(frameList)
	end
end

local function MouseDownHandler(frame, button)
	frame = parentFrame[frame] or frame
	if frame and button == "LeftButton" then
		frame:StartMoving()
		frame:SetUserPlaced(false)
	end
end

local function MouseUpHandler(frame, button)
	frame = parentFrame[frame] or frame
	if frame and button == "LeftButton" then
		frame:StopMovingOrSizing()
	end
end

function addon:HookFrames(list)
	for name, child in pairs(list) do
		self:HookFrame(name, child)
	end
end

function addon:HookFrame(name, moveParent)
	-- find frame
	-- name may contain dots for children, e.g. ReforgingFrame.InvisibleButton
	local frame = _G
	local s
	for s in string.gmatch(name, "%w+") do
		if frame then
			frame = frame[s]
		end
	end
	-- check if frame was found
	if frame == _G then
		frame = nil
	end

	local parent
	if frame and not hooked[name] then
		if moveParent then
			if type(moveParent) == "string" then
				parent = _G[moveParent]
			else
				parent = frame:GetParent()
			end
			if not parent then
				print("Parent frame not found: " .. name)
				return
			end
			parentFrame[frame] = parent
		end
		if parent then
			parent:SetMovable(true)
			parent:SetClampedToScreen(false)
		end
		frame:EnableMouse(true)
		frame:SetMovable(true)
		frame:SetClampedToScreen(false)
		self:HookScript(frame, "OnMouseDown", MouseDownHandler)
		self:HookScript(frame, "OnMouseUp", MouseUpHandler)
		hooked[name] = true
	end
end

function addon:HookScript(frame, script, handler)
	if not frame.GetScript then return end
	local oldHandler = frame:GetScript(script)
	if oldHandler then
		frame:SetScript(script, function(...)
			handler(...)
			oldHandler(...)
		end)
	else
		frame:SetScript(script, handler)
	end
end

addon:SetScript("OnEvent", function(f, e, ...) f[e](f, ...) end)
addon:RegisterEvent("PLAYER_LOGIN")
addon:RegisterEvent("ADDON_LOADED")