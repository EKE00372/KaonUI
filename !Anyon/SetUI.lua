local addon, ns = ...
local C = unpack(ns)
if not C.SetUI then return end

if InCombatLockdown() then return end

local SetCVar = C_CVar.SetCVar

--=================================================--
-----------------    [[ NOtes ]]    -----------------
--=================================================--
--[[
	巨集應用
	/run SetCVar("cvar", "值")
	/console cvar 值
	查看當前值
	/dump GetCVar("cvar")
	重置所有為預設值
	/console cvar_default
	重置特定值為預設值
	/run SetCVar("cvar", GetCVarDefault("cvar")) 或 /console cvar_default cvar

	注意：cvar_reset 用法同 cvar_default，但這是重設為初始值，某些cvar的「初始值」和「預設值」不同
	https://warcraft.wiki.gg/wiki/CVar_cvar_reset
	https://github.com/Ketho/BlizzardInterfaceResources/blob/ptr/Resources/CVars.lua
	https://github.com/BigWigsMods/WoWUI/tree/ptr
]]--
--================================================--
-----------------    [[ CVar ]]    -----------------
--================================================--

-- ! = 設定值與預設值不同
-- # = 非遊戲內選項
-- * = Secure CVar，插件只能在戰鬥外修改

-- [[ FCT CVar/浮動戰鬥文字 ]] --

local function SetFCTCfg()
	if not C.SetFCT then return end

	SetCVar("enableFloatingCombatText", 0)			-- 預設 0；自己的戰鬥文字總開關，關閉時下列進階項目不生效
	SetCVar("floatingCombatTextFloatMode_v2", 1)	-- # 預設 1；戰鬥文字運動方向，1=向上、2=向下、3=弧形

	-- !# 預設 1；0=停用方向位移（傳統位置）、1=標準倍率、>0=方向位移倍率，數字越大位移越大
	SetCVar("floatingCombatTextCombatDamageDirectionalScale_v2", 0)
	-- # 預設 1；方向性傷害文字的起始偏移量；0=無額外偏移、1=標準偏移、>1=數字越大偏移越大
	SetCVar("floatingCombatTextCombatDamageDirectionalOffset_v2", 1)	
	-- # 預設 1；範圍 1~5 並接受小數，縮放所有世界浮動文字，包含傷害、治療、經驗值等
	SetCVar("WorldTextScale_v2", 1)

	-- 玩家對目標輸出
	SetCVar("floatingCombatTextCombatDamage_v2", 0)		-- !# 預設 1；玩家輸出傷害
	SetCVar("floatingCombatTextCombatHealing_v2", 0)	-- !# 預設 1；玩家輸出治療

	-- [[ 進階 / Advance ]] --

	-- 寵物對目標傷害
	SetCVar("floatingCombatTextPetMeleeDamage_v2", 0)	-- !# 預設 1；寵物普攻傷害
	SetCVar("floatingCombatTextPetSpellDamage_v2", 0)	-- !# 預設 1；寵物技能傷害
	SetCVar("enablePetBattleFloatingCombatText_v2", 1)	-- # 預設 1；寵物對戰浮動戰鬥文字

	-- 提示
	SetCVar("floatingCombatTextCombatState_v2", 0)		-- # 預設 0；進入離開戰鬥提示
	SetCVar("floatingCombatTextLowManaHealth_v2", 0)	-- !# 預設 1；低生命力/低法力提示
	SetCVar("floatingCombatTextFriendlyHealers_v2", 0)	-- # 預設 0；治療者名稱
	SetCVar("floatingCombatTextReactives_v2", 0)		-- !# 預設 1；法術或技能可用提示
	SetCVar("floatingCombatTextAuras_v2", 0)			-- # 預設 0；自身獲得或失去光環

	-- 資源
	SetCVar("floatingCombatTextComboPoints_v2", 0)			-- # 預設 0；連擊點獲得
	SetCVar("floatingCombatTextEnergyGains_v2", 0)			-- # 預設 0；法力、怒氣、能量、真氣、符文等資源獲得
	SetCVar("floatingCombatTextPeriodicEnergyGains_v2", 0)	-- # 預設 0；週期性資源獲得
	SetCVar("floatingCombatTextHonorGains_v2", 0)			-- # 預設 0；榮譽獲得
	SetCVar("floatingCombatTextRepChanges_v2", 0)			-- # 預設 0；聲望變化

	-- 吸收、閃避與週期傷害
	SetCVar("floatingCombatTextCombatHealingAbsorbTarget_v2", 0)-- !# 預設 1；目標吸收盾數值
	SetCVar("floatingCombatTextCombatHealingAbsorbSelf_v2", 0)	-- !# 預設 1；自身吸收盾數值
	SetCVar("floatingCombatTextCombatDamageAllAutos_v2", 0)		-- !# 預設 1；自動攻擊白字
	SetCVar("floatingCombatTextDodgeParryMiss_v2", 0)			-- # 預設 0；未命中、閃避、招架、免疫、偏斜、反射
	SetCVar("floatingCombatTextDamageReduction_v2", 0)			-- # 預設 0；抵抗、格擋、吸收等減傷結果
	SetCVar("floatingCombatTextCombatLogPeriodicSpells_v2", 0)	-- !# 預設 1；週期性傷害
end

-- [[ Name and Nameplates CVar/名稱與名條 ]] --

