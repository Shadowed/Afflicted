Afflicted = LibStub("AceAddon-3.0"):NewAddon("Afflicted", "AceEvent-3.0")

local L = AfflictedLocals

local instanceType

local playerLimit = {}
local globalLimit = {}

local spellSchools = {[1] = L["Physical"], [2] = L["Holy"], [4] = L["Fire"], [8] = L["Nature"], [16] = L["Frost"], [32] = L["Shadow"], [64] = L["Arcane"]}

function Afflicted:OnInitialize()
	self.defaults = {
		profile = {
			showAnchors = true,
			showIcons = true,
			showBars = true,
			dispelEnabled = true,
			dispelHostile = true,
			dispelDest = "1",
			dispelColor = { r = 1, g = 1, b = 1 },
			interruptEnabled = true,
			interruptDest = "rwframe",
			interruptColor = { r = 1, g = 1, b = 1 },
			
			barWidth = 180,
			barName = "BantoBar",
			
			anchors = {
				["Spell"] = {
					enabled = true,
					announce = true,
					growUp = false,
					announceColor = { r = 1.0, g = 1.0, b = 1.0 },
					announceDest = "1",
					scale = 1.0,
					text = L["Spells"],

					gainMessage = L["GAINED *spell (*target)"],
					usedMessage = L["USED *spell (*target)"],
					fadeMessage = L["FADED *spell (*target)"],
					readyMessage = L["READY *spell (*target)"],
				},
				["Buff"] = {
					enabled = true,
					announce = true,
					growUp = false,
					announceColor = { r = 1.0, g = 1.0, b = 1.0 },
					announceDest = "1",
					scale = 1.0,
					text = L["Buffs"],

					gainMessage = L["GAINED *spell (*target)"],
					usedMessage = L["USED *spell (*target)"],
					fadeMessage = L["FADED *spell (*target)"],
					readyMessage = L["READY *spell (*target)"],
				},
			},
			spells = {},
			inside = {["arena"] = true, ["pvp"] = true},
			spellDefault = {
				seconds = 0,
				icon = "Interface\\Icons\\INV_Misc_QuestionMark",
				showIn = "spell",
				linkedTo = "",
			},
		},
	}

	self.db = LibStub:GetLibrary("AceDB-3.0"):New("AfflictedDB", self.defaults)
	self.revision = tonumber(string.match("$Revision$", "(%d+)") or 1)
	self.SML = LibStub:GetLibrary("LibSharedMedia-3.0")
		
	-- Upgrade
	if( self.db.profile.version ~= self.revision ) then
		for name, data in pairs(self.db.profile.spells) do
			if( not data.showIn ) then
				data.singleLimit = data.limit or 0
				data.globalLimit = 0
				
				if( data.type == "spell" ) then
					data.showIn = "Spell"
				elseif( data.type == "buff" ) then
					data.showIn = "Buff"
				elseif( data.type == "debuff" ) then
					data.checkDebuff = true
					data.showIn = "Spell"
				else
					data.showIn = "Spell"
				end
				
				data.limit = nil
				data.type = nil
			end

			data.linkedTo = data.linkedTo or ""
		end
	end
	
	self.db.profile.version = self.revision

	-- Update the spell list with the default and manual
	self.spellList = {}
	self:UpdateSpellList()

	-- Setup our visual style
	if( self.db.profile.showBars and self.modules.Bars ) then
		self.visual = self.modules.Bars:LoadVisual()
		self.currentVisual = "bars"
	elseif( self.modules.Icons ) then
		self.visual = self.modules.Icons:LoadVisual()
		self.currentVisual = "icons"
	end
	
	-- Debug, something went wrong
	if( not self.visual ) then
		self:UnregisterAllEvents()
		return
	end

	-- Monitor for zone change
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "ZONE_CHANGED_NEW_AREA")
	
	-- Quick check
	self:ZONE_CHANGED_NEW_AREA()

	-- Middle of screen alert frame
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

function Afflicted:OnEnable()
	local type = select(2, IsInInstance())
	if( not self.db.profile.inside[type] ) then
		return
	end
		
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

function Afflicted:OnDisable()
	self:UnregisterAllEvents()
	
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "ZONE_CHANGED_NEW_AREA")
end

function Afflicted:Reload()
	self:OnDisable()

	-- Check to see if we should enable it
	local type = select(2, IsInInstance())
	if( self.db.profile.inside[type] ) then
		self:OnEnable()
	end
	
	self.visual:ReloadVisual()
	self:UpdateSpellList()
