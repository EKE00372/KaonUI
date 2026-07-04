----------------------
-- Dont touch this! --
----------------------

local addon, ns = ...
	ns[1] = {} -- C, config
	ns[2] = {} -- F, functions, constants, variables
	ns[3] = {} -- G, globals (Optionnal)
	ns[4] = {} -- L, localization
	
	--if Kiminfo == nil then Kiminfo = {} end
	
local C, F, G, L = unpack(ns)

local MediaFolder = "Interface\\AddOns\\!Anyon\\Media\\"

----------------------
-- Golbal and Media --
----------------------

	G.Ccolors = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[select(2, UnitClass("player"))]
	
	G.BarTex = "Interface\\Buttons\\WHITE8X8"
	G.GlowTex = MediaFolder.."glow.tga"
	G.Resize = MediaFolder.."Resize.tga"
	
	G.Mail = "Interface\\MINIMAP\\TRACKING\\Mailbox.blp"  -- "Interface\\HELPFRAME\\ReportLagIcon-Mail.blp"
	G.Diff = MediaFolder.."difficulty.tga"
	G.Report = "Interface\\HelpFrame\\HelpIcon-ReportLag.blp"
	
	G.HealthWarning = MediaFolder.."HealthWarning.ogg" 
	G.ManaWarning = MediaFolder.."ManaWarning.ogg" 
	G.TauntBeep = MediaFolder.."TauntBeep.ogg" -- https://freesound.org/people/pan14/sounds/263128/
	
	G.SpotMe = MediaFolder.."NeonReticule-blue.tga"
	
	G.Font = STANDARD_TEXT_FONT
	G.FontSize = 14
	G.FontFlag = "OUTLINE"

--------------
-- Settings --
--------------
	
	-- [[ SetUI ]]--
	
	C.SetUI = true			-- Load default settings, custom blizzard interface
	
	C.SetNP = true			-- Nameplates cvar
	C.SetFCT = true			-- Floating combat text cvar
	C.SetChat = true		-- Chat frame settings, tab and channel settings
	
	C.NewSpell = false		-- Put new spell to actionbar
	C.NoTutorial = true		-- Do not show tutorial
	C.ForceChatPos = true	-- Force chat position and size
	--C.GolbalStrings = true
	
	C.SetUIScale = true		-- Set UI Scale
	
	-- [[ Chat ]] --
	
	C.ChatWidth = 480
	C.ChatHeight = 200
	C.ChatPoint = {"BOTTOMLEFT", UIParent, "BOTTOMLEFT", 10, 20}
	C.ChatFontSize = 18

	-- [[ Minimap ]] --
	
	C.Minimap = true		-- enable minimap module
	C.ClickMenu = true		-- enable clickmenu
	C.Objetive = true		-- enable objective tracker module
	
	-- [[ Misc ]] --
	
	C.AutoLog = true		-- auto combatlog
	C.AutoInvite = true		-- auto invite
	C.AutoShot = true		-- auto screenshot when dead, level up, earn achievemnt, mythic+ finish, raid encounter end
	
	C.AutoTKH = true		-- auto hide talking head frame
	C.TKHMode = 1			-- 1 = hide sounds and frame, 2 = hide frame only
	
	C.RuriWigs = true		-- style bigwigs
	--C.StyleDBM = true		-- style dbm
	
	C.BetterRaid = false	-- hide compactraid name realm text
	C.DummyBar = true		-- hide bags and micro menu
	
	C.SnowfallCursor = true	-- cursor highlight
	C.MooseLight = true
	--C.WideMailBox = true	-- wide mailbox
	--C.WideBoxWidth = 220
	
	C.SpotMe = true
	C.CompassCastbar = true
	
---------------
-- Functions --
---------------
	
	-- [[ Multi check ]] --
	-- F.Multicheck(unit, "player", "boss", "pet")
	F.Multicheck = function(check, ...)
		for i = 1, select("#", ...) do
			if check == select(i, ...) then
				return true
			end
		end
		return false
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
]]--