local L = AfflictedLocals
AfflictedSpells = { 
	-- Tremendous Fortitude
	[44055] = {
		text = "Tremendous Fortitude",
		seconds = 15,
		singleLimit = 0,
		globalLimit = 0,
		showIn = "buffs",
		SPELL_CAST_SUCCESS = true,
	},

	-- Cheat Death
	[45182] = {
		disabled = true,
		text = "Cheating Death",
		seconds = 3,
		cdEnabled = false,
		cdInside = "cooldowns",
		cooldown = 60,
		singleLimit = 0,
		globalLimit = 0,
		showIn = "buffs",
		SPELL_AURA_APPLIEDBUFFENEMY = true,
	},
	
	-- Blade Flurry
	[13877] = {
		disabled = true,
		text = "Blade Flurry",
		seconds = 15,
		cooldown = 0,
		singleLimit = 0,
		globalLimit = 0,
		showIn = "buffs",
		SPELL_CAST_SUCCESS = true,
	},

	-- Adrenaline Rush
	[13750] = {
		disabled = true,
		text = "Adrenaline Rush",
		seconds = 15,
		cooldown = 0,
		singleLimit = 0,
		globalLimit = 0,
		showIn = "buffs",
		SPELL_CAST_SUCCESS = true,
	},

	-- Devour Magic
	[19505] = 27277,
	[19731] = 27277,
	[19734] = 27277,
	[19736] = 27277,
	[27276] = 27277,
	[27277] = {
		disabled = true,
		dontFade = true,
		text = "Devour Magic",
		seconds = 8,
		cooldown = 0,
		singleLimit = 0,
		globalLimit = 0,
		showIn = "cooldowns",
		SPELL_CAST_SUCCESS = true,
	},

	-- Heroism
	[32182] = {
		disabled = true,
		dontFade = true,
		text = "Heroism",
		seconds = 40,
		cooldown = 0,
		singleLimit = 0,
		globalLimit = 0,
		showIn = "buffs",
		SPELL_CAST_SUCCESS = true,
	},

	-- Bloodlust
	[2825] = {
		disabled = true,
		dontFade = true,
		text = "Bloodlust",
		seconds = 40,
		cooldown = 0,
		singleLimit = 0,
		globalLimit = 0,
		showIn = "buffs",
		SPELL_CAST_SUCCESS = true,
	},

	-- Perception
	[20600] = {
		disabled = true,
		text = "Perception",
		seconds = 20,
		cooldown = 0,
		singleLimit = 0,
		globalLimit = 0,
		showIn = "spells",
		SPELL_CAST_SUCCESS = true,
	},

	-- Water Elemental
	[31687] = {
		text = "Summon Water Elemental",
		seconds = 45,
		cooldown = 0,
		singleLimit = 2,
		globalLimit = 0,
		showIn = "cooldowns",
		SPELL_SUMMON = true,
	},

	-- Scare Beast
	[1513] = 14327,
	[14326] = 14327,
	[14327] = {
		disabled = true,
		text = "Scare Beast",
		seconds = 30,
		cooldown = 0,
		singleLimit = 2,
		globalLimit = 0,
		showIn = "spells",
		SPELL_CAST_SUCCESS = true,
	},

	-- Scatter Shot
	[19503] = {
		text = "Scatter Shot",
		seconds = 30,
		cooldown = 0,
		singleLimit = 0,
		globalLimit = 0,
		showIn = "spells",
		SPELL_CAST_SUCCESS = true,
	},

	-- Bestial Wrath
	[19574] = {
		text = "Bestial Wrath",
		seconds = 18,
		cooldown = 0,
		singleLimit = 0,
		globalLimit = 0,
		showIn = "buffs",
		SPELL_CAST_SUCCESS = true,
	},

	-- Freeze (Water Elemental)
	[33395] = {
		disabled = true,
		text = "Freeze",
		seconds = 25,
		cooldown = 0,
		singleLimit = 0,
		globalLimit = 0,
		showIn = "spells",
		SPELL_CAST_SUCCESS = true,
	},

	-- Blink
	[1953] = {
		text = "Blink",
		seconds = 15,
		cooldown = 0,
		singleLimit = 2,
		globalLimit = 0,
		showIn = "spells",
		SPELL_CAST_SUCCESS = true,
	},

	-- Frost Nova
	[122] = 27088,
	[865] = 27088,
	[6131] = 27088,
	[10230] = 27088,
	[27088] = {
		disabled = true,
		text = "Frost Nova",
		seconds = 21,
		cooldown = 0,
		singleLimit = 0,
		globalLimit = 0,
		showIn = "spells",
		SPELL_CAST_SUCCESS = true,
	},
	
	-- Disarm
	[676] = {
		disabled = true,
		text = "Disarm",
		seconds = 10,
		cooldown = 60,
		cdEnabled = true,
		cdInside = "cooldowns",
		singleLimit = 0,
		globalLimit = 0,
		showIn = "spells",
		SPELL_CAST_SUCCESS = true,
	},


	-- Intervene
	[3411] = {
		disabled = true,
		text = "Intervene",
		seconds = 30,
		cooldown = 0,
		singleLimit = 0,
		globalLimit = 0,
		showIn = "spells",
		SPELL_CAST_SUCCESS = true,
	},

	-- Intimidating Shout
	[5246] = {
		disabled = true,
		text = "Intimidating Shout",
		seconds = 180,
		cooldown = 0,
		singleLimit = 0,
		globalLimit = 0,
		showIn = "spells",
		SPELL_CAST_SUCCESS = true,
	},

	-- Fear Ward
	[6346] = {
		disabled = true,
		text = "Fear Ward",
		seconds = 180,
		cooldown = 0,
		singleLimit = 2,
		globalLimit = 0,
		showIn = "spells",
		SPELL_CAST_SUCCESS = true,
	},
	
	-- Repentance
	[20066] = {
		disabled = true,
		text = "Repentance",
		seconds = 60,
		cooldown = 0,
		singleLimit = 2,
		globalLimit = 0,
		showIn = "spells",
		SPELL_CAST_SUCCESS = true,
	},

	-- Hammer of Justice
	[853] = 10308,
	[5588] = 10308,
	[5589] = 10308,
	[10308] = {
		disabled = true,
		text = "Hammer of Justice",
		seconds = 45,
		cooldown = 0,
		singleLimit = 2,
		globalLimit = 0,
		showIn = "spells",
		SPELL_CAST_SUCCESS = true,
	},

	-- Divine Shield
	[642] = 1020,
	[1020] = {
		text = "Divine Shield",
		seconds = 12,
		cooldown = 0,
		singleLimit = 0,
		globalLimit = 0,
		showIn = "buffs",
		SPELL_CAST_SUCCESS = true,
	},
	
	-- Kidney Shot
	[408] = 8643,
	[8643] = {
		disabled = true,
		text = "Kidney Shot",
		disabled = true,
		seconds = 20,
		cooldown = 0,
		singleLimit = 0,
		globalLimit = 0,
		showIn = "spells",
		SPELL_CAST_SUCCESS = true,
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
		globalLimit = 0,
		showIn = "spells",
		SPELL_CAST_SUCCESS = true,
	},
	
	-- Power Infusion
	[10060] = {
		text = "Power Infusion",
		seconds = 15,
		cooldown = 0,
		singleLimit = 0,
		globalLimit = 0,
		showIn = "buffs",
		SPELL_CAST_SUCCESS = true,
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
		SPELL_CAST_SUCCESS = true,
	},

	-- Icy Veins
	[12472] = {
		text = "Icy Veins",
		seconds = 20,
		cooldown = 0,
		singleLimit = 0,
		globalLimit = 0,
		showIn = "spells",
		SPELL_CAST_SUCCESS = true,
	},
	
	-- Berserker Rage
	[18499] = {
		disabled = true,
		text = "Berserker Rage",
		disabled = true,
		seconds = 10,
		cooldown = 30,
		cdEnabled = true,
		cdInside = "cooldowns",
		singleLimit = 0,
		globalLimit = 0,
		showIn = "spells",
		SPELL_CAST_SUCCESS = true,
	},
	
	-- Viper sting
	[3034] = 27018,
	[14279] = 27018,
	[14280] = 27018,
	[27018] = {
		text = "Viper Sting",
		seconds = 15,
		cooldown = 0,
		singleLimit = 2,
		globalLimit = 0,
		showIn = "spells",
		SPELL_CAST_SUCCESS = true,
	},
	
	
	-- Ice Block
	[45438] = {
		text = "Ice Block",
		seconds = 10,
		cooldown = 0,
		singleLimit = 0,
		globalLimit = 0,
		showIn = "buffs",
		SPELL_CAST_SUCCESS = true,
	},
	
	-- Hypothermia
	[41425] = {
		text = "Hypothermia",
		seconds = 30,
		cooldown = 0,
		singleLimit = 0,
		globalLimit = 0,
		showIn = "buffs",
		SPELL_AURA_APPLIEDDEBUFFENEMY = true,
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
		SPELL_CAST_SUCCESS = true,
	},
	
	-- Blessing of Freedom
	[1044] = {
		text = "Blessing of Freedom",
		seconds = 14,
		cooldown = 25,
		cdEnabled = true,
		cdInside = "cooldowns",
		singleLimit = 0,
		globalLimit = 0,
		showIn = "buffs",
		SPELL_CAST_SUCCESS = true,
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
		SPELL_CAST_SUCCESS = true,
	},

	-- Pain Suppression
	[33206] = {
		text = "Pain Suppression",
		seconds = 8,
		cdEnabled = true,
		cdInside = "cooldowns",
		cooldown = 120,
		singleLimit = 0,
		globalLimit = 0,
		showIn = "buffs",
		SPELL_CAST_SUCCESS = true,
	},
	
	-- Cloak of Shadows
	[31224] = {
		text = "Cloak of Shadows",
		seconds = 5,
		cooldown = 0,
		singleLimit = 0,
		globalLimit = 0,
		showIn = "buffs",
		SPELL_CAST_SUCCESS = true,
	},
	
	-- Spell reflection
	[23920] = {
		text = "Spell Reflection",
		seconds = 5,
		cooldown = 10,
		singleLimit = 0,
		globalLimit = 0,
		showIn = "buffs",
		SPELL_CAST_SUCCESS = true,
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
		SPELL_CAST_SUCCESS = true,
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
		SPELL_CAST_SUCCESS = true,
	},

	-- Feral Charge
	[16979] = {
		text = "Feral Charge",
		seconds = 15,
		cooldown = 0,
		singleLimit = 0,
		globalLimit = 0,
		dontFade = true,
		showIn = "spells",
		SPELL_CAST_SUCCESS = true,
	},

	-- Shadowstep
	[36554] = {
		text = "Shadowstep",
		seconds = 3,
		cdEnabled = true,
		cdInside = "cooldowns",
		cooldown = 15,
		singleLimit = 2,
		globalLimit = 0,
		showIn = "spells",
		SPELL_CAST_SUCCESS = true,
	},
	
	-- Intercept
	[20252] = 25275,
	[20616] = 25275,
	[20617] = 25275,
	[25272] = 25275,
	[25275] = {
		text = "Intercept",
		seconds = 15,
		cooldown = 0,
		singleLimit = 0,
		globalLimit = 0,
		dontFade = true,
		showIn = "spells",
		SPELL_CAST_SUCCESS = true,
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
		SPELL_CAST_SUCCESS = true,
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
		SPELL_CAST_SUCCESS = true,
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
		SPELL_CAST_SUCCESS = true,
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
		SPELL_CAST_SUCCESS = true,
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
		SPELL_CAST_SUCCESS = true,
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
		SPELL_CAST_SUCCESS = true,
	},

	-- Grounding Totem
	[8177] = {
		disabled = true,
		text = "Grounding Totem",
		seconds = 45,
		cooldown = 15,
		singleLimit = 0,
		globalLimit = 0,
		showIn = "cooldowns",
		SPELL_SUMMON = true,
	},

	-- Tremor Totem
	[8143] = {
		disabled = true,
		repeating = true,
		text = "Tremor Totem",
		seconds = 3,
		singleLimit = 0,
		globalLimit = 0,
		showIn = "cooldowns",
		SPELL_SUMMON = true,
	},
	
	-- Fire Nova Totem
	[1535] = 25547,
	[8498] = 25547,
	[8499] = 25547,
	[11314] = 25547,
	[11315] = 25547,
	[25546] = 25547,
	[25547] = {
		disabled = true,
		text = "Fire Nova Totem",
		seconds = 5,
		singleLimit = 0,
		globalLimit = 0,
		showIn = "cooldowns",
		SPELL_SUMMON = true,
	},
	
	-- Magma Totem
	[8190] = 25552,
	[10585] = 25552,
	[10586] = 25552,
	[10587] = 25552, 
	[25552] = {
		disabled = true,
		repeating = true,
		text = "Magma Totem",
		seconds = 2,
		singleLimit = 0,
		globalLimit = 0,
		showIn = "cooldowns",
		SPELL_SUMMON = true,
	},
	
	-- Searing Totem
	[3599] = 25533,
	[6363] = 25533,
	[6364] = 25533,
	[6365] = 25533,
	[10437] = 25533,
	[10438] = 25533,
	[25533] = {
		disabled = true,
		repeating = true,
		text = "Searing Totem",
		seconds = 2,
		singleLimit = 0,
		globalLimit = 0,
		showIn = "cooldowns",
		SPELL_SUMMON = true,
	},
	
	
	-- Flame shock
	[8050] = 25454,
	[8052] = 25454,
	[8053] = 25454,
	[10447] = 25454,
	[10448] = 25454,
	[10448] = 25454,
	[25457] = 25454,
	[29228] = 25454,
	
	-- Frost shock
	[8056] = 25454,
	[8058] = 25454,
	[10472] = 25454,
	[10473] = 25454,
	[25464] = 25454,
	
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
		icon = "Interface\\Icons\\Spell_Nature_EarthShock",
		SPELL_CAST_SUCCESS = true,
	},

	-- Explosive Trap
	[13813] = 34600,
	[14316] = 34600,
	[14317] = 34600,
	[27025] = 34600,
	

	-- Freezing Trap
	[1499] = 34600,
	[14310] = 34600,
	[14311] = 34600,
	

	-- Frost Trap
	[13809] = 34600,
	

	-- Immolation Trap
	[13795] = 34600,
	[14302] = 34600,
	[14303] = 34600,
	[14304] = 34600,
	[14305] = 34600,
	[27023] = 34600,
	
	-- Snake Trap
	[34600] = {
		disabled = true,
		text = "Traps",
		seconds = 60,
		cdEnabled = true,
		cdInside = "cooldowns",
		cooldown = 30,
		singleLimit = 0,
		globalLimit = 0,
		dontFade = true,
		showIn = "spells",
		icon = "Interface\\Icons\\Spell_Frost_ChainsOfIce",
		SPELL_CREATE = true,
	}
}