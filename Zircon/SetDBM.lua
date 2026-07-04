local addon, ns = ...

if not IsAddOnLoaded("DBM-Core") then return end

-- Load DBM varriables on demand
local SetDBM = function()
	if DBM_SavedOptions  then table.wipe(DBM_SavedOptions) end
	DBM_SavedOptions = {
	--綜合設置	
	["Enabled"] = true,  --啟用dbm
	["ShowMinimapButton"] = false,  --小地圖圖示
	["UseMasterVolume"] = true,  --使用主要聲音頻道
	
	["InfoFramePoint"] = "TOPLEFT",  --訊息框架錨點
	["InfoFrameX"] = 420,  --訊息框架x座標
	["InfoFrameY"] = -15,  --訊息框架y座標
	["InfoFrameShowSelf"] = false,
	
	["RangeFrameRadarPoint"] = "BOTTOM",  --距離雷達
	["RangeFrameRadarX"] = -200,
	["RangeFrameRadarY"] = 145,
	["RangeFramePoint"] = "BOTTOM",  --距離雷達
	["RangeFrameX"] = -260,  --距離雷達x座標
	["RangeFrameY"] = 145,  --距離雷達y座標
	["RangeFrameSound1"] = "none",	
	["RangeFrameSound2"] = "none",		
	["RangeFrameLocked"] = true,	
	["RangeFrameFrames"] = "both",
	["RangeFrameUpdates"] = "Average",
	
	["LatencyThreshold"] = 200, --設定最高延遲同步門檻
	["CRT_Enabled"] = true,  --戰復充能計時器
	["ChallengeBest"] = "Realm",  --挑戰最速計時器
	["AlwaysShowSpeedKillTimer"] = false,  --最速擊殺計時條
	
	["EnableModels"] = true,  --啟用首領3d模組
	["ModelSoundValue"] = "",  --3d模組靜音
	--綜合訊息
	["ShowPizzaMessage"] = true,  --計時條廣播訊息
	["ShowCombatLogMessage"] = true,  --在聊天框顯示戰鬥紀錄訊息
	["ShowTranscriptorMessage"] = true,  --Transcriptor訊息
	["ShowAllVersions"] = false,  --顯示團員dbm版本
	
	["ShowEngageMessage"] = true,  --開戰訊息
	["ShowKillMessage"] = true,  --戰勝訊息
	["ShowWipeMessage"] = true,  --滅團訊息
	["ShowGuildMessages"] = false,  --公會的開戰/戰勝訊息
	["ShowRecoveryMessage"] = false,  --計時器恢復訊息
	
	["DontSendBossWhispers"] = false,  --戰鬥中自動回覆密語
	["StatusEnabled"] = false,  --回覆status密語
	["WhisperStats"] = false,  --密語戰勝/滅團狀態
	--團隊警告
	["ShowWarningsInChat"] = true,  --聊天框顯示警告
	["ShowFakedRaidWarnings"] = false,  --偽裝成團隊警告
	["WarningIconLeft"] = true,
	["WarningIconRight"] = true,
	["WarningIconChat"] = true,  --聊天框警告顯示圖示
	["RaidWarningSound"] = "Sound\\interface\\AlarmClockWarning3.ogg",  --團隊警告音效"ding"
	
	["RaidWarningPosition"] = {  --團隊警告位置
		["Y"] = -200,
		["X"] = -340,
		["Point"] = "TOPRIGHT",
	},
	
	["WarningColors"] = {
		{
			["b"] = 0.941176470588235,
			["g"] = 0.8,
			["r"] = 0.411764705882353,
		}, -- [1]
		{
			["b"] = 0,
			["g"] = 0.949019607843137,
			["r"] = 0.949019607843137,
		}, -- [2]
		{
			["b"] = 0,
			["g"] = 0.501960784313726,
			["r"] = 1,
		}, -- [3]
		{
			["b"] = 0.101960784313725,
			["g"] = 0.101960784313725,
			["r"] = 1,
		}, -- [4]
	},
	--特別警告
	["ShowSpecialWarnings"] = true,  --顯示特別警告
	["ShowFlashFrame"] = true,  --閃爍
	["ShowSWarningsInChat"] = true,  --聊天框顯示
	
	["SpecialWarningFont"] = STANDARD_TEXT_FONT,
	["SpecialWarningFontSize"] = 50, --超級強調字體
	
	["SpecialWarningSound"] = "Sound\\Spells\\PVPFlagTaken.ogg",
	["SpecialWarningSound2"] = "Sound\\Creature\\AlgalonTheObserver\\UR_Algalon_BHole01.ogg",
	["SpecialWarningSound3"] = "Sound\\Creature\\KilJaeden\\KILJAEDEN02.ogg",
	["SpecialWarningSound4"] = "Sound\\Creature\\HoodWolf\\HoodWolfTransformPlayer01.ogg",
	
	["SpecialWarningPoint"] = "CENTER",
	["SpecialWarningX"] = 200,
	["SpecialWarningY"] = 222,
	
	["SpecialWarningFontCol"] = {
		1, -- [1]
		0.7, -- [2]
		0, -- [3]
	},
	
	["SpecialWarningFlashCol1"] = {
		1, -- [1]
		1, -- [2]
		0, -- [3]
	},
	["SpecialWarningFlashCol2"] = {
		1, -- [1]
		0.5, -- [2]
		0, -- [3]
	},
	["SpecialWarningFlashCol3"] = {
		1, -- [1]
		0, -- [2]
		0, -- [3]
	},
	["SpecialWarningFlashCol4"] = {
		1, -- [1]
		0, -- [2]
		1, -- [3]
	},
	
	["SpecialWarningFlashAlph1"] = 0.3,
	["SpecialWarningFlashAlph2"] = 0.3,
	["SpecialWarningFlashAlph3"] = 0.4,
	["SpecialWarningFlashAlph4"] = 0.4,
	
	["SpecialWarningFlashDura1"] = 0.4,
	["SpecialWarningFlashDura2"] = 0.4,
	["SpecialWarningFlashDura3"] = 1,
	["SpecialWarningFlashDura4"] = 0.7,
	--語音警告
	["CountdownVoice"] = "Corsica",
	["CountdownVoice2"] = "Kolt",
	["CountdownVoice3"] = "Pewsey",
	["ChosenVoicePack"] = "None",  --語音包
	
	
	["VoiceOverSpecW"] = false,  --總是播放所有語音警告
	--血量框架
	["AlwaysShowHealthFrame"] = false,  --總是顯示
	["HealthFrameGrowUp"] = false,  --血量框架向上成長
	["HealthFrameLocked"] = true,  --鎖定
	
	["HPFramePoint"] = "TOPLEFT",
	["HealthFrameWidth"] = 156,	
	["HPFrameY"] = -5,
	["HPFrameX"] = 76,
	["HPFrameMaxEntries"] = 5,	
	--過濾
	["DontShowBossAnnounces"] = false,  --不顯示提示或播放警告音效
	["DontShowFarWarnings"] = false,  --距離過遠計時
	["DontSendBossWhispers"] = true,  --不發送密語
	["DontSetIcons"] = true,  --不自動標記
	["DontShowInfoFrame"] = false, --不顯示訊息框架
	["DontShowRangeFrame"] = false,  --不顯示距離框架
	["DontShowHealthFrame"] = false,  --不顯示血量框架
	["DontPlayCountdowns"] = false,  --不播放倒數音效
	
	["StripServerName"] = true,  --過濾伺服器後綴
	["FilterTankSpec"] = true,  --過濾坦克警告
	
	["DontShowPTNoID"] = true,	--過慮不同區域
	["DontShowPT2"] = false,  --開怪倒數計時條
	["DontShowPTText"] = false,  --開怪提示文字
	["DontPlayPTCountdown"] = false,  --開怪倒數音效
	["DontShowPTCountdownText"] = false,  --開怪倒數文字
	["PTCountThreshold"] = 10,  --不顯示高於十秒的開怪計時器
	
	["DontSendBossWhispers"] = false,	
	["DontSendBossAnnounces"] = false,
	["DontShowBossAnnounces"] = false,
	["DontShowFlexMessage"] = false,
	
	["DontShowCTCount"] = false,
	
	--隱藏
	["HideBossEmoteFrame"] = false,  --隱藏暴雪首領表情
	["HideObjectivesFrame"] = true,  --隱藏追蹤框
	["HideGarrisonUpdates"] = true,  --隱藏要塞進度
	["HideTooltips"] = false,  --戰鬥中隱藏滑鼠提示
	["FilterSayAndYell"] = true,  --隱藏對話泡泡
	["MovieFilter"] = "AfterFirst",  --跳過看過一次的動畫
	["HideApplicantAlerts"] = 1,  --停止預組隊伍 如果隊伍已滿
	--額外
	["RoleSpecAlert"] = true,  --專精與好運符不同警告
	["CheckGear"] = true,  --低裝等警告
	["WorldBossAlert"] = false,  --公會有人打世界boss警告
	
	["WorldBossNearAlert"] = false,  --靠近世界BOSS播放音效
	["AFKHealthWarning"] = false,  --暫離時受到攻擊播放音效
	--["AdvancedAutologBosses"] = false,  --自動進階戰鬥紀錄
	["AutologBosses"] = false,  --自動戰鬥紀錄
	["LogOnlyRaidBosses"] = false,  --只紀錄raid boss
	["AutoAcceptGuildInvite"] = false,  --自動接受公會組隊
	["AutoAcceptFriendInvite"] = false,  --自動接受好友組隊
	["FakeBWVersion"] = false,  --假裝成BW
	["BlockVersionUpdateNotice"] = true,  --不提示更新
	

	}