end

local COMBATLOG_OBJECT_TYPE_PLAYER = COMBATLOG_OBJECT_TYPE_PLAYER
local COMBATLOG_OBJECT_REACTION_FRIENDLY = COMBATLOG_OBJECT_REACTION_FRIENDLY
local COMBATLOG_OBJECT_AFFILIATION_MINE = COMBATLOG_OBJECT_AFFILIATION_MINE
local COMBATLOG_OBJECT_AFFILIATION_PARTY = COMBATLOG_OBJECT_AFFILIATION_PARTY
local COMBATLOG_OBJECT_AFFILIATION_RAID = COMBATLOG_OBJECT_AFFILIATION_RAID
local COMBATLOG_OBJECT_REACTION_HOSTILE	= COMBATLOG_OBJECT_REACTION_HOSTILE
local GROUP_AFFILIATION = bit.bor(COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_TYPE_PLAYER, COMBATLOG_OBJECT_AFFILIATION_MINE, COMBATLOG_OBJECT_AFFILIATION_PARTY, COMBATLOG_OBJECT_AFFILIATION_RAID)

local eventRegistered = {["SPELL_AURA_APPLIED"] = true, ["SPELL_AURA_REMOVED"] = true, ["SPELL_SUMMON"] = true, ["SPELL_CREATE"] = true, ["SPELL_INTERRUPT"] = true, ["SPELL_MISSED"] = true, ["SPELL_DAMAGE"] = true, ["SPELL_DRAIN"] = true, ["SPELL_LEECH"] = true, ["SPELL_DISPEL_FAILED"] = true, ["SPELL_PERIODIC_DISPEL_FAILED"] = true, ["SPELL_AURA_DISPELLED"] = true, ["SPELL_AURA_STOLEN"] = true, ["PARTY_KILL"] = true, ["UNIT_DIED"] = true}
function Afflicted:COMBAT_LOG_EVENT_UNFILTERED(event, timestamp, eventType, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, ...)
	if( not eventRegistered[eventType] ) then
		return

	end
	

	local isDestEnemy = (bit.band(destFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE)
	local isDestGroup = (bit.band(destFlags, GROUP_AFFILIATION) > 0)
	local isSourceEnemy = (bit.band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE)
	local isSourceGroup = (bit.band(sourceFlags, GROUP_AFFILIATION) > 0)
			
	-- Buff gained on an enemy, or a debuff gained from an enemy from someone in our group
	if( eventType == "SPELL_AURA_APPLIED" ) then
		local spellID, spellName, spellSchool, auraType = ...
		
		-- Group member gained a debuff
		if( auraType == "DEBUFF" and isDestGroup ) then
			self:ProcessAbility(eventType .. auraType, spellID, spellName, spellSchool, destGUID, "", destGUID, destName)
			
		-- Enemy gained a buff
		elseif( auraType == "BUFF" and isDestEnemy ) then
			self:ProcessAbility(eventType .. auraType, spellID, spellName, spellSchool, destGUID, destName, destGUID, destName)
		end
	
	-- Buff faded from an enemy
	elseif( eventType == "SPELL_AURA_REMOVED" and isDestEnemy ) then
		local spellID, spellName, spellSchool, auraType = ...
		if( auraType == "BUFF" ) then
			self:AbilityEnded(eventType, spellID, spellName, destGUID, destName)
		end
	
	-- Check for something being summoned (Pets)
	elseif( eventType == "SPELL_SUMMON" and isSourceEnemy ) then
		local spellID, spellName, spellSchool = ...
		self:ProcessAbility(eventType, spellID, spellName, spellSchool, sourceGUID, sourceName, sourceGUID, sourceName)
	
	-- Check for something being created (Traps, ect)
	elseif( eventType == "SPELL_CREATE" and isSourceEnemy ) then
		local spellID, spellName, spellSchool = ...
		self:ProcessAbility(eventType, spellID, spellName, spellSchool, sourceGUID, sourceName, sourceGUID, sourceName)
	
	-- We got interrupted, or we interrupted someone else
	elseif( eventType == "SPELL_INTERRUPT" ) then
		local spellID, spellName, spellSchool, extraSpellID, extraSpellName, extraSpellSchool = ...
	
		-- We interrupted an enemy
		if( isDestEnemy and bit.band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) == COMBATLOG_OBJECT_AFFILIATION_MINE ) then
			self:SendMessage(string.format(L["Interrupted %s's %s (%s)"], destName, extraSpellName, spellSchools[extraSpellSchool] or ""), self.db.profile.interruptDest, self.db.profile.interruptColor, extraSpellID)
		
		-- Someone in our group was interrupted
		elseif( isSourceEnemy and isDestGroup ) then
			self:ProcessAbility(eventType, spellID, spellName, spellSchool, sourceGUID, sourceName, destGUID, destName)
		end

	-- Basically we can lump all of these into the same category, spell used/drained/leech/missed
	elseif( eventType == "SPELL_MISSED" or eventType == "SPELL_DAMAGE" or eventType == "SPELL_DRAIN" or eventType == "SPELL_LEECH" ) then
		local spellID, spellName, spellSchool = ...
		if( isSourceEnemy and isDestGroup ) then
			self:ProcessAbility(eventType, spellID, spellName, spellSchool, sourceGUID, sourceName, destGUID, destName)
		end
		
	-- We tried to dispel a buff, and failed
	elseif( eventType == "SPELL_DISPEL_FAILED" or eventType == "SPELL_PERIODIC_DISPEL_FAILED" ) then
		local spellID, spellName, spellSchool, extraSpellID, extraSpellName, extraSpellSchool, auraType = ...
		
		if( not isDestEnemy or ( isDestEnemy and not self.db.profile.dispelHostile ) ) then
			if( bit.band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) == COMBATLOG_OBJECT_AFFILIATION_MINE ) then
				self:SendMessage(string.format(L["FAILED %s's %s"], self:StripServer(destName), extraSpellName), self.db.profile.dispelDest, self.db.profile.dispelColor, extraSpellID)
			end
		end
	
	-- Managed to dispel or steal a buff
	elseif( eventType == "SPELL_AURA_DISPELLED" or eventType == "SPELL_AURA_STOLEN" ) then
		local spellID, spellName, spellSchool, extraSpellID, extraSpellName, extraSpellSchool, auraType = ...
		
		if( not isDestEnemy or ( isDestEnemy and not self.db.profile.dispelHostile ) ) then
			if( bit.band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) == COMBATLOG_OBJECT_AFFILIATION_MINE ) then
				self:SendMessage(string.format(L["Removed %s's %s"], self:StripServer(destName), extraSpellName), self.db.profile.dispelDest, self.db.profile.dispelColor, extraSpellID)
			end
		end
	
	-- Check if we should clear timers
	elseif( eventType == "PARTY_KILL" and isDestEnemy ) then
		self:UnitDied(destGUID, destName)
		
	-- Don't use UNIT_DIED inside arenas due to accuracy issues, outside of arenas we don't care too much
	elseif( instanceType ~= "arena" and eventType == "UNIT_DIED" and isDestEnemy ) then
		self:UnitDied(destGUID, destName)
	end

