local L = AfflictedLocals
AfflictedSpells = { 
	-- Shields
	[L["Divine Shield"]] = {
		seconds = 12,
		singleLimit = 0,
		showIn = "Buff",
		linkedTo = "",
		checkEvents = {["TEST"] = true, ["SPELL_DAMAGE"] = true, ["SPELL_AURA_APPLIEDDEBUFFGROUP"] = false, ["SPELL_AURA_APPLIEDBUFFENEMY"] = true, ["SPELL_SUMMON"] = true, ["SPELL_CREATE"] = true, ["SPELL_INTERRUPT"] = true},
	},
	
	[L["Ice Block"]] = {
		seconds = 10,
		singleLimit = 0,
		showIn = "Buff",
		linkedTo = "",
		checkEvents = {["TEST"] = true, ["SPELL_DAMAGE"] = true, ["SPELL_AURA_APPLIEDDEBUFFGROUP"] = false, ["SPELL_AURA_APPLIEDBUFFENEMY"] = true, ["SPELL_SUMMON"] = true, ["SPELL_CREATE"] = true, ["SPELL_INTERRUPT"] = true},
	},
	
	-- Buffs
	[L["Blessing of Protection"]] = {
		seconds = 10,
		singleLimit = 0,
		showIn = "Buff",
		linkedTo = "",
		checkEvents = {["TEST"] = true, ["SPELL_DAMAGE"] = true, ["SPELL_AURA_APPLIEDDEBUFFGROUP"] = false, ["SPELL_AURA_APPLIEDBUFFENEMY"] = true, ["SPELL_SUMMON"] = true, ["SPELL_CREATE"] = true, ["SPELL_INTERRUPT"] = true},
	},
	
	[L["Blessing of Freedom"]] = {
		seconds = 14,
		singleLimit = 0,
		showIn = "Buff",
		linkedTo = "",
		checkEvents = {["TEST"] = true, ["SPELL_DAMAGE"] = true, ["SPELL_AURA_APPLIEDDEBUFFGROUP"] = false, ["SPELL_AURA_APPLIEDBUFFENEMY"] = true, ["SPELL_SUMMON"] = true, ["SPELL_CREATE"] = true, ["SPELL_INTERRUPT"] = true},
	},
	
	[L["Blessing of Sacrifice"]] = {
		seconds = 30,
		singleLimit = 0,
		showIn = "Buff",
		linkedTo = "",
		checkEvents = {["TEST"] = true, ["SPELL_DAMAGE"] = true, ["SPELL_AURA_APPLIEDDEBUFFGROUP"] = false, ["SPELL_AURA_APPLIEDBUFFENEMY"] = true, ["SPELL_SUMMON"] = true, ["SPELL_CREATE"] = true, ["SPELL_INTERRUPT"] = true},
	},

	[L["Pain Suppression"]] = {
		seconds = 8,
		singleLimit = 0,
		showIn = "Buff",
		linkedTo = "",
		checkEvents = {["TEST"] = true, ["SPELL_DAMAGE"] = true, ["SPELL_AURA_APPLIEDDEBUFFGROUP"] = false, ["SPELL_AURA_APPLIEDBUFFENEMY"] = true, ["SPELL_SUMMON"] = true, ["SPELL_CREATE"] = true, ["SPELL_INTERRUPT"] = true},
	},
	
	-- Abilities
	[L["Cloak of Shadows"]] ={
		seconds = 5,
		singleLimit = 0,
		showIn = "Buff",
		linkedTo = "",
		checkEvents = {["TEST"] = true, ["SPELL_DAMAGE"] = true, ["SPELL_AURA_APPLIEDDEBUFFGROUP"] = false, ["SPELL_AURA_APPLIEDBUFFENEMY"] = true, ["SPELL_SUMMON"] = true, ["SPELL_CREATE"] = true, ["SPELL_INTERRUPT"] = true},
	},
	
	[L["Spell Reflection"]] ={
		seconds = 5,
		singleLimit = 0,
		showIn = "Buff",
		linkedTo = "",
		checkEvents = {["TEST"] = true, ["SPELL_DAMAGE"] = true, ["SPELL_AURA_APPLIEDDEBUFFGROUP"] = false, ["SPELL_AURA_APPLIEDBUFFENEMY"] = true, ["SPELL_SUMMON"] = true, ["SPELL_CREATE"] = true, ["SPELL_INTERRUPT"] = true},
	},
	
	-- Silences
	[L["Silencing Shot"]] = {
		seconds = 20,
		singleLimit = 0,
		showIn = "Spell",
		linkedTo = "",
		checkEvents = {["TEST"] = true, ["SPELL_DAMAGE"] = true, ["SPELL_AURA_APPLIEDDEBUFFGROUP"] = false, ["SPELL_AURA_APPLIEDBUFFENEMY"] = true, ["SPELL_SUMMON"] = true, ["SPELL_CREATE"] = true, ["SPELL_INTERRUPT"] = true},
	},

	[L["Silence"]] = {
		seconds = 45,
		singleLimit = 0,
		showIn = "Spell",
		linkedTo = "",
		checkEvents = {["TEST"] = true, ["SPELL_DAMAGE"] = true, ["SPELL_AURA_APPLIEDDEBUFFGROUP"] = true, ["SPELL_AURA_APPLIEDBUFFENEMY"] = true, ["SPELL_SUMMON"] = true, ["SPELL_CREATE"] = true, ["SPELL_INTERRUPT"] = true},
	},

	[L["Feral Charge"]] = {
		seconds = 15,
		singleLimit = 0,
		showIn = "Spell",
		linkedTo = "",
		checkEvents = {["TEST"] = true, ["SPELL_DAMAGE"] = true, ["SPELL_AURA_APPLIEDDEBUFFGROUP"] = false, ["SPELL_AURA_APPLIEDBUFFENEMY"] = true, ["SPELL_SUMMON"] = true, ["SPELL_CREATE"] = true, ["SPELL_INTERRUPT"] = true},
	},

	[L["Spell Lock"]] = {
		seconds = 24,
		singleLimit = 0,
		showIn = "Spell",
		linkedTo = "",
		checkEvents = {["TEST"] = true, ["SPELL_DAMAGE"] = true, ["SPELL_AURA_APPLIEDDEBUFFGROUP"] = false, ["SPELL_AURA_APPLIEDBUFFENEMY"] = true, ["SPELL_SUMMON"] = true, ["SPELL_CREATE"] = true, ["SPELL_INTERRUPT"] = true},
	},
	
	[L["Counterspell"]] = {
		seconds = 24,
		singleLimit = 0,
		showIn = "Spell",
		linkedTo = "",
		checkEvents = {["TEST"] = true, ["SPELL_DAMAGE"] = true, ["SPELL_AURA_APPLIEDDEBUFFGROUP"] = false, ["SPELL_AURA_APPLIEDBUFFENEMY"] = true, ["SPELL_SUMMON"] = true, ["SPELL_CREATE"] = true, ["SPELL_INTERRUPT"] = true},
	},

	[L["Counterspell - Silenced"]] ={
		seconds = 24,
		singleLimit = 0,
		showIn = "Spell",
		linkedTo = L["CounterSpell"],
		checkEvents = {["TEST"] = true, ["SPELL_DAMAGE"] = true, ["SPELL_AURA_APPLIEDDEBUFFGROUP"] = false, ["SPELL_AURA_APPLIEDBUFFENEMY"] = true, ["SPELL_SUMMON"] = true, ["SPELL_CREATE"] = true, ["SPELL_INTERRUPT"] = true},
	},

	[L["Kick"]] = {
		seconds = 10,
		singleLimit = 0,
		showIn = "Spell",
		linkedTo = "",
		checkEvents = {["TEST"] = true, ["SPELL_DAMAGE"] = true, ["SPELL_AURA_APPLIEDDEBUFFGROUP"] = false, ["SPELL_AURA_APPLIEDBUFFENEMY"] = true, ["SPELL_SUMMON"] = true, ["SPELL_CREATE"] = true, ["SPELL_INTERRUPT"] = true},
	},

	[L["Pummel"]] = {
		seconds = 10,
		singleLimit = 0,
		showIn = "Spell",
		linkedTo = "",
		checkEvents = {["TEST"] = true, ["SPELL_DAMAGE"] = true, ["SPELL_AURA_APPLIEDDEBUFFGROUP"] = false, ["SPELL_AURA_APPLIEDBUFFENEMY"] = true, ["SPELL_SUMMON"] = true, ["SPELL_CREATE"] = true, ["SPELL_INTERRUPT"] = true},
	},

	[L["Shield Bash"]] = {
		seconds = 12,
		singleLimit = 0,
		showIn = "Spell",
		--linkedTo = L["Pummel"],
		linkedTo = "",
		checkEvents = {["TEST"] = true, ["SPELL_DAMAGE"] = true, ["SPELL_AURA_APPLIEDDEBUFFGROUP"] = false, ["SPELL_AURA_APPLIEDBUFFENEMY"] = true, ["SPELL_SUMMON"] = true, ["SPELL_CREATE"] = true, ["SPELL_INTERRUPT"] = true},
	},
	
	-- Shocks
	[L["Flame Shock"]] = {
		seconds = 5,
		singleLimit = 0,
		showIn = "Spell",
		--linkedTo = L["Earth Shock"],
		linkedTo = "",
		checkEvents = {["TEST"] = true, ["SPELL_DAMAGE"] = true, ["SPELL_AURA_APPLIEDDEBUFFGROUP"] = false, ["SPELL_AURA_APPLIEDBUFFENEMY"] = true, ["SPELL_SUMMON"] = true, ["SPELL_CREATE"] = true, ["SPELL_INTERRUPT"] = true},
	},
	
	[L["Frost Shock"]] = {
		seconds = 5,
		singleLimit = 0,
		showIn = "Spell",
		--linkedTo = L["Earth Shock"],
		linkedTo = "",
		checkEvents = {["TEST"] = true, ["SPELL_DAMAGE"] = true, ["SPELL_AURA_APPLIEDDEBUFFGROUP"] = false, ["SPELL_AURA_APPLIEDBUFFENEMY"] = true, ["SPELL_SUMMON"] = true, ["SPELL_CREATE"] = true, ["SPELL_INTERRUPT"] = true},
	},
	
	[L["Earth Shock"]] = {
		seconds = 5,
		singleLimit = 0,
		showIn = "Spell",
		linkedTo = "",
		checkEvents = {["TEST"] = true, ["SPELL_DAMAGE"] = true, ["SPELL_AURA_APPLIEDDEBUFFGROUP"] = false, ["SPELL_AURA_APPLIEDBUFFENEMY"] = true, ["SPELL_SUMMON"] = true, ["SPELL_CREATE"] = true, ["SPELL_INTERRUPT"] = true},
	},
}
