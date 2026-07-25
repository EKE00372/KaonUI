local addon, ns = ...
local C, F, G, L = unpack(ns)
local GetLocale = GetLocale

--===================================================--
-----------------    [[ Locales ]]    -----------------
--===================================================--

if GetLocale() == "zhTW" then

    --[[L.SetUI = "載入 CVAR"
    L.SetUI = "導入預設 CVAR"
    L.SetUI = ""
    L.SetUI = ""
    L.SetUI = ""
    L.SetUI = ""
    L.SetUI = ""]]--

    -- interface

    L.UIScale = "介面縮放"
    L.UIScale_Desc = "自動套用符合解析度的介面縮放比例。\n\n當前解析度的最適縮放比例：%s%%"

    L.AuraFrames = "光環美化"
    L.AuraFrames_Desc = "美化暴雪右上角的玩家光環框架。"

    L.idTip = "各種 ID"
    L.idTip_Desc = "替滑鼠提示加上各種 ID。\n\n代碼引用：https://www.curseforge.com/wow/addons/idtip"
    L.idTip_Opt1 = "主要 ID"
    L.idTip_Opt1Desc = "SpellID, ItemID, NPC ID, QuestID, AchievementID, CurrencyID, MacroID, MountID, IconID"
    L.idTip_Opt2 = "其他 ID"
    L.idTip_Opt2Desc = "TalentID, CriteriaID, AbilityID, ArtifactPowerID, EnchantID, GemID, CompanionID, SetID, VisualID, SourceID, SpeciesID, AreaPoiID, VignetteID, ExpansionID, ObjectID"
    L.idTip_Opt3 = "次要 ID"
    L.idTip_Opt3Desc = "BonusID, TraitNodeID, TraitEntryID, TraitDefinitionID"

    L.tullaCTC = "倒數計時"
    L.tullaCTC_Desc = "冷卻和光環的倒數計時文字。\n\n代碼引用：https://www.curseforge.com/wow/addons/tullactc"

    L.tullaRange = "快捷鍵染色"
    L.tullaRange_Desc = "根據距離和資源染色快捷鍵按鈕。\n\n代碼引用：https://www.curseforge.com/wow/addons/tullarange"

    L.MicroMenu = "彩色微型選單"
    L.MicroMenu_Desc = "扁平風格的彩色微型選單，滑鼠指向淡入淡出，並隱藏背包欄。"

    L.BetterRaid = "團隊框架簡化"
    L.BetterRaid_Desc = "隱藏暴雪團隊框架上的伺服器名稱和小隊標題。"

    L.HideTutorial = "隱藏教學提示"
    L.HideTutorial_Desc = "隱藏新角色的教學提示。\n\n代碼引用：https://www.curseforge.com/wow/addons/hidetutorial"

    L.DragEmAll = "框體自由拖動"
    L.DragEmAll_Desc = "允許部分暴雪面板直接拖動。\n\n代碼引用：https://github.com/siweia/NDui/blob/master/Interface/AddOns/NDui/Plugins/DragEmAll.lua"

    L.TalkingHead = "對話頭像"
    L.TalkingHead_Desc = "調整暴雪的對話頭像框體。"
    L.TalkingHeadMode_Opt1 = "縮放 60%"
    L.TalkingHeadMode_Opt1Desc = "保留對話頭像和語音，但將框體縮小為 60%。"
    L.TalkingHeadMode_Opt2 = "隱藏"
    L.TalkingHeadMode_Opt2Desc = "隱藏對話頭像並停止對話語音。"

    -- misc

    L.AutoInvite = "自動邀請"
    L.AutoInvite_Desc = "密語自動邀請：\nAlt + 左鍵：組隊邀請\nCtrl + 左鍵：公會邀請\n\n密語 111/+++/inv\n自動組隊邀請\n\n密語 g++/ginv/加公會/加公会\n跳出確認視窗後公會邀請"

    L.AutoLog = "自動戰鬥紀錄"
    L.AutoLog_Desc = "在團隊副本和傳奇地城自動啟用戰鬥紀錄。"

    L.AutoShot = "自動截圖"
    L.AutoShot_Desc = "等級提升、獲得成就、完成限時地城和死亡時自動截圖。"

    L.CompassCastbar = "羅盤施法條"
    L.CompassCastbar_Desc = "滑鼠位置顯示羅盤樣式的施法條。\n\n代碼引用：https://www.wowinterface.com/downloads/info24278-rCompassCastbar.html"

    L.ShiftRight = "Shift 右鍵存取"
    L.ShiftRight_Desc = "背包或銀行物品可 Shift + 右鍵點擊批量移動。\n\n代碼引用：https://www.curseforge.com/wow/addons/shift-right"

    L.SnowfallCursor = "游標閃光"
    L.SnowfallCursor_Desc = "滑鼠游標移動時閃光。\n\n代碼引用：https://www.wowinterface.com/downloads/info15693-SnowfallCursor.html"

    L.ReloadUI = "重載介面"
    L.ReloadUI_Desc = "重載介面以套用設定。"

