--[[ 小功能微調 ]]--

	-- EventBossAutoSelect
	-- https://www.wowinterface.com/downloads/info20440-EventBossAutoSelect.html
	-- SpeedDel
	-- https://mods.curse.com/addons/wow/speeddel
	-- EasyLogger
	-- https://www.wowinterface.com/downloads/info20498-EasyLogger.html
	-- 成就自動截圖
	-- https://www.wowinterface.com/downloads/info10282-AchievementSS.html
	-- https://www.wowinterface.com/downloads/info22255-LevelCam.html

	-- 其他有的沒的
	-- [Addon/Script]party name to class name
	-- https://www.wowinterface.com/forums/showthread.php?t=49176
	-- http://www.mmo-champion.com/threads/2003404-Question-about-the-Legion-center-screen-HP-resource-bar
	-- Remove buff icons above Personal Resource Display
	-- http://www.mmo-champion.com/threads/2089610-Remove-buff-icons-above-Personal-Resource-Display	
	-- Any way to make the new 7.0.3 Personal Resource Display unclickable?
	-- https://www.wowinterface.com/forums/showthread.php?t=54126
	-- http://www.mmo-champion.com/threads/1647254-Auto-change-raid-Frames-on-group-size
	-- 姓名板字型 
	-- http://www.mmo-champion.com/threads/2064978-nameplate-of-target-back-to-normal-size
	-- collectgarbage(已集成於diminfo中)
	-- http://bbs.nga.cn/read.php?tid=4641810
	-- 小按鈕(將用chatbar取代)
	-- https://bbs.ngacn.cc/read.php?pid=138374968
	-- WorldMapPingHider
	-- https://mods.curse.com/addons/wow/world-map-ping-hider
	
-- [[ 強制載入 ]] --

local function defaultsetting()

	-- Interface
	BossBanner:UnregisterAllEvents()					-- 不顯示橫幅(擊敗首領/圖隊拾取)
	SetCVar("cameraDistanceMaxZoomFactor", 2.6)			-- 最遠視距，預設1.9
	SetCVar("guildRosterView", 1)						-- 公會預設排列方式
	SetActionBarToggles(true, false, true, false)		-- 自動啟用快捷列：左下右下右一右二(登入生效)
	SetSortBagsRightToLeft(true)						-- 順向整理背包
	SetInsertItemsLeftToRight(true)						-- 反向放置戰利品
	SetAutoDeclineGuildInvites(false)					-- 不要自動拒絕公會邀請

	-- Collection
	C_MountJournal.SetCollectedFilterSetting(2, false)	-- 座騎
	C_ToyBox.SetUncollectedShown(false)					-- 玩具
	C_PetJournal.SetFilterChecked(2)					-- 寵物
	C_Heirloom.GetUncollectedHeirloomFilter(2)			-- 傳家寶
	--C_TransmogCollection.SetShowMissingSourceInItemTooltips(true)	-- 塑型未收集提示

	-- Font
	-- 任務字體(影響全局字體)
	QuestTitleFont:SetFont(STANDARD_TEXT_FONT, 18)		-- 標題
	QuestTitleFont:SetShadowOffset(0, 0)
	QuestFont:SetFont(STANDARD_TEXT_FONT, 18)			-- 描述
	QuestFont:SetShadowOffset(0, 0)
	QuestFontNormalSmall:SetFont(STANDARD_TEXT_FONT, 18)-- 目標
	QuestFontNormalSmall:SetShadowOffset(0, 0)
	QuestFontHighlight:SetFont(STANDARD_TEXT_FONT, 18)	-- 內容
	QuestFontHighlight:SetShadowOffset(0, 0)
end 

local DFS = CreateFrame("FRAME", "defaultsetting")
DFS:RegisterEvent("PLAYER_LOGIN")	-- or use PLAYER_ENTERING_WORLD
DFS:RegisterEvent("VARIABLES_LOADED")
local function eventHandler(self, event, ...)
	defaultsetting() 
end 
DFS:SetScript("OnEvent", eventHandler)

-- [[ 根據地點調整亮度 ]] --

