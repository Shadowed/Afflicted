local L = AfflictedLocals
AfflictedSpells = { 
	-- Shields
	[L["Divine Shield"]] = {
		seconds = 12,
		singleLimit = 0,
		showIn = "buff",
		linkedTo = "",
	},
	
	[L["Ice Block"]] = {
		seconds = 10,
		singleLimit = 0,
		showIn = "buff",
		linkedTo = "",
	},
	
	["Intercept Stun"] = {
		seconds = 15,
		singleLimit = 0.5,
		showIn = "buff",
		linkedTo = "",
	},
	
	-- Buffs
	[L["Blessing of Protection"]] = {
		seconds = 10,
		singleLimit = 0,
		showIn = "buff",
		linkedTo = "",
	},
	
	[L["Blessing of Freedom"]] = {
		seconds = 14,
		singleLimit = 0,
		showIn = "buff",
		linkedTo = "",
	},
	
	[L["Blessing of Sacrifice"]] = {
		seconds = 30,
		singleLimit = 0,
		showIn = "buff",
		linkedTo = "",
	},

	[L["Pain Suppression"]] = {
		seconds = 8,
		singleLimit = 0,
		showIn = "buff",
		linkedTo = "",
	},
	
	-- Abilities
	[L["Cloak of Shadows"]] ={
		seconds = 5,
		singleLimit = 0,
		showIn = "buff",
		linkedTo = "",
	},
	
	[L["Spell Reflection"]] ={
		seconds = 5,
		singleLimit = 0,
		showIn = "buff",
		linkedTo = "",
	},
	
	-- Silences
	[L["Silencing Shot"]] = {
		seconds = 20,
		singleLimit = 0,
		showIn = "spell",
		linkedTo = "",
	},

	[L["Silence"]] = {
		seconds = 45,
		singleLimit = 0,
		type = "debuff",
		showIn = "spell",
		linkedTo = "",
	},

	[L["Feral Charge"]] = {
		seconds = 15,
		singleLimit = 0,
		showIn = "spell",
		linkedTo = "",
	},

	[L["Spell Lock"]] = {
		seconds = 24,
		singleLimit = 0,
		showIn = "spell",
		linkedTo = "",
	},
	
	[L["Counterspell"]] = {
		seconds = 24,
		singleLimit = 0,
		showIn = "spell",
		linkedTo = "",
	},

	[L["Counterspell - Silenced"]] ={
		seconds = 24,
		singleLimit = 0,
		showIn = "spell",
		linkedTo = L["Counterspell"],
	},

	[L["Kick"]] = {
		seconds = 10,
		singleLimit = 0,
		showIn = "spell",
		linkedTo = "",
	},

	[L["Pummel"]] = {
		seconds = 10,
		singleLimit = 0,
		showIn = "spell",
		linkedTo = "",
	},

	[L["Shield Bash"]] = {
		seconds = 12,
		singleLimit = 0,
		showIn = "spell",
		--linkedTo = L["Pummel"],
		linkedTo = "",
	},
	
	-- Shocks
	[L["Flame Shock"]] = {
		seconds = 5,
		singleLimit = 0,
		showIn = "spell",
		--linkedTo = L["Earth Shock"],
		linkedTo = "",
	},
	
	[L["Frost Shock"]] = {
		seconds = 5,
		singleLimit = 0,
		showIn = "spell",
		--linkedTo = L["Earth Shock"],
		linkedTo = "",
	},
	
	[L["Earth Shock"]] = {
		seconds = 5,
		singleLimit = 0,
		showIn = "spell",
		linkedTo = "",
	},
}
