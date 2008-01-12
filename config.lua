local Config = Afflicted:NewModule("Config")
local L = AfflictedLocals

local OptionHouse
local HouseAuthority

function Config:OnInitialize()
	-- Open the OH UI
	SLASH_AFFLICTED1 = "/afflicted"
	SLASH_AFFLICTED2 = "/afflict"
	SlashCmdList["AFFLICTED"] = function(msg)
		if( msg == "test" ) then
			Config:TestTimers()
		elseif( msg == "clear" ) then
			Afflicted:ClearTimers(Afflicted.spell)
			Afflicted:ClearTimers(Afflicted.buff)
		elseif( msg == "ui" ) then
			OptionHouse:Open("Afflicted")
		else
			DEFAULT_CHAT_FRAME:AddMessage(L["Afflicted slash commands"])
			DEFAULT_CHAT_FRAME:AddMessage(L["- test - Show 5 buff and 5 silence/interrupt test timers."])
			DEFAULT_CHAT_FRAME:AddMessage(L["- clear - Clears all running timers."])
			DEFAULT_CHAT_FRAME:AddMessage(L["- ui - Opens the OptionHouse configuration for Afflicted."])
		end
	end
	
	-- Register with OptionHouse
	OptionHouse = LibStub("OptionHouse-1.1")
	HouseAuthority = LibStub("HousingAuthority-1.2")
	
	local OHObj = OptionHouse:RegisterAddOn("Afflicted", nil, "Mayen", "r" .. max(tonumber(string.match("$Revision$", "(%d+)") or 1), Afflicted.revision))
	OHObj:RegisterCategory(L["General"], self, "CreateUI", nil, 1)
	OHObj:RegisterCategory(L["Spell List"], self, "CreateSpellList", true, 2)
end


function Config:TestTimers()
	-- Clear out any running timers first
	Afflicted:ClearTimers(Afflicted.spell)
	Afflicted:ClearTimers(Afflicted.buff)
	
	local playerName = UnitName("player")
	local addedTypes = {buff = 0, spell = 0}

	for spell, data in pairs(AfflictedSpells) do
		if( addedTypes[data.type] < 5 ) then
			addedTypes[data.type] = addedTypes[data.type] + 1
			Afflicted:ProcessAbility(spell, playerName, true)
		end
	end
end

-- GUI
function Config:Set(var, value)
	Afflicted.db.profile[var] = value
end

function Config:Get(var)
	return Afflicted.db.profile[var]
end

function Config:Reload()
	Afflicted:Reload()
end

