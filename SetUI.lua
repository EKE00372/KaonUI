-- [[ 介面設定，輸入/SETUI載入 ]] --

	-- Credit:
	-- 楼上的你妈妈叫你吃饭: http://bbs.nga.cn/read.php?tid=4667432
	-- AIO: https://github.com/Stanzilla/AdvancedInterfaceOptions
	-- ELVUI: http://git.tukui.org/Elv/elvui/blob/master/ElvUI/core/install.lua
	-- MONOUI: https://www.wowinterface.com/downloads/info18071-MonoUI.html
	-- Note:
	-- CVAR簡表: http://bbs.nga.cn/read.php?tid=9622396
	-- WOW WIKI CVAR: https://wow.gamepedia.com/Console_variables
	
local UIcfg = function()

-- [[ note ]] --

	-- 巨集應用為 /run SetCVar("cvar", "值") 或/console cvar 值
	-- 還原預設值為 /run SetCVar("cvar",GetCVarDefault("cvar")) 
	-- 查看當前值為 /dump GetCVar("cvar")
	-- 重置所有輸入 /console cvar_default
	-- # 為隱藏選項
	-- * 為遊戲預設

-- [[ 系統/System ]] --
	
	-- UI縮放
	SetCVar("useUiScale", 1)		-- 啟用UI縮放，1開
	SetCVar("uiScale", 0.6)			-- 若上項設為1則此處設置縮放比
	--啟用進階戰鬥紀錄
	SetCVar("advancedCombatLogging", 1)
	
	-- #截圖
	SetCVar("screenshotQuality", 10)		-- #品質（慎改，10最高）
	-- SetCVar("screenshotFormat", "tga")	-- #格式
	
	-- #和諧，1開
	SetCVar("overrideArchive", 0)
	-- #反暴力等級，0=開，1=綠血，5=最高
	SetCVar("violenceLevel", 5)
	
	-- #全螢幕泛光，1開
	SetCVar("ffxGlow", 0)
	-- #死亡特效
	SetCVar("ffxDeath", 0)
	-- #天氣特效，0~3
	SetCVar("SkyCloudLOD", 3)
	
	-- #*顯示LUA錯誤，1開
	SetCVar("scriptErrors", 1)
	-- #在TOOLTIP上顯示任務進度，1開
	SetCVar("showQuestTrackingTooltips", 0)
	-- #跨甲或同模型塑形提示，1開
	SetCVar("missingTransmogSourceInItemTooltips", 1)
	-- #顯示cpu占用(供插件調用)
	SetCVar("scriptProfile", 1)
		
	-- 延遲載入遊戲模組，可能解決7.0卡藍條，但有副（負）作用，慎改
	--SetCVar("worldPreloadNonCritical", 0)

--[[ 其他/Others ]]--

	-- 移除對話視窗的彈出延遲(?)
	--SetCVar("removeChatDelay", 0)
	-- 顯示替代資源(alternate power)
	--SetCVar("alternateResourceText", 1)
	
-- [[ 控制/Control ]] --

	-- 鎖定目標，1關
	SetCVar("deselectOnClick", 1)
	-- *自動解除飛行座騎，1開
	SetCVar("autoDismountFlying", 0)
	-- 自動清除暫離，1開
	SetCVar("autoClearAFK", 0)
	-- 自動拾取，1開
	SetCVar("autoLootDefault", 1)
	-- 左鍵進行互動，1開
	SetCVar("interactOnLeftClick", 0)
	-- *拾取框跟隨滑鼠，1開
	SetCVar("lootUnderMouse", 1)
	
	-- #*自動解除座騎，1開
	SetCVar("autoDismount", 1)
	-- #自動打開拾取紀錄，1開
	SetCVar("autoOpenLootHistory", 0)
	-- #顯示背包剩餘空間，1開
	SetCVar("displayFreeBagSlots", 0)
	-- #*自動裝備對比，1開
	SetCVar("alwaysCompareItems", 0)
	-- #*滑鼠進階提示，1開
	SetCVar("UberTooltips", 1)
	
