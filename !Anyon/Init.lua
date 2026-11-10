----------------------
-- Dont touch this! --
----------------------

local addon, ns = ...
	ns[1] = {} -- C, config
	ns[2] = {} -- F, functions, constants, variables
	ns[3] = {} -- G, globals (Optionnal)
	ns[4] = {} -- L, localization
		
local F, G = ns[2], ns[3]

G.MediaFolder = "Interface\\AddOns\\!Anyon\\Media\\"
local MediaFolder = G.MediaFolder

----------------------
-- Golbal and Media --
----------------------

	--G.Ccolors = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[select(2, UnitClass("player"))]
	
	--G.BarTex = "Interface\\Buttons\\WHITE8X8"
	G.GlowTex = MediaFolder.."glow.tga"
	G.IconBorderTex = MediaFolder.."Actionbar\\button-normal.tga"
	--G.BorderTex = MediaFolder.."Actionbar\\button-border.tga"
	G.ButtonProcTex = MediaFolder.."Actionbar\\button-proc.tga"
	G.ButtonCastTex = MediaFolder.."Actionbar\\button-cast.tga"
	--G.Resize = MediaFolder.."Resize.tga"
	
	--G.Mail = "Interface\\MINIMAP\\TRACKING\\Mailbox.blp"  -- "Interface\\HELPFRAME\\ReportLagIcon-Mail.blp"
	--G.Diff = MediaFolder.."difficulty.tga"
	--G.Report = "Interface\\HelpFrame\\HelpIcon-ReportLag.blp"
	
	--G.HealthWarning = MediaFolder.."HealthWarning.ogg" 
	--G.ManaWarning = MediaFolder.."ManaWarning.ogg" 
	--G.TauntBeep = MediaFolder.."TauntBeep.ogg" -- https://freesound.org/people/pan14/sounds/263128/
	
	G.SpotMe = MediaFolder.."NeonReticule-blue.tga"

------------------
-- GUI settings --
------------------