else
 -- interface

    L.UIScale = "UI Scale"
    L.UIScale_Desc = "Auto UI Scale for pixel perfect.\nCurrent best scale: %s%%"

    L.AuraFrames = "Auraframes style"
    L.AuraFrames_Desc = "Style Auraframes."

    L.idTip = "IDs"
    L.idTip_Desc = "Show IDs on tooltip.\n\nSource: https://www.curseforge.com/wow/addons/idtip"
    L.idTip_Opt1 = "Main ID"
    L.idTip_Opt1Desc = "SpellID, ItemID, NPC ID, QuestID, AchievementID, CurrencyID, MacroID, MountID, IconID"
    L.idTip_Opt2 = "Other ID"
    L.idTip_Opt2Desc = "TalentID, CriteriaID, AbilityID, ArtifactPowerID, EnchantID, GemID, CompanionID, SetID, VisualID, SourceID, SpeciesID, AreaPoiID, VignetteID, ExpansionID, ObjectID"
    L.idTip_Opt3 = "Minor ID"
    L.idTip_Opt3Desc = "BonusID, TraitNodeID, TraitEntryID, TraitDefinitionID"

    L.tullaCTC = "Cooldown Text"
    L.tullaCTC_Desc = "Actionbar cooldown and aura time text.\n\nSource: https://www.curseforge.com/wow/addons/tullactc"

    L.tullaRange = "Colored actionbar"
    L.tullaRange_Desc = "Actionbar button color by range and resource.\n\nSource: https://www.curseforge.com/wow/addons/tullarange"

    L.MicroMenu = "Colorful micro menu"
    L.MicroMenu_Desc = "Colorful micro menu with mouseover fadin, also hide bagsbar."
    
    L.BetterRaid = "Better raidframes"
    L.BetterRaid_Desc = "Hide realm names and group titles."

    L.HideTutorial = "Hide tutorial"
    L.HideTutorial_Desc = "Hide new character tutorial.\n\nSource: https://www.curseforge.com/wow/addons/hidetutorial"

    L.DragEmAll = "Movable frames"
    L.DragEmAll_Desc = "Allow some Blizzard panels to be dragged directly.\n\nSource: https://github.com/siweia/NDui/blob/master/Interface/AddOns/NDui/Plugins/DragEmAll.lua"

    L.TalkingHead = "Talking Head"
    L.TalkingHead_Desc = "Adjust the Blizzard Talking Head frame."
    L.TalkingHeadMode_Opt1 = "Scale 60%"
    L.TalkingHeadMode_Opt1Desc = "Keep the Talking Head and voice, but scale the frame to 60%."
    L.TalkingHeadMode_Opt2 = "Hide"
    L.TalkingHeadMode_Opt2Desc = "Hide the Talking Head frame and stop its voice."

    -- misc

    L.AutoInvite = "Auto Invite"
    L.AutoInvite_Desc = "Msg auto invite:\n"
        L.AutoInvite_Desc = "Msg auto invite:\nAlt + Left click: group invite\nCtrl + Left click: Guild invite\nWhisper 111/+++/inv: Auto group invite\nWhisper g++/ginv: Guild invite"


    L.AutoLog = "Auto combatlog"
    L.AutoLog_Desc = "Automatically enable combatlog in Raid and Mythic+ Dungeon."

    L.AutoShot = "Auto screenshot"
    L.AutoShot_Desc = "Automatically tack screenshot when you get achievement, level up, finish a dungeon and death."

    L.CompassCastbar = "Compass castbar"
    L.CompassCastbar_Desc = "Show compass ring castbar at the cursor.\n\nSource: https://www.wowinterface.com/downloads/info24278-rCompassCastbar.html"

    L.ShiftRight = "Shift Right Click"
    L.ShiftRight_Desc = "Shift + Right-click a bag or bank item to move all.\n\nSource: https://www.curseforge.com/wow/addons/shift-right"

    L.SnowfallCursor = "Cursor flash"
    L.SnowfallCursor_Desc = "Cursor flash when moving.\n\nSource: https://www.wowinterface.com/downloads/info15693-SnowfallCursor.html"

    L.ReloadUI = "Reload UI"
    L.ReloadUI_Desc = "Reload to apply settings."
    
end