end

-- Merge spells in
function Afflicted:UpdateSpellList()
	self.spellList = AfflictedSpells

	-- Merge in the players spells
	for name, data in pairs(self.db.profile.spells) do
		if( type(data) == "table" ) then
			self.spellList[name] = data
		else
			self.spellList[name] = nil
		end
	end
end

-- See if we should enable Afflicted in this zone
function Afflicted:ZONE_CHANGED_NEW_AREA()
	local type = select(2, IsInInstance())

	if( type ~= instanceType ) then
		-- Clear anchors because we changed zones
		for key in pairs(self.db.profile.anchors) do
			self.visual:ClearTimers(key)
		end
		
		-- Check if it's supposed to be enabled in this zone
		if( self.db.profile.inside[type] ) then
			self:OnEnable()
		else
			self:OnDisable()
		end
	end
		
	instanceType = type
end

-- New ability found
function Afflicted:ProcessAbility(eventType, spellID, spellName, spellSchool, sourceGUID, sourceName, destGUID, destName)
	local spellData = self.spellList[spellID] or self.spellList[spellName]
	
	-- Check if we're monitoring this spell
	if( not spellData or spellData.disabled or ( eventType == "SPELL_AURA_APPLIEDDEBUFF" and not spellData.checkDebuff ) ) then
		return
	end
	
	local anchor = self.db.profile.anchors[spellData.showIn]
	

	-- Check if this spell is enabled, and the anchors enabled
	if( not anchor or not anchor.enabled ) then
		return
	end

	local id = spellID .. sourceGUID
	local debuffID = spellID .. destGUID
	local time = GetTime()
		
	-- Check/set single trigger limits
	if( playerLimit[id] and playerLimit[id] >= time ) then
		return
	end

	if( spellData.singleLimit and spellData.singleLimit > 0 ) then
		playerLimit[id] = time + spellData.singleLimit
	end	
	
	-- Check/set global trigger limits
	if( ( globalLimit[debuffID] and globalLimit[debuffID] >= time ) or ( globalLimit[spellID] and globalLimit[spellID] >= time ) ) then
		return
	end

	if( spellData.globalLimit and spellData.globalLimit > 0 ) then
		globalLimit[spellID] = time + spellData.globalLimit
	end
	
	-- Spell interrupts generally have another component that you see after, like damage or a debuff. So don't let two timers show
	if( eventType == "SPELL_INTERRUPT" and ( not spellData.singleLimit or spellData.singleLimit < 2 ) ) then
		playerLimit[id] = time + 1
	end
	
	-- If we have to check debuffs, it means we need a global limit on the specific spellID + destGUID to prevent two timers
	if( spellData.checkDebuff and ( not spellData.globalLimit or spellData.globalLimit < 1.5 ) ) then
		globalLimit[debuffID] = GetTime() + 1
	end
	
	-- Check if it's a linked spell
	if( spellData.linkedTo and spellData.linkedTo ~= "" ) then
		for i=#(anchorFrame.active), 1, -1 do
			local row = anchorFrame.active[i]
			if( ( row.spellName == spellData.linkedTo or row.spellID == spellData.linkedTo ) and row.destGUID == destGUID ) then
				return
			end
		end
	end
	
	-- Check if we need to update the icon
	local icon = spellData.icon
	if( not icon or icon == "" or string.match(icon, "INV_Misc_QuestionMark$") ) then
		local spellIcon = select(3, GetSpellInfo(spellID))
		if( spellIcon ) then
			icon = spellIcon
			-- Store it now that we know it
			local spellSV = self.db.profile.spells[spellID] or self.db.profile.spells[spellName]
			
			-- We don't have a valid SV yet, so copy it in
			if( not spellSV ) then
				local key = spellName
				if( self.spellList[spellID] ) then
					key = spellID
				end
				
				self.db.profile.spells[key] = {}
				for k, v in pairs(self.spellList[key]) do
					self.db.profile.spells[key][k] = v
				end
				
				spellSV = self.db.profile.spells[key]
			end
			
			-- Store the new icon
			if( spellSV ) then
				spellSV.icon = icon
			end
		end
	end
	
	-- Start it up
	self.visual:CreateTimer(spellData, eventType, spellID, spellName, sourceGUID, sourceName, destGUID)

	-- Announce it
	if( anchor.announce and eventType ~= "TEST" ) then
		-- Work out if we should use a custom message, or a default one
		local msg
		if( spellData.enableCustom ) then
			msg = spellData.triggeredMessage
			
			-- No message given, so just exist
			if( msg == "" ) then
				return
			end
			
		elseif( eventType == "SPELL_AURA_APPLIEDDEBUFF" or eventType == "SPELL_AURA_APPLIEDBUFF" or eventType == "SPELL_AURA_REMOVED" ) then
			msg = anchor.gainMessage
		else
			msg = anchor.usedMessage
		end	

		msg = string.gsub(msg, "*spell", spellName)
		msg = string.gsub(msg, "*target", self:StripServer(sourceName))
		
		self:SendMessage(msg, anchor.announceDest, anchor.announceColor, spellID)
	end