F.GUIOptionGroups = {
	{
		name = "GUI_General",
		sections = {
			{
				name = "GUI_General",
				options = {
					{ type = "toggle", key = "UIScale", label = "UIScale", default = true, tooltip = "UIScale_Desc" },
					{ type = "toggle", key = "SetUI", label = "SetUI", default = true, tooltip = "SetUI_Desc" },
					{ type = "toggle", key = "SlashCMD", label = "SlashCMD", default = true, tooltip = "SlashCMD_Desc" },
				},
			},
			{
				name = ACTIONBARS_LABEL,
				options = {
					{ type = "toggle", key = "tullaCTC", label = "tullaCTC", default = true, tooltip = "tullaCTC_Desc" },
					{ type = "toggle", key = "tullaRange", label = "tullaRange", default = true, tooltip = "tullaRange_Desc" },
					{ type = "toggle", key = "ActionbarStyle", label = "ActionbarStyle", default = true },
					{ type = "toggle", key = "ActionbarOrder", label = "ActionbarOrder", default = true, tooltip = "ActionbarOrder_Desc" },
				},
			},
			{
				name = "GUI_Combat",
				options = {
					{ type = "toggle", key = "CombatText", label = "CombatText", default = true, tooltip = "CombatText_Desc" },
					{ type = "toggle", key = "SpellAnnouncer", label = "SpellAnnouncer", default = true },
					{ type = "toggle", key = "ThreatSound", label = "ThreatSound", default = false, tooltip = "ThreatSound_Desc" },
					{ type = "toggle", key = "ReadyCheckSound", label = "ReadyCheckSound", default = true },
					{ type = "toggle", key = "AFKCombatSound", label = "AFKCombatSound", default = true },
					{ type = "toggle", key = "Nougat", label = "Nougat", default = true, tooltip = "Nougat_Desc" },
				},
			},
		},
	},
	{
		name = INTERFACE_LABEL,
		sections = {
			{
				name = "GUI_Appearance",
				options = {
					{ type = "toggle", key = "AuraFrames", label = "AuraFrames", default = true },
					{ type = "toggle", key = "MicroMenu", label = "MicroMenu", default = true, tooltip = "MicroMenu_Desc" },
				},
			},
			{
				name = CHAT,
				options = {
					{ type = "toggle", key = "SetChat", label = "SetChat", default = true },
				},
			},
			{
				name = OTHER,
				options = {
					{ type = "toggle", key = "TalkingHead", label = "TalkingHead", default = true },
					{ type = "toggle", key = "BetterRaid", label = "BetterRaid", default = true, tooltip = "BetterRaid_Desc" },
					{ type = "toggle", key = "HideTutorial", label = "HideTutorial", default = true, tooltip = "HideTutorial_Desc" },
					{ type = "toggle", key = "BagItemInfo", label = "BagItemInfo", default = true },
					{ type = "toggle", key = "FriendList", label = "FriendList", default = true },
					{ type = "toggle", key = "ProfessionTabs", label = "ProfessionTabs", default = true },
					{ type = "toggle", key = "MacroFrame", label = "MacroFrame", default = true },
					{ type = "toggle", key = "CharacterStats", label = "CharacterStats", default = true, tooltip = "CharacterStats_Desc" },
				},
			},
		},
	},
	{
		name = BINDING_HEADER_MISC,
		sections = {
			{
				name = "GUI_Automation",
				options = {
					{ type = "toggle", key = "AutoInvite", label = "AutoInvite", default = true, tooltip = "AutoInvite_Desc" },
					{ type = "toggle", key = "AutoLog", label = "AutoLog", default = true, tooltip = "AutoLog_Desc" },
					{ type = "toggle", key = "AutoShot", label = "AutoShot", default = true, tooltip = "AutoShot_Desc" },
					{ type = "toggle", key = "MooseLight", label = "MooseLight", default = true, tooltip = "MooseLight_Desc" },
				},
			},
			{
				name = "GUI_Features",
				options = {
					{ type = "toggle", key = "QuickMark", label = "QuickMark", default = true, tooltip = "QuickMark_Desc" },
					{ type = "toggle", key = "SpotMe", label = "SpotMe", default = true, tooltip = "SpotMe_Desc" },
				},
			},
			{
				name = "GUI_Extensions",
				options = {
					{ type = "toggle", key = "DragEmAll", label = "DragEmAll", default = true, tooltip = "DragEmAll_Desc" },
					{ type = "toggle", key = "CompassCastbar", label = "CompassCastbar", default = true, tooltip = "CompassCastbar_Desc" },
					{ type = "toggle", key = "ShiftRight", label = "ShiftRight", default = true, tooltip = "ShiftRight_Desc" },
					{ type = "toggle", key = "SnowfallCursor", label = "SnowfallCursor", default = true, tooltip = "SnowfallCursor_Desc" },
				},
			},
			{
				name = HUD_EDIT_MODE_HUD_TOOLTIP_LABEL,
				options = {
					{ type = "toggle", key = "idTip_Opt1", label = "idTip_Opt1", default = true, tooltip = "idTip_Opt1Desc" },
					{ type = "toggle", key = "idTip_Opt2", label = "idTip_Opt2", default = true, tooltip = "idTip_Opt2Desc" },
					{ type = "toggle", key = "idTip_Opt3", label = "idTip_Opt3", default = false, tooltip = "idTip_Opt3Desc" },
					{ type = "toggle", key = "TooltipItemInfo", label = "TooltipItemInfo", default = true },
					{ type = "toggle", key = "TooltipColor", label = "TooltipColor", default = true },
					{ type = "toggle", key = "TooltipDetails", label = "TooltipDetails", default = true, tooltip = "TooltipDetails_Desc" },
				},
			},
		},
	},
}

----------
-- Init --
----------

	local pairs, ipairs, next, type = pairs, ipairs, next, type
	local xpcall, geterrorhandler = xpcall, geterrorhandler
	local tinsert = table.insert
	local modulesReady = false
	local modules = {}
	local moduleQueue = {}

	local function SafeCall(callback, ...)
		-- 讓初始化與事件回呼都走 Blizzard 錯誤處理器；單一模組報錯不會中斷整串載入。
		return xpcall(callback, geterrorhandler(), ...)
	end

--[[
	local issecretvalue, issecrettable = issecretvalue, issecrettable

	-- 統一判斷 12.x 的 secret value/table，之後需要時可給各模組共用。
	F.IsSecret = function(value)
		if type(value) == "table" then
			return issecrettable and issecrettable(value) or false
		end

		return issecretvalue and issecretvalue(value) or false
	end
--]]

------------
-- Events --
------------

	local eventCallbacks = {}
	local eventFrame = CreateFrame("Frame")
	eventFrame:SetScript("OnEvent", function(_, event, ...)
		local callbacks = eventCallbacks[event]
		if not callbacks then return end

		for callback in pairs(callbacks) do
			SafeCall(callback, event, ...)
		end
	end)

	-- 輕量事件分派器 credits: NDui
	F.RegisterEvent = function(event, callback, unit1, unit2)
		if type(event) ~= "string" or type(callback) ~= "function" then return end

		if not eventCallbacks[event] then
			eventCallbacks[event] = {}
			if unit1 then
				eventFrame:RegisterUnitEvent(event, unit1, unit2)
			else
				eventFrame:RegisterEvent(event)
			end
		end

		eventCallbacks[event][callback] = true
	end

	F.UnregisterEvent = function(event, callback)
		if type(event) ~= "string" or type(callback) ~= "function" then return end

		local callbacks = eventCallbacks[event]
		if callbacks then
			callbacks[callback] = nil
			if not next(callbacks) then
				eventCallbacks[event] = nil
				eventFrame:UnregisterEvent(event)
			end
		end
	end