local ID = {
	--[85] = true,	-- 奧格瑪
	[86] = true,	-- 奧格瑪暗影裂谷
	
	[1015] = true,	-- 威奎斯特莊園 / Waycrest Manor - The Grand Foyer 
	[1016] = true,	-- 威奎斯特莊園 / Waycrest Manor - Upstairs
	[1017] = true,	-- 威奎斯特莊園 / Waycrest Manor - The Cellar
	[1018] = true,	-- 威奎斯特莊園 / Waycrest Manor - Catacombs
	
	[974] = true,	-- 托達戈爾 / Tol Dagor
	[975] = true,	-- 托達戈爾 / Tol Dagor - The Drain
	[976] = true,	-- 托達戈爾 / Tol Dagor - The Brig
	[977] = true,	-- 托達戈爾 / Tol Dagor - Detention Block
	[978] = true,	-- 托達戈爾 / Tol Dagor - Officer Quarters
	[979] = true,	-- 托達戈爾 / Tol Dagor - Overseer's Redoubt
	[980] = true,	-- 托達戈爾 / Tol Dagor - Overseer's Summit

	[1169] = true,	-- 托達戈爾野外 / Tol Dagor

}

local function changeGamma()
	local MapId = C_Map.GetBestMapForUnit("player")
	if MapId and ID[MapId] then
		SetCVar("Gamma", 1.2)
	else
		SetCVar("Gamma", 1)
	end
end

local CG = CreateFrame("Frame", "changeGamma")
	CG:RegisterEvent("PLAYER_LOGIN")
	CG:RegisterEvent("PLAYER_ENTERING_WORLD")
	CG:RegisterEvent("ZONE_CHANGED")
	CG:RegisterEvent("ZONE_CHANGED_INDOORS")
	CG:RegisterEvent("ZONE_CHANGED_NEW_AREA")
local function eventHandler(self, event, ...)
	changeGamma() 
end 
CG:SetScript("OnEvent", eventHandler)

-- [[ 節日隨機自動排 ]] --

LFDParentFrame:HookScript("OnShow",function()
	for i = 1, GetNumRandomDungeons() do
		local id, name = GetLFGRandomDungeonInfo(i)
		local isHoliday = select(15, GetLFGDungeonInfo(id))
		if isHoliday and not GetLFGDungeonRewards(id) then
			LFDQueueFrame_SetType(id)
		end
	end
 end)

-- [[ 自動輸入delete ]] --

hooksecurefunc(StaticPopupDialogs["DELETE_GOOD_ITEM"], "OnShow", function(boxEditor)
	boxEditor.editBox:SetText(DELETE_ITEM_CONFIRM_STRING)
end)


-- [[ raid和m+自動戰鬥紀錄 ]] --

local AutoLog = CreateFrame("Frame")
AutoLog:SetScript("OnEvent", function ()
	local _, instanceType = IsInInstance()
	local difficulty = select(3, GetInstanceInfo())
	if instanceType == "raid" or difficulty == 8 then
		if not LoggingCombat() then
			LoggingCombat(true)
			print("|cff00FF00"..COMBATLOGENABLED.."|r")
		end
	else
		if LoggingCombat() then
			LoggingCombat(false)
			print("|cffFF0000"..COMBATLOGDISABLED.."|r")
		end
	end
end)
AutoLog:RegisterEvent("PLAYER_ENTERING_WORLD")
AutoLog:RegisterEvent("PLAYER_DIFFICULTY_CHANGED")
AutoLog:RegisterEvent("ZONE_CHANGED_NEW_AREA")
AutoLog:RegisterEvent("CHALLENGE_MODE_START")

-- [[ 成就、死亡和升級自動截圖 ]] --

-- 延遲一秒
local delay = 1
local time = 0
local AutoScreenshot = CreateFrame("Frame")
AutoScreenshot:Hide()
AutoScreenshot:RegisterEvent("ACHIEVEMENT_EARNED")
AutoScreenshot:RegisterEvent("PLAYER_DEAD")
AutoScreenshot:RegisterEvent("PLAYER_LEVEL_UP")
AutoScreenshot:RegisterEvent("CHALLENGE_MODE_COMPLETED") -- SCENARIO_COMPLETED/SCENARIO_CRITERIA_UPDATE/SCENARIO_UPDATE?

AutoScreenshot:SetScript("OnUpdate", function(self, elapsed)
	time = time + elapsed
	if time >= delay then
		Screenshot()
		time = 0
		self:Hide()
	end
end)

AutoScreenshot:SetScript("OnEvent", function(self, event, ...)
	self:Show()
end)