local addon, ns = ... 
local C, F, G, L = unpack(ns)
if not C.SetUI then return end

if InCombatLockdown() then return end

local format = string.format
local SetCVar = C_CVar.SetCVar


--=================================================--
-----------------    [[ NOtes ]]    -----------------
--=================================================--
--[[
	巨集應用
	/run SetCVar("cvar", "值") 或 /console cvar 值
	查看當前值
	/dump GetCVar("cvar")
	
	重置所有為預設值
	/console cvar_default
	重置特定值為預設值
	/run SetCVar("cvar", GetCVarDefault("cvar")) 或 /console cvar_default cvar
	
	注意：cvar_reset 用法同 cvar_default，但這是重設為初始值，某些cvar的「初始值」和「預設值」不同
	https://warcraft.wiki.gg/wiki/CVar_cvar_reset
	https://github.com/Ketho/BlizzardInterfaceResources/blob/live/Resources/CVars.lua
]]--
--================================================--
-----------------    [[ CVar ]]    -----------------
--================================================--

-- [[ FCT CVar/浮動戰鬥文字 ]] --

local function SetFCTCfg()
	if not C.SetFCT then return end
	
	-- *自己的戰鬥文字捲動，啟用此項才能使進階選項更改生效：1開
	SetCVar("enableFloatingCombatText", 0)
	-- #浮動戰鬥文字的運動方式，1=往上，2=往下 ，3=弧形
	SetCVar("floatingCombatTextFloatMode", 1)
	-- #浮動戰鬥文字的運動方式，0=傳統，1以上=7.0新的運動方式
	SetCVar("floatingCombatTextCombatDamageDirectionalScale", 0)
	-- 文字偏移，預設1
	-- floatingCombatTextCombatDamageDirectionalOffset
	-- #全局浮動文字縮放，數值1~5，可以有小數點；會將所有的浮動文字提示一起放大，包括經驗值之類的文字。
	SetCVar("WorldTextScale", 1)
	-- #玩家對目標輸出
	SetCVar("floatingCombatTextCombatDamage", 0)		-- 傷害
	SetCVar("floatingCombatTextCombatHealing", 0)		-- 治療
	
	-- [[ 進階 / Advance ]] --
	
	-- 寵物對目標傷害
	SetCVar("floatingCombatTextPetMeleeDamage", 0)		-- #普攻
	SetCVar("floatingCombatTextPetSpellDamage", 0)		-- #技能
	-- 法術
	SetCVar("floatingCombatTextReactives", 0)			-- #法術警示
	SetCVar("floatingCombatTextAuras", 0)				-- #光環
	SetCVar("floatingCombatTextSpellMechanics", 0)		-- #顯示目標受到的糾纏效果（誘補、沉默、緩速）
	SetCVar("floatingCombatTextSpellMechanicsOther", 0)	-- #顯示其他玩家受到的糾纏效果
	-- 提示
	SetCVar("floatingCombatTextCombatState", 0)			-- #進入離開戰鬥文字提示
	SetCVar("floatingCombatTextLowManaHealth", 0)		-- #低魔低血文字提示
	SetCVar("floatingCombatTextFriendlyHealers", 0)		-- #友方治療者名稱
	-- 資源
	SetCVar("floatingCombatTextComboPoints", 0)			-- #連擊點
	SetCVar("floatingCombatTextEnergyGains", 0)			-- #資源獲得（法力、怒氣、能量、真氣，和連擊點不同）
	SetCVar("floatingCombatTextPeriodicEnergyGains", 0)	-- #周期性能量
	SetCVar("floatingCombatTextHonorGains", 0)			-- #榮譽擊殺
	SetCVar("floatingCombatTextRepChanges", 0)			-- #聲望變化
	-- 減傷
	SetCVar("floatingCombatTextCombatHealingAbsorbTarget", 0)	-- #對目標上盾和護甲提示
	SetCVar("floatingCombatTextCombatHealingAbsorbSelf", 0)		-- #自身得盾和護甲提示
	SetCVar("floatingCombatTextCombatDamageAllAutos", 0)		-- #顯示所有白字
	SetCVar("floatingCombatTextDodgeParryMiss", 0)				-- #閃避招架未命中
	SetCVar("floatingCombatTextDamageReduction", 0)				-- #傷害減免和抵抗
	SetCVar("floatingCombatTextCombatLogPeriodicSpells", 0)		-- #周期性傷害
	
	-- floatingCombatTextAllSpellMechanics
	-- enablePetBattleFloatingCombatText
end

-- [[ Name and Nameplates CVar/名稱與名條 ]] --

