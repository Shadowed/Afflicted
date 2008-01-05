--[[
	["CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF"] = {
		"366055.734:Drama casts Windfury Totem.", -- [1]
		"366064.89:Drama casts Grounding Totem.", -- [2]
		"366068.421:Drama begins to cast Lesser Healing Wave.", -- [3]
		"366069.812:Drama's Lesser Healing Wave heals Drama for 1317.", -- [4]
		"366080.281:Drama casts Tremor Totem.", -- [5]
		"366139.968:Drama casts Tremor Totem.", -- [6]
		"366141.328:Drama casts Flametongue Totem.", -- [7]
		"366153.218:Drama casts Tremor Totem.", -- [8]
	},

	["CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE"] = {
		"415268.765:Frobozz casts Spellsteal on you.", -- [1]
		"415288.406:Frobozz begins to perform Shoot.", -- [2]
		"415307.703:Frobozz interrupts your Holy Light.", -- [3]
	},

	["CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE"] = {
		"537968.171:Deusmortis's Pummel crits Gulem for 59.", -- [1]
		"538426.187:Thenoose's Pummel crits you for 52.", -- [2]
		"538979.156:Akelda's Pummel hits you for 40.", -- [3]
		"538994.609:Akelda's Pummel hits you for 41.", -- [4]
		"539005.093:Akelda's Pummel was dodged.", -- [5]
		"539016.046:Akelda's Pummel crits you for 77.", -- [6]
	},
]]

local L = AfflictedLocals
AfflictedSpells = { 
	-- Shields
	[L["Divine Shield"]] = {
		id = "divineshield",
		seconds = 12,
		icon = "Interface\\Icons\\Spell_Holy_DivineIntervention",
		type = "buff",
	},
	
	[L["Ice Block"]] = {
		id = "iceblock",
		seconds = 10,
		icon = "Interface\\Icons\\Spell_Frost_Frost",
		type = "buff",
	},
	
	-- Buffs
	[L["Blessing of Protection"]] = {
		id = "blassingofprot",
		seconds = 10,
		icon = "Interface\\Icons\\Spell_Holy_SealOfProtection",
		type = "buff",
	},
	
	[L["Blessing of Freedom"]] = {
		id = "blessingofreedom",
		seconds = 14,
		icon = "Interface\\Icons\\Spell_Holy_SealOfValor",
		type = "buff",
	},
	
	[L["Blessing of Sacrifice"]] = {
		id = "blessingofsac",
		seconds = 30,
		icon = "Interface\\Icons\\Spell_Holy_SealOfSacrifice",
		type = "buff",
	},
	
	-- Abilities
	[L["Cloak of Shadows"]] ={
		id = "cloakofshadows",
		seconds = 5,
		icon = "Interface\\Icons\\Spell_Shadow_NetherCloak",
		type = "buff",
	},
	
	[L["Spell Reflection"]] ={
		id = "spellreflection",
		seconds = 5,
		icon = "Interface\\Icons\\Ability_Warrior_ShieldReflection",
		type = "buff",
	},
	
	-- Silences
	[L["Silencing Shot"]] = {
		id = "silencingshot",
		seconds = 20,
		icon = "Interface\\Icons\\INV_Spear_08",
		type = "spell",
	},

	[L["Silence"]] = {
		id = "silence",
		seconds = 45,
		icon = "Interface\\Icons\\Spell_Shadow_ImpPhaseShift",
		type = "spell",
	},

	[L["Feral Charge"]] = {
		id = "feralcharge",
		seconds = 15,
		icon = "Interface\\Icons\\Ability_Hunter_Pet_Bear",
		type = "spell",
	},

	[L["Spell Lock"]] = {
		id = "spelllock",
		seconds = 24,
		icon = "Interface\\Icons\\Spell_Shadow_MindRot",
		type = "spell",
	},
	
	[L["Counterspell - Silenced"]] = {
		id = "impcounterspell",
		seconds = 24,
		icon = "Interface\\Icons\\Spell_Frost_IceShock",
		type = "spell",
		afflicted = true,
	},

	[L["Kick"]] = {
		id = "kick",
		seconds = 10,
		icon = "Interface\\Icons\\Ability_Kick",
		type = "spell",
	},

	[L["Pummel"]] = {
		id = "pummel",
		seconds = 10,
		icon = "Interface\\Icons\\INV_Gauntlets_04",
		type = "spell",
	},

	[L["Shield Bash"]] = {
		id = "shieldbash",
		seconds = 12,
		icon = "Interface\\Icons\\Ability_Warrior_ShieldBash",
		type = "spell",
	},
	
	[L["Earth Shock"]] = {
		id = "earthshock",
		seconds = 12,
		icon = "Interface\\Icons\\Spell_Nature_EarthShock",
		type = "spell",
	},
}
