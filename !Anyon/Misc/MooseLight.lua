local _, ns = ...
local F = ns[2]
local M = F.RegisterModule("MooseLight", "MooseLight")

local GetAreaInfo = C_Map.GetAreaInfo
local C_Map_GetBestMapForUnit = C_Map.GetBestMapForUnit
local GetInstanceInfo, GetGameTime, GetSubZoneText = GetInstanceInfo, GetGameTime, GetSubZoneText
local SetCVar = C_CVar.SetCVar

-- [[ 根據地點調整亮度 ]] --

-- add new map id by yourself:
-- https://warcraft.wiki.gg/wiki/UiMapID
-- https://warcraft.wiki.gg/wiki/InstanceID
-- https://wago.tools/db2/UiMap
-- https://wago.tools/db2/Map
-- macro to get your map id:
-- /dump C_Map.GetBestMapForUnit("player")
--
-- C_AreaPoiInfo.GetAreaPOIInfo(uiMapID, areaPoiID)
-- https://warcraft.wiki.gg/wiki/API_C_AreaPoiInfo.GetAreaPOIInfo
-- https://wago.tools/db2/AreaTable
-- C_Map.GetAreaInfo 9964 潮水聖所  14619 14692 澤斯克拉密庫
-- CVar Gamma/Brightness/Contrast

local DFC_Active = true

local timeID = {
	-- BFA
	[896] = true,	-- Drustvar / 佐司瓦
	[895] = true,	-- Tiragarde Sound / 提加拉德
	[942] = true,	-- Stormsong Valley / 斯托頌恩
	[864] = true,	-- Vol'dun / 沃魯敦
	[863] = true,	-- Nazmir / 納茲米爾
	[862] = true,	-- Zuldazar / 祖達薩
	--[1462] = true,	-- 麥卡貢/機械岡
	--[1196] = true,
	--[1197] = true,
	--[1198] = true,

	-- DF
	[2022] = true,	-- The Waking Shores / 甦醒海岸
	[2023] = true,	-- 	Ohn'ahran Plains / 雍亞拉平原
	[2024] = true,	-- The Azure Span / 蒼藍高地
	[2025] = true,	-- 	Thaldraszus / 薩爪祖斯

	-- TWW
	[2369] = true,	-- Siren Isle / 海妖島
}

local zoneDarkID = {
	-- SL
	[1533] = true,	-- Bastion / 昇靈堡
	[1707] = true,	-- Elysian Hold, Archon's Rise / 樂土堡
	[1708] = true,	-- Elysian Hold, Sanctum of Binding / 樂土堡
}

local zoneLightID = {
	-- AZEROTH
	--[85] = true,	-- Orgrimmar / 奧格瑪探路者巢穴
	[86] = true,	-- Orgrimmar / 奧格瑪暗影裂谷
	-- LEGION
	[885] = true,	-- Antoran Wastes / 安托洛斯荒原
	-- Antorus, the Burning Throne / 安托洛斯，燃燒王座
	[909] = true,	-- 	Antorus, the Burning Throne/ 燃燒王座
	[910] = true,	-- 	Gaze of the Legion / 軍團之視
	[911] = true,	-- 	Halls of the Boundless Reach / 無縛之境
	[914] = true,	-- 	The Exhaust / 排氣口
	--[915] = true,	-- 	The Burning Throne / 燃燒王座
	[916] = true,	-- 	Chamber of Anguish / 苦痛之廳
	--[917] = true,	-- 	The World Soul / 世界之魂
	-- BFA
	[1162] = true,	-- Siege of Boralus / 波拉勒斯圍城戰
	[1038] = true,	-- Temple of Sethraliss / 瑟沙利斯神廟
	[1152] = true,	-- Uldir, Plague Vault / 奧迪爾，維克提斯
	[1169] = true,	-- Tol Dagor outside / 托達戈爾戶外
	-- BFA VISION
	[1469] = true, -- Vision of Orgrimmar / 奧格瑪幻象
	[1470] = true, -- Vision of Stormwind / 暴風城幻象
	[1570] = true, -- 恆春谷幻象
	[1571] = true, -- 奧丹姆幻象
	-- SL
	[1543] = true, -- The Maw / 噬淵
	[1664] = true, -- 贖罪之殿，痛苦中殿
	[1665] = true, -- 贖罪之殿，靈魂聖所
	[1995] = true, -- 市集，斯鐸海姆
	--[1961] = true, -- Korthia / 科西亞
	-- DF
	[2151] = true,	-- The Forbidden Reach / 禁忌離島 (澤斯克拉密庫沒有單獨的地圖)
	[2095] = true,	-- Infusion Chambers / 閃霜入侵點
	[2133] = true,	-- Zaralek Cavern / 扎拉萊克洞穴
	-- TWW
	[2214] = true,	-- 鳴響深淵
	[2255] = true,	-- 阿茲-卡罕特
	[2213] = true,	-- 蛛絲城野外
	--[2256] = true,	-- 阿茲-卡罕特下層 這啥?
	[2317] = true,	-- 培育所，風暴育所
	[2318] = true,	-- 培育所，風暴飛騎兵營
	[2319] = true,	-- 培育所，風暴廳堂
	[2320] = true,	-- 培育所，廢棄礦坑
	[2388] = true,	-- 水閘行動，GRID
}