local function SetNPCfg()
	if not C.SetNP then return end
	
	-- [[ 名稱 / Names ]] --

	-- 顯示名稱
	SetCVar("UnitNameOwn", 0)					-- *我的名稱	
	SetCVar("UnitNameNPC", 1)					-- 顯示NPC名稱，1=所有，若使用此項則下面都為0
	SetCVar("UnitNameFriendlySpecialNPCName", 0)-- 顯示任務NPC名稱
	SetCVar("UnitNameInteractiveNPC", 0)		-- 顯示可互動NPC(小地圖可追蹤)名稱，
	SetCVar("UnitNameHostleNPC", 0)				-- 顯示敵方NPC名稱
	SetCVar("UnitNameNonCombatCreatureName", 0)	-- *小動物名稱，1開

	SetCVar("UnitNameFriendlyPlayerName", 1)	-- *顯示友方玩家
	-- UnitNameFriendlyMinionName
	SetCVar("UnitNameFriendlyPetName", 1)		-- *顯示友方僕從，一選項有三個cvar
	SetCVar("UnitNameFriendlyGuardianName", 1)
	SetCVar("UnitNameFriendlyTotemName", 1)
	
	SetCVar("UnitNameEnemyPlayerName", 1)		-- *顯示敵方玩家
	SetCVar("UnitNameEnemyPetName", 1)			-- *顯示敵方僕從，一選項有三個cvar
	SetCVar("UnitNameEnemyGuardianName", 1)
	SetCVar("UnitNameEnemyTotemName", 1)
	
	-- 顯示公會
	SetCVar("UnitNameGuildTitle", 0)			-- #公會頭銜，1開
	SetCVar("UnitNamePlayerPVPTitle", 1)		-- #*角色頭銜，1開
	-- SetCVar("UnitNamePlayerGuild", 1)		-- #*公會名稱，1開
	
	-- [[ 單位名條 / Nameplates ]] --
	
	-- 自身名條
	SetCVar("nameplateShowSelf", 0)				-- 顯示個人資源，1開
	SetCVar("nameplateResourceOnTarget", 0)		-- 將個人資源顯示在目標姓名板上，1開
	
	-- 大型名條，預設均是1
	SetCVar("NamePlateHorizontalScale", 1.2)	-- 預設大型名條寬 1.4
	SetCVar("NamePlateVerticalScale", 2.4)		-- 預設大型名條高 2.7
	
	-- 名條堆疊
	SetCVar("nameplateMotion", 1)				-- 名條排列，1=堆疊，0=重疊
	SetCVar("nameplateMotionSpeed", .01)		-- 名條位移速度，預設0.025
	SetCVar("nameplateOverlapH", .7) 			-- #水平堆疊百分比，預設0.8
	SetCVar("nameplateOverlapV", .9)			-- #垂直堆疊百分比，預設1.1
	
	-- 名條顯示
	SetCVar("nameplateShowAll", 1)				-- 總是顯示名條而不是只顯示選眾目標，1開
	SetCVar("nameplateShowEnemies", 1)			-- "V"鍵，啟用敵方名條
	-- SetCVar("nameplateOtherAtBase", 0)		-- #*名條位於頭頂，2=腳下
	SetCVar("ShowNamePlateLoseAggroFlash", 1)	-- *為坦克警示目標轉移，1開
	
	-- 敵方單位(v) -僕從
	SetCVar("nameplateShowEnemyMinions", 1)			-- 僕從
	SetCVar("nameplateShowEnemyMinus", 1)			-- 次要
	-- #敵方僕從子選項
	SetCVar("nameplateShowEnemyPets", 1)			-- 寵物
	SetCVar("nameplateShowEnemyGuardians", 1)		-- 守護者
	SetCVar("nameplateShowEnemyTotems", 1)			-- 圖騰
	
	-- 友方單位(shift+v) -僕從
	SetCVar("nameplateShowFriendlyMinions", 0)		-- 僕從
	SetCVar("nameplateShowFriendlyNPCs", 0)			-- #npc
	-- #友方僕從子選項
	SetCVar("nameplateShowFriendlyPets", 0)			-- 寵物
	SetCVar("nameplateShowFriendlyGuardians", 0)	-- 守護者
	SetCVar("nameplateShowFriendlyTotems", 0)		-- 圖騰
	
	-- #名條貼齊邊緣
	SetCVar("nameplateOtherTopInset", -1)			-- #預設=0.08
	SetCVar("nameplateOtherBottomInset", -1)		-- #預設=0.1
	
	-- 名條縮放
	SetCVar("nameplateGlobalScale", 1)				-- #*名條全局縮放
	SetCVar("nameplateSelectedScale", 1.2)			-- #選中名條縮放，即當前目標
	SetCVar("namePlateMinScale", 1)					-- #距離縮放，預設0.8
	SetCVar("namePlateMaxScale", 1)					-- #距離縮放，預設1
	-- SetCVar("nameplateMinScaleDistance", 10)		-- #*距離縮放的生效距離，預設10碼以外
	-- SetCVar("nameplateMaxScaleDistance", 10)
	
	-- 名條淡出
	-- SetCVar("nameplateMinAlpha", 1)				-- #距離淡出，預設0.6
	-- SetCVar("nameplateMaxAlpha", 1)				-- #距離淡出，預設1
	-- SetCVar("nameplateMinAlphaDistance", 10)		-- #*距離淡出的生效距離，預設10碼以外
	-- SetCVar("nameplateMaxAlphaDistance", 40)
	
	-- 名字模式
	-- SetCVar("nameplateShowOnlyNames", 0)			-- #*僅顯名字，1開
	-- SetCVar("nameplateShowDebuffsOnFriendly", 0) -- #顯示友方減益光環，1開
	
	-- #重要名條，如首領
	SetCVar("nameplateLargerScale", 1)				-- #縮放
	SetCVar("nameplateLargeTopInset", .08) 			-- #貼邊
	SetCVar("nameplateLargeBottomInset", .1)
	
	SetCVar("nameplateMaxDistance", 45)				-- #名條最大視距，預設60
	SetCVar("nameplateOccludedAlphaMult", .2)		-- #障礙物後名條透明度
	SetCVar("ShowClassColorInNameplate", 1)			-- #*姓名板職業染色，1開 
	
	-- 施法條
	SetCVar("showVKeyCastbar", 1)					-- #*顯示施法條，1開
	-- SetCVar("showVKeyCastbarOnlyOnTarget", 0)	-- #只顯示當前目標的施法條，1開
	SetCVar("showVKeyCastbarSpellName", 1)			-- #*顯示法術名稱，1開
	
	-- [[ Self nameplates ]] --
	
	-- #個人資源
	SetCVar("nameplateSelfScale", 1)				-- #*縮放
	SetCVar("showSpenderFeedback", 0)				-- #資源溢出閃光動畫效果，1開
	-- SetCVar ("nameplateSelfTopInset", .69999)	-- #固定，預設0.5
	-- SetCVar ("nameplateSelfBottomInset", .3)		-- #固定，預設0.2
	
	--#個人資源顯示條件
	SetCVar("nameplatePersonalShowAlways", 0)		-- #總是顯示，1開
	SetCVar("nameplatePersonalShowInCombat", 1)		-- #*戰鬥中顯示，平時隱藏，1開
	SetCVar("nameplatePersonalShowWithTarget", 1)	-- #有目標時顯示，平時隱藏，1開
	SetCVar("nameplatePersonalHideDelaySeconds", 3)	-- #*淡出消失的時間，數值是秒
