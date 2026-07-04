if not C_AddOns.IsAddOnLoaded("BigWigs") then return end

-- 預設設置
local function SetBW()
	if BigWigs3DB then table.wipe(BigWigs3DB) end
	
	BigWigs3DB = {
		["namespaces"] = {
			["BigWigs_Plugins_Victory"] = {
				["profiles"] = {
					["Default"] = {
						["bigwigsMsg"] = true,
						["blizzMsg"] = false,	-- 不顯示中央banner
						["soundName"] = "None",	-- 不播放勝利音效
					},
				},
			},
			["BigWigs_Plugins_Countdown"] = {
				["profiles"] = {
					["Default"] = {
						["voice"] = "English: Amy",
					},
				},
			},
			["BigWigs_Plugins_Bars"] = {
				["profiles"] = {
					["Default"] = {
						["BigWigsEmphasizeAnchor_x"] = 850,
						["BigWigsEmphasizeAnchor_y"] = 480,
						["BigWigsEmphasizeAnchor_width"] = 185,
						["BigWigsEmphasizeAnchor_height"] = 24,
						["emphasizeGrowup"] = true,
						["visibleBarLimitEmph"] = 8,
						["fontSizeEmph"] = 14,
						
						["BigWigsAnchor_width"] = 185,
						["BigWigsAnchor_height"] = 24,
						["BigWigsAnchor_x"] = 140,
						["BigWigsAnchor_y"] = 710,
						["growup"] = false,
						["visibleBarLimit"] = 10,
						["fontSize"] = 14,		
						
						["font"] = "預設",
						["barStyle"] = "Ruri",
						["spacing"] = 20,
						["texture"] = "Solid",
						["outline"] = "OUTLINE",
						
						["nameplateAutoWidth"] = false,
						["nameplateWidth"] = 100,
						["nameplateHeight"] = 12,
						["nameplateOffsetY"] = 14,
					},
				},
			},
			["BigWigs_Plugins_Colors"] = {
				["profiles"] = {
					["Default"] = {
						["blue"] = {
							["BigWigs_Plugins_Colors"] = {
								["default"] = {
									0.25, -- [1]
									0.5, -- [2]
									1, -- [3]
									1, -- [4]
								},
							},
						},
						["purple"] = {
							["BigWigs_Plugins_Colors"] = {
								["default"] = {
									0.8, -- [1]
									0.33, -- [2]
									1, -- [3]
									1, -- [4]
								},
							},
						},
						["green"] = {
							["BigWigs_Plugins_Colors"] = {
								["default"] = {
									0.65, -- [1]
									1, -- [2]
									0.65, -- [3]
									1, -- [4]
								},
							},
						},
						["orange"] = {
							["BigWigs_Plugins_Colors"] = {
								["default"] = {
									1, -- [1]
									0.5, -- [2]
									0.1, -- [3]
									1, -- [4]
								},
							},
						},
						["red"] = {
							["BigWigs_Plugins_Colors"] = {
								["default"] = {
									1, -- [1]
									0.27, -- [2]
									0.27, -- [3]
									1, -- [4]
								},
							},
						},
						["barTextShadow"] = {
							["BigWigs_Plugins_Colors"] = {
								["default"] = {
									nil, -- [1]
									nil, -- [2]
									nil, -- [3]
									0, -- [4]
								},
							},
						},
						["barColor"] = {
							["BigWigs_Plugins_Colors"] = {
								["default"] = {
									0.25, -- [1]
									0.55, -- [2]
									1, -- [3]
								},
							},
						},
						["barEmphasized"] = {
							["BigWigs_Plugins_Colors"] = {
								["default"] = {
									1, -- [1]
									0.29, -- [2]
									0.32, -- [3]
								},
							},
						},
						["flash"] = {
							["BigWigs_Plugins_Colors"] = {
								["default"] = {
									0.25, -- [1]
									0.5, -- [2]
									1, -- [3]
									1, -- [4]
								},
							},
						},
					},
				},
			},
			["BigWigs_Plugins_InfoBox"] = {
				["profiles"] = {
					["Default"] = {
						["posx"] = 250,
						["posy"] = 700,
					},
				},
			},
			["BigWigs_Plugins_Super Emphasize"] = {
				["profiles"] = {
					["Default"] = {
						["fontColor"] = {
							["g"] = 0.27,
							["b"] = 0.27,
						},
						["fontSize"] = 48,
						["voice"] = "English: Amy",
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
						["outline"] = "OUTLINE",
						["emphPosition"] = {
							"TOP", -- [1]
							"TOP", -- [2]
							0, -- [3]
							-150, -- [4]
						},
						["normalPosition"] = {
							nil, -- [1]
							nil, -- [2]
							400, -- [3]
							-300, -- [4]
						},
					},
				},
			},
			["BigWigs_Plugins_Statistics"] = {
				["profiles"] = {
					["Default"] = {
						["enabled"] = true,
						["saveBestKill"] = false,
						["printNewBestKill"] = false,
						["saveKills"] = false,
						["saveWipes"] = false,
					},
				},
			},
			["BigWigs_Plugins_Proximity"] = {
				["profiles"] = {
					["Default"] = {
						["posx"] = 840,
						["posy"] = 70,
						["fontSize"] = 14,
						["outline"] = "OUTLINE",
						["width"] = 120,
						["height"] = 120,
						["objects"] = {
							["tooltip"] = false,	--技能說明tooltip
							["ability"] = true,		--技能名稱
							["close"] = false,		--關閉按鈕
							["sound"] = false,		--音效按鈕
							["background"] = false,	--背景
						},					
					},
				},
			},
			["BigWigs_Plugins_AutoReply"] = {
			},
			["BigWigs_Plugins_Pull"] = {
				["profiles"] = {
					["Default"] = {
						["voice"] = "English: Amy",
					},
				},
			},
			["BigWigs_Plugins_AltPower"] = {
				["profiles"] = {
					["Default"] = {
						["outline"] = "OUTLINE",
						["position"] = {
							"TOP", -- [1]
							"TOP", -- [2]
							-520, -- [3]
							-130, -- [4]
						},
					},
				},
			},
			["BigWigs_Plugins_BossBlock"] = {
				["profiles"] = {
					["Default"] = {
						["blockEmotes"] = false,		-- 首領表情
						["blockSpellErrors"] = false,	-- 錯誤紅字
					},
				},
			},
		},
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
        text = "載入BigWigs布局 (適用2560*1440) /n Load BigWigs layout, it only match 2560*1440",
        button1 = ACCEPT,
        button2 = CANCEL,
        OnAccept =  function() SetBW() ReloadUI() end,
        --OnAccept =  function() SetBW() end,
        timeout = 0,
        whileDead = 1,
        hideOnEscape = true,
        preferredIndex = 5,
}
SLASH_SETBW1 = "/setbw"
SlashCmdList["SETBW"] = function()
        StaticPopup_Show("SET_BW")
end