-- [[ 戰鬥/Combat ]] --

	-- 目標的目標，1開
	SetCVar("showTargetOfTarget", 1)
	-- *低生命力閃動螢幕，0開
	SetCVar("doNotFlashLowHealthWarning", 0)
	-- *喪失控制警告，1開
	SetCVar("lossOfControl", 1)
	-- *自己的戰鬥文字捲動，1開
	--SetCVar("enableFloatingCombatText", 1)
	-- 顯示法術警示的透明程度，預設0.65
	SetCVar("spellActivationOverlayOpacity", 0.5)
	-- *專注施法鍵
	
	-- *自我施法鍵
	
	-- 自動自我施法，1開
	SetCVar("autoSelfCast", 0)
	
	-- #協助(/assist)時開啟攻擊，1開
	SetCVar("assistAttack", 0)
	-- #切換目標後停止自動攻擊，1開
	SetCVar("stopAutoAttackOnTargetChange", 0)
	-- #浮動戰鬥文字逗點和大數值縮寫，1開
	SetCVar("breakUpLargeNumbers", 1)
	-- #顯示目標所有的增減益效果，1開 
	SetCVar("noBuffDebuffFilterOnTarget", 1) 
	-- #*tab最近的目標
	SetCVar("TargetNearestUseNew", 1)
	-- #框體不顯示即將到來的治療
	SetCVar("predictedHealth", 0)
	-- #*仇恨百分比，1開
	--SetCVar("threatShowNumeric", 1)
	-- #在目標頭像上顯示連擊點，1=目標，2=自己
	--SetCVar("comboPointLocation",1)
	
-- [[ 浮動戰鬥文字/Combat Text ]] --

	-- #浮動戰鬥文字的運動方式，1=往上，2=往下 ，3=弧形
	SetCVar("floatingCombatTextFloatMode", 1)
	-- #浮動戰鬥文字的運動方式，0=傳統垂直往上，1=7.0新的運動方式
	SetCVar("floatingCombatTextCombatDamageDirectionalScale", 0)
	-- #全局戰鬥文字縮放，數值1~5；會連快捷列上的經驗神器條數值一起放大。 
	SetCVar("WorldTextScale", 1.5)
	
	-- #對目標輸出
	SetCVar("floatingCombatTextCombatDamage", 0)					-- 傷害
	SetCVar("floatingCombatTextCombatHealing", 0)					-- 治療
	
	-- 以下進階設定預設都是關閉，要更改設定必需先開啟「自己的戰鬥文字捲動」才能生效
	-- 寵物對目標傷害
	SetCVar("floatingCombatTextPetMeleeDamage", 0)					-- 普攻
	SetCVar("floatingCombatTextPetSpellDamage", 0)					-- 技能
	-- 減傷
	SetCVar("floatingCombatTextCombatHealingAbsorbTarget", 1)		-- 對目標上盾/護甲提示 
	SetCVar("floatingCombatTextCombatHealingAbsorbSelf", 1)			-- 自身得盾/護甲提示 
	SetCVar("floatingCombatTextCombatDamageAllAutos", 0)			-- 顯示所有的白字 
	SetCVar("floatingCombatTextDodgeParryMiss", 0)					-- 閃招 
	SetCVar("floatingCombatTextDamageReduction", 0)					-- 傷害減免/抵抗 
	SetCVar("floatingCombatTextCombatLogPeriodicSpells", 0)			-- 周期性傷害 
	-- 法術
	SetCVar("floatingCombatTextReactives", 0)						-- 法術警示 
	SetCVar("floatingCombatTextAuras", 0)							-- 光環 
	SetCVar("floatingCombatTextSpellMechanics", 0)					-- 顯示目標受到的糾纏效果，(例如 誘補(xxxx-xxxx)，沉默緩速之類) 
	SetCVar("floatingCombatTextSpellMechanicsOther", 0)				-- 顯示其他玩家受到的糾纏效果 
	--提示
	SetCVar("floatingCombatTextCombatState", 0)						-- 進入/離開戰鬥文字提示 
	SetCVar("floatingCombatTextLowManaHealth", 0)					-- 低MP/低HP文字提示 
	SetCVar("floatingCombatTextFriendlyHealers", 1)					-- 友方治療者名稱 
	-- 資源
	SetCVar("floatingCombatTextComboPoints", 0)						-- 連擊點 
	SetCVar("floatingCombatTextEnergyGains", 0)						-- 資源獲得(法力、怒氣、能量、真氣，和連擊點不同) 
	SetCVar("floatingCombatTextPeriodicEnergyGains", 0)				-- 周期性能量  
	SetCVar("floatingCombatTextHonorGains", 0)						-- 榮譽擊殺 
	SetCVar("floatingCombatTextRepChanges", 0)						-- 聲望變化
	