local function SetNPCfg()
	if not C.SetNP then return end

	-- [[ 名稱 / Names ]] --

	SetCVar("UnitNameOwn", 0)						-- 預設 0；我的名稱
	SetCVar("UnitNameNPC", 1)						-- ! 預設 0；1=所有 NPC 名稱，啟用時下列 NPC 分類會被覆蓋
	SetCVar("UnitNameFriendlySpecialNPCName", 0)	-- ! 預設 1；任務與特殊 NPC
	SetCVar("UnitNameInteractiveNPC", 0)			-- ! 預設 1；可互動 NPC
	SetCVar("UnitNameHostleNPC", 1)					-- 預設 1；敵方 NPC；Hostile暴雪拼成 Hostle
	SetCVar("UnitNameNonCombatCreatureName", 0)		-- 預設 0；小動物

	SetCVar("UnitNameFriendlyPlayerName", 1)		-- 預設 1；友方玩家
	SetCVar("UnitNameFriendlyMinionName", 1)		-- 預設 1；友方僕從總開關
	SetCVar("UnitNameFriendlyPetName", 1)			-- # 預設 1；友方寵物
	SetCVar("UnitNameFriendlyGuardianName", 1)		-- # 預設 1；友方守護者
	SetCVar("UnitNameFriendlyTotemName", 1)			-- # 預設 1；友方圖騰

	SetCVar("UnitNameEnemyPlayerName", 1)			-- 預設 1；敵方玩家
	SetCVar("UnitNameEnemyMinionName", 1)			-- 預設 1；敵方僕從總開關
	SetCVar("UnitNameEnemyPetName", 1)				-- # 預設 1；敵方寵物
	SetCVar("UnitNameEnemyGuardianName", 1)			-- # 預設 1；敵方守護者
	SetCVar("UnitNameEnemyTotemName", 1)			-- # 預設 1；敵方圖騰

	SetCVar("UnitNameGuildTitle", 0)				-- !# 預設 1；公會頭銜
	SetCVar("UnitNamePlayerPVPTitle", 1)			-- # 預設 1；角色頭銜
	SetCVar("UnitNamePlayerGuild", 1)				-- # 預設 1；公會名稱

	-- [[ 單位名條 / Nameplates ]] --

	-- 名條多選 CVar 使用版本 byte + mask 資料 byte，12.1 版本 byte 是 "\002"
	-- 權重為 1、2、4、8、16、32，資料 byte = 0x40 + mask：A=1、B=2、C=3、D=4、E=5、G=7、[=27、_=31

	-- 顯示
	SetCVar("nameplateShowAll", 1)		-- ! 預設 0；總是顯示名條
	SetCVar("nameplateShowCastBars", 1)	-- #* 預設 1；顯示施法條
	SetCVar("nameplateShowSelf", 0)		-- * 預設 0；顯示個人資源
	SetCVar("showSpenderFeedback", 0)	-- !# 預設 1；資源溢出閃光

	-- 非簡易名條的名字是否顯示，與 UnitName* 系列 CVar 聯動
	-- 例：如果 UnitNameFriendlyPetName 為 0 則敵方寵物名條也不顯示名字，除非是當前目標
	-- 設為 1 則無視 UnitName* 系列設定，強制顯示名字
	SetCVar("nameplateForceShowUnitName", 0)		-- #* 預設 0

	-- 簡易名條顯示類型：0=無、1=僕從、2=次要敵人、4=友方玩家、8=友方 NPC
	SetCVar("nameplateSimplifiedTypes", "\002C")	-- * 預設 "\002" (0)
	SetCVar("nameplateSimplifiedScale", .3)			-- #* 預設 0.3；簡易名條縮放，範圍 0.15~1
	
	-- 顯示敵方單位
	SetCVar("nameplateShowEnemies", 1)			-- 預設 1；敵方名條
	SetCVar("nameplateShowEnemyMinions", 1)		-- ! 預設 0；僕從
	SetCVar("nameplateShowEnemyMinus", 1)		-- * 預設 1；次要敵人
	SetCVar("nameplateShowEnemyPets", 1)		-- !#* 預設 0；寵物
	SetCVar("nameplateShowEnemyGuardians", 1)	-- !#* 預設 0；守護者
	SetCVar("nameplateShowEnemyTotems", 1)		-- !#* 預設 0；圖騰

	-- 顯示友方單位
	-- SetCVar("nameplateShowFriendlyPlayers", 0)		-- 預設 0；友方玩家
	SetCVar("nameplateShowFriendlyPlayerMinions", 0)	-- 預設 0；友方僕從
	SetCVar("nameplateShowFriendlyNpcs", 0)				-- 預設 0；友方 NPC
	SetCVar("nameplateShowFriendlyPlayerPets", 0)		-- #* 預設 0；友方寵物
	SetCVar("nameplateShowFriendlyPlayerGuardians", 0)	-- #* 預設 0；友方守護者
	SetCVar("nameplateShowFriendlyPlayerTotems", 0)		-- #* 預設 0；友方圖騰

	-- 外觀
	-- 名條尺寸，數字越大尺寸越大
	-- SetCVar("nameplateSize", 4)					-- !* 預設 1，範圍 1~5，整數
	-- 名條外觀，0=現代、1=細、2=方塊、3=生命優先、4=施法優先、5=傳統
	SetCVar("nameplateStyle", 0)					-- * 預設 0
	-- 名條位置，0=頭頂、1=敵方腳下、2=全部腳下
	SetCVar("nameplateOtherAtBase", 0)				-- #* 預設 0
	SetCVar("nameplateShowClassColor", 1)			-- * 預設 1；敵方玩家血條職業染色
	SetCVar("nameplateShowFriendlyClassColor", 1)	-- * 預設 1；友方玩家血條職業染色
	SetCVar("nameplatePlayRemovalAnimation", 1)		-- #* 預設 1；名條移除動畫

	-- 堆疊
	SetCVar("nameplateStackingTypes", "\002A")		-- ! 預設 "\002" (0)；0=無、1=敵方、2=友方
	SetCVar("nameplateOverlapH", .6) 				-- !#* 預設 0.8；水平堆疊間距
	SetCVar("nameplateOverlapV", .8)				-- !#* 預設 1.1；垂直堆疊間距

	-- 友方名字模式
	SetCVar("nameplateShowOnlyNameForFriendlyPlayerUnits", 0)		-- 預設 0；名字模式
	SetCVar("nameplateUseClassColorForFriendlyPlayerUnitNames", 1)	-- 預設 0；職業顏色
	SetCVar("nameplateShowFriendlyRealmName", 0)					-- ! 預設 1；顯示伺服器
	SetCVar("nameplateShowDebuffsOnFriendly", 0)					-- !#* 預設 1；顯示減益

	-- 顯示距離
	SetCVar("nameplateMaxDistance", 60)				-- !#* 預設 60
	SetCVar("nameplatePlayerMaxDistance", 60)		-- #* 預設 60；玩家名條
	SetCVar("nameplateGameObjectMaxDistance", 30)	-- #* 預設 30；物件名條

	-- 顯示條件
	-- 徑向定位：以畫面中心為基準，根據單位相對方向，把離屏名條投影到畫面左右及下方邊緣
	-- 例：單位在畫面左側外，則名條在左側貼邊；單位由左側往左後移動，名條「走弧線」往左下移動
	-- 白話文：徑向定位 = 模擬鏡頭，沿圓弧貼邊；非徑向定位 = 按矩形畫面邊界夾持及堆疊
	-- showOffscreen=1 & radial=0 畫面外顯示的名條，不使用徑向定位
	-- showOffscreen=1 & radial=1 畫面外顯示的名條，只有當前目標使用徑向定位
	-- showOffscreen=1 & radial=2 畫面外顯示的名條，全部使用徑向定位
	SetCVar("nameplateShowOffscreen", 1)			-- !* 預設 0；顯示畫面外名條 (目標/交戰)
	SetCVar("nameplateTargetBehindMaxDistance", 40)	-- #* 預設 0.1；鏡頭後方目標名條顯示距離
	SetCVar("nameplateTargetRadialPosition", 2)		-- #* 預設 0；畫面外名條顯示方式；0=關、1=僅目標、2=戰鬥中全部
	SetCVar("nameplateCheckDistanceForTarget", 0)	-- #* 預設 0；1=當前目標也受最大距離限制
	SetCVar("nameplateOccludedAlphaMult", 0.2)		-- !#* 預設 0.4；障礙物後名條透明度

	-- 目標淡出和縮放
	SetCVar("nameplateSelectedScale", 1)		-- !#* 預設 1.2；當前目標縮放
	SetCVar("nameplateSelectedAlpha", 1)		-- #* 預設 1
	SetCVar("nameplateNotSelectedAlpha", -1)	-- #* 預設 -1 (停用)

	-- 距離淡出和縮放
	SetCVar("nameplateMaxAlpha", 1)				-- #* 預設 1
	SetCVar("nameplateMaxAlphaDistance", 40)	-- #* 預設 40
	SetCVar("nameplateMaxScale", 1)				-- #* 預設 1
	SetCVar("nameplateMaxScaleDistance", 40)	-- #* 預設 10
	SetCVar("nameplateMinAlpha", 1)				-- !#* 預設 0.6
	SetCVar("nameplateMinAlphaDistance", 40)	-- #* 預設 10
	SetCVar("nameplateMinScale", 1)				-- !#* 預設 0.8
	SetCVar("nameplateMinScaleDistance", 40)	-- #* 預設 10

	-- 名條資訊，0=無、1=生命百分比、2=目前生命值、4=稀有圖示
	SetCVar("nameplateInfoDisplay", "\002C")	-- ! 預設 "\002D" (4)
	-- 仇恨資訊，0=無、1=漸進、2=閃爍、4=血條染色
	SetCVar("nameplateThreatDisplay", "\002B")	-- ! 預設 "\002" (0)
	-- 施法資訊，0=無、1=法術名、2=圖示、4=目標、8=高亮重要施法、16=高亮目標是自己
	SetCVar("nameplateCastBarDisplay", "\002[")	-- 預設 "\002[" (27)

	-- 光環
	SetCVar("nameplateAuraScale", 1)				-- * 預設 1；光環尺寸，範圍 0.7~1.4，最小單位 0.1
	SetCVar("nameplateDebuffPadding", 0)			-- * 預設 0；光環間距，範圍 0~50，最小單位 1
	-- 擴展個人光環法術清單，顯示 DOT 和混沌烙印/奧秘之掌等被動易傷
	SetCVar("nameplateShowAllPersonalAuras", 0)		-- #* 預設 0

	-- 敵方NPC光環資訊，0=無、1=敵方增益、2=你施放的減益、4=控場
	SetCVar("nameplateEnemyNpcAuraDisplay", "\002G")		-- 預設 "\002G" (7)
	-- 敵方玩家光環資訊，0=無、1=敵方增益、2=你施放的減益、4=控場
	SetCVar("nameplateEnemyPlayerAuraDisplay", "\002G")		-- 預設 "\002G" (7)
	-- 友方玩家光環資訊，0=無、1=你施放的增益、2=玩家減益、4=控場
	SetCVar("nameplateFriendlyPlayerAuraDisplay", "\002C")	-- 預設 "\002C" (3)
end

-- [[ Visual CVar/影像 ]] --

local function SetVisualCfg()
	-- SetCVar("RenderScale", 1)			-- 預設 1；範圍由 GetMinRenderScale()/GetMaxRenderScale() 決定
	-- SetCVar("vsync", 1)					-- 預設 1；垂直同步
	-- SetCVar("LowLatencyMode", 0)			-- 預設 0；範圍 0~4，最小單位 1；0=無、1=內建、2=Reflex、3=Reflex+Boost、4=XeLL
	-- SetCVar("ffxAntiAliasingMode", 0)	-- 預設 0；範圍 0~4，最小單位 1；0=無、1=FXAA低、2=FXAA高、3=CMAA、4=CMAA2
	-- SetCVar("MSAAQuality", 0)			-- 預設 0；0=無，其他可用值由 MultiSampleAntiAliasingSupported() 決定
	-- SetCVar("cameraFov", 90)				-- 預設 90 度；範圍由 GetCameraFOVDefaults() 決定，最小單位 5 度

	-- UI 縮放
	-- SetCVar("useUiScale", 1)		-- !* 預設 0；啟用 UI 縮放
	-- SetCVar("uiScale", 1)		-- * 預設 1；範圍 0.65~1.15

	-- 圖形品質
	-- SetCVar("graphicsQuality", 6)			-- 預設 6；範圍 0~9，最小單位 1
	-- SetCVar("graphicsShadowQuality", 3)		-- 預設 3；範圍 0~5，最小單位 1
	-- SetCVar("waterDetail", 2)				-- !# 預設 0；舊引擎水體細節，範圍 0~2，最小單位 1
	-- SetCVar("graphicsLiquidDetail", 2)		-- 預設 2；12.1 GUI 水體細節，範圍 0~3，最小單位 1
	-- SetCVar("graphicsParticleDensity", 4)	-- 預設 4；範圍 0~5，最小單位 1
	-- SetCVar("graphicsSSAO", 0)				-- ! 預設 3；範圍 0~4，最小單位 1
	-- SetCVar("graphicsDepthEffects", 2)		-- ! 預設 3；範圍 0~3，最小單位 1
	-- SetCVar("graphicsComputeEffects", 3)		-- 預設 3；範圍 0~4，最小單位 1
	-- SetCVar("OutlineEngineMode", 2)			-- !# 預設 0；舊引擎外框模式，12.1 未公開範圍與步進
	-- SetCVar("graphicsOutlineMode", 2)		-- 預設 2；12.1 GUI 外框品質，範圍 0~2，最小單位 1
	-- SetCVar("graphicsTextureResolution", 2)	-- 預設 2；範圍 0~2，最小單位 1
	-- SetCVar("graphicsSpellDensity", 1)		-- 預設 1；範圍 0~2，最小單位 1；0=最低、1=降低、2=完整
	-- SetCVar("graphicsProjectedTextures", 1)	-- 預設 1；投影材質
	-- SetCVar("graphicsViewDistance", 6)		-- 預設 6；範圍 0~9，最小單位 1
	-- SetCVar("graphicsEnvironmentDetail", 6)	-- 預設 6；範圍 0~9，最小單位 1
	-- SetCVar("graphicsGroundClutter", 6)		-- 預設 6；範圍 0~9，最小單位 1

	-- 團隊副本圖形品質
	-- SetCVar("RAIDsettingsEnabled", 0)			-- 預設 0；啟用獨立團隊副本圖形設定
	-- SetCVar("RAIDgraphicsQuality", 6)			-- 預設 6；範圍 0~9，最小單位 1
	-- SetCVar("raidGraphicsShadowQuality", 3)		-- 預設 3；範圍 0~5，最小單位 1
	-- SetCVar("raidGraphicsLiquidDetail", 2)		-- 預設 2；範圍 0~3，最小單位 1
	-- SetCVar("raidGraphicsParticleDensity", 4)	-- 預設 4；範圍 0~5，最小單位 1
	-- SetCVar("raidGraphicsSSAO", 3)				-- 預設 3；範圍 0~4，最小單位 1
	-- SetCVar("raidGraphicsDepthEffects", 3)		-- 預設 3；範圍 0~3，最小單位 1
	-- SetCVar("raidGraphicsComputeEffects", 3)		-- 預設 3；範圍 0~4，最小單位 1
	-- SetCVar("raidGraphicsOutlineMode", 2)		-- 預設 2；範圍 0~2，最小單位 1
	-- SetCVar("raidGraphicsTextureResolution", 2)	-- 預設 2；範圍 0~2，最小單位 1
	-- SetCVar("raidGraphicsSpellDensity", 1)		-- 預設 1；範圍 0~2，最小單位 1
	-- SetCVar("raidGraphicsProjectedTextures", 1)	-- 預設 1
	-- SetCVar("raidGraphicsViewDistance", 6)		-- 預設 6；範圍 0~9，最小單位 1
	-- SetCVar("raidGraphicsEnvironmentDetail", 6)	-- 預設 6；範圍 0~9，最小單位 1
	-- SetCVar("raidGraphicsGroundClutter", 6)		-- 預設 6；範圍 0~9，最小單位 1

	-- 進階影像
	-- SetCVar("GxMaxFrameLatency", 3)		-- 預設 3；三倍緩衝 GUI 在 2 與 3 間切換，最小單位 1
	-- SetCVar("textureFilteringMode", 5)	-- 預設 5；範圍 0~5，最小單位 1；0=雙線性、1=三線性、2~5=2x/4x/8x/16x
	-- SetCVar("shadowRt", 0)				-- 預設 0；光線追蹤陰影，範圍 0~3，最小單位 1
	-- SetCVar("vrsValar", 0)				-- 預設 0；可變速率著色，範圍 0~2，最小單位 1
	-- SetCVar("ResampleQuality", 3)		-- 預設 3；範圍 0~3，最小單位 1；0=最近點、1=雙線性、2=雙三次、3=FSR
	-- SetCVar("ResampleSharpness", .2)		-- 預設 0.2；範圍 0~2，最小單位 0.1；0=最銳利

	-- FPS
	-- SetCVar("useMaxFPS", 1)		-- ! 預設 0；啟用前景 FPS 上限
	-- SetCVar("maxFPS", 60)		-- ! 預設 120；範圍 8~200 FPS，最小單位 1 FPS
	-- SetCVar("useMaxFPSBk", 1)	-- 預設 1；啟用背景 FPS 上限
	-- SetCVar("maxFPSBk", 60)		-- ! 預設 30；範圍 8~200 FPS，最小單位 1 FPS
	-- SetCVar("useTargetFPS", 1)	-- 預設 1；啟用目標 FPS
	-- SetCVar("targetFPS", 60)		-- 預設 60；範圍 8~200 FPS，最小單位 1 FPS

	-- 隱藏特效
	SetCVar("violenceLevel", 5)				-- !# 預設 2；血腥等級，範圍 0~5，整數
	SetCVar("ffxGlow", 0)					-- !# 預設 1；全螢幕泛光
	SetCVar("ffxDeath", 0)					-- !# 預設 1；死亡特效
	SetCVar("SkyCloudLOD", 0)				-- # 預設 0；雲霧，範圍 0~3，整數
	SetCVar("weatherDensity", 3)			-- !# 預設 2；天氣，範圍 0~3，整數
end

-- [[ Audio CVar/音效 ]] --

local function SetAudioCfg()
	-- 音效；音量範圍均為 0~1，最小單位 0.05
	--[[
	SetCVar("Sound_MasterVolume", .5)			-- ! 預設 1；主音量
	SetCVar("Sound_EnableEmoteSounds", 0)		-- ! 預設 1；表情音效
	SetCVar("Sound_EnableAmbience", 0)			-- ! 預設 1；環境音效
	SetCVar("Sound_AmbienceVolume", 0)			-- ! 預設 0.6；環境音量
	SetCVar("Sound_DialogVolume", 0)			-- ! 預設 1；對話音量
	SetCVar("Sound_EnableErrorSpeech", 0)		-- ! 預設 1；錯誤語音
	SetCVar("Sound_MusicVolume", 0)				-- ! 預設 0.4；音樂音量
	SetCVar("Sound_EnablePetBattleMusic", 0)	-- ! 預設 1；寵物對戰音樂
	SetCVar("Sound_EnablePetSounds", 0)			-- ! 預設 1；寵物音效
	SetCVar("Sound_EnableDialog", 0)			-- ! 預設 1；對話
	SetCVar("Sound_EnableMusic", 0)				-- ! 預設 1；音樂

	SetCVar("Sound_EnableSoundWhenGameIsInBG", 1)		-- ! 預設 0；背景執行時播放音效
	SetCVar("Sound_EnablePositionalLowPassFilter", 0)	-- ! 預設 1；距離低通濾波

	SetCVar("Sound_SFXVolume", 0)				-- ! 預設 1；效果音量
	SetCVar("Sound_EnableSFX", 0)				-- ! 預設 1；效果音效
	SetCVar("Sound_EnableReverb", 0)			-- ! 預設 1；殘響
	SetCVar("Sound_NumChannels", 128)			-- ! 預設 64；範圍 20~128，最小單位 1
	]]--
end

-- [[ General CVar Load ]] --

local function SetCVarCfg()
	-- 只會重設暴雪選項介面有登錄的設定
	-- SettingsPanel:SetAllSettingsToDefaults()
	-- 重置所有CVar
	ConsoleExec("cvar_default")

	SetFCTCfg()
	SetNPCfg()
	SetAudioCfg()

	-- [[ 系統 / System ]] --

	-- 記錄與除錯
	SetCVar("advancedCombatLogging", 1)		-- ! 預設 0；進階戰鬥記錄
	SetCVar("combatLogRetentionTime", 300)	-- # 預設 300 秒；戰鬥記錄保留時間
	SetCVar("scriptErrors", 1)				-- !# 預設 0；顯示 Lua 錯誤
	SetCVar("enableSourceLocationLookup", 1)-- # 預設 1；紀錄 UI 元素來源檔名，方便除錯
	-- SetCVar("taintLog", 0)				-- !# 預設 0；污染紀錄，需要再開，一般用1/2即可，查看 https://warcraft.wiki.gg/wiki/CVar_taintLog
	-- SetCVar("scriptProfile", 1)			-- !# 預設 0；插件 Lua CPU 執行時間統計
	
	-- 截圖
	SetCVar("screenshotFormat", "jpg")		-- !# 預設 "jpeg"；截圖格式，可用 JPEG/TGA
	SetCVar("screenshotQuality", 10)		-- !# 預設 3；截圖品值，範圍 1~10，整數
	-- 其他
	-- SetCVar("worldPreloadNonCritical", 2)-- # 預設 2；非關鍵世界資料預載，設為0會把模型延後到藍條完建立，別亂動

	-- [[ 控制 / Controls ]] --

	SetCVar("deselectOnClick", 1)		-- ! 預設 0；1=鎖定目標
	SetCVar("autoDismount", 1)			-- # 預設 1；自動解除座騎
	SetCVar("autoDismountFlying", 0)	-- 預設 0；自動解除飛行座騎
	SetCVar("autoClearAFK", 0)			-- ! 預設 1；自動清除暫離
	SetCVar("interactOnLeftClick", 0)	-- ! 預設 1；左鍵進行互動
	SetCVar("lootUnderMouse", 1)		-- 預設 1；拾取框跟隨滑鼠
	SetCVar("autoLootDefault", 1)		-- ! 預設 0；自動拾取
	SetCVar("autoLootRate", 10)			-- !# 預設 150 毫秒；拾取延遲
	SetCVar("combinedBags", 1)			-- ! 預設 0；整合背包
	SetCVar("expandBagBar", 0)			-- !# 預設 1；展開所有背包按鈕
	-- 互動鍵
	SetCVar("softTargetInteract", 3)				-- !* 預設 1；啟用互動鍵，1；0=關、1=手把、2=鍵鼠、3=全部
	SetCVar("softTargettingInteractKeySound", 0)	-- 預設 0；互動鍵聲音提示，目標可互動時播放

	-- 滑鼠
	SetCVar("ClipCursor", 0)				-- 預設 0；將游標鎖定在遊戲視窗內
	SetCVar("mouseInvertPitch", 0)			-- 預設 0；反轉滑鼠
	-- 滑鼠觀察速度，在 GUI 中是滑杆設定 1~10 且垂直為水平的一半，直接設定CVAR則不受此限制
	-- SetCVar("cameraYawMoveSpeed", 180)	-- 預設 180；水平鏡頭速度；範圍 90~270，最小單位 10
	-- SetCVar("cameraPitchMoveSpeed", 90)	-- 預設 90；垂直鏡頭速度；範圍 45~135，最小單位 5
	-- 滑鼠靈敏度
	-- SetCVar("enableMouseSpeed", 0)		-- 預設 0；調整滑鼠靈敏度
	-- SetCVar("mouseSpeed", .025)			-- 預設 0.025；滑鼠靈敏度範圍 0.5~1.4，最小單位 0.05
	SetCVar("autoInteract", 0)				-- 預設 0；點擊移動
	
	--SetCVar("enableWowMouse", 0)			-- # 預設 0；SteelSeries WoW 滑鼠支援
	SetCVar("rawMouseEnable", 1)			-- !# 預設 0；誰來計算滑鼠移動量，0=系統，1=遊戲
	SetCVar("mouseAcceleration", -1)		-- # 預設 -1；滑鼠加速度，0=關，1=開，-1=跟隨系統設定
	SetCVar("MouseHiddenInRelativeMode", 0)	-- !# 預設1；按住滑鼠轉調視角時是否隱藏游標
	

	SetCVar("UberTooltips", 1)				-- # 預設 1；進階提示資訊，0=只有物品法術名稱，1=有描述
	SetCVar("alwaysCompareItems", 0)		-- !# 預設 1；自動比較裝備
	SetCVar("missingTransmogSourceInItemTooltips", 1)	-- !# 預設 0；提示未收集外觀

	-- 鏡頭
	SetCVar("cameraWaterCollision", 0)		-- 預設 0；水體碰撞
	-- 自動跟隨速度，在 GUI 中是滑杆設定 1~10 且垂直為水平的四分之一，直接設定CVAR則不受此限制
	-- SetCVar("cameraYawSmoothSpeed", 180)	-- 預設 180；自動跟隨水平速度；範圍 90~270，最小單位 10
	-- SetCVar("cameraPitchSmoothSpeed", 45)-- 預設 45；自動跟隨垂直速度；範圍 22.5~67.5，最小單位 2.5
	SetCVar("cameraSmoothStyle", 0)			-- ! 預設 4；鏡頭跟隨模式，0=永不、1=智慧水平、2=總是、4=移動時
	SetCVar("cameraSmoothTrackingStyle", 0)	-- ! 預設 4；點擊移動的鏡頭跟隨模式
	
	-- SetCVar("cameraTerrainTilt", 0)		-- # 預設 0；鏡頭跟隨地形
	-- SetCVar("cameraPivot", 1)				-- # 預設 1；貼地時允許環繞角色旋轉
	-- SetCVar("cameraBobbing", 0)				-- # 預設 0；第一人稱鏡頭晃動
	SetCVar("cameraDistanceMaxZoomFactor", 2.6)	-- !# 預設 1.9；範圍 1~2.6，最小單位 0.1

	-- [[ 介面 / Interface ]] --

	SetCVar("showInGameNavigation", 1)			-- 預設 1；遊戲內導航
	SetCVar("showTutorials", 0)					-- ! 預設 1；教學說明
	SetCVar("showNPETutorials", 0)				-- !# 預設 1；新手體驗教學
	SetCVar("Outline", 3)						-- ! 預設 2；互動標示，0=無，1=任務，2=任務與指向，3=任務、指向與目標
	SetCVar("ShowQuestUnitCircles", 1)			-- # 預設 1；顯著標示，任務 NPC 腳下的淡黃色任務指示圈
	SetCVar("statusText", 1)					-- ! 預設 0；狀態文字，0=指向顯示，1=常駐顯示
	SetCVar("statusTextDisplay", "PERCENT")		-- ! 預設 "NONE"；可用 NONE/NUMERIC/PERCENT/BOTH
	SetCVar("chatBubbles", 1)					-- 預設 1；對話泡泡
	SetCVar("chatBubblesParty", 1)				-- 預設 1；隊伍對話泡泡
	SetCVar("chatBubblesRaid", 0)				-- 預設 0；團隊對話泡泡
	SetCVar("ReplaceOtherPlayerPortraits", 0)	-- 預設 0；玩家頭像改用職業圖示
	SetCVar("ReplaceMyPlayerPortrait", 0)		-- 預設 0；自己頭像改用職業圖示
	SetCVar("worldMapShowPlayerCoords", 1)		-- 預設 1；世界地圖顯示玩家座標
	SetCVar("worldMapShowCursorCoords", 1)		-- 預設 1；世界地圖顯示游標座標

	SetCVar("breakUpLargeNumbers", 1)			-- # 預設 1；大數值分隔與縮寫

	-- [[ 快捷列 / Action Bar ]] --

	SetCVar("lockActionBars", 1)			-- 預設 1；鎖定快捷列
	SetCVar("countdownForCooldowns", 0)		-- 預設 0；冷卻倒數
	SetCVar("xpBarText", 1)					-- !# 預設 0；經驗條數值，0=指向顯示，1=常駐顯示
	SetCVar("alternateResourceText", 1)		-- # 12.1 FrameXML 仍讀取此 CVar，但 metadata 未公開預設值
	SetCVar("ActionButtonUseKeyDown", 1)	-- #* 預設 1；按下按鍵時施放技能
	SetCVar("SpellQueueWindow", 250)		-- !# 預設 400 毫秒；施法隊列，範圍 0~400，最小單位 1 毫秒
	SetCVar("secureAbilityToggle", 1)		-- # 預設 1；技能切換保護

	-- [[ 戰鬥 / Combat ]] --

	-- 自我醒目標示
	SetCVar("findYourselfModeCircle", 1)	-- ! 預設 0；圓圈
	SetCVar("findYourselfModeOutline", 1)	-- ! 預設 0；外框
	SetCVar("findYourselfModeIcon", 0)		-- 預設 0；圖示
	-- 自我醒目標示顯示條件
	SetCVar("findYourselfAnywhere", 0)				-- 預設 0；總是顯示
	SetCVar("findYourselfAnywhereOnlyInCombat", 1)	-- !# 預設 0；戰鬥中顯示
	SetCVar("findYourselfInBG", 0)					-- !# 預設 1；戰場中顯示
	SetCVar("findYourselfInBGOnlyInCombat", 1)		-- !# 預設 0；戰場戰鬥中顯示
	SetCVar("findYourselfInRaid", 0)				-- !# 預設 1；團隊中顯示
	SetCVar("findYourselfInRaidOnlyInCombat", 1)	-- # 預設 1；團隊戰鬥中顯示

	SetCVar("occludedSilhouettePlayer", 0)		-- 預設 0；角色被遮蔽時顯示剪影
	SetCVar("showTargetOfTarget", 1)			-- !* 預設 0；顯示目標的目標
	SetCVar("doNotFlashLowHealthWarning", 0)	-- 預設 0；低生命力螢幕警告，0=啟用
	SetCVar("showTargetCastbar", 1)				-- # 預設 1；顯示目標框架施法條
	SetCVar("noBuffDebuffFilterOnTarget", 1)	-- !# 預設 0；顯示目標所有增減益
	SetCVar("TargetNearestUseNew", 1)			-- # 預設 1；新版 Tab 最近目標
	SetCVar("threatShowNumeric", 0)				-- !# 預設 0；目標框架仇恨百分比
	SetCVar("comboPointLocation", 2)			-- # 預設 2；連擊點位置，1=目標框架、2=玩家框架
	SetCVar("assistAttack", 0)					-- # 預設 0；協助攻擊
	SetCVar("stopAutoAttackOnTargetChange", 0)	-- # 預設 0；切換目標時停止自動攻擊

	-- 喪失控制警告
	SetCVar("lossOfControl", 1)				-- 預設 1；總開關
	SetCVar("lossOfControlFull", 2)			-- # 預設 2；昏迷，0=關、1=提示、2=倒數
	SetCVar("lossOfControlSilence", 2)		-- # 預設 2；沉默
	SetCVar("lossOfControlInterrupt", 2)	-- # 預設 2；打斷
	SetCVar("lossOfControlDisarm", 2)		-- # 預設 2；繳械
	SetCVar("lossOfControlRoot", 2)			-- # 預設 2；定身

	SetCVar("enableMouseoverCast", 0)				-- * 預設 0；滑鼠指向施法
	SetCVar("autoSelfCast", 0)						-- ! 預設 1；自動自我施法
	SetCVar("empowerTapControls", 0)				-- 預設 0；蓄能施法條，0=按住蓄力，鬆開施放、1=按一下開始，再按一下施放
	SetCVar("displaySpellActivationOverlays", 1)	-- 預設 1；法術警示總開關
	SetCVar("spellActivationOverlayOpacity", .65)	-- 預設 0.65；範圍 0~1，最小單位 0.05
	SetCVar("ActionButtonUseKeyHeldSpell", 0)		-- * 預設 0；按住施放，只在暴雪原生快捷列可用
	SetCVar("softTargetEnemy", 1)					-- * 預設 1；行動鎖定；0=關、1=手把、2=鍵鼠、3=全部

	-- [[ 社交 / Social ]] --

	-- C_SocialRestrictions.SetChatDisabled(false) -- 關閉聊天
	SetCVar("excludedCensorSources", 3)		-- 預設 1；即時聊天過濾；0=所有、1=好友、3=好友+公會、255=不過濾
	SetCVar("profanityFilter", 0)			-- ! 預設 1；不當言詞過濾
	SetCVar("guildMemberNotify", 1)			-- 預設 1；公會成員上下線提示
	SetCVar("blockTrades", 0)				-- 預設 0；阻止交易
	SetCVar("restrictCalendarInvites", 1)	-- 預設 1；只接受好友與公會的行事曆邀請
	SetCVar("blockChannelInvites", 0)		-- 預設 0；封鎖聊天頻道邀請
	
	SetCVar("guildShowOffline", 0)			-- !# 預設 1；公會名冊顯示離線成員
	SetCVar("showToastOnline", 1)			-- 預設 1；好友上線通知
	SetCVar("showToastOffline", 1)			-- 預設 1；好友下線通知
	SetCVar("showToastBroadcast", 1)		-- ! 預設 0；好友公告更新
	-- SetAllowRecentAlliesSeeLocation(true) 	-- 「近期盟友」能否在社交介面看到你目前所在的地區
	SetCVar("showToastFriendRequest", 1)		-- 預設 1；好友邀請通知
	SetCVar("showToastWindow", 1)				-- 預設 1；顯示通知視窗
	SetCVar("autoAcceptQuickJoinRequests", 0)	-- 預設 0；自動接受快速加入
	
	SetCVar("chatStyle", "im")				-- 預設 "im"；聊天方式，im=每個分頁都有自己的輸入框，classic=共用
	SetCVar("whisperMode", "inline")		-- ! 預設 "popout"；可用 inline/popout/popout_and_inline
	SetCVar("showTimestamps", "%H:%M:%S")	-- ! 預設 "none"
	SetCVar("chatMouseScroll", 1)			-- # 預設 1；滾輪滾動聊天紀錄
	SetCVar("chatClassColorOverride", 0)	-- # 預設 0；0=職業染色、1=不染色、2=傳統
	SetCVar("colorChatNamesByClass", 1)		-- !# 預設 0；聊天名稱職業染色

	-- [[ 指示系統 / Ping System ]] --

	SetCVar("enablePings", 1)			-- 預設 1；啟用指示系統
	SetCVar("pingMode", 0)				-- 預設 0；0=快速指示，1=輕鬆指示
	SetCVar("pingTarget", 0)			-- 預設 0；指示目標，0=全部、1=環境、2=單位
	SetCVar("showPingsInChat", 1)		-- 預設 1；在聊天視窗顯示指示詳情
	SetCVar("showPingsOnRaidFrames", 1)	-- 預設 1；在團隊框架顯示指示

	-- 此組也會鏡像顯示於 ESC > 選項 > 音效
	-- SetCVar("Sound_EnablePingSounds", 1)	-- 預設 1；指示音效
	-- SetCVar("Sound_PingVolume", 1)		-- 預設 1；指示音量，範圍 0~1，最小單位 0.05

	-- [[ 進階選項 / Advanced Options ]] --

	-- 協助戰鬥
	-- SetCVar("assistedCombatReduceHighlights", 1)	-- 預設 1；單鍵助手在快捷列時減少法術高亮動畫
	-- SetCVar("assistedCombatHighlight", 0)			-- 預設 0；高亮下一個建議施放的技能

	-- 首領警告
	-- SetCVar("combatWarningsEnabled", 1)			-- 預設 1；首領警告總開關
	-- SetCVar("encounterWarningsEnabled", 1)		-- 預設 1；畫面中央文字警告
	-- SetCVar("encounterWarningsLevel", 0)			-- 預設 0；最低優先度，0=全部、1=中等以上、2=重大
	-- SetCVar("encounterWarningsHideIfNotTargetingPlayer", 0)-- * 預設 0；隱藏非以玩家為目標的文字警告

	-- SetCVar("encounterTimelineEnabled", 1)		-- 預設 1；首領技能時間軸
	-- SetCVar("encounterTimelineHideLongCountdowns", 0)	-- 預設 0；隱藏長時間倒數
	-- SetCVar("encounterTimelineHideQueuedCountdowns", 0)	-- 預設 0；隱藏排隊等待施放的倒數
	-- SetCVar("encounterTimelineHideForOtherRoles", 0)	-- * 預設 0；隱藏其他職責的倒數
	-- SetCVar("encounterTimelineIconographyEnabled", 1)	-- 預設 1；時間軸法術支援圖示
	-- 隱藏圖示類型 bit：1=坦克、2=治療、4=傷害、8=致命、16=驅散、32=狂怒
	-- SetCVar("encounterTimelineIconographyHiddenMask", "\002")-- 預設 "\002" (0)；0=全部顯示

	-- 內建監控器
	-- SetCVar("cooldownViewerEnabled", 0)			-- 預設 0；冷卻監控器
	-- SetCVar("externalDefensivesEnabled", 0)		-- 預設 0；外部防禦效果監控器
	-- SetCVar("damageMeterEnabled", 0)				-- 預設 0；傷害量表
	-- SetCVar("damageMeterResetOnNewInstance", 0)	-- 預設 0；進入新副本時重置傷害量表

	-- PvP 控場遞減
	-- SetCVar("spellDiminishPVPEnemiesEnabled", 1)	-- 預設 1；競技場敵方框架顯示控場遞減
	-- SetCVar("spellDiminishPVPOnlyTriggerableByMe", 0)-- 預設 0；只顯示自己能觸發的遞減類型

	

	

	-- [[ 顯示 / Display ]] --

	SetCVar("rotateMinimap", 0)			-- # 預設 0；旋轉小地圖
	SetCVar("mapFade", 1)				-- # 預設 1；移動時世界地圖半透明
	SetCVar("autoQuestWatch", 1)		-- # 預設 1；接取任務後自動追蹤
	SetCVar("autoQuestProgress", 1)		-- # 預設 1；進入任務區域時自動追蹤

	-- [[ 協助工具 / Accessibility ]] --

	-- 介面

	-- 文字大小，GUI 選項同時控制兩者
	SetCVar("userFontScale", 1)			-- 角色登入後的文字，遊戲內介面
	SetCVar("userFontScaleGlue", 1)		-- 角色登入前的文字，角色選單等
	SetCVar("questTextContrast", 0)		-- 預設 0；任務視窗顏色，0=預設、1=棕色、2=白色、3=灰色、4=黑色
	
	-- 一般
	
	-- 游標大小及從「戰鬥」分類鏡像過來的選項已在前段設定，不重複列出
	SetCVar("enableMovePad", 0)			-- 預設 0；顯示移動面板
	SetCVar("overrideScreenFlash", 0)	-- 預設 0；光敏感模式，強制特定全螢幕閃光改為黑色淡入淡出
	SetCVar("WorldTextMinSize", 0)		-- 預設 0；角色名稱最小尺寸，範圍 0~64，最小單位 2
	-- 畫面暈眩，由兩個 CVar 組成：關閉=1/0，啟用=0/1
	--SetCVar("CameraKeepCharacterCentered", 1)		-- 預設 1；讓角色保持在畫面中央
	--SetCVar("CameraReduceUnexpectedMovement", 0)	-- 預設 0；減少非玩家輸入造成的鏡頭移動
	-- 畫面震動，GUI 選項同時控制兩者：0=無、0.25=降低、1=完整
	-- SetCVar("ShakeStrengthCamera", 1)			-- 預設 1；3D 鏡頭晃動強度
	-- SetCVar("ShakeStrengthUI", 1)				-- 預設 1；2D 介面晃動強度
	
	SetCVar("cursorSizePreferred", 4)				-- ! 預設 -1；游標大小，-1=自動、0~4=32/48/64/96/128
	-- 顯示目標提示資訊，GUI 選項同時控制兩者
	-- SetCVar("SoftTargetTooltipEnemy", 0)			-- 預設 0；行動鎖定敵人提示資訊
	-- SetCVar("SoftTargetTooltipInteract", 0)		-- 預設 0；互動目標提示資訊
	-- 互動圖示 GUI 組合：僅限 NPC=0/1/0/0、全部=1/1/1/1、不顯示=0/0/0/0
	-- SetCVar("SoftTargetIconEnemy", 0)			-- 預設 0；敵方行動鎖定圖示
	-- SetCVar("SoftTargetIconInteract", 1)			-- 預設 1；NPC 互動圖示
	-- SetCVar("SoftTargetIconGameObject", 0)		-- 預設 0；可互動物件圖示
	-- SetCVar("SoftTargetLowPriorityIcons", 0)		-- 預設 0；已有任務或拾取特效時仍顯示互動圖示
	-- SetCVar("arachnophobiaMode", 0)				-- 預設 0；蜘蛛恐懼症模式，以其他生物取代蜘蛛

	-- 顏色
	SetCVar("colorblindMode", 0)				-- 預設 0；色盲模式
	-- SetCVar("colorblindSimulator", 0)		-- * 預設 0；0=無、1=紅綠色盲、2=綠色盲、3=藍色盲
	-- SetCVar("colorblindWeaknessFactor", .5)	-- * 預設 0.5；色盲濾鏡強度，範圍 0~1，最小單位 0.05

	-- 坐騎
	-- 天空騎術畫面暈眩 GUI 組合：預設=0/0、景觀暗化=0/1、聚焦圈=1/0、兩者=1/1
	-- SetCVar("motionSicknessFocalCircle", 0)				-- 預設 0；畫面中央顯示聚焦圈
	-- SetCVar("motionSicknessLandscapeDarkening", 0)		-- 預設 0；高速飛行時暗化畫面外圍
	-- 下列兩項名稱是 Disable；0=GUI 啟用效果，1=GUI 關閉效果
	-- SetCVar("DisableAdvancedFlyingFullScreenEffects", 0)	-- 預設 0；天空騎術全螢幕效果
	-- SetCVar("DisableAdvancedFlyingVelocityVFX", 0)		-- 預設 0；天空騎術速度效果
	-- SetCVar("advFlyPitchControl", 3)						-- 預設 3；1=前進/仰轉、2=後退/仰轉、3=預設控制
	-- SetCVar("advFlyPitchControlGroundDebounce", 0)		-- 預設 0；落地與起飛後須重新按下傾斜輸入
	-- SetCVar("advFlyPitchControlCameraChase", 20)			-- 預設 20；鏡頭追隨飛行俯仰速度，範圍 10~30，最小單位 1
	-- SetCVar("advFlyKeyboardMinPitchFactor", 2.5)			-- 預設 2.5；鍵盤最小俯仰速率，範圍 1~10，最小單位 0.5
	-- SetCVar("advFlyKeyboardMaxPitchFactor", 5)			-- 預設 5；鍵盤最大俯仰速率，範圍 1~10，最小單位 0.5
	-- SetCVar("advFlyKeyboardMinTurnFactor", 5)				-- 預設 5；鍵盤最小轉向速率，範圍 1~10，最小單位 0.5
	-- SetCVar("advFlyKeyboardMaxTurnFactor", 8)				-- 預設 8；鍵盤最大轉向速率，範圍 1~10，最小單位 0.5

	-- 音效輔助；聊天語音相關 CVar 已移至 SetChat.lua

	SetCVar("accessibilityScreenNarrationEnabled", 0)			-- 預設 1；畫面朗讀，朗讀登入、伺服器與角色建立介面的元素
	-- SetCVar("accessibilityScreenNarrationVoice", 1)			-- 預設 1；聲音 ID，可用值依本機 TTS 聲音清單
	-- SetCVar("accessibilityScreenNarrationSpeechRate", 0)		-- 預設 0；朗讀速度，範圍 -10~10，整數
	-- SetCVar("accessibilityScreenNarrationSpeechVolume", 100)	-- 預設 100；朗讀音量，範圍 0~100，整數

	-- 戰鬥音效警報；僅在語音聊天功能可用時顯示於 GUI
	-- SetCVar("CAAEnabled", 0)				-- 預設 0；戰鬥音效警報總開關
	-- SetCVar("CAAVoice", 0)				-- 預設 0；主要聲音 ID，可用值依本機 TTS 聲音清單
	-- SetCVar("CAASpeed", 0)				-- 預設 0；播報速度，範圍 -10~10，最小單位 1
	-- SetCVar("CAAVolume", 100)			-- 預設 100；主要音量，範圍 0~100，最小單位 1
	-- 事件聲音可用 0=關、1=預設語音，或 100 + Enum.CooldownViewerSound
	-- SetCVar("CAASayCombatStart", 1)		-- 預設 1；進入戰鬥
	-- SetCVar("CAASayCombatEnd", 1)		-- 預設 1；離開戰鬥

	-- 自身生命力
	-- SetCVar("CAAPlayerHealthPercent", 0)	-- 預設 0；0=關、1~5=每 10/20/30/40/50% 播報
	-- SetCVar("CAAPlayerHealthFormat", 1)	-- 預設 1；0=生命力百分之X、1=生命力X、2=生命力X/10、3=百分之X、4=X、5=X/10
	-- SetCVar("CAAPlayerHealthVoice", 0)	-- 預設 0；聲音 ID，可用值依本機 TTS 聲音清單
	-- SetCVar("CAAPlayerHealthThrottle", 0)	-- 預設 0 秒；範圍 0~5 秒，最小單位 0.5 秒
	-- SetCVar("CAAPlayerHealthVolume", 100)	-- 預設 100；範圍 0~100，最小單位 1

	-- 目標
	-- SetCVar("CAASayTargetName", 1)		-- 預設 1；選取新目標時說出名稱
	-- SetCVar("CAASayIfTargeted", "")		-- 預設 ""；按專精序列化；GUI 值 0=關、1=仇恨、2=被鎖定、3=說出鎖定者，不可直接填單一數字
	-- SetCVar("CAATargetHealthPercent", 2)	-- 預設 2；0=關、1~5=每 10/20/30/40/50% 播報
	-- SetCVar("CAATargetHealthFormat", 3)	-- 預設 3；0~2=生命力文字、3~5=百分比/數字、6~8=目標百分比/數字；每組末項為數值除以 10
	-- SetCVar("CAATargetDeathBehavior", 0)	-- 預設 0；0=沿用目標生命力格式、1=說出目標死亡，或 100 + Enum.CooldownViewerSound
	-- SetCVar("CAATargetHealthVoice", 0)	-- 預設 0；聲音 ID，可用值依本機 TTS 聲音清單
	-- SetCVar("CAATargetHealthThrottle", 0)	-- 預設 0 秒；範圍 0~5 秒，最小單位 0.5 秒
	-- SetCVar("CAATargetHealthVolume", 100)	-- 預設 100；範圍 0~100，最小單位 1

	-- 隊伍生命力
	-- SetCVar("CAAPartyHealthPercent", 0)	-- 預設 0；0=關、1=低於100%，2~10=低於90%~10%
	-- SetCVar("CAAPartyHealthVoice", 0)		-- 預設 0；聲音 ID，可用值依本機 TTS 聲音清單
	-- SetCVar("CAAPartyHealthFrequency", 0)	-- 預設 0；相對頻率，範圍 -10~10，最小單位 1；-10=減半、10=加倍
	-- SetCVar("CAAPartyHealthVolume", 100)	-- 預設 100；範圍 0~100，最小單位 1

	-- 玩家資源；Percents/Formats/Voice/Volume 會把各專精設定序列化在同一個 CVar
	-- SetCVar("CAAResource1Percents", "")	-- 預設 ""；GUI 值 0=關、1~5=每 10/20/30/40/50%，不可直接填單一數字
	-- SetCVar("CAAResource1Formats", "")	-- 預設 ""；GUI 值 0~5，格式規則同生命力，不可直接填單一數字
	-- SetCVar("CAAResource1Voice", "")		-- 預設 ""；每專精的 TTS 聲音 ID，不可直接填單一數字
	-- SetCVar("CAAResource1Throttle", 0)		-- 預設 0 秒；範圍 0~5 秒，最小單位 0.5 秒
	-- SetCVar("CAAResource1Volume", "")		-- 預設 ""；每專精範圍 0~100，最小單位 1，不可直接填單一數字
	-- SetCVar("CAAResource2Percents", "")	-- 預設 ""；GUI 值 0=關、1~5=每 10/20/30/40/50%，不可直接填單一數字
	-- SetCVar("CAAResource2Formats", "")	-- 預設 ""；GUI 值 0~5，格式規則同生命力，不可直接填單一數字
	-- SetCVar("CAAResource2Voice", "")		-- 預設 ""；每專精的 TTS 聲音 ID，不可直接填單一數字
	-- SetCVar("CAAResource2Throttle", 0)		-- 預設 0 秒；範圍 0~5 秒，最小單位 0.5 秒
	-- SetCVar("CAAResource2Volume", "")		-- 預設 ""；每專精範圍 0~100，最小單位 1，不可直接填單一數字

	-- 施法
	-- SetCVar("CAAPlayerCastMode", 0)		-- 預設 0；0=關、1=施法開始、2=施法結束
	-- SetCVar("CAAPlayerCastFormat", 4)		-- 預設 4；0=正在施放技能、1=施放技能、2=施放中、3=施放、4=技能名稱
	-- SetCVar("CAAPlayerCastVoice", 0)		-- 預設 0；聲音 ID，可用值依本機 TTS 聲音清單
	-- SetCVar("CAAPlayerCastMinTime", 1.5)	-- 預設 1.5 秒；範圍 0~5 秒，最小單位 0.5 秒；0 包含瞬發
	-- SetCVar("CAAPlayerCastThrottle", 0)	-- 預設 0 秒；範圍 0~5 秒，最小單位 0.5 秒
	-- SetCVar("CAAPlayerCastVolume", 100)	-- 預設 100；範圍 0~100，最小單位 1
	-- SetCVar("CAATargetCastMode", 0)		-- 預設 0；0=關、1=施法開始、2=施法結束
	-- SetCVar("CAATargetCastFormat", 0)		-- 預設 0；0=目標正在施放技能、1=目標施放技能、2~6=省略目標/狀態文字至只說技能名稱
	-- SetCVar("CAATargetCastVoice", 0)		-- 預設 0；聲音 ID，可用值依本機 TTS 聲音清單
	-- SetCVar("CAATargetCastMinTime", 1.5)	-- 預設 1.5 秒；範圍 0~5 秒，最小單位 0.5 秒；0 包含瞬發
	-- SetCVar("CAATargetCastThrottle", 0)	-- 預設 0 秒；範圍 0~5 秒，最小單位 0.5 秒
	-- SetCVar("CAATargetCastVolume", 100)	-- 預設 100；範圍 0~100，最小單位 1
	-- SetCVar("CAAInterruptCast", 0)			-- 預設 0；0=關、1=可中斷施法語音，或 100 + Enum.CooldownViewerSound
	-- SetCVar("CAAInterruptCastSuccess", 0)	-- 預設 0；0=關、1=成功中斷語音，或 100 + Enum.CooldownViewerSound

	-- 玩家減益效果
	-- SetCVar("CAASayYourDebuffs", 1)			-- 預設 1；被施加減益效果時播報
	-- SetCVar("CAASayYourDebuffsFormat", 0)	-- 預設 0；0=減益效果+名稱、1=只說減益效果
	-- SetCVar("CAASayYourDebuffsVoice", 0)	-- 預設 0；聲音 ID，可用值依本機 TTS 聲音清單
	-- SetCVar("CAASayYourDebuffsMinDuration", 1.5)-- 預設 1.5 秒；範圍 0~5 秒，最小單位 0.5 秒
	-- SetCVar("CAASayYourDebuffsVolume", 100)	-- 預設 100；範圍 0~100，最小單位 1
	-- SetCVar("CAADebuffSelfAlert", 0)			-- 預設 0；0=關、1=說出可驅散類型，或 100 + Enum.CooldownViewerSound

	-- 字幕
	SetCVar("movieSubtitle", 1)						-- 預設 1；動畫字幕
	-- SetCVar("movieSubtitleBackground", 2)		-- 預設 2；1=無、2=深色、3=淺色
	-- SetCVar("movieSubtitleBackgroundAlpha", 70)	-- 預設 70%；GUI 範圍 50~100%，最小單位 10%

	ReloadUI()
end

--=======================================================--
-----------------    [[ Compactraid ]]    -----------------
--=======================================================--

-- [[ Compactraid style settings / 團隊檔案 ]] --
--[[
local function SetRaidCfg()
	-- 下列為 12.1 ESC > 選項 > 遊戲體驗 > 介面的團隊框架 CVar
	-- 此函數的實際套用邏輯仍使用下方 SetRaidProfileOption
	-- SetCVar("raidOptionKeepGroupsTogether", 1)			-- !# 預設 0；保持小隊相連
	-- SetCVar("raidFramesDisplayPowerBars", 1)				-- ! 預設 0；顯示能量條
	-- SetCVar("raidFramesDisplayAggroHighlight", 1)		-- 預設 1；顯示仇恨高亮
	-- SetCVar("raidFramesDisplayClassColor", 1)			-- ! 預設 0；顯示職業顏色
	-- SetCVar("raidOptionDisplayPets", 0)					-- 預設 0；顯示寵物
	-- SetCVar("raidOptionDisplayMainTankAndAssist", 0)	-- ! 預設 1；顯示主坦與主助攻
	-- SetCVar("raidOptionShowBorders", 0)					-- !# 預設 1；顯示邊框
	-- SetCVar("raidFramesDisplayOnlyDispellableDebuffs", 0) -- 預設 0；只顯示可驅散減益
	-- SetCVar("raidFramesHealthText", "none")				-- 預設 "none"；none／health／losthealth／perc
	-- SetCVar("raidFramesHeight", 44)						-- !# 預設 36；12.1 metadata 未提供範圍
	-- SetCVar("raidFramesWidth", 90)						-- !# 預設 72；12.1 metadata 未提供範圍

	-- 12.1 團隊框架補充
	-- SetCVar("raidFramesDisplayIncomingHeals", 1)			-- 預設 1；顯示預估治療，不等同已移除的 predictedHealth
	-- SetCVar("raidFramesDisplayOnlyHealerPowerBars", 0)	-- 預設 0；只顯示治療者能量條
	-- SetCVar("raidFramesHealthBarColor", "FF2B9305")		-- 預設 "FF2B9305"；非職業色生命條，ARGB
	-- SetCVar("raidFramesHealthBarColorBG", "FF141414")	-- 預設 "FF141414"；生命條背景，ARGB
	-- SetCVar("raidFramesDisplayDebuffs", 1)				-- 預設 1；顯示減益
	-- SetCVar("raidFramesDisplayLargerRoleSpecificDebuffs", 1)-- 預設 1；放大職責相關減益
	-- SetCVar("raidFramesCenterBigDefensive", 1)			-- 預設 1；中央顯示大型防禦增益
	-- SetCVar("raidFramesDispelIndicatorType", 2)			-- 預設 2；0=關、1=自己可驅散、2=全部
	-- SetCVar("raidFramesDispelIndicatorOverlay", 1)		-- 預設 1；0=關、1=減益顏色、2=黑色
	-- SetCVar("raidFramesDispelIndicatorOverlayAnimation", 0)-- 預設 0；驅散色塊脈衝動畫

	-- PvP 框架
	-- SetCVar("pvpFramesDisplayPowerBars", 0)				-- 預設 0；顯示能量條
	-- SetCVar("pvpFramesDisplayOnlyHealerPowerBars", 0)	-- 預設 0；只顯示治療者能量條
	-- SetCVar("pvpFramesDisplayClassColor", 0)			-- 預設 0；顯示職業顏色
	-- SetCVar("pvpOptionDisplayPets", 0)					-- 預設 0；顯示寵物
	-- SetCVar("pvpFramesHealthText", "none")				-- 預設 "none"；none／health／losthealth／perc

	-- showArenaEnemyCastbar	-- 顯示競技場敵方施法條
	-- showArenaEnemyFrames		-- 顯示競技場敵方框架
	-- showArenaEnemyPets		-- 顯示競技場敵方寵物框架
	-- showPartyBackground		-- 在隊伍成員和競技場敵對成員背後顯示背景
	-- showPartyPets			-- 顯示隊友寵物

	-- SetCVar("useCompactPartyFrames", 1)	-- 已移除
	-- SetCVar("activeCUFProfile", "主檔案")	-- 已移除
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
--==================================================--
-----------------    [[ Others ]]    -----------------
--==================================================--

-- [[ Hide tutorial ]] --

local function NoTutorial()
	if not C.NoTutorial then return end

	-- 關閉船塢教學
	local cvar = {
		"shipyardMissionTutorialFirst",		-- !# 預設 0；1 = 已看過
		"shipyardMissionTutorialBlockade",	-- !# 預設 0；1 = 已看過
		"shipyardMissionTutorialAreaBuff",	-- !# 預設 0；1 = 已看過
	}

	for _, v in ipairs(cvar) do
		if tonumber(GetCVar(v)) == 0 then
			SetCVar(v, 1)
		end
	end

	-- 關閉駐防與職業大廳任務教學
	-- astGarrisonMissionTutorial 已拼錯；正確名稱為 lastGarrisonMissionTutorial
	local cvar2 = {
		lastGarrisonMissionTutorial = 4294934528,	-- !# 預設 0；教學完成 bitmask
		orderHallMissionTutorial = 4294934528,		-- !# 預設 0；教學完成 bitmask
	}

	for k, v in pairs(cvar2) do
		if not GetCVar(k) or tonumber(GetCVar(k)) ~= v then
			SetCVar(k, v)
		end
	end

	-- Remove newbie tutorials
	for i = 1, NUM_LE_FRAME_TUTORIALS do
		C_CVar.SetCVarBitfield("closedInfoFrames", i, true)	-- # 預設空字串；每個 bit 表示一個已關閉教學
	end
end

-- [[ Force load default seetings ]] --

local function DefaultSettings()

	-- 停止將新學法術自動放入快捷列
	IconIntroTracker:UnregisterEvent("SPELL_PUSHED_TO_ACTIONBAR")
	IconIntroTracker:UnregisterEvent("SPELL_PUSHED_TO_FLYOUT_ON_ACTIONBAR")
	-- 最大視距
	SetCVar("cameraDistanceMaxZoomFactor", 2.6)	-- !# 預設 1.9；範圍 1~2.6，最小單位 0.1

	BossBanner:UnregisterAllEvents()			-- 不顯示首領橫幅：擊敗首領／團隊拾取
	-- GroupLootContainer:UnregisterAllEvents()	-- 不顯示團隊拾取框
	
	-- 特效
	SetCVar("overrideArchive", 0)	-- # 預設 0；反和諧
	SetCVar("ffxGlow", 0)			-- !# 預設 1；關閉全螢幕光暈
	SetCVar("ffxDeath", 0)			-- !# 預設 1；關閉死亡畫面效果
	-- 玩家對目標輸出
	SetCVar("floatingCombatTextCombatDamage_v2", 0)
	SetCVar("floatingCombatTextCombatHealing_v2", 0)
	-- 快捷列，最後一個值是「總是顯示按鈕」
	SetActionBarToggles(true, false, true, false, false, false, false, false)
	-- 背包
	C_Container.SetSortBagsRightToLeft(true)		-- 順向整理背包
	C_Container.SetInsertItemsLeftToRight(true)		-- 反向放置戰利品
	-- 社交
	SetAutoDeclineGuildInvites(false)			-- 自動拒絕公會邀請
	SetAutoDeclineNeighborhoodInvites(true)		-- 封鎖社群邀請
	-- 座騎
	C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_COLLECTED, true)
	C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED, false)
	-- 寵物
	C_PetJournal.SetFilterChecked(LE_PET_JOURNAL_FILTER_COLLECTED, true)
	C_PetJournal.SetFilterChecked(LE_PET_JOURNAL_FILTER_NOT_COLLECTED, false)
	-- 玩具
	C_ToyBox.SetCollectedShown(true)
	C_ToyBox.SetUncollectedShown(false)
	-- 傳家寶
	C_Heirloom.SetCollectedHeirloomFilter(true)
	C_Heirloom.SetUncollectedHeirloomFilter(false)
	-- 塑型外觀
	C_TransmogCollection.SetCollectedShown(true)
	C_TransmogCollection.SetUncollectedShown(false)
	-- 外觀套裝
	C_TransmogSets.SetBaseSetsFilter(LE_TRANSMOG_SET_FILTER_COLLECTED, true)
	C_TransmogSets.SetBaseSetsFilter(LE_TRANSMOG_SET_FILTER_UNCOLLECTED, false)
	-- 任務字型
	QuestTitleFont:SetFont(STANDARD_TEXT_FONT, 24, "")		-- 標題
	QuestTitleFont:SetShadowOffset(0, 0)
	QuestFont:SetFont(STANDARD_TEXT_FONT, 24, "")			-- 描述
	QuestFont:SetShadowOffset(0, 0)
	QuestFontNormalSmall:SetFont(STANDARD_TEXT_FONT, 24, "")-- 目標
	QuestFontNormalSmall:SetShadowOffset(0, 0)
end

-- [[ Load functions ]] --

local function OnEvent()
	--NoTutorial()
	DefaultSettings()
	--self:UnregisterEvent("PLAYER_LOGIN")
end

local function OnSlash()
	SetCVarCfg()
	--SetRaidCfg()
	ReloadUI()
end

-- [[ 載入設定 / Load Settings ]] --

local frame = CreateFrame("FRAME", nil)
	--frame:RegisterEvent("PLAYER_LOGIN") -- VARIABLES_LOADED/PLAYER_LOGIN/ADDON_LOADED/PLAYER_ENTERING_WORLD
	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	frame:SetScript("OnEvent", OnEvent)

-- [[ Slasm CMD ]] --

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
		OnAccept =  function() OnSlash() end,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 5,
}

SlashCmdList["SETUI"] = function()
	StaticPopup_Show("SET_UI")
end
SLASH_SETUI1 = "/setui"