-------------------------
-- Initialize settings --
-------------------------

	-- 按 key 查找選項；頁面直屬選項與子分類內的選項使用同一張查詢表。
	F.GUIOptionMap = {}

	local function AddGUIOption(option)
		F.GUIOptionMap[option.key] = option
	end

	for _, group in ipairs(F.GUIOptionGroups) do
		for _, option in ipairs(group.options or {}) do
			AddGUIOption(option)
		end
		for _, section in ipairs(group.sections or {}) do
			for _, option in ipairs(section.options or {}) do
				AddGUIOption(option)
			end
		end
	end

	-- 與 Ruri 一樣，把 GUI 選項集中儲存在 SavedVariables 的 Options 表。
	local function GetGUIOptionsDB()
		if type(AnyonDB) ~= "table" then
			AnyonDB = {}
		end

		if type(AnyonDB.Options) ~= "table" then
			AnyonDB.Options = {}
			-- 這次換結構時搬入現有設定，已取消勾選的 false 也照原樣保留。
			for key in pairs(F.GUIOptionMap) do
				AnyonDB.Options[key] = AnyonDB[key]
				AnyonDB[key] = nil
			end
		end

		return AnyonDB.Options
	end

	local loadedOptions = {}

	-- ADDON_LOADED 後補齊預設值，並刪除選項表中已不存在的設定。
	local function ApplyGUIOptions()
		local db = GetGUIOptionsDB()

		-- 舊總開關拆成三項；保留已保存的 false 與已存在的新設定。
		local legacyTooltip = db.Tooltip
		if legacyTooltip == nil then legacyTooltip = AnyonDB.Tooltip end
		if type(legacyTooltip) == "boolean" then
			for _, key in ipairs({"TooltipItemInfo", "TooltipColor", "TooltipDetails"}) do
				if db[key] == nil then db[key] = legacyTooltip end
			end
		end
		db.Tooltip, AnyonDB.Tooltip = nil, nil

		-- 缺少的設定補預設值；disabled 選項固定使用預設值。
		for key, option in pairs(F.GUIOptionMap) do
			if option.disabled then
				db[key] = option.default
			elseif db[key] == nil then
				db[key] = option.default
			end
			-- 保存本次載入的設定，讓 GUI 能辨識尚待重載與已改回原值的狀態。
			loadedOptions[key] = db[key]
		end

		-- 只清理 Options，不動日後可能存放在根目錄的其他資料。
		for key in pairs(db) do
			if F.GUIOptionMap[key] == nil then
				db[key] = nil
			end
		end
	end

	-- 讀取目前設定；保留 Anyon 原本的 API 名稱，既有模組不必跟著改名。
	F.GetSetting = function(key)
		local option = F.GUIOptionMap[key]
		if not option then return nil end

		if option.disabled then return option.default end

		local db = GetGUIOptionsDB()
		if db[key] == nil then
			db[key] = option.default
		end

		return db[key]
	end

	-- 只儲存設定，不重新載入模組；勾選值與禁用規則沿用 Ruri。
	F.SetSetting = function(key, value)
		local option = F.GUIOptionMap[key]
		if not option or option.disabled then
			return F.GetSetting(key)
		end

		local db = GetGUIOptionsDB()
		if option.type == "toggle" then
			db[key] = value == true
		else
			db[key] = value
		end

		return db[key]
	end

	F.HasPendingSettings = function()
		for key, value in pairs(loadedOptions) do
			if F.GetSetting(key) ~= value then return true end
		end
		return false
	end

	-------------
	-- Modules --
	-------------

	local function IsModuleSettingEnabled(settingKey)
		-- settingKey 可為單一 key、多個 key，或自訂函數。
		-- 多個 key 使用「任一啟用就載入」，適合 idTip 這種由多個開關控制的模組。
		if not settingKey then return true end

		if type(settingKey) == "function" then
			return settingKey()
		elseif type(settingKey) == "table" then
			for _, key in ipairs(settingKey) do
				if F.GetSetting(key) then
					return true
				end
			end
			return false
		end

		return F.GetSetting(settingKey)
	end

	local function EnableModule(module)
		if module.enabled or not IsModuleSettingEnabled(module.settingKey) then return end
		module.enabled = true

		if module.OnEnable then
			SafeCall(module.OnEnable, module)
		end
	end

	local function EnableModules()
		modulesReady = true

		for _, module in ipairs(moduleQueue) do
			EnableModule(module)
		end
	end

	F.RegisterModule = function(name, settingKey)
		-- 功能檔只負責登記自己；Init.lua 會在 PLAYER_LOGIN 時依 AnyonDB 設定決定是否啟用。
		if type(name) ~= "string" or name == "" then return end
		if modules[name] then return modules[name] end

		local module = {
			name = name,
			settingKey = settingKey,
		}

		modules[name] = module
		tinsert(moduleQueue, module)

		-- 若未來出現 PLAYER_LOGIN 後才登記的檔案，等目前 Lua 檔跑完再啟用。
		-- 這樣 local M = F.RegisterModule(...); function M:OnEnable() ... end 的 OnEnable 會先定義完成。
		if modulesReady then
			C_Timer.After(0, function()
				EnableModule(module)
			end)
		end

		return module
	end

	F.GetModule = function(name)
		return modules[name]
	end

	F.GetModules = function()
		return modules
	end

	-- 存檔先在 ADDON_LOADED 初始化；模組仍統一等 PLAYER_LOGIN 啟用。
	local dbLoader = CreateFrame("Frame")
	dbLoader:RegisterEvent("ADDON_LOADED")
	dbLoader:SetScript("OnEvent", function(self, event, name)
		if name ~= addon then return end

		ApplyGUIOptions()
		self:UnregisterEvent(event)
		self:SetScript("OnEvent", nil)
	end)

	local function OnPlayerLogin(event)
		-- SavedVariables 仍在 ADDON_LOADED 同步；模組統一等 PLAYER_LOGIN 後才依設定載入。
		EnableModules()

		F.UnregisterEvent(event, OnPlayerLogin)
	end

	F.RegisterEvent("PLAYER_LOGIN", OnPlayerLogin)


