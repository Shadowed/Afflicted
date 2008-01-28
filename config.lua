local Config = Afflicted:NewModule("Config")
local L = AfflictedLocals

local OptionHouse
local HouseAuthority
local OHObj

function Config:OnInitialize()
	-- Open the OH UI
	SLASH_AFFLICTED1 = "/afflicted"
	SLASH_AFFLICTED2 = "/afflict"
	SlashCmdList["AFFLICTED"] = function(msg)
		if( msg == "test" ) then
			Config:TestTimers()
		elseif( msg == "clear" ) then
			for key in pairs(Afflicted.anchors) do
				if( Afflicted[key] ) then
					Afflicted:ClearTimers(Afflicted[key])
				end
			end
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
	
	OHObj = OptionHouse:RegisterAddOn("Afflicted", nil, "Mayen", "r" .. max(tonumber(string.match("$Revision$", "(%d+)") or 1), Afflicted.revision))
	OHObj:RegisterCategory(L["General"], self, "CreateUI", nil, 1)
	OHObj:RegisterCategory(L["Spell List"], self, "CreateSpellList", true, 2)
	
	for name, data in pairs(Afflicted.spellList) do
		if( type(data) == "table" ) then
			OHObj:RegisterSubCategory(L["Spell List"], name, self, "ModifySpell", nil, name)
		end

	end
end


function Config:TestTimers()
	-- Clear out any running timers first
	for key in pairs(Afflicted.anchors) do
		if( Afflicted[key] ) then
			Afflicted:ClearTimers(Afflicted[key])
		end
	end
	
	local playerName = UnitName("player")
	local addedTypes = {buff = 0, spell = 0}

	for spell, data in pairs(AfflictedSpells) do
		local type = Afflicted.anchors[data.type]
		if( addedTypes[type] < 5 ) then
			addedTypes[type] = addedTypes[type] + 1
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
		for key in pairs(Afflicted.anchors) do
			if( Afflicted[key] and #(Afflicted[key].active) == 0 ) then
				Afflicted[key]:Hide()
			end
		end
	end)
	
	return frame
end

-- Spell list
local cachedFrame, spellName
function Config:SetSpellName(var, value)
	spellName = value
end

function Config:OpenSpellModifier(var)
	if( cachedFrame ) then
		cachedFrame:Hide()
	end
	
	OptionHouse:Open("Afflicted", L["Spell List"], var)
end

function Config:AddSpellModifier()
	-- Make sure it's a valid input
	if( not spellName or string.len(spellName) == 0 ) then
		Afflicted:Print(L["You must enter a spell name."])
		return
	else
		for name, data in pairs(Afflicted.spellList) do
			if( type(data) == "table" and string.lower(name) == string.lower(spellName) ) then
				Afflicted:Print(string.format(L["The spell \"%s\" already exists, you cannot have multiple spells with the same name."], spellName))
				return
			end
		end
	end

	-- Reset cache
	cachedFrame:Hide()
	cachedFrame = nil

	-- Copy the defaults into our base info
	Afflicted.db.profile.spells[spellName] = {id = GetTime()}
	for k, v in pairs(Afflicted.defaults.profile.spellDefault) do
		Afflicted.db.profile.spells[spellName][k] = v
	end
	
	Afflicted:UpdateSpellList()
	

	-- Register with OH and pop open the default
	OHObj:RegisterSubCategory(L["Spell List"], spellName, self, "ModifySpell", nil, spellName)
	OptionHouse:Open("Afflicted", L["Spell List"], spellName)
end

function Config:DeleteSpellModifier(var)
	Afflicted.db.profile.spells[var] = false
	Afflicted:UpdateSpellList()

	cachedFrame:Hide()
	cachedFrame = nil
	
	OHObj:RemoveSubCategory(L["Spell List"], var, true)
	self:CreateSpellList()
end

function Config:GetSpellName()
	return ""
end