function Config:CreateUI()
	local config = {
		{ group = L["General"], type = "groupOrder", order = 1 },
		{ order = 1, group = L["General"], text = L["Only enable inside arenas"], help = L["No timers, interrupt or removal alerts will be shown outside of arenas."], type = "check", var = "arenaOnly"},	
	
		{ group = L["Alerts"], type = "groupOrder", order = 2 },
		{ order = 1, group = L["Alerts"], text = L["Show interrupt alerts"], help = L["Shows player name, and the spell you interrupted to chat."], type = "check", var = "showInterrupt"},
		{ order = 2, group = L["Alerts"], text = L["Show spell removal alerts"], help = L["Shows spells that you remove from enemies to chat, or failed attempts at removing something."], type = "check", var = "showPurge"},
		
		{ group = L["Alert Chat"], type = "groupOrder", order = 3 },
		{ order = 1, group = L["Alert Chat"], text = L["Output"], help = L["Frame to show alerts in."], type = "dropdown", list = {{"ct", L["Combat Text"]}, {"rw", L["Raid Warning"]}, {"rwframe", L["Middle of screen"]}, {"party", L["Party"]}, {1, string.format(L["Chat frame #%d"], 1)}, {2, string.format(L["Chat frame #%d"], 2)}, {3, string.format(L["Chat frame #%d"], 3)}, {4, string.format(L["Chat frame #%d"], 4)}, {5, string.format(L["Chat frame #%d"], 5)}, {6, string.format(L["Chat frame #%d"], 6)}, {7, string.format(L["Chat frame #%d"], 7)}}, var = "alertOutput"},
		{ order = 2, group = L["Alert Chat"], text = L["Output color"], help = L["Color the text should be shown in if you're outputting using \"Middle of screen\" or \"Combat text\"."], type = "color", var = "alertColor"},

		{ group = L["Timers"], type = "groupOrder", order = 4 },
		{ order = 1, group = L["Timers"], text = L["Show buff timers"], help = L["Show timers on buffs like Divine Shield, Ice Block, Blessing of Protection and so on, for how long until they fade."], type = "check", var = "buff"},
		{ order = 2, group = L["Timers"], text = L["Show silence and interrupt timers"], help = L["Show timers on silence and interrupt spells like Spell Lock or Silencing Shot, for how long until they're ready again."], type = "check", var = "spell"},
		{ order = 3, group = L["Timers"], text = L["Announce Timers"], help = L["Announces when the selected types of abilities are used, and are over."], type = "dropdown", list = {{"buff", L["Buffs"]}, {"spell", L["Interrupts & Silences"]}}, multi = true, var = "announce"},
		{ order = 6, group = L["Timers"], text = L["Test Timers"], type = "button", onSet = "TestTimers"},
				
		{ group = L["Timer Chat"], type = "groupOrder", order = 5 },
		{ order = 1, group = L["Timer Chat"], text = L["Output"], help = L["Frame to show alerts in."], type = "dropdown", list = {{"ct", L["Combat Text"]}, {"rw", L["Raid Warning"]}, {"rwframe", L["Middle of screen"]}, {"party", L["Party"]}, {1, string.format(L["Chat frame #%d"], 1)}, {2, string.format(L["Chat frame #%d"], 2)}, {3, string.format(L["Chat frame #%d"], 3)}, {4, string.format(L["Chat frame #%d"], 4)}, {5, string.format(L["Chat frame #%d"], 5)}, {6, string.format(L["Chat frame #%d"], 6)}, {7, string.format(L["Chat frame #%d"], 7)}}, var = "timerOutput"},
		{ order = 5, group = L["Timer Chat"], text = L["Output color"], help = L["Color the text should be shown in if you're outputting using \"Middle of screen\" or \"Combat text\"."], type = "color", var = "timerColor"},
		
		{ group = L["Frame"], type = "groupOrder", order = 6 },
		{ order = 1, group = L["Frame"], text = L["Show timers anchor"], help = L["ALT + Drag the anchors to move the frames."], type = "check", var = "anchor"},
		{ order = 2, group = L["Frame"], text = L["Grow Up"], help = L["Timers that should grow up instead of down."], type = "dropdown", list = {{"buff", L["Buffs"]}, {"spell", L["Interrupts & Silences"]}}, multi = true, var = "growup"},
		{ order = 3, group = L["Frame"], format = L["Scale: %d%%"], min = 0.0, max = 2.0, type = "slider", var = "scale"},
	}

	local frame = HouseAuthority:CreateConfiguration(config, {set = "Set", get = "Get", onSet = "Reload", handler = self})	
	frame:SetScript("OnHide", function()
		if( #(Afflicted.buff.active) == 0 ) then
			Afflicted.buff:Hide()
		end
		
		if( #(Afflicted.spell.active) == 0 ) then
			Afflicted.spell:Hide()
		end
	end)
	
	return frame
end

-- Spell list
local cachedFrame
function Config:OpenSpellModifier(var)
	OptionHouse:Open("Afflicted", L["Spell List"], var)
end

function Config:AddSpellModifier()
	for k, v in pairs(Afflicted.defaults.spellDefault) do
		Afflicted.db.profile.spells[L["New"]][k] = v
	end
	
	OptionHouse:RegisterSubCategory(L["Spell List"], L["New"], self, "ModifySpell", nil, nil, true)
end

function Config:DeleteSpellModifier(var)
	Afflicted.db.profile.spells[var] = false
	Afflicted:UpdateSpellList()
end
function Config:CreateSpellList()
	-- This lets us implement at least a basic level of caching
	if( cachedFrame ) then
		return cachedFrame
	end
	
	local config = {}
	local order = 0
	
	-- Add a new spell
	--table.insert(config, { group = L["New"], type = "groupOrder", order = order})
	--table.insert(config, { group = L["New"], type = "button", text = L["Add New"], onSet = "AddSpellModifier"})
	
	-- List current ones
	for name, data in pairs(Afflicted.spellList) do
		order = order + 1
		
		local spellType
		if( data.type == "buff" ) then
			spellType = string.format(L["Type: %s%s%s"], GREEN_FONT_COLOR_CODE, L["Buff"], FONT_COLOR_CODE_CLOSE)
		else
			spellType = string.format(L["Type: %s%s%s"], GREEN_FONT_COLOR_CODE, L["Spell"], FONT_COLOR_CODE_CLOSE)
		end
		
		local cooldown
		if( data.seconds ) then
			cooldown = string.format(L["Cooldown: %s%d%s"], GREEN_FONT_COLOR_CODE, data.seconds, FONT_COLOR_CODE_CLOSE)
		else
			cooldown = string.format(L["Cooldown: %s%d%s"], RED_FONT_COLOR_CODE, 0, FONT_COLOR_CODE_CLOSE)
		end
		
		table.insert(config, { group = name, type = "groupOrder", order = order})
		table.insert(config, { group = name, type = "button", texture = data.icon, height = 19, width = 19, template = ""})
		table.insert(config, { group = name, type = "label", text = name, xPos = -60, font = GameFontHighlightSmall})
		table.insert(config, { group = name, type = "label", text = cooldown, xPos = 60, font = GameFontHighlightSmall})
		table.insert(config, { group = name, type = "label", text = spellType, xPos = 120, font = GameFontHighlightSmall})
		--table.insert(config, { group = name, type = "button", text = L["Edit"], xPos = 160, onSet = "OpenSpellModifier", var = name})
		--table.insert(config, { group = name, type = "button", text = L["Delete"], xPos = 190, onSet = "DeleteSpellModifier", var = name})
	end

	-- Update the dropdown incase any new textures were added
	cachedFrame = HouseAuthority:CreateConfiguration(config, {handler = self, columns = 6})
	return cachedFrame
end

--[[
-- Spell modifier
function Config:SetSpell(var, value)
	cachedFrame = nil
	Afflicted.db.profile.spells[var[1] ][var[2] ] = value
end

function Config:OnSetSpell(var, value)
	Afflicted:UpdateSpellList()
end

function Config:SaveInfo(var)
	OptionHouse:RegisterSubCategory(L["Spell List"], var, self, "ModifySpell", nil, nil, true)
end

function Config:GetSpell(var)
	if( not Afflicted.db.profile.spells[var[1] ] ) then
		cachedFrame = nil
		
		for k, v in pairs(Afflicted.defaults.spellDefault) do
			Afflicted.db.profile.spells[var[1] ][k] = v
		end
	end
	
	return Afflicted.db.profile.spells[var[1] ][var[2] ]
end

function Config:DeleteSpell(var)
	OptionHouse:RemoveSubCategory(L["Spell List"], var[1], true)
end



--[ [
	[L["Counterspell - Silenced"] ] = {
		id = "impcounterspell",
		seconds = 24,
		icon = "Interface\\Icons\\Spell_Frost_IceShock",
		type = "spell",
		afflicted = true,
	},
] ]


function Config:ModifySpell(category, spell)
	local config = {
		{ group = L["General"], type = "groupOrder", order = 1 },
		{ order = 1, group = L["General"], text = L["Enable auto join"], type = "check", var = {"join", "enabled"}},
		{ order = 3, group = L["General"], text = L["Priority check mode"], type = "dropdown", list = {{"less", L["Less than"]}, {"lseql", L["Less than/equal"]}},  var = {"join", "priority"}},
		{ order = 1, group = L["Delay"], text = L["Battleground join delay"], type = "input", numeric = true, width = 30, var = {"join", "battleground"}},
		{ order = 2, group = L["Delay"], text = L["AFK battleground join delay"], type = "input", numeric = true, width = 30, var = {"join", "afkBattleground"}},

		{ group = L["Update"], type = "button", text = L["Edit"], xPos = 160, onSet = "OpenSpellModifier", var = spell})
		{ group = L["Update"], type = "button", text = L["Delete"], xPos = 190, onSet = "DeleteSpellModifier", var = spell})
	}

	return HouseAuthority:CreateConfiguration(config, {set = "SetSpell", get = "GetSpell", onSet = "OnSetSpell", handler = self})
end
]]