end

-- [[ General CVar Load ]] --

local function SetCVarCfg()
	-- Reset at first: it only reset options show in in-game interface.
	--SettingsPanel:SetAllSettingsToDefaults()
	
	SetFCTCfg()
	SetNPCfg()
	
	-- [[ note ]] --

	-- # 為隱藏選項
	-- * 為遊戲預設
	
	-- [[ 系統 / System ]] --
	
	-- 影像
	
	--SetCVar("RenderScale", 1)	-- 繪製比例
	-- 垂直同步
	-- 低延遲模式
	-- 反鋸齒
	--CMAA
	--mxaa
	--視野

	-- UI縮放
	--SetCVar("useUiScale", 1)			-- 啟用UI縮放：1開
	--SetCVar("uiScale", scale)			-- 若上項設為1，則此處設置縮放比
	--SetCVar("minimumAutomaticUiScale", scale)	-- #高解析度停止ui縮放的閾值，避免小過頭，經典0.9正式0.64
	-- graphicsQuality 圖形品質
	
	-- 進階
	-- 陰影品質
	--SetCVar("waterDetail", 2)			-- 水體細節 0-2
	--SET refraction "1"

	-- 粒子密度
	--SetCVar("graphicsSSAO", 0)			-- SSAO
	--SetCVar("graphicsDepthEffects", 2)	--景深效果
	-- 計算效果
	--SetCVar("OutlineEngineMode", 2)	-- 顯著標示

	-- 材質解析度
	-- 法術密度
	-- 投影材質
	--graphicsProjectedTextures
	--projectedTextures
	-- 視野距離
	-- 環境細節
	-- 地面雜物
	-- 團隊副本圖形品質
	
	-- 圖隊和戰場
	
	-- 三倍緩衝
	-- 材質過濾
	-- 光跡追蹤陰影
	-- 環境遮蔽類別
	-- 重新採樣品質
	
	--SetCVar("useMaxFPS", 1)	-- 最大前景幀數
	--SetCVar("maxFPS",60)
	--SetCVar("maxFPSBk", 60)	-- 最大背景幀數
	-- 目標幀數
	--重新採樣銳利化
	
	--RestartGx()
	--[[
	SetCVar("Sound_MasterVolume", .5)		-- 主音量
	SetCVar("Sound_EnableEmoteSounds", 0)
	SetCVar("Sound_EnableAmbience", 0)
	SetCVar("Sound_AmbienceVolume", 0)
	SetCVar("Sound_DialogVolume", 0)
	SetCVar("Sound_EnableErrorSpeech", 0)	-- 錯誤提示音效，1開，巨集應用插件：https://www.curseforge.com/wow/addons/quietmacros
	SetCVar("Sound_MusicVolume", 0)
	SetCVar("Sound_EnablePetBattleMusic", 0)
	SetCVar("Sound_EnablePetSounds", 0)
	SetCVar("Sound_EnableDialog", 0)
	SetCVar("Sound_EnableMusic", 0)
	SetCVar("Sound_EnableSoundWhenGameIsInBG", 1)
	SetCVar("Sound_EnablePositionalLowPassFilter", 0)
	SetCVar("Sound_SFXVolume", 0)
	SetCVar("Sound_EnableSFX", 0)
	SetCVar("Sound_EnableReverb", 0)
	SetCVar("Sound_NumChannels", 128)		-- 音效頻道，預設64
	]]--
	
	SetCVar("combatLogRetentionTime", 300)
	
	-- #紀錄
	SetCVar("advancedCombatLogging", 1)	-- 啟用進階戰鬥紀錄
	SetCVar("scriptErrors", 1)				-- #*顯示 LUA 錯誤：1 開
	-- #*顯示 XML 錯誤：1 開，受保護，必需 SET AllowDangerousScripts "1"
	-- SetCVar("enableSourceLocationLookup", 1) 
	--SetCVar("taintLog", 1)				-- #顯示污染紀錄：0=關，1=開，2=詳細，最多可到11
	--SetCVar("scriptProfile", 1)			-- #顯示 CPU 占用（供插件調用）
	
	-- #截圖
	SetCVar("screenshotQuality", 10)	-- #品質（慎改，10 最高）
	SetCVar("screenshotFormat", "jpg")	-- #格式：JPG/TGA ETC.
	
	-- #特效
	SetCVar("violenceLevel", 5)			-- #*反暴力等級：0=開，1=綠血，5=最高
	SetCVar("ffxGlow", 0)				-- #全螢幕泛光：1開
	SetCVar("ffxDeath", 0)				-- #死亡特效：1開
	SetCVar("SkyCloudLOD", 0)			-- #*天空特效：0-3
	SetCVar("weatherDensity", 3)		-- #*天氣特效: 0-3
	
	-- [[ 其他/Others ]] --
	
	-- #在滑鼠提示中顯示任務進度：1開
	SetCVar("showQuestTrackingTooltips", 0)
	-- #跨甲或同模型塑形收藏提示：1開
	SetCVar("missingTransmogSourceInItemTooltips", 1)
	-- 延遲載入遊戲模組，設為 0 解決 Legion 卡藍條，目前不需要：預設2
	-- SetCVar("worldPreloadNonCritical", 2)
	
	-- [[ 控制/Control ]] --

	SetCVar("deselectOnClick", 1)		-- 鎖定目標：1關
	SetCVar("autoDismount", 1)			-- #*自動解除座騎：1開
	SetCVar("autoDismountFlying", 0)	-- *自動解除飛行座騎：1開
	SetCVar("autoClearAFK", 0)			-- 自動清除暫離：1開
	SetCVar("interactOnLeftClick", 0)	-- 左鍵進行互動：1開
	SetCVar("lootUnderMouse", 1)		-- *拾取框跟隨滑鼠：1開
	SetCVar("autoLootDefault", 1)		-- 自動拾取：1開
	SetCVar("autoOpenLootHistory", 0)	-- #自動打開拾取紀錄：1開
	SetCVar("autoLootRate", 100)		-- #自動拾取速度：預設 150 毫秒
	SetCVar("combinedBags", 1)			-- 整合背包
	SetCVar("displayFreeBagSlots", 0)	-- #顯示背包剩餘空間：1開
	-- SetCVar("expandBagBar, 0)		-- #展開背包與選單列，1開
	-- 啟用互動鍵
	-- 互動鍵聲音提示
	
	-- [[ 滑鼠 ]] --

	-- 將游標鎖定在視窗內
	-- *反轉滑鼠
	-- #*滑鼠觀察速度（滑鼠改變鏡頭視角時的移動速度）
	-- *啟用滑鼠靈敏度
	-- 靈敏度數值
	SetCVar("Autointeract", 0)			-- *點擊移動
	-- 點擊移動模式
	SetCVar("UberTooltips", 1)			-- #*滑鼠進階提示：1開
	SetCVar("alwaysCompareItems", 0)	-- #*自動裝備對比：1開
	
	-- [[ 鏡頭/camera ]] --

	SetCVar("cameraWaterCollision", 0)			-- *水體碰撞，1開
	-- 自動跟隨速度
	SetCVar("cameraSmoothStyle", 0)				-- 鏡頭跟隨模式，預設4，0=永不調整，1=只調整水平面，2=總是調整，4=只有移動時調整
	-- SetCVar("cameraTerrainTilt", 0)			-- #*鏡頭跟隨地形，爬坡時往上，下坡時往下
	-- SetCVar("cameraYawMoveSpeed", 180)		-- #*左右移動速度，預設180，90-270
	-- SetCVar("cameraPitchMoveSpeed", 90)		-- #*上下移動速度，預設90，90-270，通常設為左右速率的一半
	-- SetCVar("cameraYawSmoothSpeed", 180)		-- #*啟用鏡頭跟隨模式的自動調整(0以外)時，鏡頭視角的改變速度，90-270
	-- SetCVar("cameraPivot", 1)				-- #*當鏡頭在地上時讓你能夠自由地貼地旋轉視角，1開；若關閉會使視角一路拉近至你的人物跨下
	-- SetCVar("cameraBobbing", 0)				-- #*第一人稱相機抖動，搖頭晃腦？1開
	SetCVar("cameraSmoothTrackingStyle", 0)		-- #引導施法不轉視角
	SetCVar("cameraDistanceMaxZoomFactor", 2.6)	-- #最遠視距，1-2.6 (/run print(GetCameraZoom()))

	-- [[ 介面 ]]--
	
	--遊戲內導航
	--教學說明
	SetCVar("Outline", 3)							-- 顯著標示
	SetCVar("statusTextDisplay","PERCENT")			-- 狀態文字，數值="NUMERIC"，百分比="PERCENT"，兩者="BOTH"
	-- SetCVar("statusText", 0)					-- #只在滑鼠移過時顯示狀態文字
	SetCVar("chatBubbles", 1)					-- *對話泡泡：1=全開
	-- SetCVar("chatBubblesParty", 1)			-- #隊伍對話泡泡：1開
	-- 團隊隊話泡泡
	-- 更換玩家框架頭像
	-- 更換我的框架頭像


	-- [[ 任務 ]] --
	--顯示戰隊已完成
	--顯示低等級

	-- [[ 團隊框架 ]] --

	-- [[ 快捷列/Action Bar ]] --

	SetCVar("lockActionBars", 1)				-- #*鎖定，1開
	SetCVar("countdownForCooldowns", 0)			-- *冷卻計時，1開

	SetCVar("multiBarRightVerticalLayout", 0)	-- *垂直堆疊右方快捷列
	SetCVar("alwaysShowActionBars", 0)			-- *總是顯示，1開
	SetCVar("xpBarText", 1)						-- #顯示經驗值數值，1開，0=指向顯示
	SetCVar("alternateResourceText", 1)			-- 顯示替代資源(alternate power)
	SetCVar("ActionButtonUseKeyDown", 1)		-- #*按下按鍵時施放技能，1開
	SetCVar("SpellQueueWindow", 250)			-- #*技能隊列，0-400
	SetCVar("secureAbilityToggle", 1)			-- #*切換技能時觸發保險，1開

	-- [[ 戰鬥/Combat ]] --
	
	--顯示個人資源
	SetCVar("findYourselfMode", 1)					-- 團隊醒目標示，0=圓圈，1=圓圈和外框，2=外框
	-- #模型醒目標示的場合
	SetCVar("findYourselfAnywhere", 0)				-- #總是顯示
	SetCVar("findYourselfAnywhereOnlyInCombat", 1)	-- #總是在戰鬥中顯示
	SetCVar("findYourselfInBG", 0)					-- #總是在戰場顯示
	SetCVar("findYourselfInBGOnlyInCombat", 1)		-- #總是在戰場的戰鬥中顯示
	SetCVar("findYourselfInRaid", 0)				-- #總是在團隊中顯示
	SetCVar("findYourselfInRaidOnlyInCombat", 1)	-- #總是在團隊的戰鬥中顯示
	--遮蔽時顯示剪影
	SetCVar("showTargetOfTarget", 1)		-- 目標的目標：1開
	SetCVar("showTargetCastbar", 1)			-- #*目標頭像顯示施法條：1開
	SetCVar("noBuffDebuffFilterOnTarget", 1)-- #顯示目標所有的增減益效果：1開
	SetCVar("TargetNearestUseNew", 1)		-- #*Tab最近的目標：1開
	-- SetCVar("threatShowNumeric", 1)		-- #*目標頭像上顯示仇恨百分比：1開
	-- SetCVar("comboPointLocation",1)		-- #在目標頭像上顯示連擊點：1=目標，2=自己
	SetCVar("doNotFlashLowHealthWarning", 0)	-- *低生命力閃動螢幕：0開
	-- 失控警告
	SetCVar("lossOfControl", 1)				-- *喪失控制警告：1開
	SetCVar("lossOfControlFull", 2)			-- #所有控場：0=關，1=顯示提示，2=顯示倒數
	SetCVar("lossOfControlSilence", 2)		-- #平靜警告
	SetCVar("lossOfControlInterrupt", 2)	-- #打斷警告
	SetCVar("lossOfControlDisarm", 2)		-- #暈眩警告
	SetCVar("lossOfControlRoot", 1)			-- #定身警告
	-- 自己的戰鬥文字捲動：見FCT
	-- 施法
	-- 滑鼠指向施法
	SetCVar("autoSelfCast", 0)					-- 自我施法，0=無，1=自動
	--專注施法
	--聚能法術
	SetCVar("displaySpellActivationOverlays", 1)	-- #顯示法術警示：1開
	SetCVar("spellActivationOverlayOpacity", 0.65)	-- *法術警示透明度：預設 0.65
	--按住施放
	--行動鎖定
	SetCVar("assistAttack", 0)					-- #協助(/assist)時開啟攻擊：1開
	SetCVar("stopAutoAttackOnTargetChange", 0)	-- #切換目標後停止自動攻擊：1開
	SetCVar("breakUpLargeNumbers", 1)			-- #浮動戰鬥文字逗點和大數值縮寫：1開
	SetCVar("predictedHealth", 1)				-- #預估治療和預估能量，框體顯示即將到來的治療：1開

	-- [[ 社交/Social ]] --

	--關閉聊天
	SetCVar("spamFilter", 1)			-- *濫發訊息過濾器，1開
	SetCVar("profanityFilter", 0)		-- 不當言詞過濾器，1開
	SetCVar("guildMemberNotify", 1)		-- *公會成員上下線提示，1開
	SetCVar("BlockTrades", 0)			-- *阻止交易，1開
	--阻止公會邀請
	--封鎖社區邀請
	SetCVar("blockChannelInvites", 0)	-- *封鎖對話頻道邀請，1開
	SetCVar("guildShowOffline", 0)		-- #顯示公會離線成員，1開
	SetCVar("showToastOnline", 1)		-- *線上好友，1開
	SetCVar("showToastOffline", 1)		-- *離線好友，1開
	SetCVar("showToastBroadcast",1)		-- 公告更新，1開
	--顯示位置
	SetCVar("showToastFriendRequest",1)	-- *好友邀請提示
	SetCVar("showToastWindow",1)		-- *顯示通知視窗
	--自動接受快速加入
	SetCVar("chatStyle", "classic")		-- *聊天方式："im"=即時通訊方式，"classic"=傳統模式
	SetCVar("whisperMode", "inline")	-- *新的密語："inline"=內嵌，"popout"=新分頁，"popout_and_inline"=兩者
	-- 對話時間標記(24小時制時分秒)
	SetCVar("showTimestamps", "%I:%M:%S")
	-- #對其他人只顯示角色成就

	-- 聊天視窗
	-- SetCVar("removeChatDelay", 0)		-- Remove Chat Hover Delay / 移除對話視窗的分頁延遲(?)
	-- SetCVar("chatMouseScroll", 1)		--#*啟用聊天框滾輪捲動，1開
	-- SetCVar("chatClassColorOverride", 0)	-- #聊天框「不」顯示職業顏色，1開，0=染色，1=不染色，2=傳統
	-- SetCVar("colorChatNamesByClass", 1)	-- #聊天框顯示職業顏色，1開，好像上面那個才有用吧
	
	--[[ 指示系統 ]]--
	--[[ 遊戲體驗強化 ]]--
	--[[ 名條 ]]--


	--[[ 音效輔助 ]]--
	SetCVar("remoteTextToSpeech", 0)		-- 關閉語音轉文字
	

	
	--[[ 顯示 ]]--
	
	SetCVar("hideAdventureJournalAlerts", 0)	-- *地圖冒險指南提示：0開
	SetCVar("showTutorials", 0)					-- 教學說明：1開
	SetCVar("showNPETutorials", 0)				-- #新內容(這並沒有什麼鳥用)：1開


	
	-- [[ 顯示/Display ]] --

	
	SetCVar("rotateMinimap", 0)		-- 旋轉小地圖：1開
	SetCVar("mapFade", 1)			-- #*移動時大地圖半透明，1開
	SetCVar("autoQuestWatch", 1)	-- #*接任務後自動追蹤直到完成，1開
	SetCVar("autoQuestProgress", 1)	-- #進入一個任務目的地時會自動觀察任務，1開

	SetCVar("cursorsizepreferred", 2)	-- #更大的滑鼠遊標，32/48/64/96/128
	-- SetCVar("enableWowMouse", 0)		-- 啟用Steelseries滑鼠
	-- SetCVar("enableMouseSpeed", 0)
	
	SetCVar("rawMouseEnable", 1)				-- #啟用魔獸世界滑鼠，讓驅動接管，可修復游標位置重置bug，1開
	-- SetCVar("rawMouseAccelerationEnable", 1)	-- #*啟用滑鼠加速，1開
	-- SetCVar("rawMouseRate", 125)				-- #*滑鼠更新速路
	-- SetCVar("rawMouseResolution", 400)		-- #*滑鼠DPI
	
	-- [[ 協助工具 ]] --
	
	-- SetCVar("enableMovePad", 0)	-- *移動面板，1開
	SetCVar("movieSubtitle", 1)		-- *動畫字幕，1開
	SetCVar("colorblindMode", 0)	-- *色盲模式，1開
	
	-- SetCVar("ShakeStrengthUI", 4)-- *#畫面暈眩，1=角色置中，2=減少鏡頭晃動，3=1+2，4=允許鏡頭晃動
	
	-- 最後重載介面以應用
	-- ReloadUI()
end	

--=======================================================--
-----------------    [[ Compactraid ]]    -----------------
--=======================================================--

-- [[ Compactraid style settings / 團隊檔案 ]] --
--[[
local function SetRaidCfg()
	-- 在小隊使用團隊風格的隊伍框架
	SetCVar("useCompactPartyFrames", 1)
	
	-- 不能以這種方式設定
	-- SetCVar("raidOptionKeepGroupsTogether", 1)			-- 隊伍排列
	-- SetCVar("raidFramesDisplayPowerBars", 1)				-- 顯示能量條
	-- SetCVar("raidFramesDisplayAggroHighlight", 1)		-- 顯示獲得仇恨
	-- SetCVar("raidFramesDisplayClassColor", 1)			-- 顯示職業顏色
	-- SetCVar("raidOptionDisplayPets", 0)					-- 顯示寵物
	-- SetCVar("raidOptionDisplayMainTankAndAssist", 0)		-- 顯示主坦與主助攻
	-- SetCVar("raidOptionShowBorders", 0)					-- 顯示邊框
	-- SetCVar("raidFramesDisplayOnlyDispellableDebuffs", 0)-- 只顯示可驅散，1開
	-- SetCVar("raidFramesHealthText", "none")				-- HP值
	-- SetCVar("raidFramesHeight", 44)						-- 高度
	-- SetCVar("raidFramesWidth", 90)						-- 寬度
	
	-- showArenaEnemyCastbar	-- 顯示競技場敵方施法條
	-- showArenaEnemyFrames		-- 顯示競技場敵方框架
	-- showArenaEnemyPets		-- 顯示競技場敵方寵物框架
	-- showPartyBackground		-- 在隊伍成員和競技場敵對成員背後顯示背景(what?)
	-- showPartyPets			-- 顯示隊友寵物
	
	SetCVar("useCompactPartyFrames", 1)																		-- 使用團隊風格的小隊框架
	-- SetCVar("activeCUFProfile","主檔案")
	SetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, "keepGroupsTogether", true)				-- 小隊相連
	SetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, "displayHealPrediction", true)			-- 預估治療
	SetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, "displayPowerBar", true)					-- 能量
	SetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, "displayAggroHighlight", true)			-- 仇恨
	SetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, "useClassColors", true)					-- 職業顏色
	SetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, "displayPets", false)					-- 寵物
	SetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, "displayMainTankAndAssist", false)		-- 主坦克與主助攻
	SetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, "displayBorder", false)					-- 邊框
	SetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, "displayOnlyDispellableDebuffs", false)	-- 只顯示可驅散
	
	SetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, "autoActivate2Players", true)
	SetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, "autoActivate3Players", true)
	SetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, "autoActivate5Players", true)
	SetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, "autoActivate10Players", true)
	SetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, "autoActivate15Players", true)
	SetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, "autoActivate25Players", true)
	SetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, "autoActivate40Players", true)
	SetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, "autoActivateSpec1", true)
	SetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, "autoActivateSpec2", true)
	SetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, "autoActivateSpec3", true)
	SetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, "autoActivatePvP", true)
	SetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, "autoActivatePvE", true)
	
	-- 大小
	SetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, "frameWidth", 160)
	SetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, "frameHeight", 70)
	
	-- 應用設定
	CompactUnitFrameProfiles_SaveChanges(CompactUnitFrameProfiles)
	CompactUnitFrameProfiles_ApplyCurrentSettings()
	
	-- 最後重載介面以應用
	-- ReloadUI()
