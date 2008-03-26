if( not Afflicted ) then return end

local Config = Afflicted:NewModule("Config")
local L = AfflictedLocals

local OptionHouse
local HouseAuthority
local OHObj
local SML

local currentAnchors = {}
local spellList = {{"", L["None"]}}

function Config:OnInitialize()
	-- Open the OH UI
	SLASH_AFFLICTED1 = "/afflicted"
	SLASH_AFFLICTED2 = "/afflict"
	SlashCmdList["AFFLICTED"] = function(msg)
		if( msg == "clear" ) then
			for key in pairs(Afflicted.db.profile.anchors) do
				Afflicted.visual:ClearTimers(key)
			end
		elseif( msg == "test" ) then
			-- Clear out any running timers first
			for key in pairs(Afflicted.db.profile.anchors) do
				Afflicted.visual:ClearTimers(key)
			end

			local addedTypes = {}
			for spell, data in pairs(AfflictedSpells) do
				if( not addedTypes[data.showIn] ) then
					addedTypes[data.showIn] = 0
				end

				if( addedTypes[data.showIn] < 5 and data.icon and data.icon ~= "" ) then
					addedTypes[data.showIn] = addedTypes[data.showIn] + 1
					Afflicted:ProcessAbility("TEST", 0, spell, 0, GetTime() .. spell, "", "", "")
				end
			end

		elseif( msg == "ui" ) then
			OptionHouse:Open("Afflicted")
		else
			DEFAULT_CHAT_FRAME:AddMessage(L["Afflicted slash commands"])
			DEFAULT_CHAT_FRAME:AddMessage(L["- clear - Clears all running timers."])
			DEFAULT_CHAT_FRAME:AddMessage(L["- test - Shows test timers in Afflicted."])
			DEFAULT_CHAT_FRAME:AddMessage(L["- ui - Opens the OptionHouse configuration for Afflicted."])
		end
	end
	
	-- Set up current anchors
	for k, v in pairs(Afflicted.db.profile.anchors) do
		table.insert(currentAnchors, {k, v.text})
	end
	
	-- Now the current spell list
	for k, v in pairs(Afflicted.spellList) do
		table.insert(spellList, {k, k})
	end
	
	-- Register with OptionHouse
	OptionHouse = LibStub("OptionHouse-1.1")
	HouseAuthority = LibStub("HousingAuthority-1.2")
	SML = Afflicted.SML
	
	OHObj = OptionHouse:RegisterAddOn("Afflicted", nil, "Mayen", "r" .. max(tonumber(string.match("$Revision$", "(%d+)") or 1), Afflicted.revision))
	OHObj:RegisterCategory(L["General"], self, "CreateUI", nil, 1)
	OHObj:RegisterCategory(L["Anchor List"], self, "CreateAnchorList", true, 2)
	OHObj:RegisterCategory(L["Spell List"], self, "CreateSpellList", true, 3)
	
	for name, data in pairs(Afflicted.db.profile.anchors) do
		if( type(data) == "table" ) then
			OHObj:RegisterSubCategory(L["Anchor List"], name, self, "ModifyAnchor", nil, name)
		end
	end

	for name, data in pairs(Afflicted.spellList) do
		if( type(data) == "table" ) then
			OHObj:RegisterSubCategory(L["Spell List"], name, self, "ModifySpell", nil, name)
		end
	end

	SML:Register(SML.MediaType.STATUSBAR, "BantoBar", "Interface\\Addons\\Afflicted\\images\\banto")
	SML:Register(SML.MediaType.STATUSBAR, "Smooth",   "Interface\\Addons\\Afflicted\\images\\smooth")
	SML:Register(SML.MediaType.STATUSBAR, "Perl",     "Interface\\Addons\\Afflicted\\images\\perl")
	SML:Register(SML.MediaType.STATUSBAR, "Glaze",    "Interface\\Addons\\Afflicted\\images\\glaze")
	SML:Register(SML.MediaType.STATUSBAR, "Charcoal", "Interface\\Addons\\Afflicted\\images\\Charcoal")
	SML:Register(SML.MediaType.STATUSBAR, "Otravi",   "Interface\\Addons\\Afflicted\\images\\otravi")
	SML:Register(SML.MediaType.STATUSBAR, "Striped",  "Interface\\Addons\\Afflicted\\images\\striped")
	SML:Register(SML.MediaType.STATUSBAR, "LiteStep", "Interface\\Addons\\Afflicted\\images\\LiteStep")
