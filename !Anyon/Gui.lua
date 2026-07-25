local addon, ns = ...
local C, F, G, L = unpack(ns)

local ADDON_TITLE = "!Anyon"
local SETTING_PREFIX = "Anyon_"

local pairs, ipairs, type = pairs, ipairs, type
local format = string.format
local bit = bit

-----------
-- idTip --
-----------

-- idTip 下拉選單：若三個子選項均關閉，idTip.lua 下次載入時會停用整個模組。
local IDTIP_OPTIONS = {
	{ key = "idTip_Opt1", nameKey = "idTip_Opt1", descKey = "idTip_Opt1Desc", value = 1 },
	{ key = "idTip_Opt2", nameKey = "idTip_Opt2", descKey = "idTip_Opt2Desc", value = 2 },
	{ key = "idTip_Opt3", nameKey = "idTip_Opt3", descKey = "idTip_Opt3Desc", value = 3 },
}

local IDTIP_DROPDOWN = { key = "idTip", nameKey = "idTip", descKey = "idTip_Desc", children = IDTIP_OPTIONS, noneOption = true }

-----------------
-- TalkingHead --
-----------------

-- TalkingHead 模式是單選下拉；1 = 縮放 60%，2 = 隱藏。
local TALKING_HEAD_OPTIONS = {
	{ value = 1, nameKey = "TalkingHeadMode_Opt1", descKey = "TalkingHeadMode_Opt1Desc" },
	{ value = 2, nameKey = "TalkingHeadMode_Opt2", descKey = "TalkingHeadMode_Opt2Desc" },
}

-----------------
-- Option list --
-----------------

-- GUI 顯示順序。分類標題也放進列表，之後選項增加到數十個時，只要在這裡插入 row。
-- 真正的設定值仍定義在 Init.lua 的 C.defaultSettings。
local OPTIONS = {
	{ header = INTERFACE_LABEL },
	{ key = "UIScale", nameKey = "UIScale", descKey = "UIScale_Desc" },
	{ key = "AuraFrames", nameKey = "AuraFrames", descKey = "AuraFrames_Desc" },
	IDTIP_DROPDOWN,
	{ key = "tullaCTC", nameKey = "tullaCTC", descKey = "tullaCTC_Desc" },
	{ key = "tullaRange", nameKey = "tullaRange", descKey = "tullaRange_Desc" },
	{ key = "MicroMenu", nameKey = "MicroMenu", descKey = "MicroMenu_Desc" },
	{ key = "BetterRaid", nameKey = "BetterRaid", descKey = "BetterRaid_Desc" },
	{ key = "HideTutorial", nameKey = "HideTutorial", descKey = "HideTutorial_Desc" },
	{ key = "DragEmAll", nameKey = "DragEmAll", descKey = "DragEmAll_Desc" },
	{ key = "TalkingHeadMode", nameKey = "TalkingHead", descKey = "TalkingHead_Desc", choices = TALKING_HEAD_OPTIONS },

	{ header = BINDING_HEADER_MISC },
	{ key = "AutoInvite", nameKey = "AutoInvite", descKey = "AutoInvite_Desc" },
	{ key = "AutoLog", nameKey = "AutoLog", descKey = "AutoLog_Desc" },
	{ key = "AutoShot", nameKey = "AutoShot", descKey = "AutoShot_Desc" },
	{ key = "CompassCastbar", nameKey = "CompassCastbar", descKey = "CompassCastbar_Desc" },
	{ key = "ShiftRight", nameKey = "ShiftRight", descKey = "ShiftRight_Desc" },
	{ key = "SnowfallCursor", nameKey = "SnowfallCursor", descKey = "SnowfallCursor_Desc" },
}