function Config:CreateSpellList()
	-- This lets us implement at least a basic level of caching
	if( cachedFrame ) then
		return cachedFrame
	end
	
	local config = {}
	local order = 0
	
	-- Add a new spell
	table.insert(config, { group = L["New"], type = "groupOrder", order = order})
	table.insert(config, { group = L["New"], text = L["Spell Name"], help = L["This is the exact debuff, or spell name. If it's a debuff then it's the exact debuff name, if it's a spell it needs to be the exact spell that shows up in combat log."], type = "input", set = "SetSpellName", get = "GetSpellName", realTime = true, var = ""})
	table.insert(config, { group = L["New"], type = "button", xPos = 120, text = L["Add New"], set = "AddSpellModifier"})
	
	-- List current ones
	for name, data in pairs(Afflicted.spellList) do
		if( type(data) == "table" ) then
			order = order + 1

			local spellType
			if( data.type == "buff" ) then
				spellType = string.format(L["Type: %s%s%s"], "|cffffffff", L["Buff"], FONT_COLOR_CODE_CLOSE)
			elseif( data.type == "debuff" ) then
				spellType = string.format(L["Type: %s%s%s"], "|cffffffff", L["Debuff"], FONT_COLOR_CODE_CLOSE)
			else
				spellType = string.format(L["Type: %s%s%s"], "|cffffffff", L["Spell"], FONT_COLOR_CODE_CLOSE)
			end

			local cooldown
			if( data.seconds ) then
				cooldown = string.format(L["Cooldown: %s%d%s"], "|cffffffff", data.seconds, FONT_COLOR_CODE_CLOSE)
			else
				cooldown = string.format(L["Cooldown: %s%d%s"], RED_FONT_COLOR_CODE, 0, FONT_COLOR_CODE_CLOSE)
			end
			
			local status
			if( not data.disabled ) then
				status = name
			else
				status = RED_FONT_COLOR_CODE .. name .. FONT_COLOR_CODE_CLOSE
			end

			table.insert(config, { group = name, type = "groupOrder", order = order})
			table.insert(config, { group = name, type = "button", texture = data.icon, height = 19, width = 19, template = ""})
			table.insert(config, { group = name, type = "label", text = status, xPos = -60, font = GameFontHighlightSmall})
			table.insert(config, { group = name, type = "label", text = cooldown, xPos = 60, font = GameFontNormalSmall})
			table.insert(config, { group = name, type = "label", text = spellType, xPos = 120, font = GameFontNormalSmall})
			table.insert(config, { group = name, type = "button", text = L["Edit"], xPos = 160, onSet = "OpenSpellModifier", var = name})
			table.insert(config, { group = name, type = "button", text = L["Delete"], xPos = 190, onSet = "DeleteSpellModifier", var = name})
		end
	end

	-- Update the dropdown incase any new textures were added
	cachedFrame = HouseAuthority:CreateConfiguration(config, {handler = self, columns = 6})
	return cachedFrame
end

-- Spell modifier
function Config:SetSpell(var, value)
	-- We're setting a spell and we have it in our merged list, but not in our SV
	-- this lets us modify the default list of spells
	if( not Afflicted.db.profile.spells[var[1]] and Afflicted.spellList[var[1]] ) then
		Afflicted.db.profile.spells[var[1]] = {}
		for k, v in pairs(Afflicted.spellList[var[1]]) do
			Afflicted.db.profile.spells[var[1]][k] = v
		end
	end
	
	cachedFrame = nil
	
	Afflicted.db.profile.spells[var[1]][var[2]] = value
	Afflicted:UpdateSpellList()
end

function Config:GetSpell(var)
	return Afflicted.spellList[var[1]][var[2]]
end

function Config:Validate(var, val)
	return tonumber(val)
end

function Config:TestSpell(var)
	Afflicted:ProcessAbility(var, UnitName("player"), true)
end

function Config:ModifySpell(category, spell)
	if( not spell or spell == "" ) then
		return
	end
	
	if( cachedFrame ) then
		cachedFrame:Hide()
	end
	
	local config = {
		{ group = L["General"], type = "groupOrder", order = 1 },
		{ order = 1, group = L["General"], text = L["Disable spell"], help = L["When disabled, you won't see any timers fired from this."], type = "check", var = {spell, "disabled"}},
		{ order = 2, group = L["General"], text = L["Timer type"], help = L["\"Buff\" - Buffs like Ice Block or Divine Shield.\n\"Spells\" - Spells like Kick, Pummel, Earth Shock.\n\"Debuff\" - Debuffs like Priests Silence, or Feral Charge."], type = "dropdown", list = {{"buff", L["Buff"]}, {"debuff", L["Debuff"]}, {"spell", L["Spell"]}},  var = {spell, "type"}},
		{ order = 3, group = L["General"], text = L["Cooldown/duration"], help = L["Timer to show when this spell is triggered."], type = "input", numeric = true, width = 30, default = 0, var = {spell, "seconds"}},
		{ order = 4, group = L["General"], text = L["Trigger limit (seconds)"], help = L["Limits how many times this timer can be triggered in the entered amount of seconds, you may need to enter 0.50-1.0 seconds for things like Physic Scream that debuff multiple people at once."], type = "input", validate = "Validate", error = L["You may only enter a number or a float into this, \"%s\" is invalid."], width = 30, default = 0, var = {spell, "limit"}},
		{ order = 5, group = L["General"], text = L["Icon path"], help = L["Full icon path to the texture, for example \"Interface\\Icons\\<NAME>\"."], type = "input", width = 350, var = {spell, "icon"}},
		{ order = 6, group = L["General"], text = L["Test Timer"], type = "button", onSet = "TestSpell", var = spell},
	}

	return HouseAuthority:CreateConfiguration(config, {set = "SetSpell", get = "GetSpell", handler = self})
end