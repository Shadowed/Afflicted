local L = AfflictedLocals
AfflictedSpells = { 
	-- Divine Shield
	[642] = 1020,
	[1020] = {
		text = "Divine Shield",
		seconds = 12,
		cooldown = 0,
		singleLimit = 0,
		globalLimit = 0,
		showIn = "buffs",
		TEST = true, SPELL_MISC = true, SPELL_AURA_APPLIEDDEBUFFGROUP = false, SPELL_AURA_APPLIEDBUFFENEMY = true, SPELL_SUMMON = false, SPELL_CREATE = false, SPELL_INTERRUPT = false,
	},
	
	-- Kidney Shot
	[408] = 8643,
	[8643] = {
		text = "Kidney Shot",
		disabled = true,
		seconds = 20,
		cooldown = 0,
		singleLimit = 0,
		globalLimit = 0,
		showIn = "spells",
		TEST = true, SPELL_MISC = true, SPELL_AURA_APPLIEDDEBUFFGROUP = true, SPELL_AURA_APPLIEDBUFFENEMY = false, SPELL_SUMMON = false, SPELL_CREATE = false, SPELL_INTERRUPT = false,
	},
	
	-- Psychic Scream
	[8122] = 10890,
	[8124] = 10890,
	[10888] = 10890,
	[10890] = {
		text = "Psychic Scream",
		disabled = true,
		seconds = 24,
		cooldown = 0,
		singleLimit = 0,
		globalLimit = 2,
		showIn = "spells",
		TEST = true, SPELL_MISC = true, SPELL_AURA_APPLIEDDEBUFFGROUP = true, SPELL_AURA_APPLIEDBUFFENEMY = false, SPELL_SUMMON = false, SPELL_CREATE = false, SPELL_INTERRUPT = false,
	},
	
	-- Power Infusion
	[10060] = {
		text = "Power Infusion",
		seconds = 15,
		cooldown = 0,
		singleLimit = 0,
		globalLimit = 0,
		showIn = "buffs",
		TEST = true, SPELL_MISC = true, SPELL_AURA_APPLIEDDEBUFFGROUP = false, SPELL_AURA_APPLIEDBUFFENEMY = true, SPELL_SUMMON = false, SPELL_CREATE = false, SPELL_INTERRUPT = false,
	},

	--  Evasion
	[5277] = 26669,
	[26669] = {
		text = "Evasion",
		seconds = 15,
		cooldown = 0,
		singleLimit = 0,
		globalLimit = 0,
		showIn = "buffs",
		TEST = true, SPELL_MISC = true, SPELL_AURA_APPLIEDDEBUFFGROUP = false, SPELL_AURA_APPLIEDBUFFENEMY = true, SPELL_SUMMON = false, SPELL_CREATE = false, SPELL_INTERRUPT = false,
	},

	-- Icy Veins
	[12472] = {
		text = "Icy Veins",
		seconds = 20,
		cooldown = 0,
		singleLimit = 0,
		globalLimit = 0,
		showIn = "spells",
		TEST = true, SPELL_MISC = true, SPELL_AURA_APPLIEDDEBUFFGROUP = false, SPELL_AURA_APPLIEDBUFFENEMY = true, SPELL_SUMMON = false, SPELL_CREATE = false, SPELL_INTERRUPT = false,
	},
	
	-- Berserker Rage
	[18499] = {
		text = "Berserker Rage",
		disabled = true,
		seconds = 10,
		cooldown = 30,
		singleLimit = 0,
		globalLimit = 0,
		showIn = "spells",
		TEST = true, SPELL_MISC = true, SPELL_AURA_APPLIEDDEBUFFGROUP = false, SPELL_AURA_APPLIEDBUFFENEMY = false, SPELL_SUMMON = false, SPELL_CREATE = false, SPELL_INTERRUPT = false,
	},
	
	-- Viper sting
	[3034] = 27018,
	[14279] = 27018,
	[14280] = 27018,
	[27018] = {
		text = "Viper Sting",
		seconds = 15,
		cooldown = 0,
		singleLimit = 0,
		globalLimit = 0,
		showIn = "spells",
		TEST = true, SPELL_MISC = true, SPELL_AURA_APPLIEDDEBUFFGROUP = true, SPELL_AURA_APPLIEDBUFFENEMY = false, SPELL_SUMMON = false, SPELL_CREATE = false, SPELL_INTERRUPT = false,
	},
	
	
	-- Ice Block
	[45438] = {
		text = "Ice Block",
		seconds = 10,
		cooldown = 0,
		singleLimit = 0,
		globalLimit = 0,
		showIn = "buffs",
		TEST = true, SPELL_MISC = true, SPELL_AURA_APPLIEDDEBUFFGROUP = false, SPELL_AURA_APPLIEDBUFFENEMY = true, SPELL_SUMMON = false, SPELL_CREATE = false, SPELL_INTERRUPT = false,
	},
	
	-- Hypothermia
	[41425] = {
		text = "Hypothermia",
		seconds = 30,
		cooldown = 0,
		singleLimit = 0,
		globalLimit = 0,
		showIn = "buffs",
		TEST = true, SPELL_MISC = true, SPELL_AURA_APPLIEDDEBUFFGROUP = false, SPELL_AURA_APPLIEDBUFFENEMY = false, SPELL_SUMMON = false, SPELL_CREATE = false, SPELL_INTERRUPT = false,
	},
	
	-- Blessing of Protection
	[1022] = 10278,
	[5599] = 10278,
	[10278] = {
		text = "Blessing of Protection",
		seconds = 10,
		singleLimit = 0,
		cooldown = 0,
		singleLimit = 0,
		globalLimit = 0,
		showIn = "buffs",
		TEST = true, SPELL_MISC = true, SPELL_AURA_APPLIEDDEBUFFGROUP = false, SPELL_AURA_APPLIEDBUFFENEMY = true, SPELL_SUMMON = false, SPELL_CREATE = false, SPELL_INTERRUPT = false,
	},
	
	-- Blessing of Freedom
	[1044] = {
		text = "Blessing of Freedom",
		seconds = 14,
		cooldown = 25,
		singleLimit = 0,
		globalLimit = 0,
		showIn = "buffs",
		TEST = true, SPELL_MISC = true, SPELL_AURA_APPLIEDDEBUFFGROUP = false, SPELL_AURA_APPLIEDBUFFENEMY = true, SPELL_SUMMON = false, SPELL_CREATE = false, SPELL_INTERRUPT = false,
	},
	
	-- Blessing of Sacrifice
	[6940] = 27148,
	[20729] = 27148,
	[27147] = 27148,
	[27148] = {
		text = "Blessing of Sacrifice",
		seconds = 30,
		cooldown = 0,
		singleLimit = 0,
		globalLimit = 0,
		showIn = "buffs",
		TEST = true, SPELL_MISC = true, SPELL_AURA_APPLIEDDEBUFFGROUP = false, SPELL_AURA_APPLIEDBUFFENEMY = true, SPELL_SUMMON = false, SPELL_CREATE = false, SPELL_INTERRUPT = false,
	},

	-- Pain Suppression
	[33206] = {
		text = "Pain Suppression",
		seconds = 8,
		cooldown = 0,
		singleLimit = 0,
		globalLimit = 0,
		showIn = "buffs",
		TEST = true, SPELL_MISC = true, SPELL_AURA_APPLIEDDEBUFFGROUP = false, SPELL_AURA_APPLIEDBUFFENEMY = true, SPELL_SUMMON = false, SPELL_CREATE = false, SPELL_INTERRUPT = false,
	},
	
	-- Cloak of Shadows
	[31224] = {
		text = "Cloak of Shadows",
		seconds = 5,
		cooldown = 0,
		singleLimit = 0,
		globalLimit = 0,
		showIn = "buffs",
		TEST = true, SPELL_MISC = true, SPELL_AURA_APPLIEDDEBUFFGROUP = false, SPELL_AURA_APPLIEDBUFFENEMY = true, SPELL_SUMMON = false, SPELL_CREATE = false, SPELL_INTERRUPT = false,
	},
	
	-- Spell reflection
	[23920] = {
		text = "Spell Relfection",
		seconds = 5,
		cooldown = 10,
		singleLimit = 0,
		globalLimit = 0,
		showIn = "buffs",
		TEST = true, SPELL_MISC = true, SPELL_AURA_APPLIEDDEBUFFGROUP = false, SPELL_AURA_APPLIEDBUFFENEMY = true, SPELL_SUMMON = false, SPELL_CREATE = false, SPELL_INTERRUPT = false,
	},
	
	-- Hunter Silence
	[34490] = {
		text = "Silencing Shot",
		seconds = 20,
		cooldown = 0,
		singleLimit = 0,
		globalLimit = 0,
		dontFade = true,
		showIn = "spells",
		TEST = true, SPELL_MISC = true, SPELL_AURA_APPLIEDDEBUFFGROUP = false, SPELL_AURA_APPLIEDBUFFENEMY = false, SPELL_SUMMON = false, SPELL_CREATE = false, SPELL_INTERRUPT = true,
	},
	
	-- Priest Silence
	[15487] = {
		text = "Silence",
		seconds = 45,
		cooldown = 0,
		singleLimit = 0,
		globalLimit = 0,
		dontFade = true,
		showIn = "spells",
		TEST = true, SPELL_MISC = true, SPELL_AURA_APPLIEDDEBUFFGROUP = false, SPELL_AURA_APPLIEDBUFFENEMY = false, SPELL_SUMMON = false, SPELL_CREATE = false, SPELL_INTERRUPT = false,
	},

	-- Feral Charge
	[19675] = {
		text = "Feral Charge Effect",
		seconds = 15,
		cooldown = 0,
		singleLimit = 0,
		globalLimit = 0,
		dontFade = true,
		showIn = "spells",
		TEST = true, SPELL_MISC = true, SPELL_AURA_APPLIEDDEBUFFGROUP = true, SPELL_AURA_APPLIEDBUFFENEMY = false, SPELL_SUMMON = false, SPELL_CREATE = false, SPELL_INTERRUPT = true,
	},

	-- Spell lock
	[19244] = 19647,
	[19647] = {
		text = "Spell Lock",
		seconds = 24,
		cooldown = 0,
		singleLimit = 0,
		globalLimit = 0,
		dontFade = true,
		showIn = "spells",
		TEST = true, SPELL_MISC = true, SPELL_AURA_APPLIEDDEBUFFGROUP = true, SPELL_AURA_APPLIEDBUFFENEMY = false, SPELL_SUMMON = false, SPELL_CREATE = false, SPELL_INTERRUPT = true,
	},
	
	-- Counterspell
	[2139] = {
		text = "Counterspell",
		seconds = 24,
		cooldown = 0,
		singleLimit = 0,
		globalLimit = 0,
		dontFade = true,
		showIn = "spells",
		TEST = true, SPELL_MISC = true, SPELL_AURA_APPLIEDDEBUFFGROUP = false, SPELL_AURA_APPLIEDBUFFENEMY = false, SPELL_SUMMON = false, SPELL_CREATE = false, SPELL_INTERRUPT = true,
	},
	
	-- Counterspell - Silenced
	[18469] = {
		text = "Counterspell - Silenced",
		seconds = 24,
		cooldown = 0,
		singleLimit = 0,
		globalLimit = 0,
		dontFade = true,
		showIn = "spells",
		linkedTo = 2139,
		TEST = true, SPELL_MISC = true, SPELL_AURA_APPLIEDDEBUFFGROUP = false, SPELL_AURA_APPLIEDBUFFENEMY = false, SPELL_SUMMON = false, SPELL_CREATE = false, SPELL_INTERRUPT = false,
	},
	
	-- Kick
	[1766] = 38768,
	[1767] = 38768,
	[1768] = 38768,
	[1769] = 38768,
	[38768] = {
		text = "Kick",
		seconds = 10,
		cooldown = 0,
		singleLimit = 0,
		globalLimit = 0,
		showIn = "spells",
		TEST = true, SPELL_MISC = true, SPELL_AURA_APPLIEDDEBUFFGROUP = false, SPELL_AURA_APPLIEDBUFFENEMY = false, SPELL_SUMMON = false, SPELL_CREATE = false, SPELL_INTERRUPT = true,
	},

	-- Pummel
	[6552] = 6554,
	[6554] = {
		text = "Pummel",
		seconds = 10,
		cooldown = 0,
		singleLimit = 0,
		globalLimit = 0,
		showIn = "spells",
		TEST = true, SPELL_MISC = true, SPELL_AURA_APPLIEDDEBUFFGROUP = false, SPELL_AURA_APPLIEDBUFFENEMY = false, SPELL_SUMMON = false, SPELL_CREATE = false, SPELL_INTERRUPT = true,
	},
	
	-- Shield bash
	[72] = 29704,
	[1671] = 29704,
	[1672] = 29704,
	[29704] = {
		text = "Shield Bash",
		seconds = 12,
		cooldown = 0,
		singleLimit = 0,
		globalLimit = 0,
		showIn = "spells",
		TEST = true, SPELL_MISC = true, SPELL_AURA_APPLIEDDEBUFFGROUP = false, SPELL_AURA_APPLIEDBUFFENEMY = false, SPELL_SUMMON = false, SPELL_CREATE = false, SPELL_INTERRUPT = true,
	},
	
	-- Earth shock
	[8042] = 25454,
	[8044] = 25454,
	[8045] = 25454,
	[10412] = 25454,
	[10413] = 25454,
	[10414] = 25454,
	[25454] = {
		text = "Earth Shock",
		seconds = 5,
		cooldown = 0,
		singleLimit = 0,
		globalLimit = 0,
		dontFade = true,
		showIn = "spells",
		
		TEST = true, SPELL_MISC = true, SPELL_AURA_APPLIEDDEBUFFGROUP = false, SPELL_AURA_APPLIEDBUFFENEMY = false, SPELL_SUMMON = false, SPELL_CREATE = false, SPELL_INTERRUPT = true,
	},
	
	-- Flame shock
	[8050] = 29228,
	[8052] = 29228,
	[8053] = 29228,
	[10447] = 29228,
	[10448] = 29228,
	[10448] = 29228,
	[25457] = 29228,
	[29228] = {
		text = "Flame Shock",
		seconds = 5,
		cooldown = 5,
		singleLimit = 0,
		globalLimit = 0,
		dontFade = true,
		showIn = "spells",
		
		TEST = true, SPELL_MISC = true, SPELL_AURA_APPLIEDDEBUFFGROUP = false, SPELL_AURA_APPLIEDBUFFENEMY = false, SPELL_SUMMON = false, SPELL_CREATE = false, SPELL_INTERRUPT = false,
	},

	-- Frost shock
	[8056] = 25464,
	[8058] = 25464,
	[10472] = 25464,
	[10473] = 25464,
	[25464] = {
		text = "Frost Shock",
		seconds = 5,
		cooldown = 0,
		singleLimit = 0,
		globalLimit = 0,
		dontFade = true,
		showIn = "spells",
		
		TEST = true, SPELL_MISC = true, SPELL_AURA_APPLIEDDEBUFFGROUP = false, SPELL_AURA_APPLIEDBUFFENEMY = false, SPELL_SUMMON = false, SPELL_CREATE = false, SPELL_INTERRUPT = false,
	},
}