end
]]--
-- [[ Switch compactraid position / 動態切換團隊框架的位置以保持布局 ]]--
--[[
local function SwitchRaid()
	local num = GetNumGroupMembers()
	-- if InCombatLockdown() then return end
	-- /run EnableAddOn("Blizzard_CompactRaidFrames");EnableAddOn("Blizzard_CUFProfiles")
	--GetCVar("activeCUFProfile")
	if CompactRaidFrameContainer then
		if num > 20 then
			SetRaidProfileSavedPosition(GetActiveRaidProfile(), false, "TOP", 580, "BOTTOM", 250, "LEFT", 1750)	-- 超過20
		else
			SetRaidProfileSavedPosition(GetActiveRaidProfile(), false, "TOP", 580, "BOTTOM", 460, "LEFT", 1750)	-- 20
		end
		-- 應用設定
		CompactUnitFrameProfiles_SaveChanges(CompactUnitFrameProfiles) 
		CompactUnitFrameProfiles_ApplyCurrentSettings()
	end
	
	-- 最後重載介面以應用
	-- ReloadUI()
end
]]--
--================================================--
-----------------    [[ Chat ]]    -----------------
--================================================--

-- [[ Default chat frame size and position ]] --

local function DefaultChatPos()
	if not C.ForceChatPos then return end
	
	for i = 1, NUM_CHAT_WINDOWS do
		local frame = _G[format("ChatFrame%s", i)]
		
		-- 大小和位置
		if i == 1 then
			frame:SetUserPlaced(true)	-- 使其能夠置底
			frame:ClearAllPoints()
			frame:SetWidth(C.ChatWidth)
			frame:SetHeight(C.ChatHeight)
			--frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 10, 20)
			frame:SetPoint(unpack(C.ChatPoint))
		end
		
		FCF_SavePositionAndDimensions(frame)
		FCF_SetChatWindowFontSize(self, frame, C.ChatFontSize)
	end