-- [[ 顯示/Display ]] --

	-- 顯著標示
	SetCVar("Outline", 3)
	-- 團隊醒目標示，圓圈和外框
	SetCVar("findYourselfMode", 1)
	-- 狀態文字，數值="NUMERIC"，百分比="PERCENT"，兩者="BOTH"
	SetCVar("statusTextDisplay","BOTH")
	-- *對話泡泡，全開
	SetCVar("chatBubbles", 1)
	-- 旋轉小地圖，1開
	SetCVar("rotateMinimap", 0)
	-- *地圖冒險指南提示，0開
	SetCVar("hideAdventureJournalAlerts", 0)
	-- 教學說明，1開
	SetCVar("showTutorials", 0)

	-- #對話泡泡子選項：隊伍對話泡泡，1開
	--SetCVar("chatBubblesParty", 0)
	-- #只在滑鼠移過時顯示狀態文字
	--SetCVar("statusText", 0)
	-- #新內容(這並沒有什麼鳥用)，1開
	SetCVar("showNPETutorials", 0)
	-- #*移動時大地圖半透明，1開 
	SetCVar("mapFade", 1)
	-- #*接任務後自動追蹤直到完成，1開
	SetCVar("autoQuestWatch", 1)
	-- #進入一個任務目的地時會自動觀察任務，1開
	SetCVar("autoQuestProgress", 1)	
	
-- [[ 社交/Social ]] --

	-- 不當言詞過濾器，1開
	SetCVar("profanityFilter", 0)
	-- *濫發訊息過濾器，1開
	SetCVar("spamFilter", 1)
	-- *公會成員上下線提示，1開
	SetCVar("guildMemberNotify", 1)
	-- *阻止交易，1開
	SetCVar("BlockTrades", 0)
	-- *阻止公會邀請，1開
	-- it's an api not cvar
	-- *封鎖對話頻道邀請，1開
	SetCVar("blockChannelInvites", 0)
	-- 對其他人只顯示角色成就
	
	-- *聊天方式："im"=即時通訊方式，"classic"=傳統模式
	SetCVar("chatStyle", "classic")
	-- 對話時間標記(24小時制，時分秒，藍色)
	SetCVar("showTimestamps", "|cff64C2F5%H:%M:%S|r ")
	-- *新的密語："inline"=內嵌，"popout"=新分頁，"popout_and_inline"=兩者 
	SetCVar("whisperMode", "inline")
	-- *線上好友，1開
	SetCVar("showToastOnline", 1)
	-- *離線好友，1開
	SetCVar("showToastOffline", 1)
	-- 公告更新，1開
	SetCVar("showToastBroadcast",1)
	-- 自動接受快速加入
	
	-- *好友邀請提示
	SetCVar("showToastFriendRequest",1)
	-- *顯示通知視窗
	SetCVar("showToastWindow",1)
	
	--#*啟用聊天框滾輪捲動，1開
	--SetCVar("chatMouseScroll", 1)
	-- #顯示公會離線成員，1開
	SetCVar("guildShowOffline", 0)
	-- #聊天框顯示職業顏色(好像沒用)
	--SetCVar("colorChatNamesByClass", 1)
	
