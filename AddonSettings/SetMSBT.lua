local SetMSBT = function()
	if not IsAddOnLoaded("MikScrollingBattleText") then return end
	if(MSBTProfiles_SavedVars) then table.wipe(MSBTProfiles_SavedVars) end
	MSBTProfiles_SavedVars = {
	["profiles"] = {
		["Default"] = {
			["normalOutlineIndex"] = 2,
			["glancing"] = {
				["trailer"] = " <D>",
			},
			["mergeSwingsDisabled"] = true,
			["hideSkills"] = true,
			["block"] = {
				["trailer"] = " <B:%a>",
			},
			["stickyCritsDisabled"] = true,
			["absorb"] = {
				["trailer"] = " <A:%a>",
			},
			["hideNames"] = true,
			["critOutlineIndex"] = 2,
			["animationSpeed"] = 50,
			["enableBlizzardHealing"] = false,
			["textShadowingDisabled"] = true,
			["creationVersion"] = "5.7.147",
			["resist"] = {
				["trailer"] = " <R:%a>",
			},
			["enableBlizzardDamage"] = false,
			["groupNumbers"] = true,
			["critFontSize"] = 18,
			["events"] = {
				["INCOMING_HEAL_CRIT"] = {
					["scrollArea"] = "Custom1",
				},
				["INCOMING_HEAL"] = {
					["scrollArea"] = "Custom1",
				},
				["INCOMING_HOT"] = {
					["scrollArea"] = "Custom1",
				},
				["INCOMING_HOT_CRIT"] = {
					["scrollArea"] = "Custom1",
				},
				["INCOMING_SPELL_DAMAGE_SHIELD_CRIT"] = {
					["scrollArea"] = "Custom1",
				},
				["INCOMING_SPELL_DAMAGE_SHIELD"] = {
					["scrollArea"] = "Custom1",
				},
			},
			["crushing"] = {
				["trailer"] = " <Cursing>",
			},
			["scrollAreas"] = {
				["Outgoing"] = {
					["direction"] = "Up",
					["scrollWidth"] = 10,
					["offsetX"] = 460,
					["iconAlign"] = "Left",
					["stickyBehavior"] = "Normal",
					["offsetY"] = -100,
					["animationStyle"] = "Straight",
					["behavior"] = "MSBT_NORMAL",
				},
				["Notification"] = {
					["disabled"] = true,
				},
				["Static"] = {
					["disabled"] = true,
				},
				["Custom1"] = {
					["stickyDirection"] = "Up",
					["stickyTextAlignIndex"] = 3,
					["offsetX"] = -650,
					["name"] = "heal",
					["iconAlign"] = "Right",
					["offsetY"] = -100,
					["textAlignIndex"] = 3,
					["stickyAnimationStyle"] = "Static",
				},
				["Incoming"] = {
					["direction"] = "Up",
					["behavior"] = "MSBT_NORMAL",
					["normalFontSize"] = 18,
					["stickyBehavior"] = "MSBT_NORMAL",
					["critFontSize"] = 20,
					["scrollWidth"] = 10,
					["offsetX"] = -500,
					["stickyDirection"] = "Up",
					["iconAlign"] = "Right",
					["offsetY"] = -100,
					["animationStyle"] = "Straight",
					["stickyAnimationStyle"] = "Static",
				},
			},
			["normalFontSize"] = 16,
		},
	},
	}
	if(MSBTProfiles_SavedVarsPerChar) then table.wipe(MSBTProfiles_SavedVarsPerChar) end
	MSBTProfiles_SavedVarsPerChar = {
		["currentProfileName"] = "Default",
	}
end
SLASH_SETMSBT1 = "/setmsbt"
SlashCmdList["SETMSBT"] = function()
        SetMSBT() ReloadUI()
end