end

-- [[ Load chat settings ]]--

local function SetChatCfg()
	if not C.SetChat then return end
	
	-- 重置
	FCF_ResetChatWindows()
	
	-- [[ Create new tabs ]]--
	
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
	
	-- Load default position
	DefaultChatPos()
	
	-- Renamed tabs / 命名分頁
	for i = 1, NUM_CHAT_WINDOWS do
		local frame = _G[format("ChatFrame%s", i)]
		
		if i == 1 then
			FCF_SetWindowName(frame, GENERAL)
		elseif i == 2 then
			FCF_SetWindowName(frame, COMBAT_LOG)
		elseif i == 3 then
			FCF_SetWindowName(frame, TRADE)
		elseif i == 4 then
			FCF_SetWindowName(frame, CHAT)
		elseif i == 5 then
			FCF_SetWindowName(frame, LOOT)
		end
	end
	
	-- [[ GENERAL ]] --

	-- 移除用 ChatFrame_RemoveMessageGroup
	
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
	ChatFrame_AddMessageGroup(ChatFrame1, "BN_INLINE_TOAST_ALERT")	-- 戰網廣播
	ChatFrame_AddMessageGroup(ChatFrame1, "PET_BATTLE_INFO")		-- 寵物戰鬥紀錄
	-- 怪物
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_SAY")			-- 怪物說話
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_EMOTE")			-- 怪物表情
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_YELL")			-- 怪物大喊
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_WHISPER")		-- 怪物密語
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_BOSS_EMOTE")		-- 首領表情
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_BOSS_WHISPER")	-- 首領密語
	-- 狀態
	ChatFrame_AddMessageGroup(ChatFrame1, "AFK")
	ChatFrame_AddMessageGroup(ChatFrame1, "DND")

	-- [[ LOOT ]] --

	ChatFrame_AddMessageGroup(ChatFrame5, "COMBAT_XP_GAIN")			-- 經驗值
	ChatFrame_AddMessageGroup(ChatFrame5, "COMBAT_HONOR_GAIN")		-- 榮譽值
	ChatFrame_AddMessageGroup(ChatFrame5, "COMBAT_FACTION_CHANGE")	-- 聲望值
	ChatFrame_AddMessageGroup(ChatFrame5, "SKILL")					-- 專業技能
	ChatFrame_AddMessageGroup(ChatFrame5, "LOOT")					-- 戰例品拾取
	ChatFrame_AddMessageGroup(ChatFrame5, "CURRENCY")				-- 貨幣
	ChatFrame_AddMessageGroup(ChatFrame5, "MONEY")					-- 金錢
	
	ChatFrame_AddMessageGroup(ChatFrame1, "LOOT")					-- 戰例品拾取(P1)
	
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
end

