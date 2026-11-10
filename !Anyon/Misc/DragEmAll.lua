--[[ 框體自由拖動 ]]--
-- Credits:
-- DragEmAll by emelio
-- NDui MOD: https://github.com/siweia/NDui/blob/master/Interface/AddOns/NDui/Plugins/DragEmAll.lua
-- RayUI: https://github.com/fgprodigal/RayUI/blob/master/Interface/AddOns/RayUI/mini/DragEmAll/DragEmAll.lua
-- AltzUI: https://github.com/Paojy/Altz-UI/blob/master/Interface/AddOns/AltzUI/mods/tweaks/dragemall.lua

local _, ns = ...
local F = ns[2]
local M = F.RegisterModule("DragEmAll", "DragEmAll")

local _G = _G
local pairs, type = pairs, type
local string_gmatch = string.gmatch

local C_AddOns_IsAddOnLoaded = C_AddOns.IsAddOnLoaded

-- false = 拖動該框體；true = 拖動父框體；字串 = 拖動指定框體

-- 常駐框體
local FRAMES = {
	["AddonList"] = false,				-- 插件列表
	["ChannelFrame"] = false,			-- 聊天頻道
	["ChatConfigFrame"] = false,		-- 聊天設定
	["CommunitiesFrame"] = false,		-- 公會與社群
	["CooldownViewerSettings"] = false, -- 冷卻監控設定
	["DressUpFrame"] = false,			-- 試衣間
	["FriendsFrame"] = false,			-- 好友列表
	["GossipFrame"] = false,			-- NPC 對話
	["GuildInviteFrame"] = false,		-- 公會邀請
	["GuildRegistrarFrame"] = false,	-- 公會登記
	["HelpFrame"] = false,				-- 客服
	["ItemTextFrame"] = false,			-- 物品文字
	["LootFrame"] = false,				-- 拾取
	["MailFrame"] = false,				-- 信箱
	["MerchantFrame"] = false,			-- 商人
	["ModelPreviewFrame"] = false,		-- 模型預覽
	["OpenMailFrame"] = false,			-- 閱讀郵件
	["PaperDollFrame"] = true,			-- 角色資訊
	["PetitionFrame"] = false,			-- 公會註冊簽名表
	["PVEFrame"] = false,				-- 尋求組隊
	["QuestFrame"] = false,				-- 交接任務
	["QuickKeybindFrame"] = false,		-- 快速按鍵綁定
	["RaidParentFrame"] = false,		-- 團隊資訊
	["ReputationFrame"] = true,			-- 聲望
	["SendMailFrame"] = true,			-- 寄送郵件
	["SettingsPanel"] = false,			-- 設定面板
	["SplashFrame"] = false,			-- 歡迎公告
	["StackSplitFrame"] = false,		-- 拆分堆疊
	["TabardFrame"] = false,			-- 公會外袍
	["TaxiFrame"] = false,				-- 飛行路線
	["TokenFrame"] = true,				-- 貨幣
	["TutorialFrame"] = false,			-- 教學提示
}

