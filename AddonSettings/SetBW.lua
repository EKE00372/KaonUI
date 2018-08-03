local addon, ns = ...

if not IsAddOnLoaded("BigWigs") then return end

-- 調用moniui風格美化
--[[
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, event, addon)
        if event == "ADDON_LOADED" and addon == "BigWigs_Plugins" then
                if not BigWigs then return end
                local bars = BigWigs:GetPlugin("Bars", true)
                if bars then
					--if cfg.StyleBW then
                        bars:SetBarStyle("MonoUI")
					--end
                end
                f:UnregisterEvent("ADDON_LOADED")
        end
end)]]--

-- 預設設置
local SetBW = function()
if(BigWigs3DB) then table.wipe(BigWigs3DB) end
	BigWigs3DB = {
	["namespaces"] = {
		["BigWigs_Plugins_Victory"] = {
			["profiles"] = {
				["Default"] = {
					["soundName"] = "None",	--不播放勝利音效
				},
			},
		},
		["BigWigs_Plugins_BossBlock"] = {
		},
		["BigWigs_Plugins_Colors"] = {
		},
		["BigWigs_Plugins_Wipe"] = {
		},
		["LibDualSpec-1.0"] = {
		},
		["BigWigs_Plugins_Bars"] = {
			["profiles"] = {
				["Default"] = {
					["BigWigsEmphasizeAnchor_x"] = 760,
					["BigWigsEmphasizeAnchor_y"] = 500,
					["BigWigsEmphasizeAnchor_width"] = 220,
					["BigWigsEmphasizeAnchor_height"] = 22,
					["emphasizeGrowup"] = true,
					["visibleBarLimitEmph"] = 8,
					["fontSizeEmph"] = 16,
					
					["BigWigsAnchor_width"] = 160,
					["BigWigsAnchor_height"] = 20,
					["BigWigsAnchor_x"] = 131,
					["BigWigsAnchor_y"] = 749,
					["growup"] = false,
					["visibleBarLimit"] = 16,
					["fontSize"] = 14,		
					
					["font"] = "預設",
					["barStyle"] = "MonoUI",
					["tempSpacingReset"] = true,
					["outline"] = "OUTLINE",
					["tempMonoUIReset"] = true,
					
				},
			},
		},
		["BigWigs_Plugins_InfoBox"] = {
			["profiles"] = {
				["Default"] = {
					["posx"] = 395,
					["posy"] = 740,
				},
			},
		},
		["BigWigs_Plugins_Super Emphasize"] = {
			["profiles"] = {
				["Default"] = {
					["fontSize"] = 40,
					["voice"] = "English: Amy",
					["font"] = "預設",
				},
			},
		},
		["BigWigs_Plugins_Sounds"] = {
		},
		["BigWigs_Plugins_Raid Icons"] = {
		},
		["BigWigs_Plugins_Messages"] = {
			["profiles"] = {
				["Default"] = {
					["fontSize"] = 20,
					["BWMessageAnchor_x"] = 764,
					["font"] = "預設",
					["BWMessageAnchor_y"] = 635,
				},
			},
		},
		["BigWigs_Plugins_Statistics"] = {
		},
		["BigWigs_Plugins_Proximity"] = {
			["profiles"] = {
				["Default"] = {
					["posx"] = 350,
					["posy"] = 120,
					["fontSize"] = 20,
					["width"] = 100,
					["height"] = 100,
					["objects"] = {
						["tooltip"] = false,	--技能說明tooltip
						["ability"] = false,	--技能名稱
						["close"] = false,		--關閉
						["sound"] = false,		--音效按鈕
						["background"] = false,	--背景
					},					
					["font"] = "預設",
				},
			},
		},
		["BigWigs_Plugins_AutoReply"] = {
		},
		["BigWigs_Plugins_Pull"] = {
			["profiles"] = {
				["Default"] = {
					["engageSound"] = "BigWigs: Alarm",
					["voice"] = "English: Amy",
				},
			},
		},
		["BigWigs_Plugins_Alt Power"] = {
			["profiles"] = {
				["Default"] = {
					["posx"] = 240,
					["posy"] = 730,
					["fontSize"] = 14,
					["font"] = "預設",
					["fontOutline"] = "OUTLINE",
				},
			},
		},
	},
	["discord"] = 1,
	["profiles"] = {
		["Default"] = {
			["fakeDBMVersion"] = true,
		},
	},
}
BigWigsIconDB = {
	--隱藏小地圖圖示
	["hide"] = true,
}
end



-- 載入設置
StaticPopupDialogs.SET_BW = {
        text = "載入BigWigs布局(僅適用1920*1200)",
        button1 = ACCEPT,
        button2 = CANCEL,
        OnAccept =  function() SetBW() ReloadUI() end,
        timeout = 0,
        whileDead = 1,
        hideOnEscape = true,
        preferredIndex = 5,
}
SLASH_SETBW1 = "/setbw"
SlashCmdList["SETBW"] = function()
        StaticPopup_Show("SET_BW")
end