local insLightID = {
	-- AZEROTH
	[289] = true,	-- Scholomance OLD / 舊通靈學院
	[1007] = true,	-- Scholomance / 新通靈學院
	[329] = true,	-- Stratholme / 斯坦索姆
	[533] = true,	-- Naxxramas / 納克薩瑪斯
	-- WLK
	[658] = true,	-- 薩倫之淵
	-- CATA
	[670] = true,	-- Grim Batol / 格瑞姆巴托
	-- WOD
	[1176] = true,	-- Shadowmoon Burial Grounds / 影月墓地
	-- LEG
	[1466] = true,	-- Darkheart Thicket / 暗心灌木林
	[1501] = true,	-- Black Rook Hold / 玄鴉堡
	-- BFA
	[1841] = true,	-- The Underrot / 幽腐深窟
	[1711] = true,	-- Tol Dagor / 托達戈爾
	[1862] = true,	-- Waycrest Manor / 威奎斯特莊園
	-- SL
	[2284] = true,	-- Sanguine Depths / 血紅深淵
	[2162] = true,	-- Torghast, Tower of the Damned / 托加斯特
	-- DF
	[2515] = true,	-- The Azure Vault / 蒼藍密庫
	[2519] = true,	-- Neltharus / 奈薩魯斯堡
	[2520] = true,	-- Brackenhide Hollow / 撅屁...蕨皮谷
	--[2527] = true,	-- Halls of Infusion / 灌注迴廊
	-- TWW
	[2664] = true,	-- 菌菇愚行
	[2679] = true,	-- 真菌法師洞窟
	[2680] = true,	-- 地行礦坑
	[2681] = true,	-- 克里格瓦之眠
	[2682] = true,	-- 澤克維爾巢穴
	[2683] = true,	-- 水力發電壩
	[2684] = true,	-- 恐怖地穴
	[2685] = true,	-- 奔蛛裂層
	[2686] = true,	-- 夜暮聖所
	[2687] = true,	-- 陷坑
	[2688] = true,	-- 迴繞地道
	[2689] = true,	-- 塔克-瑞桑深淵
	[2690] = true,	-- 深淵堡
	[2826] = true,	-- 後街水閘
	[2815] = true,	-- 9號挖掘場
	[2669] = true,	-- 蛛絲城
	[2652] = true,	-- 石庫
	[2651] = true,	-- 暗焰裂縫
	[2660] = true,	-- 『回音之城』厄拉卡拉
	[2803] = true,	-- 文庫襲擊
	-- Midnight
	[2952] = true,	-- 暗影領區
	[2961] = true,	-- 暮光墓穴
	[2963] = true,	-- 怨鬥坑洞
	[3003] = true,	-- 黑暗之途
	[2874] = true,	-- 梅薩拉洞穴
	[3043] = true,	-- 金多詹的迷宮
}