-- 延遲載入框體：暴雪按需載入需要勾 ADDON_LOADED
local LOAD_FRAMES = {
	Blizzard_AchievementUI = { -- 成就
		["AchievementFrame"] = false,
		["AchievementFrame.Header"] = true,
		["AchievementFrame.Categories"] = "AchievementFrame",
		["AchievementFrame.SearchResults"] = false,
	},
	Blizzard_AdventureMap = {["AdventureMapQuestChoiceDialog"] = false,}, -- 冒險地圖任務選擇
	Blizzard_AlliedRacesUI = {["AlliedRacesFrame"] = false,}, -- 同盟種族
	Blizzard_ArchaeologyUI = {["ArchaeologyFrame"] = false,}, -- 考古學
	Blizzard_ArtifactUI = {["ArtifactFrame"] = false,}, -- 神兵武器
	Blizzard_AuctionHouseUI = {["AuctionHouseFrame"] = false,}, -- 拍賣場
	Blizzard_AzeriteEssenceUI = {["AzeriteEssenceUI"] = false,}, -- 艾澤萊精華
	Blizzard_AzeriteRespecUI = {["AzeriteRespecFrame"] = false,}, -- 艾澤萊重鑄
	Blizzard_AzeriteUI = {["AzeriteEmpoweredItemUI"] = false,}, -- 艾澤萊護甲
	Blizzard_BlackMarketUI = {["BlackMarketFrame"] = false,}, -- 黑市
	-- 行事曆 / 建立事件 / 事件選擇
	Blizzard_Calendar = {["CalendarFrame"] = false, ["CalendarCreateEventFrame"] = true, ["CalendarEventPickerFrame"] = false,},
	Blizzard_ChallengesUI = {["ChallengesKeystoneFrame"] = false,}, -- 傳奇鑰石
	Blizzard_ClickBindingUI = {["ClickBindingFrame"] = false,}, -- 點擊施法設定
	Blizzard_CovenantRenown = {["CovenantRenownFrame"] = false,}, -- 誓盟名望
	Blizzard_CovenantSanctum = {["CovenantSanctumFrame"] = false,}, -- 誓盟聖所
	Blizzard_EncounterJournal = {["EncounterJournal"] = false,}, -- 冒險指南
	Blizzard_FlightMap = {["FlightMapFrame"] = false,}, -- 飛行地圖
	Blizzard_GenericTraitUI = {["GenericTraitFrame"] = false,}, -- 通用天賦樹
	-- 公會銀行
	Blizzard_GuildBankUI = {["GuildBankFrame"] = false, ["GuildBankFrame.Emblem"] = true,},
	Blizzard_GuildControlUI = {["GuildControlUI"] = false,}, -- 公會控制
	-- 觀察 / 觀察PvP
	Blizzard_InspectUI = {["InspectFrame"] = false, ["InspectPVPFrame"] = true,},
	Blizzard_IslandsPartyPoseUI = {["IslandsPartyPoseFrame"] = false,}, -- 島嶼遠征結算
	Blizzard_IslandsQueueUI = {["IslandsQueueFrame"] = false,}, -- 島嶼遠征佇列
	Blizzard_ItemSocketingUI = {["ItemSocketingFrame"] = false,}, -- 寶石鑲嵌
	Blizzard_ItemUpgradeUI = {["ItemUpgradeFrame"] = false,}, -- 物品升級
	Blizzard_MacroUI = {["MacroFrame"] = false,}, -- 巨集
	Blizzard_ObliterumUI = {["ObliterumForgeFrame"] = false,}, -- 抹滅熔爐
	Blizzard_OrderHallUI = {["OrderHallTalentFrame"] = false,}, -- 職業大廳研究
	Blizzard_PlayerSpells = {["PlayerSpellsFrame"] = false,}, -- 專精、天賦與法術書
	-- 觀察配方 / 專業
	Blizzard_Professions = {["InspectRecipeFrame"] = false, ["ProfessionsFrame"] = false,},
	Blizzard_ProfessionsCustomerOrders = {["ProfessionsCustomerOrdersFrame"] = false,}, -- 製作訂單
	Blizzard_PVPUI = {["PVPTalentPrestigeLevelDialog"] = false,}, -- PvP 天賦聲望
	Blizzard_ScrappingMachineUI = {["ScrappingMachineFrame"] = false,}, -- 拆解機
	Blizzard_TimeManager = {["TimeManagerFrame"] = false,}, -- 時間管理
	Blizzard_TrainerUI = {["ClassTrainerFrame"] = false,}, -- 訓練師
	-- 塑形 / 套裝編輯
	Blizzard_Transmog = {["TransmogFrame"] = false, ["TransmogFrame.OutfitPopup"] = false,},
	Blizzard_WeeklyRewards = {["WeeklyRewardsFrame"] = false,}, -- 宏偉寶庫
}

local parentFrame = {}
local hooked = {}

-- 解析 "Frame.Child.GrandChild" 這類 parentKey 路徑
local function GetFrameByPath(path)
	local frame = _G
	for key in string_gmatch(path, "[^%.]+") do
		if not frame then return end
		frame = frame[key]
	end

	if frame ~= _G then
		return frame
	end
end

local function MouseDownHandler(frame, button)
	local target = parentFrame[frame] or frame
	if button == "LeftButton" then
		target:StartMoving()
		target:SetUserPlaced(false)
	end
end

local function MouseUpHandler(frame, button)
	local target = parentFrame[frame] or frame
	if button == "LeftButton" then
		target:StopMovingOrSizing()
	end
end

local function HookFrame(name, moveParent)
	if hooked[name] then return end

	local frame = GetFrameByPath(name)
	if not frame or (frame.IsForbidden and frame:IsForbidden()) then return end
	if not frame.EnableMouse or not frame.SetMovable or not frame.SetClampedToScreen then return end

	local parent
	if moveParent then
		parent = type(moveParent) == "string" and GetFrameByPath(moveParent) or frame:GetParent()
		if not parent then return end
		if not parent.SetMovable or not parent.SetClampedToScreen then return end

		parentFrame[frame] = parent
		parent:SetMovable(true)
		parent:SetClampedToScreen(false)
	end

	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:SetClampedToScreen(false)
	frame:HookScript("OnMouseDown", MouseDownHandler)
	frame:HookScript("OnMouseUp", MouseUpHandler)

	hooked[name] = true
end

local function HookFrames(list)
	for name, moveParent in pairs(list) do
		HookFrame(name, moveParent)
	end
end

local function OnAddonLoaded(_, loadedAddon)
	local frameList = LOAD_FRAMES[loadedAddon]
	if frameList then
		HookFrames(frameList)
	end
end

function M:OnEnable()
	HookFrames(FRAMES)

	for addonName, frameList in pairs(LOAD_FRAMES) do
		if C_AddOns_IsAddOnLoaded(addonName) then
			HookFrames(frameList)
		end
	end

	F.RegisterEvent("ADDON_LOADED", OnAddonLoaded)
end