-- [[ 快捷列/Action Bar ]] --

	-- 垂直堆疊右方快捷列
	
	-- #*鎖定，1開
	SetCVar("lockActionBars", 1)
	-- *總是顯示，1開
	SetCVar("alwaysShowActionBars", 0)
	-- 冷卻計時，1開
	SetCVar("countdownForCooldowns", 0)
	SetActionBarToggles(1, 0, 1, 0)
	-- #顯示經驗值數值，1開，0=滑鼠移過顯示
	SetCVar("xpBarText", 1)
	-- #*技能隊列，0~400，預設250
	--SetCVar("SpellQueueWindow", 250)
	-- #*按下按鍵時施放技能，1開
	SetCVar("ActionButtonUseKeyDown", 1)
	-- #*切換技能時觸發保險，1開
	SetCVar("secureAbilityToggle", 1)	 
	
-- [[ 名稱/Names ]] --

	-- *我的名稱
	SetCVar("UnitNameOwn", 0)
	-- *小動物名稱，1開
	SetCVar("UnitNameNonCombatCreatureName", 0)
	
	-- NPC名稱，1=顯示所有，若使用此項則下面都為0
	SetCVar("UnitNameNPC", 1)
	--SetCVar("UnitNameFriendlySpecialNPCName", 1)	-- 顯示任務NPC，預設只啟用這項
	--SetCVar("UnitNameInteractiveNPC", 1)			-- 顯示可互動NPC名稱(可互動=追蹤：小地圖的追蹤功能)
	--SetCVar("UnitNameHostleNPC", 1)				-- 顯示敵方NPC名稱	
	-- *友方玩家
	SetCVar("UnitNameFriendlyPlayerName", 1)
	-- *友方僕從，一選項有三個cvar
	SetCVar("UnitNameFriendlyPetName", 1)
	SetCVar("UnitNameFriendlyGuardianName", 1)
	SetCVar("UnitNameFriendlyTotemName", 1)	
	-- *敵方玩家
	SetCVar("UnitNameEnemyPlayerName", 1)
	-- *敵方僕從，一選項有三個cvar
	SetCVar("UnitNameEnemyPetName", 1)
	SetCVar("UnitNameEnemyGuardianName", 1)
	SetCVar("UnitNameEnemyTotemName", 1) 

	-- #公會頭銜，1開
	SetCVar("UnitNameGuildTitle", 0)
	-- #*角色頭銜，1開
	SetCVar("UnitNamePlayerPVPTitle", 1)
	-- #*公會名稱，1開
	--SetCVar("UnitNamePlayerGuild", 1)
		