--==================================================--
-----------------    [[ Others ]]    -----------------
--==================================================--

-- [[ Stop putting spells into my bars, thank you ]]--

local function NewSpell()
	if C.NewSpell then
		IconIntroTracker:RegisterEvent("SPELL_PUSHED_TO_ACTIONBAR")
		UnregisterStateDriver(IconIntroTracker, "visibility")
	else
		IconIntroTracker:UnregisterAllEvents()
		RegisterStateDriver(IconIntroTracker, "visibility", "hide")
	end
end

-- [[ Hide tutorial ]] --

local function NoTutorial()
	if not C.NoTutorial then return end

	-- Remove shipyard tutorails
	local cvar = {
		"shipyardMissionTutorialFirst",
		"shipyardMissionTutorialBlockade",
		"shipyardMissionTutorialAreaBuff",
		}
	
	for k, v in ipairs(cvar) do
		if (tonumber(GetCVar(v)) == 0) then
			SetCVar(v, 1)
		end
	end
	
	-- Remove Void Storage tutorails
	local cvar2 = {
		astGarrisonMissionTutorial = 4294934528,
		orderHallMissionTutorial = 4294934528,
		lastVoidStorageTutorial = 3,
		}
	
	for k, v in pairs(cvar2) do
		if not GetCVar(k) or (tonumber(GetCVar(k)) ~= v) then
			SetCVar(k, v)
		end
	end
	
	-- Remove newbie tutorials
	for i = 1, NUM_LE_FRAME_TUTORIALS do
		C_CVar.SetCVarBitfield("closedInfoFrames", i, true)
	end
