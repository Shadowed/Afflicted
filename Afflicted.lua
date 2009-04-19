--[[ 
	Afflicted 3, Mayen/Selari/Dayliss from Illidan (US) PvP
]]

Afflicted = LibStub("AceAddon-3.0"):NewAddon("Afflicted", "AceEvent-3.0")

local L = AfflictedLocals
local instanceType, arenaBracket
local summonedTotems = {}
local summonedObjects = {}

function Afflicted:OnInitialize()
	self.defaults = {
		profile = {
			showAnchors = false,
			announceColor = {r = 1, g = 1, b = 1},
			dispelLocation = "none",
			interruptLocation = "none",
			targetOnly = false,
			cooldownMessage = L["READY *spell (*target)"],
			barWidth = 180,
			barNameOnly = false,
			barName = "BantoBar",
			fontSize = 12,
			fontName = "Friz Quadrata TT",
			inside = {["none"] = true},
			anchors = {},
			spells = {},
			arenas = {[2] = {}, [3] = {}, [5] = {}},
			revision = 0,
			spellRevision = 0,
			anchorDefault = {
				enabled = true,
				announce = false,
				growUp = false,
				scale = 1.0,
				maxRows = 20,
				fadeTime = 0.5,
				icon = "LEFT",
				redirect = "",
				display = "bars",
				startMessage = "USED *spell (*target)",
				endMessage = "FADED *spell (*target)",
				announceColor = { r = 1.0, g = 1.0, b = 1.0 },
				announceDest = "1",
			},
		},
	}
	
	-- Load default anchors
	local anchor = self.defaults.profile.anchorDefault
	self.defaults.profile.anchors.interrupts = CopyTable(anchor)
	self.defaults.profile.anchors.interrupts.text = "Interrupts"
	self.defaults.profile.anchors.cooldowns = CopyTable(anchor)
	self.defaults.profile.anchors.cooldowns.text = "Cooldowns"
	self.defaults.profile.anchors.spells = CopyTable(anchor)
	self.defaults.profile.anchors.spells.text = "Spells"
	self.defaults.profile.anchors.buffs = CopyTable(anchor)
	self.defaults.profile.anchors.buffs.text = "Buffs"
	self.defaults.profile.anchors.defenses = CopyTable(anchor)
	self.defaults.profile.anchors.defenses.text = "Defensive"
	self.defaults.profile.anchors.damage = CopyTable(anchor)
	self.defaults.profile.anchors.damage.text = "Damage"
		
	-- Initialize DB
	self.db = LibStub:GetLibrary("AceDB-3.0"):New("AfflictedDB", self.defaults)
	self.db.RegisterCallback(self, "OnProfileChanged", "Reload")
	self.db.RegisterCallback(self, "OnProfileCopied", "Reload")
	self.db.RegisterCallback(self, "OnProfileReset", "Reload")
	self.db.RegisterCallback(self, "OnDatabaseShutdown", "OnDatabaseShutdown")

	self.revision = tonumber(string.match("$Revision$", "(%d+)") or 1)
	
	-- Load SML
	self.SML = LibStub:GetLibrary("LibSharedMedia-3.0")
		
	-- Found an old Afflicted2 install
	if( self.db.profile.spellRevision == 0 and self.db.profile.revision == 0 and self.db.profile.version ) then
		self:Print(L["Reset Afflicted configuration as you were using Afflicted2."])
		self.db:ResetDB()
	end

	-- Load spell defaults in if the DB has changed
	if( self.db.profile.spellRevision <= AfflictedSpells.revision ) then
		self.db.profile.spellRevision = AfflictedSpells.revision
		
		local spells = AfflictedSpells:GetData()
		for spellID, data in pairs(spells) do
			-- Do not add a spell if it doesn't exist
			if( GetSpellInfo(spellID) and not self.db.profile.spells[spellID] ) then
				self.db.profile.spells[spellID] = data
			end
		end
	end
	
	-- Setup our spell cache
	self.spells = setmetatable({}, {
		__index = function(tbl, index)
			-- No data found, don't try and load this index again
			if( not Afflicted.db.profile.spells[index] ) then
				tbl[index] = false
				return false
			end
			
			tbl[index] = loadstring("return " .. Afflicted.db.profile.spells[index])()
			if( type(tbl[index]) == "table" ) then
				tbl[index].cooldown = tbl[index].cooldown or 0
				tbl[index].duration = tbl[index].duration or 0
			end
		
			return tbl[index]
		end
	})

	-- So we know what spellIDs need to be updated when logging out
	self.writeQueue = {}

	-- Load display libraries
	self.bars = self.modules.Bars:LoadVisual()
	self.icons = self.modules.Icons:LoadVisual()
	
	-- Annnd update revision
	self.db.profile.revision = self.revision

	self:RegisterEvent("PLAYER_ENTERING_WORLD", "ZONE_CHANGED_NEW_AREA")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