if(DBT_PersistentOptions) then table.wipe(DBT_PersistentOptions) end
	DBT_SavedOptions = {
		["DBM"] = {
		["Texture"] = "Interface\\TargetingFrame\\UI-StatusBar",  --計時條材質
		["Style"] = "BigWigs",  --計時條風格
		["Font"] = STANDARD_TEXT_FONT,  --計時條字型
		
		["IconLeft"] = true,  --左側圖示
		["IconRight"] = false,  --右側圖示
		["ExpandUpwards"] = true,  --向上延伸
		["FillUpBars"] = false,  --填滿計時條
		["ClickThrough"] = true,  --點擊穿透計時條
		["Flash"] = true,  --計時條閃光
		["Spark"] = false,  --計時條閃爍
		
		["FontSize"] = 16,  --字體大小
		["Height"] = 20,  --計時條高度
		["EnlargeBarsTime"] = 10,  --低於10秒放大
		["EnlargeBarsPercent"] = 0.125,  --低於12.5%放大
		--小型計時條
		["Scale"] = 1,  --縮放比
		["Width"] = 160,  --長度
		["BarXOffset"] = 0,  --x軸偏移
		["BarYOffset"] = 0,  --y軸偏移
		["TimerPoint"] = "CENTER",  --錨點
		["TimerX"] = 340,
		["TimerY"] = -15,
		--大型計時條
		["HugeScale"] = 1.4,  --縮放比
		["HugeWidth"] = 170,  --長度
		["HugeBarXOffset"] = 0,  --x軸偏移
		["HugeBarYOffset"] = 0,  --y軸偏移
		["HugeTimerPoint"] = "CENTER",  --錨點
		["HugeTimerX"] = 385,
		["HugeTimerY"] = 200,
		--起始顏色
		["StartColorR"] = 1,
		["StartColorG"] = 0.14,
		["StartColorB"] = 0.26,
		--結束顏色
		["EndColorR"] = 1,
		["EndColorG"] = 0,
		["EndColorB"] = 0,		
		},
	}
end
-- 載入設置
StaticPopupDialogs.SET_DBM = {
        text = "載入DBM布局(僅適用1920*1200)",
        button1 = ACCEPT,
        button2 = CANCEL,
        OnAccept =  function() SetDBM() ReloadUI() end,
        timeout = 0,
        whileDead = 1,
        hideOnEscape = true,
        preferredIndex = 5,
}
SLASH_SETDBM1 = "/setdbm"
SlashCmdList["SETDBM"] = function()
        StaticPopup_Show("SET_DBM")
end