-- [[ 單位名條/Nameplates ]] --

	-- 顯示個人資源，1開
	SetCVar("nameplateShowSelf", 0)
	-- 將個人資源顯示在目標姓名板上，1開
	SetCVar("nameplateResourceOnTarget", 0)
	-- 大型名條，預設是1，預設大型名條是1.4寬2.7高
	-- SetCVar("NamePlateHorizontalScale", 1)
	-- SetCVar("NamePlateVerticalScale", 3)
	-- *為坦克警示目標轉移，1開
	SetCVar("ShowNamePlateLoseAggroFlash", 1)
	-- 名條排列，1=堆疊，0=重疊
	SetCVar("nameplateMotion", 1)
	-- 總是顯示名條，1開
	SetCVar("nameplateShowAll", 1)
	-- 敵方單位(v) -僕從
	SetCVar("nameplateShowEnemyMinions", 1)			-- 僕從
	SetCVar("nameplateShowEnemyMinus", 1)			-- 次要
	-- 友方單位(shift+v) -僕從
	SetCVar("nameplateShowFriendlyMinions", 0)		-- 僕從
	SetCVar("nameplateShowFriendlyNPCs", 0)			-- #npc
	
	-- #敵方僕從子選項
	SetCVar("nameplateShowEnemyPets", 1)			-- 寵物
	SetCVar("nameplateShowEnemyGuardians", 1)		-- 守護者
	SetCVar("nameplateShowEnemyTotems", 1)			-- 圖騰
	-- #友方僕從子選項
	SetCVar("nameplateShowFriendlyPets", 0)			-- 寵物
	SetCVar("nameplateShowFriendlyGuardians", 0)	-- 守護者
	SetCVar("nameplateShowFriendlyTotems", 0)		-- 圖騰	
	-- #名條貼齊邊緣
	SetCVar("nameplateOtherTopInset", -1)			-- #預設=0.08
	SetCVar("nameplateOtherBottomInset", -1)		-- #預設=0.1
	--#名條距離縮放
	SetCVar("namePlateMinScale", 1)					-- #距離，預設0.8
	SetCVar("namePlateMaxScale", 1)	
	--SetCVar("nameplateMinScaleDistance", 10)		-- #距離縮放值，預設10碼
	SetCVar("nameplateSelectedScale", 1.2)			-- #選中目標縮放	
	--#名條堆疊百分比
	SetCVar("nameplateOverlapH",  0.3) 				-- #水平預設0.8
	SetCVar("nameplateOverlapV",  0.7)				-- #垂直預設1.1	
	-- #重要名條(如首領)
	SetCVar("nameplateLargerScale", 1)				-- #縮放
	SetCVar("nameplateLargeTopInset", 0.08) 		-- #貼邊
	SetCVar("nameplateLargeBottomInset", 0.1)
	
	-- #名條最大視距，預設60
	SetCVar("nameplateMaxDistance", 45)
	-- #*姓名板職業染色，1開 
	SetCVar("ShowClassColorInNameplate", 1)	
	-- 施法條
	SetCVar("showVKeyCastbar", 1)					-- #*顯示施法條，1開 
	--SetCVar("showVKeyCastbarOnlyOnTarget", 0)		-- #只顯示當前目標的施法條，1開
	--SetCVar("showVKeyCastbarSpellName", 1)		-- #顯示法術名稱，1開
	
	-- "V"
	SetCVar("nameplateShowEnemies", 1)

	-- #個人資源
	SetCVar("nameplateSelfScale", 1)				-- #*縮放
	SetCVar("showSpenderFeedback", 0)				-- #咨源溢出閃光動畫效果，1開
	--SetCVar ("nameplateSelfTopInset", .69999)		-- #固定，預設0.5
	--SetCVar ("nameplateSelfBottomInset", .3)		-- #固定，預設0.2
	
	--#個人資源顯示條件
	SetCVar("nameplatePersonalShowAlways", 0)		-- #總是顯示，1開
	SetCVar("nameplatePersonalShowInCombat", 1)		-- #*戰鬥中顯示，平時隱藏，1開 
	SetCVar("nameplatePersonalShowWithTarget", 1)	-- #有目標時顯示，平時隱藏，1開 	
	SetCVar("nameplatePersonalHideDelaySeconds", 3)	-- #*淡出消失的時間，數值是秒

-- [[ 鏡頭/camera ]] --

	-- *水體碰撞
	
	-- #最遠視距，最大2.6 (/run print(GetCameraZoom()))
	SetCVar("cameraDistanceMaxZoomFactor", 2.6)
	-- 鏡頭跟隨模式，0=永不調整，1=只調整水平面，0~4
	SetCVar("cameraSmoothStyle", 0)
	
	--#當鏡頭在地上時讓你自由旋轉視角，1開(這是啥?)
	--SetCVar("cameraPivot", 0)
	--#鏡頭跟隨地形，爬坡時往上，下坡時往下
	--SetCVar("cameraTerrainTilt", 0)
	-- #引導時不轉視角
	SetCVar("cameraSmoothTrackingStyle", 0)
	
-- [[ 滑鼠 ]] --
	
	-- *反轉滑鼠
	
	-- *滑鼠觀察速度(改變鏡頭視角時的移動速度)
	--cameraYawMoveSpeed
	-- *點擊移動
	SetCVar("Autointeract", 0)
	-- 點擊移動模式
	
	-- *啟用滑鼠靈敏度
	
	-- 靈敏度數值
	
	-- 將游標鎖定在視窗內
	
	-- #更大的滑鼠遊標，-1=自動，0=32*32，1=48*48，2=64*64 
	SetCVar("cursorsizepreferred", 1)	
	-- #啟用魔獸世界滑鼠，讓驅動接管，可修復游標位置重置bug
	--SetCVar("rawMouseEnable", 1)