end

-- Ability ended due to event, or timers up
function Afflicted:AbilityEnded(eventType, spellID, spellName, sourceGUID, sourceName, isTimedOut)
	local spellData = self.spellList[spellID] or self.spellList[spellName]
	if( not spellData ) then
		return
	end
	
	local anchor = self.db.profile.anchors[spellData.showIn]
	if( not anchor or not anchor.enabled or spellData.disabled or (spellData.dontFade and not isTimedOut) ) then
		return
	end
	
	-- Remove the timer
	local removed = self.visual:RemoveTimer(spellData.showIn, spellID, sourceGUID)
	if( not removed ) then
		return
	end
	
	-- Unlock the limiter early
	playerLimit[spellID .. sourceGUID] = nil

	-- Announce it
	if( anchor.announce and eventType ~= "TEST" ) then
		-- Work out if we should use a custom message, or a default one
		local msg
		if( spellData.enableCustom ) then
			msg = spellData.fadedMessage
			-- No message, exit quickly
			if( msg == "" ) then
				return
			end
			
		elseif( eventType == "SPELL_AURA_APPLIEDDEBUFF" or eventType == "SPELL_AURA_APPLIEDBUFF" or eventType == "SPELL_AURA_REMOVED" ) then
			msg = anchor.fadeMessage
		else
			msg = anchor.readyMessage
		end
		
		msg = string.gsub(msg, "*spell", spellName)
		msg = string.gsub(msg, "*target", self:StripServer(sourceName))
		
		self:SendMessage(msg, anchor.announceDest, anchor.announceColor, spellID)
	end