---------------
-- Functions --
---------------
	
	-- [[ Multi check ]] --
	-- F.Multicheck(unit, "player", "boss", "pet")
	--[=[
	F.Multicheck = function(check, ...)
		for i = 1, select("#", ...) do
			if check == select(i, ...) then
				return true
			end
		end
		return false
	end
	]=]

	-- GUI 的外圈陰影；光環與快捷列的圖示邊框由各模組自行建立。
	F.CreateSD = function(parent, anchor, size, r, g, b, a)
		anchor = anchor or parent
		size = size or 3

		local shadow = CreateFrame("Frame", nil, parent, "BackdropTemplate")
		local frameLevel = parent:GetFrameLevel()

		shadow:ClearAllPoints()
		shadow:SetPoint("TOPLEFT", anchor, "TOPLEFT", -size, size)
		shadow:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", size, -size)
		shadow:SetFrameLevel(frameLevel > 1 and frameLevel - 1 or 0)
		shadow:SetBackdrop({
			edgeFile = G.GlowTex,
			edgeSize = size,
		})
		shadow:SetBackdropBorderColor(r or .05, g or .05, b or .05, a or 1)

		return shadow
	end
	
	
-------------
-- Credits --
-------------
--[[
	楼上的你妈妈叫你吃饭: http://bbs.nga.cn/read.php?tid=4667432
	AIO: https://github.com/Stanzilla/AdvancedInterfaceOptions
	ELVUI: http://git.tukui.org/Elv/elvui/blob/master/ElvUI/core/install.lua
	MONOUI: https://www.wowinterface.com/downloads/info18071-MonoUI.html

]]--
-----------
-- Notes --
-----------
--[[
	wowpedia
	https://wow.gamepedia.com/CVar_cvar_default
	https://wow.gamepedia.com/API_C_CVar.SetCVar
	https://wow.gamepedia.com/API_ConsoleExec
	https://wow.gamepedia.com/Console_variables
	https://wow.gamepedia.com/Console_variables/Complete_list
	https://wow.gamepedia.com/Console_variables/Complete_list/Character
	https://wow.gamepedia.com/Console_variables/Complete_list/Classic
	
	Resetting the WoW User Interface - Blizzard Support
	https://us.battle.net/support/en/article/7549
	
	Mouse jumping/centering FIX
	https://eu.forums.blizzard.com/en/wow/t/mouse-jumping-centering-fix/40704
	
	[代码片段]界面设置自动化
	https://bbs.nga.cn/read.php?tid=15294332
	
	CVAR簡表
	http://bbs.nga.cn/read.php?tid=9622396

	https://www.curseforge.com/wow/addons/tullactc
	https://www.curseforge.com/wow/addons/tullarange

	https://www.curseforge.com/wow/addons/hidetutorial
	https://www.curseforge.com/wow/addons/idtip

	https://github.com/siweia/NDui/blob/master/Interface/AddOns/NDui/Plugins/DragEmAll.lua
	https://www.curseforge.com/wow/addons/shift-right

	https://www.wowinterface.com/downloads/info15693-SnowfallCursor.html
	https://github.com/zorker/rothui/blob/master/wow11.0/rCompassCastbar/rCompassCastbar.lua
	https://www.wowinterface.com/downloads/info22526-SpotMe.html
]]--