-- [[ 協助工具 ]] --
	
	-- *移動面板
	--enableMovePad
	-- *動畫字幕
	SetCVar("movieSubtitle", 1)
	-- *色盲模式，1開
	SetCVar("colorblindMode", 0)
	
-- [[ 團隊檔案/Compact Raid ]] --
	
	-- 在小隊使用團隊風格的隊伍框架
	SetCVar("useCompactPartyFrames", 1)
	
	-- 不能以這種方式設定
	--SetCVar("raidOptionKeepGroupsTogether", 1)			-- 隊伍排列
	--SetCVar("raidFramesDisplayPowerBars", 1)				-- 顯示能量條
	--SetCVar("raidFramesDisplayAggroHighlight", 1)			-- 顯示獲得仇恨
	--SetCVar("raidFramesDisplayClassColor", 1)				-- 顯示職業顏色
	--SetCVar("raidOptionDisplayPets", 0)					-- 顯示寵物
	--SetCVar("raidOptionDisplayMainTankAndAssist", 0)		-- 顯示主坦與主助攻
	--SetCVar("raidOptionShowBorders", 0)					-- 顯示邊框
	--SetCVar("raidFramesDisplayOnlyDispellableDebuffs", 0)	-- 只顯示可驅散，1開
	--SetCVar("raidFramesHealthText", "none")				-- HP值
	--SetCVar("raidFramesHeight", 45)						-- 高度
	--SetCVar("raidFramesWidth", 90)						-- 寬度

-- [[ 重設聊天為雙視窗 ]] --

	-- 重置
	FCF_ResetChatWindows()
	-- 主框體
	FCF_SetLocked(ChatFrame1, true)
	FCF_DockFrame(ChatFrame2)
	FCF_SetLocked(ChatFrame2, true)
	FCF_DockFrame(ChatFrame3)
	FCF_SetLocked(ChatFrame3, true)
	FCF_DockFrame(ChatFrame4)
	FCF_SetLocked(ChatFrame4, true)
	FCF_DockFrame(ChatFrame5)
	FCF_SetLocked(ChatFrame5, true)
	-- 清空
	ChatFrame_RemoveAllChannels(ChatFrame1)
	ChatFrame_RemoveAllMessageGroups(ChatFrame1)
	ChatFrame_RemoveAllChannels(ChatFrame3)
	ChatFrame_RemoveAllMessageGroups(ChatFrame3)
	ChatFrame_RemoveAllChannels(ChatFrame4)
	ChatFrame_RemoveAllMessageGroups(ChatFrame4)
	ChatFrame_RemoveAllChannels(ChatFrame5)
	ChatFrame_RemoveAllMessageGroups(ChatFrame5)

	for i = 1, NUM_CHAT_WINDOWS do
		local frame = _G[format("ChatFrame%s", i)]
		-- 大小和位置
		if i == 1 then
			frame:SetUserPlaced(true)	-- 使其能夠置底
			frame:ClearAllPoints()
			frame:SetWidth(480)
			frame:SetHeight(200)
			frame:SetPoint("BOTTOMLEFT",UIParent,"BOTTOMLEFT",10,20)
		end
		FCF_SavePositionAndDimensions(frame)
		FCF_StopDragging(frame)
		FCF_SetChatWindowFontSize(self, frame, 18)
		-- 命名分頁
		if i == 1 then
			FCF_SetWindowName(frame, GENERAL)
		elseif i == 2 then
			FCF_SetWindowName(frame, "LOG")
		elseif i == 3 then
			FCF_SetWindowName(frame, "TFW")
		elseif i == 4 then
			FCF_SetWindowName(frame, "MSG")
		elseif i == 5 then
			FCF_SetWindowName(frame, "LOOT")
		end
	end
	