end

-- Check if we should remove the timers due to them dying
function Afflicted:UnitDied(destGUID)
	-- Loop through all created anchors
	for anchorName in pairs(self.db.profile.anchors) do
		local frame = self[anchorName]
		if( frame and #(frame.active) > 0 ) then
			-- Now through all active timers
			for i=#(frame.active), 1, -1 do
				local row = frame.active[i]

				if( row.sourceGUID == destGUID and not row.dontFade ) then
					row:Hide()

					table.insert(frame.inactive, row)
					table.remove(frame.active, i)

					playerLimit[row.id] = nil
				end
			end

			-- No more icons, hide the base frame
			if( #(frame.active) == 0 ) then
				frame:Hide()
			end

			-- Reposition everything
			self:RepositionTimers(frame)
		end
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

-- See if we should wrap an icon stuff around this
function Afflicted:WrapIcon(msg, dest, spellID)
	if( not self.db.profile.showIcons or not spellID ) then
		return msg
	end
	
	-- Make sure we have a valid icon
	local icon = select(3, GetSpellInfo(spellID))
	if( not icon ) then
		return msg
	end
	
	-- CT or RWFrame can be bigger due to more room
	local size = 12
	if( dest == "ct" ) then
		size = 18	
	elseif( dest == "rwframe" ) then
		size = select(2, self.alertFrame:GetFont())
	end

	return string.format("|T%s:0:0|t %s", icon, msg)
end

function Afflicted:SendMessage(msg, dest, color, spellID)
	if( dest == "none" ) then
		return

	end
	

	-- We're ungrouped, so redirect it to RWFrame
	if( dest == "rw" and GetNumRaidMembers() == 0 and GetNumPartyMembers() == 0 ) then
		dest = "rwframe"
	-- We're grouped, in a raid and not leader or assist
	elseif( dest == "rw" and not IsRaidLeader() and not IsRaidOfficer() and GetNumRaidMembers() > 0 ) then
		dest = "party"
	end
	
	-- Strip out any () leftover from no name being given
	msg = string.trim(string.gsub(msg, "%(%)", ""))
		
	-- Chat frame
	if( tonumber(dest) ) then
		local frame = getglobal("ChatFrame" .. dest) or DEFAULT_CHAT_FRAME
		frame:AddMessage("|cff33ff99Afflicted|r|cffffffff:|r " .. self:WrapIcon(msg, dest, spellID), color.r, color.g, color.b)
	-- Raid warning announcement to raid/party
	elseif( dest == "rw" ) then
		SendChatMessage(msg, "RAID_WARNING")
	-- Raid warning frame, will not send it out to the party
	elseif( dest == "rwframe" ) then
		self.alertFrame:AddMessage(self:WrapIcon(msg, dest, spellID), color.r, color.g, color.b)
	-- Party chat
	elseif( dest == "party" ) then
		SendChatMessage(msg, "PARTY")
	-- Combat text
	elseif( dest == "ct" ) then
		self:CombatText(self:WrapIcon(msg, dest, spellID), color)
	end
end

function Afflicted:CombatText(text, color, spellID)	
	-- SCT
	if( IsAddOnLoaded("sct") ) then
		SCT:DisplayText(text, color, nil, "event", 1)
	-- MSBT
	elseif( IsAddOnLoaded("MikScrollingBattleText") ) then
		MikSBT.DisplayMessage(text, MikSBT.DISPLAYTYPE_NOTIFICATION, false, color.r * 255, color.g * 255, color.b * 255)		
	-- Parrot
	elseif( IsAddOnLoaded("Parrot") ) then
		Parrot:ShowMessage(text, nil, nil, color.r, color.g, color.b)
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
	DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99Afflicted|r: " .. msg)
end