local insDarkID = {
	[2285] = true,	-- Spires Of Ascension / 晉升之巔
}

local subLightName = {
	-- 諸王之眠：室內沒有獨立 AreaID，WMOAreaTable：94268（先王之堂）、94269（逝塵之廳）。

	-- 先王之堂
	["先王之堂"] = true, -- zhTW
	["荣耀亡者大厅"] = true, -- zhCN
	["Hall of Honored Dead"] = true, -- enUS
	["Die Halle der Geehrten Toten"] = true, -- deDE
	["Cámara de los Muertos Honorables"] = true, -- esES
	["Salón de los Muertos Reverenciados"] = true, -- esMX
	["Hall des Morts honorés"] = true, -- frFR
	["Sala dei Morti Onorevoli"] = true, -- itIT
	["명예로운 죽음의 회당"] = true, -- koKR
	["Salão dos Mortos Honoráveis"] = true, -- ptBR
	["Зал почитаемых усопших"] = true, -- ruRU

	-- 逝塵之廳
	["逝塵之廳"] = true, -- zhTW
	["灰烬灵堂"] = true, -- zhCN
	["Halls of Ash"] = true, -- enUS
	["Die Hallen der Asche"] = true, -- deDE
	["Cámara de las Cenizas"] = true, -- esES
	["Salones de Cenizas"] = true, -- esMX
	["Salles des Cendres"] = true, -- frFR
	["Sale delle Ceneri"] = true, -- itIT
	["유골의 전당"] = true, -- koKR
	["Salão das Cinzas"] = true, -- ptBR
	["Галереи праха"] = true, -- ruRU
}

-- 特例

local DFC_instanceID = {
	[2651] = true,	-- 暗焰裂縫
}

local subDarkName, DFC_subName
local updateTimer

local function UpdateLighting()
	local MapID = C_Map_GetBestMapForUnit("player")
	local hour = GetGameTime()
	local name = GetSubZoneText()
	local instanceID = select(8, GetInstanceInfo())
	-- 無光深淵固定加亮，避開燭光光環的 Secret 限制。
	local inDepths = (DFC_Active == true) and DFC_instanceID[instanceID] and DFC_subName[name]

	if inDepths then
		SetCVar("Gamma", 1.5)
		SetCVar("Brightness", 60)
		SetCVar("Contrast", 70)
		return
	end

	if not MapID then return end

	local gamma, brightness = 1, 50
	if zoneLightID[MapID] or insLightID[instanceID] or subLightName[name] then
		gamma = 1.2
	elseif zoneDarkID[MapID] or insDarkID[instanceID] or subDarkName[name] then
		gamma, brightness = .9, 40
	elseif timeID[MapID] and (hour < 6 or hour > 17) then
		gamma = 1.2
	end

	SetCVar("Gamma", gamma)
	SetCVar("Brightness", brightness)
	SetCVar("Contrast", 50)

	-- 停用全螢幕泛光與死亡特效。
	SetCVar("ffxGlow", 0)
	SetCVar("ffxDeath", 0)
end

local function ScheduleUpdate()
	if updateTimer then updateTimer:Cancel() end

	-- 合併連續換區事件，保留最後一次事件後的兩秒等待。
	updateTimer = C_Timer.NewTimer(2, function()
		updateTimer = nil
		UpdateLighting()
	end)
end

function M:OnEnable()
	subDarkName = {
		[GetAreaInfo(16422)] = true, -- 埃達尼秘境，埃達尼沙地
		[GetAreaInfo(16569)] = true, -- 埃達尼秘境，不羈神殿
	}

	DFC_subName = {
		[GetAreaInfo(15023)] = true, -- 暗焰裂縫，無光深淵
	}

	local frame = CreateFrame("Frame")
	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	frame:RegisterEvent("ZONE_CHANGED")
	frame:RegisterEvent("ZONE_CHANGED_INDOORS")
	frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	frame:SetScript("OnEvent", ScheduleUpdate)
end
