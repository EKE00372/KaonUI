local _, ns = ...
local F, L = ns[2], ns[4]

local GetLocale = GetLocale
local format = string.format

-- 指向說明時才讀取縮放比例，避免載入詞條時 UIScale 模組尚未建立 API
local function CreateScaleTooltip(text)
	return function()
		local percent = format("%.2f", F.GetUIScaleValue() * 100):gsub("%.?0+$", "")
		return format(text, percent)
	end
end

-- 每次指向說明才查詢，改綁按鍵後不必重載便能看到新設定。
local function CreateBindingTooltip(text, command)
	return function()
		local keys = { GetBindingKey(command) }
		for index, key in ipairs(keys) do
			keys[index] = GetBindingText(key)
		end
		local binding = #keys > 0 and table.concat(keys, " / ") or NOT_BOUND
		return text.."\n\n"..format(L.CurrentBinding, "|cffe6d5a8"..binding.."|r")
	end
end

--===================================================--
-----------------    [[ Locales ]]    -----------------
--===================================================--

if GetLocale() == "zhTW" then

	-- 分類標題
	L.GUI_General = "一般"
	L.GUI_Combat = "戰鬥"
	L.GUI_Appearance = "美化"
	L.GUI_Automation = "自動化"
	L.GUI_Features = "功能"
	L.GUI_Extensions = "擴展"

	-- 一般
	L.UIScale = "介面縮放"
	L.UIScale_Desc = CreateScaleTooltip("自動套用符合解析度的介面縮放比例。\n\n當前解析度的最適縮放比例：%s%%")
	L.SetUI = "自動設定"
	L.SetUI_Desc = "自動載入某些設定，具體可以查看 SetUI.lua。"
	L.SlashCMD = "快捷指令"
	L.SlashCMD_Desc = "啟用額外的快捷指令，具體可以查看 slashCMD.lua。"

	-- 一般：快捷列
	L.tullaCTC = "倒數計時"
	L.tullaCTC_Desc = "調整快捷鍵的倒數計時文字。\n\n參考：tullaCTC"
	L.tullaRange = "按鍵染色"
	L.tullaRange_Desc = "根據距離和資源染色快捷鍵按鈕。\n\n參考：tullaRange"
	L.ActionbarStyle = "按鍵美化"
	L.ActionbarOrder = "反序排列"
	L.ActionbarOrder_Desc = "將水平多列快捷列的按鍵順序改為由上往下。"

	-- 一般：戰鬥
	L.CombatText = "承受戰鬥文字"
	L.CombatText_Desc = "顯示受到傷害和治療的戰鬥文字。"
	L.SpellAnnouncer = "戰復音效"
	L.ThreatSound = "仇恨音效"
	L.ThreatSound_Desc = "坦克專精的仇恨由穩定轉為不穩或丟怪時播放音效。"
	L.ReadyCheckSound = "準備確認音效"
	L.AFKCombatSound = "野外暫離戰鬥音效"
	L.Nougat = "玩家屬性"
	L.Nougat_Desc = "顯示綠字屬性、移動速度與戰鬥時長。"

	-- 介面：美化
	L.AuraFrames = "光環"
	L.MicroMenu = "微型選單"
	L.MicroMenu_Desc = "扁平風格的彩色微型選單，滑鼠指向淡入淡出。"

	-- 介面：聊天
	L.SetChat = "外觀簡化"

	-- 介面：其他
	L.TalkingHead = "縮小對話頭像"
	L.BetterRaid = "簡化團隊框架"
	L.BetterRaid_Desc = "隱藏暴雪團隊框架上的伺服器名稱和小隊標題。"
	L.HideTutorial = "隱藏教學提示"
	L.HideTutorial_Desc = "隱藏一般、新手、要塞、船塢與職業大廳的教學提示。\n\n參考：HideTutorial"
	L.BagItemInfo = "背包銀行裝等"
	L.MacroFrame = "巨集介面加寬"
	L.FriendList = "好友染色"
	L.ProfessionTabs = "專業分頁"
	
	-- 雜項：自動化
	L.AutoInvite = "自動邀請"
	L.AutoInvite_Desc = "密語邀請\n\n|cffe6d5a8Alt + 左鍵|r：組隊邀請\n|cffe6d5a8Ctrl + 左鍵|r：公會邀請\n\n密語關鍵字自動邀請\n\n組隊關鍵字\n111/+++/inv\n\n公會關鍵字\ng++/ginv/加公會/加公会"
	L.AutoLog = "自動戰鬥紀錄"
	L.AutoLog_Desc = "在團隊副本和傳奇地城自動啟用戰鬥紀錄。"
	L.AutoShot = "自動截圖"
	L.AutoShot_Desc = "等級提升、獲得成就、完成限時地城和死亡時自動截圖。"
	L.MooseLight = "自動亮度"
	L.MooseLight_Desc = "為特定地區、副本與夜間調整畫面亮度。\n\n參考：MooseLight"

	-- 雜項：功能
	L.QuickMark = "快速標記"
	L.QuickMark_Desc = CreateBindingTooltip("在按鍵設定中綁定按鍵，啟用快速標記功能，按下按鍵在滑鼠位置顯示標記工具。\n\n|cffe6d5a8左鍵|r：團隊標記。\n|cffe6d5a8右鍵|r：世界標記。\n\n參考：DejaMark", "CLICK DejaMark:LeftButton")
	L.SpotMe = "中心標記"
	L.SpotMe_Desc = CreateBindingTooltip("在按鍵設定中綁定按鍵，啟用中心標記功能，在畫面中央顯示一個靜態材質。\n\n這可以讓你快速定位自己的角色模型。", "SPOTME")

	-- 雜項：擴展
	L.DragEmAll = "框體自由拖動"
	L.DragEmAll_Desc = "使你可以直接拖動部分暴雪面板。\n\n參考：DragEmAll"
	L.CompassCastbar = "游標施法環"
	L.CompassCastbar_Desc = "在滑鼠位置顯示環形施法條。\n\n參考：rCompassCastbar"
	L.ShiftRight = "批量存取"
	L.ShiftRight_Desc = "|cffe6d5a8Shift + 右鍵|r點擊背包或銀行的物品可以批量移動。\n\n參考：ShiftRight"
	L.SnowfallCursor = "游標閃光"
	L.SnowfallCursor_Desc = "滑鼠游標移動時閃光。\n\n參考：SnowfallCursor"
	L.CharacterStats = "角色資訊"
	L.CharacterStats_Desc = "顯示裝等與附魔，屬性擴展至小數點後一位。"

	-- 雜項：Tooltip
	L.idTip_Opt1 = "主要 ID"
	L.idTip_Opt1Desc = "SpellID, ItemID, NPC ID, QuestID, AchievementID, CurrencyID, MacroID, MountID, IconID, ExpansionID, ObjectID, SetID"
	L.idTip_Opt2 = "其他 ID"
	L.idTip_Opt2Desc = "|cffe6d5a8TalentID|r：PvP 天賦\n|cffe6d5a8CriteriaID|r：成就條件\n\n|cffe6d5a8VisualID|r：塑形外觀\n|cffe6d5a8SourceID|r：塑形來源\n\n|cffe6d5a8SpeciesID|r：戰鬥寵物類型\n|cffe6d5a8AbilityID|r：戰鬥寵物技能\n\n|cffe6d5a8AreaPoiID|r：地圖活動標記\n|cffe6d5a8VignetteID|r：地圖稀有標記"
	L.idTip_Opt3 = "次要 ID"
	L.idTip_Opt3Desc = "|cffe6d5a8ArtifactPowerID|r：神器特質\n\n|cffe6d5a8EnchantID|r：附魔效果\n|cffe6d5a8GemID|r：鑲嵌寶石\n|cffe6d5a8BonusID|r：裝備加成，裝等、難度、插槽等物品變體資訊\n\n|cffe6d5a8TraitNodeID|r：天賦節點\n|cffe6d5a8TraitEntryID|r：天賦選項\n|cffe6d5a8TraitDefinitionID|r：天賦效果"
	L.TooltipItemInfo = "分類與堆疊"
	L.TooltipColor = "職業染色"
	L.TooltipDetails = "單位資訊"
	L.TooltipDetails_Desc = "顯示玩家裝等。\n\n按住 |cffe6d5a8Shift|r 顯示頭銜、會階、M+ 分數與坐騎。受限時保留原生內容。"
	L.TooltipStack = "堆疊"
	L.TooltipRare = "稀有"

	-- 共用
	L.ReloadUI = "重載 UI"
	L.StatusChanged = "設定已變更，重載後生效。"
	L.CurrentBinding = "當前綁定按鍵：%s"