-- 建立 key -> option 查詢表
-- 下拉子選項不是獨立 checkbox，沒有 settingsByKey
-- 記錄 GUI 已知的選項 key，供 F.AnyonGUI.Set 判斷是否允許寫入
local OPTION_BY_KEY = {}
local DROPDOWN_LISTS = {}
local DROPDOWN_LIST_BY_CHILD_KEY = {}
for _, option in ipairs(OPTIONS) do
	if option.key then
		OPTION_BY_KEY[option.key] = option
	end

	if option.children then
		DROPDOWN_LISTS[#DROPDOWN_LISTS + 1] = option
		for _, child in ipairs(option.children) do
			OPTION_BY_KEY[child.key] = child
			DROPDOWN_LIST_BY_CHILD_KEY[child.key] = option
		end
	end
end

-- /anyon 開啟設定頁時需要 Blizzard 回傳的 category ID。
local categoryID

-- checkbox 會建立 Blizzard Setting 物件；保存下來供 Reset / F.AnyonGUI.Set 同步控制項狀態。
local settingsByKey = {}

-- 缺少本地化時預設英文
local function GetText(localeKey, fallback)
	return L[localeKey] or fallback or localeKey
end

local function GetOptionName(option)
	return GetText(option.nameKey, option.key)
end

local function GetOptionDesc(option)
	if option.key == "UIScale" then
		return function()
			-- 滑鼠指向 UIScale 時，即時計算目前縮放比例
			local value = F.GetUIScaleValue and F.GetUIScaleValue() or UIParent:GetScale()
			local percent = format("%.2f", value * 100):gsub("%.?0+$", "")
			local desc = GetText(option.descKey, "")
			local text

			-- 詞條使用 %s%%；pcall 可避免翻譯字串誤放單一 % 時造成 Lua error。
			local ok, formattedText = pcall(format, desc, percent)
			if ok then
				text = formattedText
			else
				text = desc:gsub("%%s%%", percent .. "%%")
			end

			return text
		end
	end

	return GetText(option.descKey, "")
end

local function GetOptionValue(optionOrKey)
	-- optionOrKey 可傳 option table 或字串 key，方便 checkbox 和下拉子選項共用
	local key = type(optionOrKey) == "table" and optionOrKey.key or optionOrKey
	return F.GetSetting(key)
end

local function SetOptionValue(optionOrKey, value)
	-- 所有寫入都集中走 Init.lua 的設定 API，確保 AnyonDB 和 C 表永遠同步。
	local key = type(optionOrKey) == "table" and optionOrKey.key or optionOrKey
	return F.SetSetting(key, value)
end

local function GetDefaultValue(key)
	return F.GetDefaultSetting(key)
end

local function GetSettingVariable(key)
	-- Blizzard Settings 內部用 variable 字串辨識設定；不要直接拿 AnyonDB key 以免撞名。
	return SETTING_PREFIX .. key
end

local function RegisterBooleanSetting(category, option)
	local key = option.key

	-- 使用 ProxySetting 而不是 AddOnSetting：
	-- AddOnSetting 在這個插件的 SavedVariables 結構下曾無法穩定回寫 AnyonDB。
	-- ProxySetting 讓 get/set 完全由本檔掌控，存檔路徑固定走 SetOptionValue。
	local setting = Settings.RegisterProxySetting(
		category,
		GetSettingVariable(key),
		Settings.VarType.Boolean,
		GetOptionName(option),
		GetDefaultValue(key),
		function()
			return GetOptionValue(key)
		end,
		function(value)
			SetOptionValue(key, value)
		end
	)

	-- 有些控制項會走 setValue，有些會觸發 value changed；兩邊都導回 SetOptionValue。
	setting:SetValueChangedCallback(function(_, value)
		SetOptionValue(key, value)
	end)

	local initializer = Settings.CreateCheckbox(category, setting, GetOptionDesc(option))
	settingsByKey[key] = setting
	return setting, initializer
end

local function GetDropdownListVariable(option)
	-- 下拉選單本身不存檔，但 Blizzard Settings 仍需要一個虛擬 variable 名稱。
	return GetSettingVariable(option.key.."Options")
end

local function GetDropdownListMask(option)
	-- Blizzard checkbox dropdown 用數字 bitmask；實際設定仍拆回各子選項 boolean。
	-- 例如 Opt1 + Opt3 會是 1 + 4 = 5。
	local mask = 0
	for _, child in ipairs(option.children) do
		if GetOptionValue(child) then
			mask = bit.bor(mask, bit.lshift(1, child.value - 1))
		end
	end
	return mask
end

local function SetDropdownListMask(option, mask)
	-- Settings.CreateDropdownOptionInserter 會傳入更新後的 bitmask，這裡回寫各子選項。
	-- 功能檔讀取這些 boolean，因此下拉選項不用重載就能停用對應類別。
	for _, child in ipairs(option.children) do
		local optionMask = bit.lshift(1, child.value - 1)
		SetOptionValue(child, bit.band(mask, optionMask) ~= 0)
	end
end

local function GetDefaultDropdownListMask(option)
	-- 重設設定時需要還原 dropdown 的預設勾選狀態，所以要從 C.defaultSettings 重新組 bitmask。
	local mask = 0
	for _, child in ipairs(option.children) do
		if GetDefaultValue(child.key) then
			mask = bit.bor(mask, bit.lshift(1, child.value - 1))
		end
	end
	return mask
end

local function GetDropdownListOptions(option)
	-- Settings dropdown 每次展開都會取資料；這裡建立 checkbox 項目與各自 tooltip。
	local container = Settings.CreateControlTextContainer()
	if option.noneOption then
		-- 多選 dropdown 的 mask 為 0 時沒有任何 checkbox 被選中。
		-- 加入 value=0 的 radio 項，讓選單標籤顯示「無」而不是 Blizzard 預設的「自訂」。
		container:Add(0, NONE or "None", GetOptionDesc(option))
	end
	for _, child in ipairs(option.children) do
		container:AddCheckbox(child.value, GetOptionName(child), GetOptionDesc(child))
	end
	return container:GetData()
end

local function RegisterDropdownList(category, option)
	-- 這是一個虛擬 Number setting，只代表下拉選單目前的 bitmask。
	-- 不會存成 AnyonDB.xxxOptions，真正持久化的是各子選項 boolean。
	local setting = Settings.RegisterProxySetting(
		category,
		GetDropdownListVariable(option),
		Settings.VarType.Number,
		GetOptionName(option),
		GetDefaultDropdownListMask(option),
		function()
			return GetDropdownListMask(option)
		end,
		function(mask)
			SetDropdownListMask(option, mask)
		end
	)

	setting:SetValueChangedCallback(function()
		-- Proxy setting 本身不直接保存值；變更後同步子設定到 C 表。
		for _, child in ipairs(option.children) do
			F.SyncSettingValue(child.key)
		end
	end)

	local initializer = Settings.CreateDropdown(category, setting, function()
		return GetDropdownListOptions(option)
	end, GetOptionDesc(option))

	return setting, initializer
end

local function GetChoiceOptions(option)
	-- 單選 dropdown 使用 container:Add；與 idTip 的 AddCheckbox 多選清單不同。
	local container = Settings.CreateControlTextContainer()
	for _, choice in ipairs(option.choices) do
		container:Add(choice.value, GetOptionName(choice), GetOptionDesc(choice))
	end
	return container:GetData()
end

local function RegisterChoiceDropdown(category, option)
	local key = option.key

	local setting = Settings.RegisterProxySetting(
		category,
		GetSettingVariable(key),
		Settings.VarType.Number,
		GetOptionName(option),
		GetDefaultValue(key),
		function()
			return GetOptionValue(key)
		end,
		function(value)
			SetOptionValue(key, value)
		end
	)

	setting:SetValueChangedCallback(function(_, value)
		SetOptionValue(key, value)
	end)

	local initializer = Settings.CreateDropdown(category, setting, function()
		return GetChoiceOptions(option)
	end, GetOptionDesc(option))

	settingsByKey[key] = setting
	return setting, initializer
end

local function NotifyDropdownList(option)
	-- 外部若透過 F.AnyonGUI.Set 改下拉子選項，需要通知 Settings 重新讀取 dropdown bitmask。
	if option and Settings and Settings.NotifyUpdate then
		Settings.NotifyUpdate(GetDropdownListVariable(option))
	end
end

local function RegisterSectionHeader(layout, text)
	if layout and CreateSettingsListSectionHeaderInitializer then
		-- 使用 Blizzard Settings 內建分類標題；文字直接取 GlobalStrings。
		layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(text))
	end