end

-- [[ Force load default seetings ]] --

local function DefaultSettings()

	SetCVar("overrideArchive", 0)

	SetGuildNewsFilter(1, 0)
	SetGuildNewsFilter(2, 0)
	SetGuildNewsFilter(3, 0)
	SetGuildNewsFilter(4, 0)
	SetGuildNewsFilter(5, 0)
	SetGuildNewsFilter(6, 0)
	SetGuildNewsFilter(7, 0)
	SetGuildNewsFilter(8, 0)
	SetGuildNewsFilter(9, 0)
	
	-- Interface
	SetCVar("cameraDistanceMaxZoomFactor", 2.6)			-- 最遠視距，預設1.9，1-2.6
	BossBanner:UnregisterAllEvents()					-- 不顯示首領橫幅：擊敗首領/團隊拾取
	-- GroupLootContainer:UnregisterAllEvents()			-- 不顯示團隊拾取框
	SetCVar("ffxGlow", 0)
	SetCVar("ffxDeath", 0)

	-- #玩家對目標輸出
	SetCVar("floatingCombatTextCombatDamage", 0)		-- 傷害
	SetCVar("floatingCombatTextCombatHealing", 0)		-- 治療
	
	-- Nameplates
	-- NamePlateDriverFrame:UpdateNamePlateOptions()	-- 強制名條更新
	-- InterfaceOptionsNamesPanelUnitNameplatesMakeLarger:SetValue(1)
	
	-- ActionBar
	SetActionBarToggles(true, false, true, false)		-- 自動啟用快捷列：左下右下右一右二
	--InterfaceOptions_UpdateMultiActionBars()			-- 強制快捷列更新以套用設定
	
	-- Bags: sort order
	C_Container.SetSortBagsRightToLeft(true)			-- 順向整理背包
	C_Container.SetInsertItemsLeftToRight(true)			-- 反向放置戰利品
	
	-- Guild
	SetCVar("guildRosterView", "playerStatus")			-- 公會預設排列方式：玩家狀態
	SetAutoDeclineGuildInvites(false)					-- 不要自動拒絕公會邀請
	
	-- Collection: show alreadyknow
	C_MountJournal.SetCollectedFilterSetting(2, false)	-- 座騎
	C_ToyBox.SetUncollectedShown(false)					-- 玩具
	C_PetJournal.SetFilterChecked(2)					-- 寵物
	C_Heirloom.GetUncollectedHeirloomFilter(2)			-- 傳家寶
	-- C_TransmogCollection.SetShowMissingSourceInItemTooltips(true)	-- 塑型未收集提示
	
	-- Fonts: globaly change quest fonts
	QuestTitleFont:SetFont(STANDARD_TEXT_FONT, 24, "")		-- 標題
	QuestTitleFont:SetShadowOffset(0, 0)
	QuestFont:SetFont(STANDARD_TEXT_FONT, 24, "")			-- 描述
	QuestFont:SetShadowOffset(0, 0)
	QuestFontNormalSmall:SetFont(STANDARD_TEXT_FONT, 24, "")-- 目標
	QuestFontNormalSmall:SetShadowOffset(0, 0)
	--QuestFontHighlight:SetFont(STANDARD_TEXT_FONT, 18)	-- 內容
	--QuestFontHighlight:SetShadowOffset(0, 0)