end

local function updateAnchorVisibility()
	for key in pairs(Afflicted.db.profile.anchors) do
		if( Afflicted[key] and #(Afflicted[key].active) == 0 ) then
			Afflicted[key]:Hide()
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
	local textures = {}
	for _, name in pairs(SML:List(SML.MediaType.STATUSBAR)) do
		table.insert(textures, {name, name})
	end

	local config = {
		{ group = L["General"], type = "groupOrder", order = 1 },
		{ order = 1, group = L["General"], text = L["Only enable inside"], help = L["Only enable Afflicted inside the specified areas."], type = "dropdown", list = {{"none", L["Everywhere else"]}, {"pvp", L["Battlegrounds"]}, {"arena", L["Arenas"]}, {"raid", L["Raid Instances"]}, {"party", L["Party Instances"]}}, multi = true, var = "inside"},
		{ order = 2, group = L["General"], text = L["Show icons in local alerts"], help = L["Shows the spell icon when the alert is sent to a local channel like middle of screen, or a chat frame."], type = "check", var = "showIcons"},
		{ order = 3, group = L["General"], text = L["Show timers anchor"], help = L["ALT + Drag the anchors to move the frames."], type = "check", var = "showAnchors"},

		{ group = L["Bars"], type = "groupOrder", order = 2 },
		{ order = 1, group = L["Bars"], text = L["Show timer as bars"], help = L["Shows timers as bars instead of just icons, requires a reloadui to take effect."], type = "check", var = "showBars"},
		{ order = 2, group = L["Bars"], format = L["Bar size"], min = 10, max = 300, maxText = "300", minText = "10", default = 180, type = "slider", var = "barWidth"},
		{ order = 3, group = L["Bars"], text = L["Bar texture"], help = L["Texture to be used for the timer bars."], type = "dropdown", list = textures, var = "barName"},

		{ group = L["Dispel Alerts"], type = "groupOrder", order = 3 },
		{ order = 1, group = L["Dispel Alerts"], text = L["Enable dispel alerts"], help = L["Enable alerts when you dispel a player while Afflicted is enabled."], type = "check", var = "dispelEnabled"},
		{ order = 1, group = L["Dispel Alerts"], text = L["Show hostile dispels"], help = L["Displays alerts when you dispel hostile players as well, instead of just friendly players."], type = "check", var = "dispelHostile"},
		{ order = 2, group = L["Dispel Alerts"], text = L["Announce channel"], help = L["Channel to send abilities announcements to."], type = "dropdown", list = {{"none", L["None"]}, {"ct", L["Combat Text"]}, {"rw", L["Raid Warning"]}, {"rwframe", L["Middle of screen"]}, {"party", L["Party"]}, {1, string.format(L["Chat frame #%d"], 1)}, {2, string.format(L["Chat frame #%d"], 2)}, {3, string.format(L["Chat frame #%d"], 3)}, {4, string.format(L["Chat frame #%d"], 4)}, {5, string.format(L["Chat frame #%d"], 5)}, {6, string.format(L["Chat frame #%d"], 6)}, {7, string.format(L["Chat frame #%d"], 7)}}, var = "dispelDest"},
		{ order = 3, group = L["Dispel Alerts"], text = L["Announce color"], help = L["Color the text should be shown in if you're outputting using \"Middle of screen\" or \"Combat text\"."], type = "color", var = "dispelColor"},

		{ group = L["Interrupt Alerts"], type = "groupOrder", order = 4 },
		{ order = 1, group = L["Interrupt Alerts"], text = L["Enable interrupt alerts"], help = L["Enable alerts when you interrupt an enemies player spell."], type = "check", var = "interruptEnabled"},
		{ order = 2, group = L["Interrupt Alerts"], text = L["Announce channel"], help = L["Channel to send abilities announcements to."], type = "dropdown", list = {{"none", L["None"]}, {"ct", L["Combat Text"]}, {"rw", L["Raid Warning"]}, {"rwframe", L["Middle of screen"]}, {"party", L["Party"]}, {1, string.format(L["Chat frame #%d"], 1)}, {2, string.format(L["Chat frame #%d"], 2)}, {3, string.format(L["Chat frame #%d"], 3)}, {4, string.format(L["Chat frame #%d"], 4)}, {5, string.format(L["Chat frame #%d"], 5)}, {6, string.format(L["Chat frame #%d"], 6)}, {7, string.format(L["Chat frame #%d"], 7)}}, var = "interruptDest"},
		{ order = 3, group = L["Interrupt Alerts"], text = L["Announce color"], help = L["Color the text should be shown in if you're outputting using \"Middle of screen\" or \"Combat text\"."], type = "color", var = "interruptColor"},
	}

	local frame = HouseAuthority:CreateConfiguration(config, {set = "Set", get = "Get", onSet = "Reload", handler = self})	
	frame:SetScript("OnHide", updateAnchorVisibility)
	return frame
end

-------------------------------
--------- ANCHOR LIST ---------
-------------------------------
-- This is HORRIBLY hackish, I'm not happy with it at all. But it's functional and it'll work until I get HousingAuthority-2.0 going

local cachedAnchorFrame, anchorName
function Config:SetAnchorName(var, value)
	anchorName = value
end

function Config:OpenAnchor(var)
	if( cachedAnchorFrame ) then
		cachedAnchorFrame:Hide()
	end
	
	OptionHouse:Open("Afflicted", L["Anchor List"], var)
end

function Config:AddAnchor()
	-- Make sure it's a valid input
	if( not anchorName or string.len(anchorName) == 0 ) then
		Afflicted:Print(L["You must enter an anchor name."])
		return

	else
		for name, data in pairs(Afflicted.db.profile.anchors) do
			if( string.lower(name) == string.lower(anchorName) ) then
				Afflicted:Print(string.format(L["The anchor \"%s\" already exists, you cannot have multiple anchors with the same id."], anchorName))
				return
			end
		end
	end
	
	table.insert(currentAnchors, {anchorName, anchorName})

	-- Reset cache
	cachedAnchorFrame:Hide()
	cachedAnchorFrame = nil

	-- Copy the defaults into our base info
	Afflicted.db.profile.anchors[anchorName] = {announceColor = { r = 1, g = 1, b = 1}, scale = 1.0, text = anchorName}
	
	-- Register with OH and pop open the default
	OHObj:RegisterSubCategory(L["Anchor List"], anchorName, self, "ModifyAnchor", nil, anchorName)
	OptionHouse:Open("Afflicted", L["Anchor List"], anchorName)
end

function Config:DeleteAnchor(var)
	Afflicted.db.profile.anchors[var] = nil
	
	for i=#(currentAnchors), 1, -1 do
		if( currentAnchors[i][1] == var ) then
			table.remove(currentAnchors, i)
		end
	end
	
	-- Default all anchors to another one if this is deleted
	local totalMoved = 0
	local movedName
	
	if( Afflicted.db.profile.anchors.Spell ) then
		movedName = "Spell"
	elseif( Afflicted.db.profile.anchors.Buff ) then
		movedName = "Buff"
	else
		for anchor in pairs(Afflicted.db.profile.anchors) do
			movedName = anchor
			break
		end
	end
	
	if( movedName ) then
		for name, data in pairs(Afflicted.db.profile.spells) do
			if( data.showIn == var ) then
				data.showIn = movedName
				totalMoved = totalMoved + 1
			end
		end

		if( totalMoved > 0 ) then
			Afflicted:Print(string.format(L["%d timers have been moved to the anchor %s."], totalMoved, movedName))
			Afflicted:UpdateSpellList()

		end
	end
	
	
	cachedAnchorFrame:Hide()
	cachedAnchorFrame = nil
	
	OHObj:RemoveSubCategory(L["Anchor List"], var, true)
	self:CreateAnchorList()
end

function Config:GetAnchorName()
	return ""
end

function Config:CreateAnchorList()
	-- This lets us implement at least a basic level of caching
	if( cachedAnchorFrame ) then
		return cachedAnchorFrame
	end
	
	local config = {}
	local order = 0
	
	-- Add a new spell
	table.insert(config, { group = L["New"], type = "groupOrder", order = order})
	table.insert(config, { group = L["New"], text = L["Anchor Name"], help = L["Name of the anchor, this must be unique."], type = "input", set = "SetAnchorName", get = "GetAnchorName", realTime = true, var = ""})
	table.insert(config, { group = L["New"], type = "button", xPos = 125, text = L["Add New"], set = "AddAnchor"})
	
	-- List current ones
	for name, data in pairs(Afflicted.db.profile.anchors) do
		order = order + 1

		local text
		if( data.enabled ) then
			text = string.format("%s%s%s", GREEN_FONT_COLOR_CODE, data.text, FONT_COLOR_CODE_CLOSE)
		else
			text = string.format("%s%s%s", RED_FONT_COLOR_CODE, data.text, FONT_COLOR_CODE_CLOSE)
		end

		local growUp
		if( data.growUp ) then
			growUp = string.format(L["Grow Up: %s%s%s"], "|cffffffff", L["Yes"], FONT_COLOR_CODE_CLOSE)
		else
			growUp = string.format(L["Grow Up: %s%s%s"], "|cffffffff", L["No"], FONT_COLOR_CODE_CLOSE)
		end

		local announce
		if( data.announce ) then
			local location = L["Unknown"]
			if( tonumber(data.announceDest) ) then
				location = string.format(L["Chat frame #%d"], tonumber(data.announceDest))
			elseif( data.announceDest == "rwframe" ) then
				location = L["Middle of screen"]
			elseif( data.announceDest == "rw" ) then
				location = L["Raid Warning"]
			elseif( data.announceDest == "party" ) then
				location = L["Party"]
			elseif( data.announceDest == "ct" ) then
				location = L["Combat Text"]
			end

			announce = string.format(L["Announce: %s%s%s"], "|cffffffff", location, FONT_COLOR_CODE_CLOSE)
		else
			announce = string.format(L["Announce: %s%s%s"], "|cffffffff", L["Disabled"], FONT_COLOR_CODE_CLOSE)
		end

		table.insert(config, { group = data.text, type = "groupOrder", order = order})
		table.insert(config, { group = data.text, type = "label", text = text, font = GameFontHighlightSmall})
		table.insert(config, { group = data.text, type = "label", text = growUp, font = GameFontNormalSmall})
		table.insert(config, { group = data.text, type = "label", text = announce, xPos = 50, font = GameFontNormalSmall})
		table.insert(config, { group = data.text, type = "button", text = L["Edit"], xPos = 200, onSet = "OpenAnchor", var = name})
		table.insert(config, { group = data.text, type = "button", text = L["Delete"], xPos = 200, onSet = "DeleteAnchor", var = name})
	end

	-- Update the dropdown incase any new textures were added
	cachedAnchorFrame = HouseAuthority:CreateConfiguration(config, {handler = self, columns = 5})
	cachedAnchorFrame:SetScript("OnHide", updateAnchorVisibility)
	return cachedAnchorFrame
end

-- Spell modifier
function Config:SetAnchor(var, value)
	cachedAnchorFrame = nil
	Afflicted.db.profile.anchors[var[1]][var[2]] = value
end

function Config:GetAnchor(var)
	return Afflicted.db.profile.anchors[var[1]][var[2]]
end

local displayAnchors = {}
function Config:ModifyAnchor(category, anchor)
	if( not anchor or anchor == "" ) then
		return
	end
	
	if( cachedAnchorFrame ) then
		cachedAnchorFrame:Hide()
	end
	
	local config = {	
		{ group = L["General"], type = "groupOrder", order = 1 },
		{ order = 1, group = L["General"], text = L["Enable anchor"], help = L["Enables this anchor allowing timers to show up inside it, while it's disabled any timers associated with it won't be seen."], type = "check", var = {anchor, "enabled"}},
		{ order = 2, group = L["General"], text = L["Enable announcements"], help = L["Enables sending abilities used/ready/faded information to the specified channel."], type = "check", var = {anchor, "announce"}},
		{ order = 3, group = L["General"], text = L["Announce channel"], help = L["Channel to send abilities announcements to."], type = "dropdown", list = {{"none", L["None"]}, {"ct", L["Combat Text"]}, {"rw", L["Raid Warning"]}, {"rwframe", L["Middle of screen"]}, {"party", L["Party"]}, {1, string.format(L["Chat frame #%d"], 1)}, {2, string.format(L["Chat frame #%d"], 2)}, {3, string.format(L["Chat frame #%d"], 3)}, {4, string.format(L["Chat frame #%d"], 4)}, {5, string.format(L["Chat frame #%d"], 5)}, {6, string.format(L["Chat frame #%d"], 6)}, {7, string.format(L["Chat frame #%d"], 7)}}, var = {anchor, "announceDest"}},
		{ order = 4, group = L["General"], text = L["Announce color"], help = L["Color the text should be shown in if you're outputting using \"Middle of screen\" or \"Combat text\"."], type = "color", var = {anchor, "announceColor"}},
		{ order = 5, group = L["General"], text = L["Grow up"], help = L["Causes timers to be added from bottom -> top order, instead of the current top -> bottom."], type = "check", var = {anchor, "growUp"}},
		{ order = 7, group = L["General"], format = L["Scale: %d%%"], min = 0.0, max = 2.0, default = 1.0, type = "slider", var = {anchor, "scale"}},

		{ group = L["Messages"], type = "groupOrder", order = 3 },
		{ order = 1, group = L["Messages"], text = L["Gain message"], help = L["Text used when an enemy gains a buff, or a friendly player is afflicted by a debuff."], width = 300, type = "input", var = {anchor, "gainMessage"}},
		{ order = 2, group = L["Messages"], text = L["Fade message"], help = L["Text used when an enemies buff or debuff fades."],  width = 300, type = "input", var = {anchor, "fadeMessage"}},
		{ order = 3, group = L["Messages"], text = L["Used message"], help = L["Text used when an enemies ability is used."], width = 300, type = "input", var = {anchor, "usedMessage"}},
		{ order = 4, group = L["Messages"], text = L["Ready message"], help = L["Text used when an enemies ability is ready again."], width = 300, type = "input", var = {anchor, "readyMessage"}},
	}
	
	if( Afflicted.db.profile.showBars and Afflicted.currentVisual == "bars" ) then
		for i=#(displayAnchors), 1, -1 do
			table.remove(displayAnchors, i)
		end

		table.insert(displayAnchors, {"", L["None"]})
		for name, data in pairs(Afflicted.modules.Bars.GTB:GetGroups()) do
			table.insert(displayAnchors, {name, name})
		end

		table.insert(config, { group = L["Redirection"], type = "groupOrder", order = 2 })
		table.insert(config, { order = 1, group = L["Redirection"], text = L["Redirect bar timers to"], help = L["Anchor to redirect all bar timers to, for example you can make it so all timers from \"Buff\" go to the \"Spell\" anchor without having to redo all of the show in options."], type = "dropdown", list = displayAnchors, var = {anchor, "redirectTo"}})
	end

	return HouseAuthority:CreateConfiguration(config, {set = "SetAnchor", get = "GetAnchor", onSet = "Reload", handler = self})
end


-------------------------------
---------- SPELL LIST ---------
-------------------------------

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
	Afflicted.db.profile.spells[spellName] = {}
	for k, v in pairs(Afflicted.defaults.profile.spellDefault) do
		Afflicted.db.profile.spells[spellName][k] = v
	end
	
	Afflicted:UpdateSpellList()
	
	table.insert(spellList, {spellName, spellName})

	-- Register with OH and pop open the default
	OHObj:RegisterSubCategory(L["Spell List"], spellName, self, "ModifySpell", nil, spellName)
	OptionHouse:Open("Afflicted", L["Spell List"], spellName)
end

function Config:DeleteSpellModifier(var)
	Afflicted.db.profile.spells[var] = false
	Afflicted:UpdateSpellList()

	cachedFrame:Hide()
	cachedFrame = nil
	
	for i=#(spellList), 1, -1 do
		if( spellList[i][1] == var ) then
			table.remove(spellList, i)
		end
	end
	
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
	table.insert(config, { group = L["New"], type = "button", xPos = 160, text = L["Add New"], set = "AddSpellModifier"})
	
	-- List current ones
	for name, data in pairs(Afflicted.spellList) do
		if( type(data) == "table" ) then
			order = order + 1

			local spellType = string.format(L["Anchor: %s%s%s"], "|cffffffff", data.showIn, FONT_COLOR_CODE_CLOSE)
			
			local cooldown
			if( data.seconds ) then
				cooldown = string.format(L["Timer: %s%d%s"], "|cffffffff", data.seconds, FONT_COLOR_CODE_CLOSE)
			else
				cooldown = string.format(L["Timer: %s%d%s"], RED_FONT_COLOR_CODE, 0, FONT_COLOR_CODE_CLOSE)
			end

			local triggerLimit
			if( data.singleLimit ) then
				triggerLimit = string.format(L["Limit: %s%d%s"], "|cffffffff", data.singleLimit, FONT_COLOR_CODE_CLOSE)
			else
				triggerLimit = string.format(L["Limit: %s%d%s"], "|cffffffff", 0, FONT_COLOR_CODE_CLOSE)
			end
			
			local status
			if( not data.disabled ) then
				status = name
			else
				status = RED_FONT_COLOR_CODE .. name .. FONT_COLOR_CODE_CLOSE
			end
			
			local icon = data.icon
			if( not icon or icon == "" ) then
				icon = "Interface\\Icons\\INV_Misc_QuestionMark"
			end

			table.insert(config, { group = name, type = "groupOrder", order = order})
			table.insert(config, { group = name, type = "button", texture = icon, height = 19, width = 19, template = ""})
			table.insert(config, { group = name, type = "label", text = status, xPos = -60, font = GameFontHighlightSmall})
			table.insert(config, { group = name, type = "label", text = cooldown, xPos = 60, font = GameFontNormalSmall})
			table.insert(config, { group = name, type = "label", text = spellType, xPos = 100, font = GameFontNormalSmall})
			table.insert(config, { group = name, type = "label", text = triggerLimit, xPos = 160, font = GameFontNormalSmall})
			table.insert(config, { group = name, type = "button", text = L["Edit"], xPos = 190, onSet = "OpenSpellModifier", var = name})
			table.insert(config, { group = name, type = "button", text = L["Delete"], xPos = 220, onSet = "DeleteSpellModifier", var = name})
		end
	end

	-- Update the dropdown incase any new textures were added
	cachedFrame = HouseAuthority:CreateConfiguration(config, {handler = self, columns = 7})
	cachedFrame:SetScript("OnHide", updateAnchorVisibility)
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
		{ order = 2, group = L["General"], text = L["Ignore spell fade events"], help = L["Some buffs you don't want to have the timer removed just because it faded from the person, this is the case for things like Shadowstep where you don't want it removed 3 seconds after the buff fades because you want the cooldown timer."], type = "check", var = {spell, "dontFade"}},
		{ order = 3, group = L["General"], text = L["Check debuffs for spell"], help = L["Enables checking of debuffs enemies put onto people in our group for triggering this timer."], type = "check", var = {spell, "checkDebuff"}},
		{ order = 4, group = L["General"], text = L["Show in"], help = L["Anchor to show this timer inside, remember if the anchor is disabled this spell won't be tracked."], type = "dropdown", list = currentAnchors,  var = {spell, "showIn"}},
		{ order = 5, group = L["General"], text = L["Repeating timer"], help = L["Keeps repeating the timer everytime it hits 0 until the timer in question is removed either by the item being destroyed, or another way."], type = "check", var = {spell, "repeating"}},
		{ order = 6, group = L["General"], text = L["Cooldown/duration"], help = L["Timer to show when this spell is triggered."], type = "input", numeric = true, width = 30, default = 0, var = {spell, "seconds"}},
		{ order = 7, group = L["General"], text = L["Linked spell"], help = L["The parent spell, for example. \"Counterspell - Silence\" should be linked to \"Counterspell\" so that way if a timer is started for Counterspell, another won't be done for \"Counterspell - Silence\" if their on the same target."], type = "dropdown", list = spellList, default = "", var = {spell, "linkedTo"}},
		{ order = 8, group = L["General"], text = L["Icon path"], help = L["Full icon path to the texture, for example \"Interface\\Icons\\<NAME>\".\nThis will automatically be set using the in-game spell icon, so it's not required. But you can override it if you wish."], type = "input", width = 350, var = {spell, "icon"}},

		{ group = L["Limits"], type = "groupOrder", order = 2 },
		{ order = 1, group = L["Limits"], text = L["Per-player trigger limit (seconds)"], help = L["Limits how many times this timer can be triggered in the entered amount of seconds, you may need to enter 0.50-1.0 seconds for things like Physic Scream that debuff multiple people at once."], type = "input", validate = "Validate", error = L["You may only enter a number or a float into this, \"%s\" is invalid."], width = 30, default = 0, var = {spell, "singleLimit"}},
		{ order = 2, group = L["Limits"], text = L["Global trigger limit (seconds)"], help = L["Limits how many times this timer can be triggered in the entered amount of seconds, you may need to enter 0.50-1.0 seconds for things like Physic Scream that debuff multiple people at once."], type = "input", validate = "Validate", error = L["You may only enter a number or a float into this, \"%s\" is invalid."], width = 30, default = 0, var = {spell, "globalLimit"}},
		
		{ group = L["Messages"], type = "groupOrder", order = 3 },
		{ order = 1, group = L["Messages"], text = L["Enable custom message"], help = L["Enables this anchor allowing timers to show up inside it, while it's disabled any timers associated with it won't be seen."], type = "check", var = {spell, "enableCustom"}},
		{ order = 2, group = L["Messages"], text = L["Triggered  message"],  width = 300, help = L["Custom text for when this timer is triggered, overrides the anchor text."], type = "input", var = {spell, "triggeredMessage"}},
		{ order = 3, group = L["Messages"], text = L["Faded message"],  width = 300, help = L["Custom text for when this timer fades, either because the time ran out of the target was removed."], type = "input", var = {spell, "fadedMessage"}},
	}

	return HouseAuthority:CreateConfiguration(config, {set = "SetSpell", get = "GetSpell", handler = self})
end