end

local function RegisterReloadButton(layout)
	if not layout or not CreateSettingsButtonInitializer then
		return
	end

	local function OnButtonClick()
		-- 只做操作，不寫入 AnyonDB。
		ReloadUI()
	end

	-- name 留空時只顯示按鈕，不建立左側選項名稱。
	local addSearchTags = true
	local initializer = CreateSettingsButtonInitializer(
		"",
		GetText("ReloadUI", RELOADUI or "Reload UI"),
		OnButtonClick,
		GetText("ReloadUI_Desc", ""),
		addSearchTags
	)

	layout:AddInitializer(initializer)
end

local function RegisterSettingsPanel()
	if not Settings or not Settings.RegisterVerticalLayoutCategory then
		-- Settings 系統尚未載入時避免報錯；TOC 目前會在 Blizzard Settings 可用後執行到這裡。
		return
	end

	-- 12.1 正式服 RegisterVerticalLayoutCategory 會回傳 category 與 layout。
	-- category 用來建立 Setting，layout 用來插入 section header 和 button initializer。
	local category, layout = Settings.RegisterVerticalLayoutCategory(ADDON_TITLE)

	for _, option in ipairs(OPTIONS) do
		if option.header then
			-- 分類標題直接使用 Blizzard GlobalStrings 或未來自訂字串。
			RegisterSectionHeader(layout, option.header)
		elseif option.children then
			RegisterDropdownList(category, option)
		elseif option.choices then
			RegisterChoiceDropdown(category, option)
		else
			RegisterBooleanSetting(category, option)
		end
	end

	RegisterReloadButton(layout)

	-- 註冊到 AddOns 分頁，並保存 categoryID 供 /anyon 快速開啟。
	Settings.RegisterAddOnCategory(category)
	categoryID = category.ID