-- [[ GENERAL ]] --

	-- 全區
	ChatFrame_AddChannel(ChatFrame1, "綜合")
	ChatFrame_AddChannel(ChatFrame3, "交易")
	ChatFrame_AddChannel(ChatFrame3, "本地防務")
	-- 對話
	ChatFrame_AddMessageGroup(ChatFrame1, "SAY") 					-- 說
	ChatFrame_AddMessageGroup(ChatFrame1, "EMOTE")					-- 表情
	ChatFrame_AddMessageGroup(ChatFrame1, "YELL")					-- 大喊
	ChatFrame_AddMessageGroup(ChatFrame1, "GUILD")					-- 公會
	ChatFrame_AddMessageGroup(ChatFrame1, "OFFICER")				-- 幹部
	ChatFrame_AddMessageGroup(ChatFrame1, "GUILD_ACHIEVEMENT")		-- 公會成就
	ChatFrame_AddMessageGroup(ChatFrame1, "ACHIEVEMENT")			-- 成就
	ChatFrame_AddMessageGroup(ChatFrame1, "WHISPER")				-- 密語
	ChatFrame_AddMessageGroup(ChatFrame1, "BN_WHISPER")				-- 戰網密語
	ChatFrame_AddMessageGroup(ChatFrame1, "PARTY")					-- 小隊
	ChatFrame_AddMessageGroup(ChatFrame1, "PARTY_LEADER")			-- 小隊隊長
	ChatFrame_AddMessageGroup(ChatFrame1, "RAID")					-- 團隊
	ChatFrame_AddMessageGroup(ChatFrame1, "RAID_LEADER")			-- 團隊隊長
	ChatFrame_AddMessageGroup(ChatFrame1, "RAID_WARNING")			-- 團隊警告
	ChatFrame_AddMessageGroup(ChatFrame1, "INSTANCE_CHAT")			-- 地城
	ChatFrame_AddMessageGroup(ChatFrame1, "INSTANCE_CHAT_LEADER")	-- 地城隊長
	ChatFrame_AddMessageGroup(ChatFrame1, "BN_CONVERSATION")		-- 戰網對話
	-- 戰場
	ChatFrame_AddMessageGroup(ChatFrame1, "BG_HORDE")				-- 部落
	ChatFrame_AddMessageGroup(ChatFrame1, "BG_ALLIANCE")			-- 聯盟
	ChatFrame_AddMessageGroup(ChatFrame1, "BG_NEUTRAL")				-- 中立
	-- 其他
	ChatFrame_AddMessageGroup(ChatFrame1, "SYSTEM")					-- 系統
	ChatFrame_AddMessageGroup(ChatFrame1, "ERRORS")					-- 錯誤
	ChatFrame_AddMessageGroup(ChatFrame1, "IGNORED")				-- 忽略
	ChatFrame_AddMessageGroup(ChatFrame1, "CHANNEL")				-- 頻道
	ChatFrame_AddMessageGroup(ChatFrame1, "TARGETICONS")			-- 目標圖示
	ChatFrame_AddMessageGroup(ChatFrame1, "BN_INLINE_TOAST_ALERT")	-- 戰網提醒
	ChatFrame_AddMessageGroup(ChatFrame1, "PET_BATTLE_INFO")		-- 寵物戰鬥紀錄
	-- 怪物
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_SAY")			-- 怪物說話
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_EMOTE")			-- 怪物表情
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_YELL")			-- 怪物大喊
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_WHISPER")		-- 怪物密語
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_BOSS_EMOTE")		-- 首領表情
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_BOSS_WHISPER")	-- 首領密語
	
	ChatFrame_AddMessageGroup(ChatFrame1, "AFK")
	ChatFrame_AddMessageGroup(ChatFrame1, "DND")

-- [[ LOOT ]] --

	ChatFrame_AddMessageGroup(ChatFrame5, "COMBAT_XP_GAIN")			-- 經驗值
	ChatFrame_AddMessageGroup(ChatFrame5, "COMBAT_HONOR_GAIN")		-- 榮譽值
	ChatFrame_AddMessageGroup(ChatFrame5, "COMBAT_FACTION_CHANGE")	-- 聲望值
	ChatFrame_AddMessageGroup(ChatFrame5, "SKILL")					-- 專業技能
	ChatFrame_AddMessageGroup(ChatFrame5, "LOOT")					-- 戰例品拾取
	ChatFrame_AddMessageGroup(ChatFrame1, "LOOT")					-- 戰例品拾取(P1)
	ChatFrame_AddMessageGroup(ChatFrame5, "CURRENCY")				-- 貨幣
	ChatFrame_AddMessageGroup(ChatFrame5, "MONEY")					-- 金錢
	
