local origin = C_MountJournal.GetMountLink
_G.C_MountJournal.GetMountLink = function(id)
    local mountLink = origin(id)
    if not mountLink then
        return C_Spell.GetSpellLink(id)
    end

    local prefix, postfix = strmatch(mountLink, '(\124cff71d5ff\124Hmount:%d+:%d+:).*(\124h%[[^%]]+%]\124h\124r)')
    if not prefix or not postfix then
        return C_Spell.GetSpellLink(id)
    end

    return prefix .. postfix
end


local SetMSBT = function()
	if not IsAddOnLoaded("MikScrollingBattleText") then return end
	if(MSBTProfiles_SavedVars) then table.wipe(MSBTProfiles_SavedVars) end
	
	MSBTProfiles_SavedVars = {
		["profiles"] = {
			["Default"] = {
				["glancing"] = {
					["trailer"] = " <D>",
				},
				["mergeSwingsDisabled"] = true,
				["textShadowingDisabled"] = true,
				["block"] = {
					["trailer"] = " <B:%a>",
				},
				["stickyCritsDisabled"] = true,
				["absorb"] = {
					["trailer"] = " <A:%a>",
				},
				["resist"] = {
					["trailer"] = " <R:%a>",
				},
				["critOutlineIndex"] = 2,
				["creationVersion"] = "5.8.1",
				["hideNames"] = true,
				["events"] = {
					["SELF_HOT"] = {
						["scrollArea"] = "Custom1",
					},
					["INCOMING_HEAL_CRIT"] = {
						["scrollArea"] = "Custom1",
					},
					["INCOMING_HOT_CRIT"] = {
						["scrollArea"] = "Custom1",
					},
					["SELF_HOT_CRIT"] = {
						["scrollArea"] = "Custom1",
					},
					["INCOMING_HOT"] = {
						["scrollArea"] = "Custom1",
					},
					["SELF_HEAL_CRIT"] = {
						["scrollArea"] = "Custom1",
					},
					["INCOMING_HEAL"] = {
						["scrollArea"] = "Custom1",
					},
					["SELF_HEAL"] = {
						["scrollArea"] = "Custom1",
					},
				},
				["normalOutlineIndex"] = 2,
				["enableBlizzardHealing"] = false,
				["scrollAreas"] = {
					["Outgoing"] = {
						["disabled"] = true,
					},
					["Incoming"] = {
						["direction"] = "Up",
						["behavior"] = "MSBT_NORMAL",
						["stickyBehavior"] = "Normal",
						["scrollHeight"] = 300,
						["offsetX"] = -499,
						["scrollWidth"] = 80,
						["iconAlign"] = "Right",
						["offsetY"] = -110,
						["animationStyle"] = "Straight",
					},
					["Static"] = {
						["disabled"] = true,
					},
					["Custom1"] = {
						["stickyTextAlignIndex"] = 3,
						["offsetX"] = -650,
						["scrollHeight"] = 300,
						["name"] = "受到治療",
						["scrollWidth"] = 80,
						["iconAlign"] = "Right",
						["offsetY"] = -109,
						["textAlignIndex"] = 3,
					},
					["Notification"] = {
						["disabled"] = true,
					},
				},
				["enableBlizzardDamage"] = false,
				["enableBlizzardDamage"] = false,
				["hideSkills"] = true,
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