end

local function OpenSettingsPanel()
	if Settings and Settings.OpenToCategory and categoryID then
		Settings.OpenToCategory(categoryID)
	end
end

-- Settings 面板本身也等 AnyonDB 同步後再建立，避免控制項先讀到預設值。
F.RunWhenSettingsReady(RegisterSettingsPanel)

F.AnyonGUI = {
	options = OPTIONS,
	dropdownLists = DROPDOWN_LISTS,

	-- 提供給需要讀取最新設定的功能檔使用；例如 idTip 每次顯示 tooltip 時會讀下拉子選項狀態。
	-- 模組是否載入由 Init.lua 的 RegisterModule 流程統一判斷。
	Get = function(key)
		return GetOptionValue(key)
	end,

	-- 提供給除錯或其他模組寫值；寫入後同步 AnyonDB、C 表與 Blizzard Settings 控制項。
	Set = function(key, value)
		local setting = settingsByKey[key]
		if setting then
			if type(GetDefaultValue(key)) == "boolean" then
				value = value and true or false
			end
			setting:SetValue(value, true)
		elseif OPTION_BY_KEY[key] then
			SetOptionValue(key, value)
			NotifyDropdownList(DROPDOWN_LIST_BY_CHILD_KEY[key])
		end
	end,

	-- 手動重設 API：checkbox 走 Blizzard Settings default，下拉清單則重組預設 bitmask。
	Reset = function()
		for key, setting in pairs(settingsByKey) do
			setting:SetValueToDefault()
			F.SyncSettingValue(key)
		end

		for _, option in ipairs(DROPDOWN_LISTS) do
			SetDropdownListMask(option, GetDefaultDropdownListMask(option))
			NotifyDropdownList(option)
		end
	end,

	Open = OpenSettingsPanel,
}

SlashCmdList["ANYON"] = OpenSettingsPanel
SLASH_ANYON1 = "/anyon"