end

-- Quick function to get the linked spells easily and such
function Afflicted:GetSpell(spellID, spellName)
	if( self.spells[spellName] ) then
		return self.spells[spellName]
	elseif( not self.spells[spellID] ) then
		return nil
	elseif( tonumber(self.spells[spellID]) ) then
		return self.spells[self.spells[spellID]]
	end
	
	return self.spells[spellID]
end

local COMBATLOG_OBJECT_REACTION_HOSTILE	= COMBATLOG_OBJECT_REACTION_HOSTILE
local COMBATLOG_OBJECT_AFFILIATION_MINE = COMBATLOG_OBJECT_AFFILIATION_MINE
local eventRegistered = {["SPELL_CAST_SUCCESS"] = true, ["SPELL_AURA_REMOVED"] = true, ["SPELL_SUMMON"] = true, ["SPELL_CREATE"] = true, ["PARTY_KILL"] = true, ["UNIT_DIED"] = true, ["SPELL_INTERRUPT"] = true, ["SPELL_STOLEN"] = true, ["SPELL_DISPEL_FAILED"] = true, ["SPELL_DISPEL"] = true}
function Afflicted:COMBAT_LOG_EVENT_UNFILTERED(event, timestamp, eventType, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, ...)
	if( not eventRegistered[eventType] ) then
		return
	end
				
	-- Enemy buff faded
	if( eventType == "SPELL_AURA_REMOVED" and bit.band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE ) then
		local spellID, spellName, spellSchool, auraType = ...
		local spell = self:GetSpell(spellID, spellName)
		if( auraType == "BUFF" and spell and spell.type == "buff" ) then
			self:AbilityEarlyFade(sourceGUID, sourceName, spell, spellID)
		end

	-- Spell casted succesfully
	elseif( eventType == "SPELL_CAST_SUCCESS" and bit.band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE ) then
		local spellID, spellName, spellSchool, auraType = ...
		local spell = self:GetSpell(spellID, spellName)
		if( spell and spell.resets ) then
			self:ResetCooldowns(sourceGUID, spell.resets)
		end
		
		-- Totems and traps will be handled in SPELL_SUMMON and SPELL_CREATE, don't trigger them here
		if( spell and ( spell.type == "totem" or spell.type == "trap" ) ) then
			return
		end
		
		self:AbilityTriggered(sourceGUID, sourceName, spell, spellID)
		
	-- Check for something being summoned (Pets, totems)
	elseif( eventType == "SPELL_SUMMON" and bit.band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE ) then
		local spellID, spellName, spellSchool = ...
		
		-- Fixes an issue with totems not being removed when they get redropped
		local id = sourceGUID .. (AfflictedSpells:GetTotemClass(spellName) or spellName)
		local spell = self:GetSpell(spellID, spellName)
		if( spell and spell.type == "totem" ) then
			-- We already had a totem of this timer up, remove the previous one first
			if( summonedTotems[id] ) then
				self[self.db.profile.anchors[spell.anchor].display]:RemoveTimerByID(summonedTotems[id])
			end
			
			-- Set it as summoned so the totem specifically dying removes its timers
			summonedObjects[destGUID] = sourceGUID .. spellID
			
			-- Now trigger
			self:AbilityTriggered(sourceGUID, sourceName, spell, spellID)
		end

		-- Set this as the active totem of that type down
		summonedTotems[id] = sourceGUID .. spellID
		
	-- Check for something being created (Traps, ect)
	elseif( eventType == "SPELL_CREATE" and bit.band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE ) then
		local spellID, spellName, spellSchool = ...
		
		local spell = self:GetSpell(spellID, spellName)
		if( spell and spell.type == "trap" ) then
			-- Set it as summoned so the totem specifically dying removes its timers
			summonedObjects[destGUID] = sourceGUID .. spellID

			self:AbilityTriggered(sourceGUID, sourceName, spell, spellID)
		end

	-- We got interrupted, or we interrupted someone else
	elseif( eventType == "SPELL_INTERRUPT" and self.db.profile.interruptLocation ~= "none" and bit.band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) == COMBATLOG_OBJECT_AFFILIATION_MINE ) then
		local spellID, spellName, spellSchool, extraSpellID, extraSpellName, extraSpellSchool = ...
		
		-- Combat text output should be shorttened since we know who we did it on anyway
		if( self.db.profile.interruptLocation == "ct" ) then
			self:SendMessage(string.format(L["Interrupted %s"], extraSpellName), self.db.profile.interruptLocation, self.db.profile.announceColor)
		else
			self:SendMessage(string.format(L["Interrupted %s's %s"], self:StripServer(destName), extraSpellName), self.db.profile.interruptLocation, self.db.profile.announceColor)
		end
		
		
	-- We tried to dispel a buff, and failed
	elseif( eventType == "SPELL_DISPEL_FAILED" and self.db.profile.dispelLocation ~= "none" and bit.band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) == COMBATLOG_OBJECT_AFFILIATION_MINE and bit.band(destFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE ) then
		local spellID, spellName, spellSchool, extraSpellID, extraSpellName, extraSpellSchool, auraType = ...
		self:SendMessage(string.format(L["FAILED %s's %s"], self:StripServer(destName), extraSpellName), self.db.profile.dispelLocation, self.db.profile.announceColor)
			
	-- Managed to dispel or steal a buff
	elseif( ( eventType == "SPELL_DISPEL" or eventType == "SPELL_STOLEN") and self.db.profile.dispelLocation ~= "none" and bit.band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) == COMBATLOG_OBJECT_AFFILIATION_MINE and bit.band(destFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE ) then
		local spellID, spellName, spellSchool, extraSpellID, extraSpellName, extraSpellSchool, auraType = ...
		-- Combat text output should be shorttened since we know who we did it on anyway
		if( self.db.profile.dispelLocation == "ct" ) then
			local msg = L["Removed %s"]
			if( eventType == "SPELL_STOLEN" ) then
				msg = L["Stole %s"]
			end
			
			self:SendMessage(string.format(msg, self:StripServer(destName)), self.db.profile.dispelLocation, self.db.profile.announceColor)
		else
			local msg = L["Removed %s's %s"]
			if( eventType == "SPELL_STOLEN" ) then
				msg = L["Stole %s's %s"]
			end

			self:SendMessage(string.format(msg, self:StripServer(destName), extraSpellName), self.db.profile.dispelLocation, self.db.profile.announceColor)
		end
		
		-- Check if we should clear timers
	elseif( ( eventType == "PARTY_KILL" or ( instanceType ~= "arena" and eventType == "UNIT_DIED" ) ) and bit.band(destFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE ) then
		-- If this is a summoned object (trap/totem) that was specifically killed, remove its timer
		if( summonedObjects[destGUID] ) then
			self.bars:RemoveTimerByID(summonedObjects[destGUID])
			self.icons:RemoveTimerByID(summonedObjects[destGUID])
			return
		end

		-- If the player has any totems, kill them off with the player
		local offset = string.len(destGUID)
		for guid in pairs(summonedTotems) do
			if( string.sub(guid, 0, offset) == destGUID ) then
				self.bars:UnitDied(guid)
				self.icons:UnitDied(guid)
				
				summonedTotems[guid] = nil
			end
		end
		
		self.bars:UnitDied(destGUID)
		self.icons:UnitDied(destGUID)
	end
end

-- Reset spells
function Afflicted:ResetCooldowns(sourceGUID, resets)
	for spellID in pairs(resets) do
		local spellData = Afflicted.spells[spellID]
		if( spellData and spellData.cdAnchor ) then
			self[self.db.profile.anchors[spellData.cdAnchor].display]:RemoveTimerByID(sourceGUID .. spellID .. "CD")
		end
	end
end

-- Timer started
function Afflicted:AbilityTriggered(sourceGUID, sourceName, spellData, spellID)
	-- No data found, it's disabled, or it's not in our interest cause it's not focus/target
	if( not spellData or ( self.db.profile.targetOnly and UnitGUID("target") ~= sourceGUID and UnitGUID("focus") ~= sourceGUID ) ) then
		return
	end
		
	-- Grab spell info
	local spellName, _, spellIcon = GetSpellInfo(spellID)
	
	-- We're in an arena, and we don't want this spell enabled in the bracket
	if( arenaBracket and self.db.profile.arenas[arenaBracket][spellID or spellName] ) then
		return
	end
	-- Start duration timer (if any)
	if( not spellData.disabled and spellData.anchor and spellData.duration > 0 ) then
		self:CreateTimer(sourceGUID, sourceName, spellData.anchor, spellData.repeating, false, spellData.duration, spellID, spellName, spellIcon)
		
		-- Announce timer used
		self:Announce(spellData, self.db.profile.anchors[spellData.anchor], "startMessage", spellName, sourceName)
	end
	
	-- Start CD timer
	if( not spellData.cdDisabled and spellData.cdAnchor and spellData.cooldown > 0 ) then
		self:CreateTimer(sourceGUID, sourceName, spellData.cdAnchor, false, true, spellData.cooldown, spellID, spellName, spellIcon)
		
		-- Only announce that a cooldown was used if we didn't announce a duration, it's implied that the cooldown started.
		if( spellData.disabled or not spellData.anchor or spellData.duration == 0 ) then
			self:Announce(spellData, self.db.profile.anchors[spellData.cdAnchor], "startMessage", spellName, sourceName)
		end
	end
end

-- Spell faded early, so announce that
function Afflicted:AbilityEarlyFade(sourceGUID, sourceName, spellData, spellID, spellName, announce)
	if( spellData and not spellData.disabled and spellData.type == "buff" ) then
		local removed = self[self.db.profile.anchors[spellData.anchor].display]:RemoveTimerByID(sourceGUID .. spellID)
		if( removed and announce ) then
			self:Announce(spellData, self.db.profile.anchors[spellData.anchor], "endMessage", spellName, sourceName)
		end
	end
end

-- Timer faded naturally
function Afflicted:AbilityEnded(sourceGUID, sourceName, spellData, spellID, spellName, isCooldown)
	if( spellData ) then
		if( not isCooldown and not spellData.disabled ) then
			self:Announce(spellData, self.db.profile.anchors[spellData.anchor], "endMessage", spellName, sourceName)
		elseif( isCooldown and not spellData.cdDisabled ) then
			self:Announce(spellData, self.db.profile.anchors[spellData.cdAnchor], "cooldownMessage", spellName, sourceName)
		end
	end
end

-- Create a timer and shunt it to the correct display
function Afflicted:CreateTimer(sourceGUID, sourceName, anchorName, repeating, isCooldown, duration, spellID, spellName, spellIcon)
	anchor = self.db.profile.anchors[anchorName]
	if( anchor ) then
		self[anchor.display]:CreateTimer(sourceGUID, sourceName, anchorName, repeating, isCooldown, duration, spellID, spellName, spellIcon)
	end
end

-- Announce something
function Afflicted:Announce(spellData, anchor, key, spellName, sourceName, isCooldown)
	local msg
	if( key == "cooldownMessage" and ( spellData.custom or ( anchor.enabled and anchor.announce ) ) ) then
		msg = self.db.profile.cooldownMessage
	elseif( spellData.custom ) then
		msg = spellData[key]
	elseif( anchor.enabled and anchor.announce ) then
		msg = anchor[key]
	end
		
	if( not msg or msg == "" ) then
		return
	end
	
	msg = string.gsub(msg, "*spell", spellName)
	msg = string.gsub(msg, "*target", self:StripServer(sourceName))

	self:SendMessage(msg, anchor.announceDest, anchor.announceColor)
end

-- Database is getting ready to be written, we need to convert any changed data back into text
function Afflicted:OnDatabaseShutdown()
	for id in pairs(self.writeQueue) do
		-- We currently have a table, meaning we can write it out as a string
		if( type(self.spells[id]) == "table" ) then
			local data = ""
			for key, value in pairs(self.spells[id]) do
				local text = ""
				-- Right now, the tables in the spells are resets which is a number indexed table
				if( type(value) == "table" ) then
					for _, subValue in pairs(value) do
						text = string.format("%s%s;", text, subValue)
					end
					
					text = string.format("{%s}", text)
				elseif( type(value) == "string" ) then
					text = string.format("'%s'", value)
				else
					text = tostring(value)
				end
				
				data = string.format("%s%s=%s;", data, key, text)	
			end

			self.db.profile.spells[id] = string.format("{%s}", data)
			
		-- We have a linked spell setup (spellID -> spellID)
		elseif( type(self.spells[id]) == "number" ) then
			self.db.profile.spells[id] = self.spells[id]
		-- Nothing found, so reset the value
		else
			self.db.profile.spells[id] = nil
		end
		
		self.writeQueue[id] = nil
	end
end

-- Enabling Afflicted based on zone type
function Afflicted:ZONE_CHANGED_NEW_AREA()
	local type = select(2, IsInInstance())

	if( type ~= instanceType ) then
		-- Clear anchors because we changed zones
		for key, data in pairs(self.db.profile.anchors) do
			self[data.display]:ClearTimers(key)
		end
		
		-- Reset bracket
		arenaBracket = nil
		
		-- Monitor spells?
		if( self.db.profile.inside[type] ) then
			-- Find arena bracket
			if( type == "arena" ) then
				for i=1, MAX_BATTLEFIELD_QUEUES do
					local status, _, _, _, _, teamSize = GetBattlefieldStatus(i)
					if( status == "active" and teamSize > 0 ) then
						arenaBracket = teamSize
					end
				end
			end
			
			-- Reset our summoned stuff since we don't care about anything before inside
			for k in pairs(summonedObjects) do summonedObjects[k] = nil end
			for k in pairs(summonedTotems) do summonedTotems[k] = nil end

			self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		else
			self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		end
	end
	
	instanceType = type
end

function Afflicted:ReloadEnabled()
	instanceType = nil
	self:ZONE_CHANGED_NEW_AREA()
end

function Afflicted:Reload()
	if( self.icons ) then
		self.icons:ReloadVisual()
	end
	
	if( self.bars ) then
		self.bars:ReloadVisual()
	end
end

-- Strips server name
function Afflicted:StripServer(text)
	local name, server = string.match(text, "(.-)%-(.*)$")
	if( not name and not server ) then
		return text
	end
	
	return name
end

local chatFrames = {}
function Afflicted:SendMessage(msg, dest, color)
	-- We're not showing anything
	if( dest == "none" ) then
		return
	-- We're undergrouped, so redirect it to our fake alert frame
	elseif( dest == "rw" and GetNumRaidMembers() == 0 and GetNumPartyMembers() == 0 ) then
		dest = "rwframe"
	-- We're grouped, in a raid and not leader or assist
	elseif( dest == "rw" and not IsRaidLeader() and not IsRaidOfficer() and GetNumRaidMembers() > 0 ) then
		dest = "party"
	end
	
	-- Strip out any () leftover from no name being given
	msg = string.trim(string.gsub(msg, "%(%)", ""))
		
	-- Chat frame
	if( tonumber(dest) ) then
		if( not chatFrames[dest] ) then
			chatFrames[dest] = getglobal("ChatFrame" .. dest)
		end
		
		local frame = chatFrames[dest] or DEFAULT_CHAT_FRAME
		frame:AddMessage("|cff33ff99Afflicted|r|cffffffff:|r " .. msg, color.r, color.g, color.b)
	-- Raid warning announcement to raid/party
	elseif( dest == "rw" ) then
		SendChatMessage(msg, "RAID_WARNING")
	-- Raid warning frame, will not send it out to the party
	elseif( dest == "rwframe" ) then
		if( not self.alertFrame ) then
			self.alertFrame = CreateFrame("MessageFrame", nil, UIParent)
			self.alertFrame:SetInsertMode("TOP")
			self.alertFrame:SetFrameStrata("HIGH")
			self.alertFrame:SetWidth(UIParent:GetWidth())
			self.alertFrame:SetHeight(60)
			self.alertFrame:SetFadeDuration(0.5)
			self.alertFrame:SetTimeVisible(2)
			self.alertFrame:SetFont((GameFontNormal:GetFont()), 20, "OUTLINE")
			self.alertFrame:SetPoint("CENTER", 0, 60)
		end
		
		self.alertFrame:AddMessage(msg, color.r, color.g, color.b)
	-- Party chat
	elseif( dest == "party" ) then
		SendChatMessage(msg, "PARTY")
	-- Combat text
	elseif( dest == "ct" ) then
		self:CombatText(msg, color)
	end
end

function Afflicted:CombatText(text, color, spellID)	
	-- SCT
	if( IsAddOnLoaded("sct") ) then
		SCT:DisplayText(text, color, nil, "event", 1)
	-- MSBT
	elseif( IsAddOnLoaded("MikScrollingBattleText") ) then
		MikSBT.DisplayMessage(text, MikSBT.DISPLAYTYPE_NOTIFICATION, false, color.r * 255, color.g * 255, color.b * 255)		
	-- Blizzard Combat Text
	elseif( IsAddOnLoaded("Blizzard_CombatText") ) then
		-- Haven't cached the movement function yet
		if( not COMBAT_TEXT_SCROLL_FUNCTION ) then
			CombatText_UpdateDisplayedMessages()
		end
		
		CombatText_AddMessage(text, COMBAT_TEXT_SCROLL_FUNCTION, color.r, color.g, color.b)
	end
end

function Afflicted:Print(msg)
	DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99Afflicted3|r: " .. msg)
end