-- [[ MSG ]] --

	ChatFrame_AddMessageGroup(ChatFrame4, "WHISPER")				-- 密語
	ChatFrame_AddMessageGroup(ChatFrame4, "BN_WHISPER")				-- 戰網對話
	ChatFrame_AddMessageGroup(ChatFrame4, "BN_CONVERSATION")		-- 戰網對話
	ChatFrame_AddMessageGroup(ChatFrame4, "SYSTEM")					-- 系統
	ChatFrame_AddMessageGroup(ChatFrame4, "IGNORED")				-- 忽略
	
-- [[ 職業染色 ]] --

	ToggleChatColorNamesByClassGroup(true, "SAY")
	ToggleChatColorNamesByClassGroup(true, "EMOTE")
	ToggleChatColorNamesByClassGroup(true, "YELL")
	ToggleChatColorNamesByClassGroup(true, "GUILD")
	ToggleChatColorNamesByClassGroup(true, "GUILD_OFFICER")
	ToggleChatColorNamesByClassGroup(true, "OFFICER")
	ToggleChatColorNamesByClassGroup(true, "GUILD_ACHIEVEMENT")
	ToggleChatColorNamesByClassGroup(true, "ACHIEVEMENT")
	ToggleChatColorNamesByClassGroup(true, "WHISPER")
	ToggleChatColorNamesByClassGroup(true, "PARTY")
	ToggleChatColorNamesByClassGroup(true, "PARTY_LEADER")
	ToggleChatColorNamesByClassGroup(true, "RAID")
	ToggleChatColorNamesByClassGroup(true, "RAID_LEADER")
	ToggleChatColorNamesByClassGroup(true, "RAID_WARNING")
	ToggleChatColorNamesByClassGroup(true, "BATTLEGROUND")
	ToggleChatColorNamesByClassGroup(true, "BATTLEGROUND_LEADER")  
	ToggleChatColorNamesByClassGroup(true, "INSTANCE_CHAT_LEADER")
	ToggleChatColorNamesByClassGroup(true, "INSTANCE_CHAT")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL1")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL2")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL3")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL4")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL5")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL6")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL7")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL8")

-- [[ 頻道染色 ]] --

	ChangeChatColor("CHANNEL1", 255/255, 192/255, 192/255)	-- 1綜合(預設顏色)
	ChangeChatColor("CHANNEL2", 255/255, 130/255, 130/255)	-- 2交易(橙紅色)
	ChangeChatColor("CHANNEL3", 255/255, 192/255, 192/255)	-- 3本地防務(預設顏色)
	ChangeChatColor("CHANNEL4", 150/255, 255/255, 185/255)	-- 4私人頻道(淺綠色)
	ChangeChatColor("CHANNEL5", 255/255, 255/255 ,150/255)	-- 5私人頻道(米黃色)
	ChangeChatColor("CHANNEL6", 180/255, 200/255 ,200/255)	-- 6私人頻道(藍灰色)
	ChangeChatColor("CHANNEL7", 195/255, 180/255 ,225/255)	-- 7私人頻道(淡紫色)
	ChangeChatColor("CHANNEL8", 150/255, 200/255 ,150/255)	-- 8私人頻道(綠色)

	-- 最後重載介面以應用
	ReloadUI()
end

-- [[ 載入確認/Load Settings ]] --

StaticPopupDialogs["SET_UI"] = {
		text = "載入預設的介面設定，查看EKCore/Setui",
		button1 = ACCEPT,
		button2 = CANCEL,
		OnAccept =  function() UIcfg() ReloadUI() end,
		timeout = 0,			-- 延遲消失，0為一直存在
		whileDead = true,		-- 死亡時顯示
		hideOnEscape = true,	-- 使esc可取消
		preferredIndex = 5,
}
SLASH_SETUI1 = "/setui"
SLASH_SETUI2 = "/SETUI"
SlashCmdList["SETUI"] = function()
		StaticPopup_Show("SET_UI")
end