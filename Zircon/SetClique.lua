-- 減少重複表格
local function Bind(binding)
	binding.sets = {
		default = true,
	}

	return binding
end

local function Spell(key, spell, icon)
	return Bind({
		type = "spell",
		key = key,
		spell = spell,
		icon = icon,
	})
end

-- Clique Settings
local CliquePresets = {
	PALADIN = {
		label = "聖騎士",
		char = {
			blizzframes = {
				statusBarFix = false,
			},
			fastooc = false,
			specswap = false,
			downclick = false,
		},
		profile = {
			bindings = {
				Bind({
					type = "target",
					key = "BUTTON1",
					unit = "mouseover",
				}),
				Spell("CTRL-BUTTON2", "保護祝福", 135964),
				Spell("SHIFT-BUTTON1", "聖光閃現", 135907),
				Spell("CTRL-BUTTON3", "榮耀聖言", 133192),
				Bind({
					type = "menu",
					key = "BUTTON2",
				}),
				Spell("BUTTON3", "淨化毒素", 135953),
				Spell("SHIFT-BUTTON3", "聖療術", 135928),
				Spell("SHIFT-BUTTON2", "代禱", 4726195),
				Spell("SHIFT-Y", "犧牲祝福", 135966),
				Spell("CTRL-BUTTON1", "自由祝福", 135968),
				Spell("SHIFT-6", "抗咒祝福", 135880),
				Spell("X", "神聖堅盾", 5927636),
			},
		},
	},
}

local function SetClique(class)
	if not C_AddOns.IsAddOnLoaded("Clique") then return end

	local preset = CliquePresets[class]
	if not preset then return end

	local realmName = GetRealmName() or ""
	local characterKey = UnitName("player") .. " - " .. realmName
	
	-- CliqueDB3 是 Clique 的 SavedVariables 主表
	CliqueDB3 = CliqueDB3 or {}
	CliqueDB3.char = CliqueDB3.char or {}
	CliqueDB3.profileKeys = CliqueDB3.profileKeys or {}
	CliqueDB3.profiles = CliqueDB3.profiles or {}
	-- 只對當前角色寫入
	CliqueDB3.char[characterKey] = CopyTable(preset.char, true)
	CliqueDB3.profileKeys[characterKey] = characterKey
	CliqueDB3.profiles[characterKey] = CopyTable(preset.profile, true)

	return true
end

StaticPopupDialogs.SET_CLIQUE = {
	text = "載入 Clique 按鍵設定：%s",
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(_, class)
		if SetClique(class) then
			ReloadUI()
		end
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = true,
	preferredIndex = 5,
}

SLASH_SETCLIQUE1 = "/setclique"
SlashCmdList.SETCLIQUE = function()
	local class = select(2, UnitClass("player"))
	local preset = CliquePresets[class]

	if not preset then return end
	if not C_AddOns.IsAddOnLoaded("Clique") then return end

	-- 將職業 token 傳入確認框，確認後才覆蓋目前角色 Clique 設定。
	StaticPopup_Show("SET_CLIQUE", preset.label, nil, class)
end