end

-- [[ Load functions ]] --

local function OnEvent()
	NewSpell()
	--NoTutorial()
	DefaultSettings()
	DefaultChatPos()
	--self:UnregisterEvent("PLAYER_LOGIN")
end

local function OnSlash()
	SetCVarCfg()
	--SetRaidCfg()
	SetChatCfg()
	ReloadUI()
end

-- [[ 載入設定 / Load Settings ]] --

local frame = CreateFrame("FRAME", nil)
	--frame:RegisterEvent("PLAYER_LOGIN") -- VARIABLES_LOADED/PLAYER_LOGIN/ADDON_LOADED/PLAYER_ENTERING_WORLD
	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	frame:SetScript("OnEvent", OnEvent)

-- [[ Slasm CMD ]] --

SlashCmdList["SETCHAT"] = function()
	DefaultChatPos()
end
SLASH_SETCHAT1 = "/setchat"

SlashCmdList["SETRAID"] = function()
	SetRaidCfg()
end
SLASH_SETRAID1 = "/setraid"
--[[
SlashCmdList["SWITCH"] = function()
	SwitchRaid()
end
SLASH_SWITCH1 = "/swr"
]]--
StaticPopupDialogs["SET_UI"] = {
		text = "載入預設的介面設定，將會重載介面。\n具體內容查看 !Anyon/SetUI",
		button1 = ACCEPT,
		button2 = CANCEL,
		--OnAccept =  function() SetCVarCfg() SetRaidCfg() SetChatCfg() ReloadUI() end,
		OnAccept =  function() OnSlash() end,
		timeout = 0,			-- 延遲消失，0為一直存在
		whileDead = true,		-- 死亡時顯示
		hideOnEscape = true,	-- 使esc可取消
		preferredIndex = 5,
}

SlashCmdList["SETUI"] = function()
	StaticPopup_Show("SET_UI")
end
SLASH_SETUI1 = "/setui"
