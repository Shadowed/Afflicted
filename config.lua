if( not Afflicted ) then return end

local Config = Afflicted:NewModule("Config")
local L = AfflictedLocals

local SML, registered, options, config, dialog
local addedSpellIndex = 0
local addedAnchorIndex = 0
local spellIDToNames = {}
local anchorIDToNames = {}
local linkedSpells = {}
local spellFilter = ""
local moveToAnchor = ""

function Config:OnInitialize()
	config = LibStub("AceConfig-3.0")
	dialog = LibStub("AceConfigDialog-3.0")

	SML = Afflicted.SML
	SML:Register(SML.MediaType.STATUSBAR, "BantoBar", "Interface\\Addons\\Afflicted\\images\\banto")
	SML:Register(SML.MediaType.STATUSBAR, "Smooth",   "Interface\\Addons\\Afflicted\\images\\smooth")
	SML:Register(SML.MediaType.STATUSBAR, "Perl",     "Interface\\Addons\\Afflicted\\images\\perl")
	SML:Register(SML.MediaType.STATUSBAR, "Glaze",    "Interface\\Addons\\Afflicted\\images\\glaze")
	SML:Register(SML.MediaType.STATUSBAR, "Charcoal", "Interface\\Addons\\Afflicted\\images\\Charcoal")
	SML:Register(SML.MediaType.STATUSBAR, "Otravi",   "Interface\\Addons\\Afflicted\\images\\otravi")
	SML:Register(SML.MediaType.STATUSBAR, "Striped",  "Interface\\Addons\\Afflicted\\images\\striped")
	SML:Register(SML.MediaType.STATUSBAR, "LiteStep", "Interface\\Addons\\Afflicted\\images\\LiteStep")
end

-- Force deletes all modified default spells
function Config:Purge()
	for id in pairs(AfflictedSpells) do
		self.db.profile.spells[id] = nil
	end
end

-- GUI
local announceDest = {["none"] = L["None"], ["ct"] = L["Combat text"], ["party"] = L["Party"], ["raid"] = L["Raid"], ["rw"] = L["Raid warning"], ["rwframe"] = L["Middle of screen"], ["1"] = string.format(L["Chat frame #%d"], 1), ["2"] = string.format(L["Chat frame #%d"], 2), ["3"] = string.format(L["Chat frame #%d"], 3), ["4"] = string.format(L["Chat frame #%d"], 4), ["5"] = string.format(L["Chat frame #%d"], 5), ["6"] = string.format(L["Chat frame #%d"], 6), ["7"] = string.format(L["Chat frame #%d"], 7)}

-- Return all fonts
local fonts = {}
function Config:GetFonts()
	for k in pairs(fonts) do fonts[k] = nil end

	for _, name in pairs(SML:List(SML.MediaType.FONT)) do
		fonts[name] = name
	end
	
	return fonts
end

-- Return all registered SML textures
local textures = {}
function Config:GetTextures()
	for k in pairs(textures) do textures[k] = nil end

	for _, name in pairs(SML:List(SML.MediaType.STATUSBAR)) do
		textures[name] = name
	end
	
	return textures
end

-- Return all registered GTB groups
local groups = {}
function Config:GetGroups()
	for k in pairs(groups) do groups[k] = nil end

	groups[""] = L["None"]
	for name, data in pairs(Afflicted.modules.Bars.GTB:GetGroups()) do
		groups[name] = name
	end
	
	return groups
end

-- Return all anchors
local anchors = {}
function Config:GetAnchors()
	for k in pairs(anchors) do anchors[k] = nil end
	
	for key, data in pairs(Afflicted.db.profile.anchors) do
		anchors[key] = data.text or key
	end
	
	return anchors
end

