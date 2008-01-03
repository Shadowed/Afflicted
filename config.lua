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
		elseif( msg == "toggle" ) then
			if( not Afflicted.spell:IsVisible() ) then
				Afflicted.spell:Show()
			else
				Afflicted.spell:Hide()
			end
			
			if( not Afflicted.buff:IsVisible() ) then
				Afflicted.buff:Show()
			else
				Afflicted.buff:Hide()
			end
		elseif( msg == "ui" ) then
			OptionHouse:Open("Afflicted")
		else
			DEFAULT_CHAT_FRAME:AddMessage(L["Afflicted slash commands"])
			DEFAULT_CHAT_FRAME:AddMessage(L["- test - Show 5 buff and 5 silence/interrupt test timers."])
			DEFAULT_CHAT_FRAME:AddMessage(L["- toggle - Toggles the anchors shown/hidden."])
			DEFAULT_CHAT_FRAME:AddMessage(L["- ui - Opens the OptionHouse configuration for Afflicted."])
		end
	end
	
	-- Register with OptionHouse
	OptionHouse = LibStub("OptionHouse-1.1")
	HouseAuthority = LibStub("HousingAuthority-1.2")
	
	local OHObj = OptionHouse:RegisterAddOn("Afflicted", nil, "Mayen", "r" .. max(tonumber(string.match("$Revision$", "(%d+)") or 1), Afflicted.revision))
	OHObj:RegisterCategory(L["General"], self, "CreateUI", nil, 1)
end


function Config:TestTimers()
	-- Clear out any running timers first
	Afflicted:ClearTimers(Afflicted.spell)
	Afflicted:ClearTimers(Afflicted.buff)
	
	local playerName = UnitName("player")
	for spell, data in pairs(AfflictedSpells) do
		Afflicted:ProcessAbility(data.id .. playerName, spell, playerName, nil, true)
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
		{ order = 3, group = L["Alerts"], text = L["Chat frame"], help = L["Frame to show alerts in."], type = "dropdown", list = {{1, 1}, {2, 2}, {3, 3}, {4, 4}, {5, 5}, {6, 6}, {7, 7}, {8, 8}, {9, 9}}, var = "alertChat"},
		
		{ group = L["Timers"], type = "groupOrder", order = 3 },
		{ order = 1, group = L["Timers"], text = L["Show buff timers"], help = L["Show timers on buffs like Divine Shield, Ice Block, Blessing of Protection and so on, for how long until they fade."], type = "check", var = "buff"},
		{ order = 2, group = L["Timers"], text = L["Show silence and interrupt timers"], help = L["Show timers on silence and interrupt spells like Spell Lock or Silencing Shot, for how long until they're ready again."], type = "check", var = "spell"},
		{ order = 3, group = L["Timers"], text = L["Announce Timers"], help = L["Announces when the selected types of abilities are used, and are over."], type = "dropdown", list = {{"buff", L["Buffs"]}, {"spell", L["Interrupts & Silences"]}}, multi = true, var = "announce"},
		{ order = 4, group = L["Timers"], text = L["Chat frame"], help = L["Frame to show alerts in."], type = "dropdown", list = {{1, 1}, {2, 2}, {3, 3}, {4, 4}, {5, 5}, {6, 6}, {7, 7}, {8, 8}, {9, 9}}, var = "timerChat"},
		{ order = 5, group = L["Timers"], text = L["Test Timers"], type = "button", onSet = "TestTimers"},

		{ group = L["Frame"], type = "groupOrder", order = 4 },
		{ order = 1, group = L["Frame"], text = L["Show timers anchor"], help = L["ALT + Drag the anchors to move the frames."], type = "check", var = "locked"},
		{ order = 2, group = L["Frame"], text = L["Grow Up"], help = L["Timers that should grow up instead of down."], type = "dropdown", list = {{"buff", L["Buffs"]}, {"spell", L["Interrupts & Silences"]}}, multi = true, var = "growup"},
		{ order = 3, group = L["Frame"], format = L["Scale: %d%%"], min = 0.0, max = 2.0, type = "slider", var = "scale"},
	}

	-- Update the dropdown incase any new textures were added
	return HouseAuthority:CreateConfiguration(config, {set = "Set", get = "Get", onSet = "Reload", handler = self})
end