elseif GetLocale() == "zhCN" then

	-- 分類標題
	L.GUI_General = "一般"
	L.GUI_Combat = "战斗"
	L.GUI_Appearance = "美化"
	L.GUI_Automation = "自动化"
	L.GUI_Features = "功能"
	L.GUI_Extensions = "扩展"

	-- 一般
	L.UIScale = "界面缩放"
	L.UIScale_Desc = CreateScaleTooltip("自动应用符合分辨率的界面缩放比例。\n\n当前分辨率的最佳缩放比例：%s%%")
	L.SetUI = "自动设置"
	L.SetUI_Desc = "自动载入某些设置，具体可以查看 SetUI.lua。"
	L.SlashCMD = "快捷指令"
	L.SlashCMD_Desc = "启用额外的快捷指令，具体可以查看 slashCMD.lua。"

	-- 一般：快捷列
	L.tullaCTC = "倒计时"
	L.tullaCTC_Desc = "调整快捷键的倒计时文字。\n\n参考：tullaCTC"
	L.tullaRange = "按键染色"
	L.tullaRange_Desc = "根据距离和资源给快捷键按钮染色。\n\n参考：tullaRange"
	L.ActionbarStyle = "按键美化"
	L.ActionbarOrder = "反序排列"
	L.ActionbarOrder_Desc = "将水平多行动作条的按钮顺序改为从上往下。"

	-- 一般：戰鬥
	L.CombatText = "承受战斗文字"
	L.CombatText_Desc = "显示受到伤害和治疗的战斗文字。"
	L.SpellAnnouncer = "战复音效"
	L.ThreatSound = "仇恨音效"
	L.ThreatSound_Desc = "坦克专精的仇恨由稳定转为不稳或丢怪时播放音效。"
	L.ReadyCheckSound = "准备确认音效"
	L.AFKCombatSound = "野外暂离战斗音效"
	L.Nougat = "玩家属性"
	L.Nougat_Desc = "显示绿字属性、移动速度与战斗时长。"

	-- 介面：美化
	L.AuraFrames = "光环"
	L.MicroMenu = "微型菜单"
	L.MicroMenu_Desc = "扁平风格的彩色微型菜单，鼠标指向淡入淡出。"

	-- 介面：聊天
	L.SetChat = "外观简化"

	-- 介面：其他
	L.TalkingHead = "缩小对话头像"
	L.BetterRaid = "简化团队框架"
	L.BetterRaid_Desc = "隐藏暴雪团队框架上的服务器名称和小队标题。"
	L.HideTutorial = "隐藏教程提示"
	L.HideTutorial_Desc = "隐藏常规、新手、要塞、船坞与职业大厅的教学提示。\n\n参考：HideTutorial"
	L.BagItemInfo = "背包银行装等"
	L.FriendList = "好友染色"
	L.ProfessionTabs = "专业分页"
	L.MacroFrame = "宏界面加宽"

	-- 雜項：自動化
	L.AutoInvite = "自动邀请"
	L.AutoInvite_Desc = "密语邀请\n\n|cffe6d5a8Alt + 左键|r：组队邀请\n|cffe6d5a8Ctrl + 左键|r：公会邀请\n\n密语关键词自动邀请\n\n组队关键词\n111/+++/inv\n\n公会关键词\ng++/ginv/加公會/加公会"
	L.AutoLog = "自动战斗记录"
	L.AutoLog_Desc = "在团队副本和史诗地下城自动启用战斗记录。"
	L.AutoShot = "自动截图"
	L.AutoShot_Desc = "等级提升、获得成就、完成限时地下城和死亡时自动截图。"
	L.MooseLight = "自动亮度"
	L.MooseLight_Desc = "为特定地区、副本与夜间调整画面亮度。\n\n参考：MooseLight"

	-- 雜項：功能
	L.QuickMark = "快速标记"
	L.QuickMark_Desc = CreateBindingTooltip("在按键设置中绑定按键，启用快速标记功能，按下按键在鼠标位置显示标记工具。\n\n|cffe6d5a8左键|r：团队标记。\n|cffe6d5a8右键|r：世界标记。\n\n参考：DejaMark", "CLICK DejaMark:LeftButton")
	L.SpotMe = "中心标记"
	L.SpotMe_Desc = CreateBindingTooltip("在按键设置中绑定按键，启用中心标记功能，在画面中央显示一个静态材质。\n\n这可以让你快速定位自己的角色模型。", "SPOTME")

	-- 雜項：擴展
	L.DragEmAll = "框体自由拖动"
	L.DragEmAll_Desc = "使你可以直接拖动部分暴雪面板。\n\n参考：DragEmAll"
	L.CompassCastbar = "光标施法环"
	L.CompassCastbar_Desc = "在鼠标位置显示环形施法条。\n\n参考：rCompassCastbar"
	L.ShiftRight = "批量存取"
	L.ShiftRight_Desc = "|cffe6d5a8Shift + 右键|r点击背包或银行的物品可以批量移动。\n\n参考：ShiftRight"
	L.SnowfallCursor = "光标闪光"
	L.SnowfallCursor_Desc = "鼠标光标移动时闪光。\n\n参考：SnowfallCursor"
	L.CharacterStats = "角色信息"
	L.CharacterStats_Desc = "显示装等与附魔，属性扩展至小数点后一位。"

	-- 雜項：Tooltip
	L.idTip_Opt1 = "主要 ID"
	L.idTip_Opt1Desc = "SpellID, ItemID, NPC ID, QuestID, AchievementID, CurrencyID, MacroID, MountID, IconID, ExpansionID, ObjectID, SetID"
	L.idTip_Opt2 = "其他 ID"
	L.idTip_Opt2Desc = "|cffe6d5a8TalentID|r：PvP 天赋\n|cffe6d5a8CriteriaID|r：成就条件\n\n|cffe6d5a8VisualID|r：幻化外观\n|cffe6d5a8SourceID|r：幻化来源\n\n|cffe6d5a8SpeciesID|r：战斗宠物类型\n|cffe6d5a8AbilityID|r：战斗宠物技能\n\n|cffe6d5a8AreaPoiID|r：地图活动标记\n|cffe6d5a8VignetteID|r：地图稀有标记"
	L.idTip_Opt3 = "次要 ID"
	L.idTip_Opt3Desc = "|cffe6d5a8ArtifactPowerID|r：神器特质\n\n|cffe6d5a8EnchantID|r：附魔效果\n|cffe6d5a8GemID|r：镶嵌宝石\n|cffe6d5a8BonusID|r：装备加成，装等、难度、插槽等物品变体信息\n\n|cffe6d5a8TraitNodeID|r：天赋节点\n|cffe6d5a8TraitEntryID|r：天赋选项\n|cffe6d5a8TraitDefinitionID|r：天赋效果"
	L.TooltipItemInfo = "分类与堆叠"
	L.TooltipColor = "职业染色"
	L.TooltipDetails = "单位信息"
	L.TooltipDetails_Desc = "显示玩家装等。\n\n按住 |cffe6d5a8Shift|r 显示头衔、会阶、M+ 分数与坐骑。受限时保留原生内容。"
	L.TooltipStack = "堆叠"
	L.TooltipRare = "稀有"

	-- 共用
	L.ReloadUI = "重载 UI"
	L.StatusChanged = "设置已变更，重载后生效。"
	L.CurrentBinding = "当前绑定按键：%s"

