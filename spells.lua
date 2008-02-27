local L = AfflictedLocals
AfflictedSpells = { 
	-- Shields
	[L["Divine Shield"]] = {
		seconds = 12,
		singleLimit = 0,
		showIn = "Buff",
		linkedTo = "",
	},
	
	[L["Ice Block"]] = {
		seconds = 10,
		singleLimit = 0,
		showIn = "Buff",
		linkedTo = "",
	},
	
	-- Buffs
	[L["Blessing of Protection"]] = {
		seconds = 10,
		singleLimit = 0,
		showIn = "Buff",
		linkedTo = "",
	},
	
	[L["Blessing of Freedom"]] = {
		seconds = 14,
		singleLimit = 0,
		showIn = "Buff",
		linkedTo = "",
	},
	
	[L["Blessing of Sacrifice"]] = {
		seconds = 30,
		singleLimit = 0,
		showIn = "Buff",
		linkedTo = "",
	},

	[L["Pain Suppression"]] = {
		seconds = 8,
		singleLimit = 0,
		showIn = "Buff",
		linkedTo = "",
	},
	
	-- Abilities
	[L["Cloak of Shadows"]] ={
		seconds = 5,
		singleLimit = 0,
		showIn = "Buff",
		linkedTo = "",
	},
	
	[L["Spell Reflection"]] ={
		seconds = 5,
		singleLimit = 0,
		showIn = "Buff",
		linkedTo = "",
	},
	
	-- Silences
	[L["Silencing Shot"]] = {
		seconds = 20,
		singleLimit = 0,
		showIn = "Spell",
		linkedTo = "",
	},

	[L["Silence"]] = {
		seconds = 45,
		singleLimit = 0,
		type = "deBuff",
		showIn = "Spell",
		linkedTo = "",
	},

	[L["Feral Charge"]] = {
		seconds = 15,
		singleLimit = 0,
		showIn = "Spell",
		linkedTo = "",
	},

	[L["Spell Lock"]] = {
		seconds = 24,
		singleLimit = 0,
		showIn = "Spell",
		linkedTo = "",
	},
	
	[L["Counterspell"]] = {
		seconds = 24,
		singleLimit = 0,
		showIn = "Spell",
		linkedTo = "",
	},

	[L["Counterspell - Silenced"]] ={
		seconds = 24,
		singleLimit = 0,
		showIn = "Spell",
		linkedTo = L["CounterSpell"],
	},

	[L["Kick"]] = {
		seconds = 10,
		singleLimit = 0,
		showIn = "Spell",
		linkedTo = "",
	},

	[L["Pummel"]] = {
		seconds = 10,
		singleLimit = 0,
		showIn = "Spell",
		linkedTo = "",
	},

	[L["Shield Bash"]] = {
		seconds = 12,
		singleLimit = 0,
		showIn = "Spell",
		--linkedTo = L["Pummel"],
		linkedTo = "",
	},
	
	-- Shocks
	[L["Flame Shock"]] = {
		seconds = 5,
		singleLimit = 0,
		showIn = "Spell",
		--linkedTo = L["Earth Shock"],
		linkedTo = "",
	},
	
	[L["Frost Shock"]] = {
		seconds = 5,
		singleLimit = 0,
		showIn = "Spell",
		--linkedTo = L["Earth Shock"],
		linkedTo = "",
	},
	
	[L["Earth Shock"]] = {
		seconds = 5,
		singleLimit = 0,
		showIn = "Spell",
		linkedTo = "",
	},
}