-- Database things
local globalOptions = {["displayType"] = "", ["scale"] = 1, ["maxRows"] = 10, ["growUp"] = false}
local function getGlobalOption(info)
	return globalOptions[info[#(info)]]
end

local function setGlobalOption(info, value)
	if( info.arg == "displayType" and value == "" ) then
		return
	end
	
	for name, anchor in pairs(Afflicted.db.profile.anchors) do
		anchor[info[#(info)]] = value
	end
	
	globalOptions[info[#(info)]] = value

	Afflicted.modules.Bars:ReloadVisual()
	Afflicted.modules.Icons:ReloadVisual()
end

local setSpell, getSpell

-- Advanced feature set/gets
local function parseLinked(id, ...)
	for i=#(linkedSpells[id]), 1, -1 do
		local spellID = linkedSpells[id][i]
		Afflicted.spells[spellID] = false
		Afflicted.writeQueue[spellID] = true
		
		table.remove(linkedSpells[id], i)
	end
	
	for i=1, select("#", ...) do
		local spellID = tonumber((select(i, ...)))
		if( spellID ) then
			Afflicted.spells[spellID] = id
			Afflicted.writeQueue[spellID] = true
			table.insert(linkedSpells[id], spellID)
		end
	end
end

local function parseReset(id, ...)
	local data = {}
	local found
	for i=1, select("#", ...) do
		local spellID = tonumber((select(i, ...)))
		if( spellID ) then
			data[spellID] = true
			found = true
		end
	end
	
	if( found ) then
		Afflicted.writeQueue[id] = true
		Afflicted.spells[id].resets = CopyTable(data)
	else
		Afflicted.writeQueue[id] = true
		Afflicted.spells[id].resets = nil
	end
end

-- Load all the spells into the per class list
local function buildString(spell, divider)
	local txt = ""
	if( spell.disabled or spell.duration == 0 or not spell.anchor ) then
		txt = L["Duration disabled"]
	else
		txt = string.format(L["Duration: %d (%s)"], spell.duration, (Afflicted.db.profile.anchors[spell.anchor] and Afflicted.db.profile.anchors[spell.anchor].text or spell.anchor))
	end

	if( txt ~= "" ) then
		txt = txt .. divider
	end

	if( spell.cdDisabled or spell.cooldown == 0 or not spell.cdAnchor ) then
		txt = txt .. L["Cooldown disabled"]
	else
		txt = txt .. string.format(L["Cooldown: %d (%s)"], spell.cooldown, (Afflicted.db.profile.anchors[spell.cdAnchor] and Afflicted.db.profile.anchors[spell.cdAnchor].text or spell.anchor))
	end

	return txt
end

-- Build a list of spells based on a filter (if any)
local function createSpellConfiguration(index, spell, spellID, spellName)
	local classList = {}
	for classToken in pairs(RAID_CLASS_COLORS) do
		classList[classToken] = L.classes[classToken]
	end
	
	if( not setSpell ) then
		setSpell = function(info, value)
			local id = spellIDToNames[info[2]]
			local key = info[#(info)]

			-- We changed the class this was associated to, so shift the spell cat option to the new one
			if( key == "class" and Afflicted.spells[id][key] ~= value and Afflicted.spells[id][key] and options.args.spellcats.args[Afflicted.spells[id][key]][id] ) then
				options.args.spellcats.args[value][id] = CopyTable(options.args.spellcats.args[Afflicted.spells[id][key]][id])
				options.args.spellcats.args[Afflicted.spells[id][key]] = nil
			end

			Afflicted.writeQueue[id] = true
			Afflicted.spells[id][key] = value
		end
		getSpell = function(info)
			local key = info[#(info)]
			local id = spellIDToNames[info[2]]
			if( key == "type" and not Afflicted.spells[id][key] ) then
				return "cast"
			end

			return Afflicted.spells[id][key]
		end
	end
	
	return {
		type = "group",
		order = 1,
		name = spellName or string.format("#%d", spellID),
		desc = buildString(spell, "\n"),
		set = setSpell,
		get = getSpell,
		arg = index,
		args = {
			duration = {
				type = "group",
				order = 1,
				inline = true,
				name = L["Spell timer"],
				args = {
					disabled = {
						order = 1,
						type = "toggle",
						name = L["Disable duration"],
						width = "full",
					},
					duration = {
						order = 2,
						name = L["Duration"],
						desc = L["Click the number between the 0 and 900 to set the time to a specific number of seconds."],
						type = "range",
						min = 0, max = 900, step = 1,
					},
					anchor = {
						order = 3,
						type = "select",
						name = L["Anchor"],
						values = "GetAnchors",
					},
				},
			},
			cooldown = {
				type = "group",
				order = 2,
				inline = true,
				name = L["Spell cooldown"],
				args = {
					cdDisabled = {
						order = 1,
						type = "toggle",
						name = L["Disable cooldown"],
						width = "full",

					},
					cooldown = {
						order = 2,
						name = L["Cooldown"],
						desc = L["Click the number between the 0 and 900 to set the time to a specific number of seconds."],
						type = "range",
						min = 0, max = 900, step = 1,
					},
					cdAnchor = {
						order = 3,
						type = "select",
						name = L["Cooldown anchor"],
						values = "GetAnchors",
					},
				},
			},
			announce = {
				order = 3,
				type = "group",
				inline = true,
				name = L["Announcements"],
				args = {
					custom = {
						order = 1,
						type = "toggle",
						name = L["Enable announcements"],
						width = "full",
					},
					startMessage = {
						order = 2,
						type = "input",
						name = L["Start message"],
						desc = L["Message to show when the spell is used."],
						width = "full",
					},
					endMessage = {
						order = 3,
						type = "input",
						name = L["Ended message"],
						desc = L["Message to show the spell ends, this only applies to duration based typers, cooldowns will use a static message."],
						width = "full",
					},
				},
			},
			type = {
				type = "group",
				order = 4,
				inline = true,
				name = L["Spell data"],
				args = {
					type = {
						order = 1,
						name = L["Type"],
						desc = L["Spell type, buffs are things that the player actually gains, casts are anything thats an instant cast spell, summoned objects are things such as totems, and created objects are traps."],
						type = "select",
						values = {["cast"] = L["Casts"], ["totem"] = L["Summoned objects"], ["trap"] = L["Created objects"], ["buff"] = L["Buffs"]},
					},
					class = {
						order = 2,
						name = L["Class from"],
						desc = L["The class that actually casts this spell, used for categorization."],
						type = "select",
						values = classList,
					},
					advanced = {
						type = "group",
						order = 3,
						hidden = true,
						inline = true,
						name = L["Advanced"],
						args = {
							desc = {
								order = 0,
								type = "description",
								name = L["Advanced configuration linked to more internal functions.\nValues are separated by commas.\nDO NOT edit these if you do not know what you are doing, you do not have to touch them 99% of the time."],
							},
							linked = {
								order = 1,
								type = "input",
								name = L["Spells linked to this one"],
								desc = L["Spells that are specifically linked to this one by a spell id. This is basically lower ranked spells, and you only need to set this if you're adding by spell id... and even then you don't really have to."],
								set = function(info, value)
									parseLinked(spellIDToNames[info[2]], string.split(",", value))
								end,
								get = function(info)
									local id = spellIDToNames[info[2]]
									if( not linkedSpells[id] ) then
										linkedSpells[id] = {}
										return ""
									end

									local txt
									for _, spellID in pairs(linkedSpells[id]) do
										if( txt ) then
											txt = txt .. "," .. spellID
										else
											txt = spellID .. ""
										end
									end

									return txt
								end,
							},
							reset = {
								order = 1,
								type = "input",
								name = L["Reset when this is used"],
								desc = L["Spells that should have there cooldown reset when this one is used, think Preparation or Iceblock."],
								set = function(info, value)
									parseReset(spellIDToNames[info[2]], string.split(",", value))	
								end,
								get = function(info)
									local id = spellIDToNames[info[2]]
									if( not Afflicted.spells[id].resets ) then
										return ""
									end
									
									local txt
									for spellID in pairs(Afflicted.spells[id].resets) do
										if( txt ) then
											txt = txt .. "," .. spellID
										else
											txt = spellID .. ""
										end
									end
									
									return txt or ""
								end,
							},
						},
					},

				},
			},
			delete = {
				order = 5,
				type = "group",
				inline = true,
				name = L["Delete"],
				args = {
					desc = {
						order = 1,
						type = "description",
						name = L["Spells that were added manually will be deleted, however spells that are added by default are simply reset next update."],
					},
					delete = {
						order = 2,
						type = "execute",
						name = L["Delete"],
						confirm = true,
						confirmText = L["Are you REALLY sure you want to delete this spell?"],
						func = function(info)
							local id = spellIDToNames[info[2]]
							options.args.spells.args[info[2]] = nil
							options.args.spellcats.args.ALL[info[2]] = nil
							if( Afflicted.spells[id].class ) then
								options.args.spellcats.args[Afflicted.spells[id].class][info[2]] = nil
							end

							Afflicted.spells[id] = false
							Afflicted.writeQueue[id] = true
						end,
					},
				},
			},
		},
	}
end

-- Anchor DB
local setAnchor, getAnchor, setAnchorColor, getAnchorColor

-- Create an anchor configuration
local function createAnchorConfiguration(index, anchor)
	if( not setAnchor ) then
		setAnchor = function(info, value)
			local id = anchorIDToNames[info[2]]
			local key = info[#(info)]
			if( key == "text" ) then
				options.args.anchors.args[info[2]].name = value
			end
			
			Afflicted.db.profile.anchors[id][key] = value
		end

		getAnchor = function(info)
			local id = anchorIDToNames[info[2]]
			return Afflicted.db.profile.anchors[id][info[#(info)]]
		end

		setAnchorColor = function(info, r, g, b)
			setAnchor(info, {r = r, g = g, b = b})
		end

		getAnchorColor = function(info)
			local color = getAnchor(info)
			return color.r, color.g, color.b
		end

		isBarOptionsHidden = function(info)
			return Afflicted.db.profile.anchors[anchorIDToNames[info[2]]].display == "icons"
		end
	end
	
	return {
		order = 1,
		type = "group",
		name = anchor.text,
		set = setAnchor,
		get = getAnchor,
		arg = index,
		args = {
			enabled = {
				order = 1,
				type = "toggle",
				name = L["Enable anchor"],
				desc = L["Allows timers to be shown under this anchor, if the anchor is disabled you won't see any timers."],
				width = "full",
			},
			text = {
				order = 2,
				type = "input",
				name = L["Anchor name"],
				validate = function(info, value)
					value = string.trim(value)
					if( value == "" ) then
						return L["No anchor name entered."]
					end

					for _, data in pairs(Afflicted.db.profile.anchors) do
						if( string.lower(data.text or "") == string.lower(value) ) then
							return L["An anchor with that name already exists."]
						end
					end

					return true
				end,
			},
			display = {
				order = 3,
				type = "group",
				inline = true,
				name = L["Display"],
				args = {
					growUp = {
						order = 1,
						type = "toggle",
						name = L["Grow up"],
						desc = L["Instead of adding everything from top to bottom, timers will be shown from bottom to top."],
						width = "double",
					},
					display = {
						order = 2,
						type = "select",
						name = L["Display type"],
						values = {["bars"] = L["Bars"], ["icons"] = L["Icons"]},
					},
					icon = {
						order = 3,
						type = "select",
						name = L["Icon position"],
						values = {["LEFT"] = L["Left"], ["RIGHT"] = L["Right"]},
						hidden = isBarOptionsHidden,
					},
					fadeTime = {
						order = 4,
						type = "range",
						name = L["Fade time"],
						desc = L["How many seconds it should take after a bar is finished for it to fade out."],
						min = 0, max = 2, step = 0.1,
						hidden = isBarOptionsHidden,
					},
					sep = {
						order = 5,
						name = "",
						type = "description",
					},
					scale = {
						order = 6,
						type = "range",
						name = L["Scale"],
						min = 0, max = 2, step = 0.01,
					},
					maxRows = {
						order = 7,
						type = "range",
						name = L["Max timers"],
						desc = L["Maximum amount of timers that should be ran per an anchor at the same time, if too many are running at the same time then the new ones will simply be hidden until older ones are removed."],
						min = 1, max = 50, step = 1,
					},
					redirection = {
						order = 8,
						type = "group",
						inline = true,
						name = L["Redirection"],
						hidden = isBarOptionsHidden,
						args = {
							desc = {
								order = 0,
								name = L["Group name to redirect bars to, this lets you show Afflicted timers under another addons bar group. Requires the bars to be created using GTB, and the bar display to be enabled for this anchor."],
								type = "description",
							},
							redirect = {
								order = 1,
								type = "select",
								name = L["Redirect bars to group"],
								values = "GetGroups",
							},
						},
					},
				},
			},
			announce = {
				order = 5,
				type = "group",
				inline = true,
				name = L["Announcements"],
				args = {
					announce = {
						order = 1,
						type = "toggle",
						name = L["Enable announcements"],
						width = "full",
					},
					announceColor = {
						order = 2,
						type = "color",
						name = L["Text color"],
						desc = L["Alert text color, only applies to local outputs."],
						set = setAnchorColor,
						get = getAnchorColor,
						width = "full",
					},
					announceDest = {
						order = 3,
						type = "select",
						name = L["Destination"],
						values = announceDest,
					},
					announceText = {
						order = 6,
						type = "group",
						inline = true,
						name = L["Announce text"],
						args = {
							desc = {
								order = 0,
								name = L["Announcement text for when timers are triggered in this anchor. You can use *spell for the spell name, and *target for the person who triggered it (if any)."],
								type = "description",
							},
							startMessage = {
								order = 1,
								type = "input",
								name = L["Start message"],
								desc = L["Message to show when a timer is started in this anchor."],
								width = "full",
							},
							endMessage = {
								order = 2,
								type = "input",
								name = L["Ended message"],
								desc = L["Message to show when a timer ends inside this anchor."],
								width = "full",
							},
						},
					},
				},
			},
			delete = {
				order = 6,
				type = "group",
				inline = true,
				name = L["Delete"],
				args = {
					desc = {
						order = 1,
						type = "description",
						name = L["Anchors that were added manually will be deleted, default anchors will be reset to default settings if you delete them. Disable default anchors to stop timers from showing.\nYou will have to choose a new anchor to move any spells in this one to when you delete this anchor."],
					},
					move = {
						order = 1,
						type = "select",
						name = L["Move spells in this anchor to"],
						desc = L["You have to choose which anchor spells should be moved to when this one is deleted."],
						values = function(info)
							local groups = Config:GetAnchors()
							groups[anchorIDToNames[info[2]]] = nil
							
							return groups
						end,
						set = function(info, value) moveToAnchor = value end,
						get = function() return moveToAnchor end,
					},
					delete = {
						order = 2,
						type = "execute",
						name = L["Delete"],
						confirm = true,
						confirmText = L["Are you REALLY sure you want to delete this anchor?"],
						func = function(info)
							local anchorID = anchorIDToNames[info[2]]
							options.args.anchors.args[info[2]] = nil
							Afflicted.db.profile.anchors[anchorID] = nil
							
							-- Move all spells that were in this anchor to the new one
							-- None set, find one quickly.
							if( not moveToAnchor or moveToAnchor == "" ) then
								for key in pairs(Afflicted.db.profile.anchors) do moveToAnchor = key break end
							end
							
							-- Now move them all
							for id in pairs(Afflicted.db.profile.spells) do
								local spell = Afflicted.spells[id]
								if( type(spell) == "table" ) then
									if( spell.anchor and spell.anchor == anchorID ) then
										spell.anchor = moveToAnchor
									end
									if( spell.cdAnchor and spell.cdAnchor == anchorID ) then
										spell.cdAnchor = moveToAnchor
									end
								end
							end
							
							-- Annd refresh
							Afflicted.modules.Bars:ReloadVisual()
							Afflicted.modules.Icons:ReloadVisual()
						end,
					},
				},
			},
		},
	}
end

-- General option
local function loadOptions()
	options = {}
	options.type = "group"
	options.name = "Afflicted"
	
	options.args = {}
	options.args.general = {
		type = "group",
		order = 1,
		name = L["General"],
		set = function(info, value)
			Afflicted.db.profile[info[#(info)]] = value
			Afflicted:Reload()
		end,
		get = function(info)
			return Afflicted.db.profile[info[#(info)]]
		end,
		handler = Config,
		args = {
			showAnchors = {
				order = 0,
				type = "toggle",
				name = L["Show timer anchors"],
				desc = L["Show the anchors that lets you drag timer groups around."],
			},
			showIcons = {
				order = 1,
				type = "toggle",
				name = L["Show icons in alerts"],
				desc = L["Any announcement into a local channel, will show the icon of the spell that was announced."],
			},
			inside = {
				order = 2,
				type = "multiselect",
				name = L["Enable inside"],
				values = {["none"] = L["Everywhere else"], ["pvp"] = L["Battlegrounds"], ["arena"] = L["Arenas"], ["raid"] = L["Raid instances"], ["party"] = L["Party instances"]},
				set = function(info, value, state)
					Afflicted.db.profile[info[#(info)]][value] = state
					Afflicted:ReloadEnabled()
				end,
				get = function(info, value)
					return Afflicted.db.profile[info[#(info)]][value]
				end,
				width = "double",
				arg = "inside"
			},
			announce = {
				order = 3,
				type = "group",
				inline = true,
				name = L["Announcements"],
				args = {
					announceColor = {
						order = 1,
						type = "color",
						name = L["Color"],
						set = function(info, r, g, b)
							Afflicted.db.profile[info[#(info)]].r = r
							Afflicted.db.profile[info[#(info)]].g = g
							Afflicted.db.profile[info[#(info)]].b = b
						end,
						get = function(info)
							return Afflicted.db.profile[info[#(info)]].r, Afflicted.db.profile[info[#(info)]].g, Afflicted.db.profile[info[#(info)]].b
						end,
						width = "full",
					},
					dispelLocation = {
						order = 2,
						type = "select",
						name = L["Dispel announcements"],
						values = announceDest,
					},
					interruptLocation = {
						order = 3,
						type = "select",
						name = L["Interrupt announcements"],
						values = announceDest,
					},
				},
			},
			display = {
				order = 4,
				type = "group",
				inline = true,
				name = L["Display"],
				args = {
					targetOnly = {
						order = 1,
						type = "toggle",
						name = L["Only show target/focus timers"],
						desc = L["Only timers of people you have targeted, or focused will be triggered. They will not be removed if you change targets however."],   
						width = "full",
					},
					anchors = {
						order = 2,
						type = "group",
						inline = true,
						name = L["Anchors"],
						args = {
							desc = {
								order = 0,
								name = L["Global display setting, changing these will change all the anchors settings.\nNOTE: These values do not reflect each anchors configuration, this is just a quick way to set all of them to the same thing."],
								type = "description",
							},
							growUp = {
								order = 1,
								type = "toggle",
								name = L["Grow up"],
								desc = L["Instead of adding everything from top to bottom, timers will be shown from bottom to top."],
								get = getGlobalOption,
								set = setGlobalOption,
								width = "full",
							},
							display = {
								order = 3,
								type = "select",
								name = L["Display style"],
								values = {[""] = "----", ["bars"] = L["Bars"], ["icons"] = L["Icons"]},
								get = getGlobalOption,
								set = setGlobalOption,
							},
							sep = {
								order = 4,
								name = "",
								type = "description",
							},
							scale = {
								order = 5,
								type = "range",
								name = L["Scale"],
								min = 0, max = 2, step = 0.01,
								get = getGlobalOption,
								set = setGlobalOption,
							},
							maxRows = {
								order = 6,
								type = "range",
								name = L["Max timers"],
								desc = L["Maximum amount of timers that should be ran per an anchor at the same time, if too many are running at the same time then the new ones will simply be hidden until older ones are removed."],
								min = 1, max = 50, step = 1,
								get = getGlobalOption,
								set = setGlobalOption,
							},
							
						},
					},
					display = {
						order = 3,
						type = "group",
						inline = true,
						name = L["Bar only"],
						args = {
							desc = {
								order = 0,
								name = L["Configuration that only applies to bar displays."],
								type = "description",
							},
							barNameOnly = {
								order = 1,
								type = "toggle",
								name = L["Only show triggered name in text"],
								desc = L["Instead of showing both the spell name and the triggered name, only the name will be shown in the bar."],
								width = "full",
								arg = "barNameOnly",
							},
							barWidth = {
								order = 2,
								type = "range",
								name = L["Width"],
								min = 0, max = 300, step = 1,
							},
							fontSize = {
								order = 3,
								type = "range",
								name = L["Font size"],
								min = 1, max = 20, step = 1,
							},
							sep = {
								order = 4,
								name = "",
								type = "description",
							},
							barName = {
								order = 5,
								type = "select",
								name = L["Texture"],
								dialogControl = "LSM30_Statusbar",
								values = "GetTextures",
							},
							fontName = {
								order = 6,
								type = "select",
								name = L["Font name"],
								dialogControl = "LSM30_Font",
								values = "GetFonts",
							},
						},
					},
				},
			},
		},
	}
	
	-- Anchor configuration
	options.args.anchors = {
		type = "group",
		order = 2,
		name = L["Anchors"],
		handler = Config,
		args = {
			newAnchor = {
				type = "group",
				order = 0,
				name = L["New anchor"],
				inline = true,
				args = {
					desc = {
						order = 1,
						type = "description",
						name = L["Add a new anchor to Afflicted that timers can be displayed in."],
						width = "full",
					},
					spell = {
						order = 2,
						type = "input",
						name = L["Anchor name"],
						validate = function(info, value)
							value = string.trim(value)
							if( value == "" ) then
								return L["No anchor name entered."]
							end
							
							for _, data in pairs(Afflicted.db.profile.anchors) do
								if( string.lower(data.text or "") == string.lower(value) ) then
									return L["An anchor with that name already exists."]
								end
							end
							
							return true
						end,
						get = function() return "" end,
						set = function(info, value)
							addedAnchorIndex = addedAnchorIndex + 1
							local anchorID = string.gsub(string.lower(value), " ", "") .. addedAnchorIndex
							anchorIDToNames[tostring(addedAnchorIndex)] = anchorID

							Afflicted.db.profile.anchors[anchorID] = CopyTable(Afflicted.defaults.profile.anchorDefault)
							Afflicted.db.profile.anchors[anchorID].text = value

							options.args.anchors.args[tostring(addedAnchorIndex)] = createAnchorConfiguration(addedAnchorIndex, Afflicted.db.profile.anchors[anchorID])

							Afflicted.modules.Bars:ReloadVisual()
							Afflicted.modules.Icons:ReloadVisual()
						end,
						width = "full",
					},
				},
			},
		},
	}
	
	for key, data in pairs(Afflicted.db.profile.anchors) do
		addedAnchorIndex = addedAnchorIndex + 1
		anchorIDToNames[tostring(addedAnchorIndex)] = key
		options.args.anchors.args[tostring(addedAnchorIndex)] = createAnchorConfiguration(addedAnchorIndex, data)
	end
	
	-- Create the actual spell list modifier
	options.args.spells = {
		type = "group",
		order = 3,
		name = L["Spells"],
		handler = Config,
		args = {
			newSpell = {
				type = "group",
				order = 0,
				name = L["New spell"],
				inline = true,
				args = {
					desc = {
						order = 1,
						type = "description",
						name = L["Add a new spell to Afflicted, you can add it either by the spell name or spell id. However, if you add it by spell name then you must match the casing Blizzard uses as it is case sensitive."],
						width = "full",
					},
					spell = {
						order = 2,
						type = "input",
						name = L["Add new spell by name or spell id"],
						validate = function(info, value)
							value = string.trim(value)
							if( Afflicted.spells[value] ) then
								return L["A spell with that name already exists."]
							elseif( value == "" ) then
								return L["No spell name entered."]
							end
							
							return true
						end,
						get = function() return "" end,
						set = function(info, value)
							if( tonumber(value) ) then
								value = tonumber(value)
							end

							-- Add it!
							Afflicted.db.profile.spells[value] = ""
							Afflicted.spells[value] = {}
							Afflicted.writeQueue[value] = true

							-- And do our quick translation table, thing-a-ma-bob
							addedSpellIndex = addedSpellIndex + 1
							spellIDToNames[tostring(addedSpellIndex)] = value

							-- Figure out spell name
							local spellName = value
							if( type(spellName) == "number" ) then
								spellName = GetSpellInfo(spellName)
							end

							options.args.spells.args[tostring(addedSpellIndex)] = createSpellConfiguration(addedSpellIndex, Afflicted.spells[value], value, spellName)
						end,
						width = "full",
					},
				},
			},
		},
	}
	
	-- Spells that should be enabled in arenas
	options.args.arenas = {
		type = "group",
		order = 2,
		name = L["Arena spells"],
		handler = Config,
		set = function(info, value)
			Afflicted.db.profile.arenas[tonumber(info[2])][spellIDToNames[info[#(info)]]] = not value
		end,
		get = function(info)
			return not Afflicted.db.profile.arenas[tonumber(info[2])][spellIDToNames[info[#(info)]]]
		end,
		childGroups = "tab",
		args = {
			desc = {
				order = 0,
				type = "description",
				name = L["Spells that should be enabled inside a specific arena bracket."],
			},
			search = {
				order = 1,
				type = "input",
				name = L["Search spells"],
				get = function() return spellFilter end,
				set = function(info, val) spellFilter = val; end,
			},
			["2"] = {
				order = 1,
				type = "group",
				name = L["2 vs 2"],
				args = {},
			},
			["3"] = {
				order = 1,
				type = "group",
				name = L["3 vs 3"],
				args = {},
			},
			["5"] = {
				order = 1,
				type = "group",
				name = L["5 vs 5"],
				args = {},
			},
		},
	}
	
	-- Categoric listing of spells
	options.args.spellcats = {
		type = "group",
		order = 2,
		name = L["Spell categories"],
		handler = Config,
		childGroups = "tab",
		args = {
			search = {
				order = 2,
				type = "input",
				name = L["Search spells"],
				get = function() return spellFilter end,
				set = function(info, val) spellFilter = val; end,
			},
		},
	}

	-- Load the spell categories per classes in
	options.args.spellcats.args.ALL = {
		order = 1,
		type = "group",
		name = L["All"],
		args = {},
	}

	local order = 2
	for classToken in pairs(RAID_CLASS_COLORS) do
		options.args.spellcats.args[classToken] = {
			type = "group",
			order = order,
			name = L.classes[classToken],
			args = {}
		}
		
		order = order + 1
	end

	local order = 2
	for classToken in pairs(RAID_CLASS_COLORS) do
		options.args.spellcats.args[classToken] = {
			type = "group",
			order = order,
			name = L.classes[classToken],
			args = {},
		}
		
		order = order + 1
	end
	
	-- Open a specific spell
	local timerFrame
	local timeElapsed = 0.15
	local AceDialog, AceRegistry
	local function openSpell(info)
		AceDialog = AceDialog or LibStub("AceConfigDialog-3.0")
		AceRegistry = AceRegistry or LibStub("AceConfigRegistry-3.0")
		
		AceDialog.Status.Afflicted.status.groups.groups.spells = true
		AceDialog.Status.Afflicted.status.groups.selected = "spells\001" .. info[#(info)]
		AceRegistry:NotifyChange("Afflicted")
	end
	
	-- Spell search thing
	local function isSpellHidden(info)
		if( not spellFilter or spellFilter == "" ) then
			return false
		end

		return not string.match(string.lower(info.arg), string.lower(spellFilter))
	end
	
	-- Category spell toggling
	local totalAdded = {}
	local function createCatSpell(index, spell, spellID, spellName, category)
		totalAdded[category] = (totalAdded[category] or 0) + 1
		
		options.args.spellcats.args[category].args[tostring(index)] = {
			order = index,
			type = "execute",
			name = spellName or spellID,
			desc = buildString(spell, "\n"),
			arg = spellName,
			hidden = isSpellHidden,
			func = openSpell,
		}
	end
	
	-- Spell enabled in arenas
	local function createSpellArenaConfiguration(index, spell, spellID, spellName)
		return {
			type = "toggle",
			order = 1,
			name = spellName or string.format("#%d", spellID),
			desc = buildString(spell, "\n"),
			hidden = isSpellHidden,
			arg = spellName,
		}
	end
	
	-- Load it all up
	for id in pairs(Afflicted.db.profile.spells) do
		addedSpellIndex = addedSpellIndex + 1
		spellIDToNames[tostring(addedSpellIndex)] = id

		local spell = Afflicted.spells[id]
		if( type(spell) == "table" ) then
			local spellName = id
			if( type(spellName) == "number" ) then
				spellName = GetSpellInfo(id)
			end
			
			-- Add the group tab entry
			if( spell.class ) then
				createCatSpell(addedSpellIndex, spell, id, spellName, spell.class)
			end
			
			-- Add the all tab entry
			createCatSpell(addedSpellIndex, spell, id, spellName, "ALL")
			
			-- Add the arena listing
			options.args.arenas.args["2"].args[tostring(addedSpellIndex)] = createSpellArenaConfiguration(addedSpellIndex, spell, id, spellName)
			options.args.arenas.args["3"].args[tostring(addedSpellIndex)] = createSpellArenaConfiguration(addedSpellIndex, spell, id, spellName)
			options.args.arenas.args["5"].args[tostring(addedSpellIndex)] = createSpellArenaConfiguration(addedSpellIndex, spell, id, spellName)
						
			-- Now add the spell modifier thingy one
			options.args.spells.args[tostring(addedSpellIndex)] = createSpellConfiguration(addedSpellIndex, spell, id, spellName)	
		elseif( type(spell) == "number" ) then
			linkedSpells[spell] = linkedSpells[spell] or {}
			table.insert(linkedSpells[spell], id)
		end
	end
	
	-- DB Profiles
	options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(Afflicted.db)
	options.args.profile.order = 5
end

-- Slash commands
SLASH_AFFLICTED1 = "/afflicted3"
SLASH_AFFLICTED2 = "/afflicted"
SLASH_AFFLICTED3 = "/afflict"
SlashCmdList["AFFLICTED"] = function(msg)
	msg = string.lower(msg or "")
	
	local self = Afflicted
	if( msg == "clear" ) then
		for name, data in pairs(self.db.profile.anchors) do
			self[data.display]:ClearTimers(name)
		end
	elseif( msg == "test" ) then
		-- Clear out any running timers first
		local totalAnchors = 0
		for name, data in pairs(self.db.profile.anchors) do
			totalAnchors = totalAnchors + 1
			self[data.display]:ClearTimers(name)
		end
		
		local added = {}
		local addedCount = 0
		for id in pairs(self.db.profile.spells) do
			local spell = self.spells[id]
			if( type(id) == "number" and type(spell) == "table" ) then
				local spellName, _, spellIcon = GetSpellInfo(id)
				
				if( spell.anchor and spell.duration > 0 and not added[spell.anchor] ) then
					added[spell.anchor] = true
					addedCount = addedCount + 1
					self:CreateTimer(UnitGUID("player"), UnitName("player"), spell.anchor, spell.repeating, false, spell.duration, id, spellName, spellIcon)
				end
				
				if( spell.cdAnchor and spell.cooldown > 0 and not added[spell.cdAnchor] ) then
					added[spell.cdAnchor] = true
					addedCount = addedCount + 1
					self:CreateTimer(UnitGUID("player"), UnitName("player"), spell.cdAnchor, false, true, spell.cooldown, id, spellName, spellIcon)
				end
				
				-- We have at least one timer in each anchor now
				if( addedCount >= totalAnchors ) then
					break
				end
			end
		end

	elseif( msg == "ui" ) then
		if( not registered ) then
			if( not options ) then
				loadOptions()
			end
			
			config:RegisterOptionsTable("Afflicted", options)
			dialog:SetDefaultSize("Afflicted", 640, 590)
			registered = true
		end

		dialog:Open("Afflicted")
	else
		Afflicted:Print(L["Slash commands"])
		DEFAULT_CHAT_FRAME:AddMessage(L["- clear - Clears all running timers."])
		DEFAULT_CHAT_FRAME:AddMessage(L["- test - Shows test timers in Afflicted."])
		DEFAULT_CHAT_FRAME:AddMessage(L["- ui - Opens the configuration for Afflicted."])
	end
end