else

	-- 分類標題
	L.GUI_General = "General"
	L.GUI_Combat = "Combat"
	L.GUI_Appearance = "Appearance"
	L.GUI_Automation = "Automation"
	L.GUI_Features = "Features"
	L.GUI_Extensions = "Extensions"

	-- 一般
	L.UIScale = "UI Scale"
	L.UIScale_Desc = CreateScaleTooltip("Automatically apply the UI scale suited to your resolution.\n\nOptimal scale for the current resolution: %s%%")
	L.SetUI = "Automatic Settings"
	L.SetUI_Desc = "Automatically load selected settings. See SetUI.lua for details."
	L.SlashCMD = "Slash Commands"
	L.SlashCMD_Desc = "Enable additional slash commands. See slashCMD.lua for details."

	-- 一般：快捷列
	L.tullaCTC = "Cooldown Text"
	L.tullaCTC_Desc = "Adjust action button countdown text.\n\nReference: tullaCTC"
	L.tullaRange = "Button Coloring"
	L.tullaRange_Desc = "Color action buttons based on range and resources.\n\nReference: tullaRange"
	L.ActionbarStyle = "Button Styling"
	L.ActionbarOrder = "Reverse Row Order"
	L.ActionbarOrder_Desc = "Arrange buttons in horizontal multi-row action bars from top to bottom."

	-- 一般：戰鬥
	L.CombatText = "Incoming Combat Text"
	L.CombatText_Desc = "Show combat text for damage and healing taken."
	L.SpellAnnouncer = "Battle Res Sound"
	L.ThreatSound = "Threat Sounds"
	L.ThreatSound_Desc = "Play a sound when a tank threat becomes insecure or aggro is lost."
	L.ReadyCheckSound = "Ready Check Sound"
	L.AFKCombatSound = "Outdoor AFK Combat Sound"
	L.Nougat = "Player Stats"
	L.Nougat_Desc = "Show secondary stats, movement speed, and combat duration."

	-- 介面：美化
	L.AuraFrames = "Auras"
	L.MicroMenu = "Micro Menu"
	L.MicroMenu_Desc = "A flat, colorful micro menu that fades in and out on mouseover."

	-- 介面：聊天
	L.SetChat = "Simplified Appearance"

	-- 介面：其他
	L.TalkingHead = "Smaller Talking Head"
	L.BetterRaid = "Simplified Raid Frames"
	L.BetterRaid_Desc = "Hide realm names and group titles on Blizzard raid frames."
	L.HideTutorial = "Hide Tutorials"
	L.HideTutorial_Desc = "Hide general, new-player, garrison, shipyard, and class hall tutorials.\n\nReference: HideTutorial"
	L.BagItemInfo = "Bag & Bank Item Levels"
	L.FriendList = "Friend Colors"
	L.ProfessionTabs = "Profession Tabs"
	L.MacroFrame = "Wide Macro Window"

	-- 雜項：自動化
	L.AutoInvite = "Auto Invite"
	L.AutoInvite_Desc = "Whisper invitations\n\n|cffe6d5a8Alt + Left-click|r: Invite to group\n|cffe6d5a8Ctrl + Left-click|r: Invite to guild\n\nAuto-invite using whisper keywords\n\nGroup keywords\n111/+++/inv\n\nGuild keywords\ng++/ginv/加公會/加公会"
	L.AutoLog = "Auto Combat Logging"
	L.AutoLog_Desc = "Automatically enable combat logging in raids and Mythic dungeons."
	L.AutoShot = "Auto Screenshot"
	L.AutoShot_Desc = "Automatically take screenshots when leveling up, earning achievements, completing timed dungeons, or dying."
	L.MooseLight = "Auto Brightness"
	L.MooseLight_Desc = "Adjust screen brightness for specific zones, instances, and nighttime.\n\nReference: MooseLight"

	-- 雜項：功能
	L.QuickMark = "Quick Mark"
	L.QuickMark_Desc = CreateBindingTooltip("Assign a key in Key Bindings to enable Quick Mark. Press the key to show the marker tool at the cursor.\n\n|cffe6d5a8Left-click|r: Raid target markers.\n|cffe6d5a8Right-click|r: World markers.\n\nReference: DejaMark", "CLICK DejaMark:LeftButton")
	L.SpotMe = "Center Marker"
	L.SpotMe_Desc = CreateBindingTooltip("Assign a key in Key Bindings to enable the center marker and display a static texture in the middle of the screen.\n\nThis helps you quickly locate your character model.", "SPOTME")

	-- 雜項：擴展
	L.DragEmAll = "Movable Frames"
	L.DragEmAll_Desc = "Allow some Blizzard panels to be dragged directly.\n\nReference: DragEmAll"
	L.CompassCastbar = "Cursor Cast Ring"
	L.CompassCastbar_Desc = "Show a circular cast bar at the cursor.\n\nReference: rCompassCastbar"
	L.ShiftRight = "Bulk Item Transfer"
	L.ShiftRight_Desc = "|cffe6d5a8Shift + Right-click|r a bag or bank item to move items in bulk.\n\nReference: ShiftRight"
	L.SnowfallCursor = "Cursor Flash"
	L.SnowfallCursor_Desc = "Flash when cursor moving.\n\nReference: SnowfallCursor"
	L.CharacterStats = "Character Info"
	L.CharacterStats_Desc = "Show item levels and enchantments, and display character stats to one decimal place."

	-- 雜項：Tooltip
	L.idTip_Opt1 = "Main ID"
	L.idTip_Opt1Desc = "SpellID, ItemID, NPC ID, QuestID, AchievementID, CurrencyID, MacroID, MountID, IconID, ExpansionID, ObjectID, SetID"
	L.idTip_Opt2 = "Other ID"
	L.idTip_Opt2Desc = "|cffe6d5a8TalentID|r: PvP talent\n|cffe6d5a8CriteriaID|r: Achievement criterion\n\n|cffe6d5a8VisualID|r: Transmog appearance\n|cffe6d5a8SourceID|r: Transmog source\n\n|cffe6d5a8SpeciesID|r: Battle pet species\n|cffe6d5a8AbilityID|r: Battle pet ability\n\n|cffe6d5a8AreaPoiID|r: Map activity marker\n|cffe6d5a8VignetteID|r: Map rare marker"
	L.idTip_Opt3 = "Minor ID"
	L.idTip_Opt3Desc = "|cffe6d5a8ArtifactPowerID|r: Artifact trait\n\n|cffe6d5a8EnchantID|r: Enchantment effect\n|cffe6d5a8GemID|r: Socketed gem\n|cffe6d5a8BonusID|r: Equipment bonus; item variant information such as item level, difficulty, and sockets\n\n|cffe6d5a8TraitNodeID|r: Talent node\n|cffe6d5a8TraitEntryID|r: Talent choice\n|cffe6d5a8TraitDefinitionID|r: Talent effect"
	L.TooltipItemInfo = "Item Type and Stack"
	L.TooltipColor = "Class Colors"
	L.TooltipDetails = "Mob Info"
	L.TooltipDetails_Desc = "Show player item levels.\n\nHold |cffe6d5a8Shift|r for titles, guild ranks, Mythic+ scores, and mounts. While restricted, keep native content."
	L.TooltipStack = "Stack"
	L.TooltipRare = "Rare"

	-- 共用
	L.ReloadUI = "Reload UI"
	L.StatusChanged = "Reload UI to apply settings."
	L.CurrentBinding = "Current key binding: %s"

end
