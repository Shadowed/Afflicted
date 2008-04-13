Afflicted = LibStub("AceAddon-3.0"):NewAddon("Afflicted", "AceEvent-3.0")

local L = AfflictedLocals

local instanceType

local timerLimits = {}
local spellSchools = {[1] = L["Physical"], [2] = L["Holy"], [4] = L["Fire"], [8] = L["Nature"], [16] = L["Frost"], [32] = L["Shadow"], [64] = L["Arcane"]}

function Afflicted:OnInitialize()
	self.SML = LibStub:GetLibrary("LibSharedMedia-3.0")
	self.revision = tonumber(string.match("$Revision$", "(%d+)") or 1)
	self.modules.Config:SetupDB()
	
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
end

local COMBATLOG_OBJECT_TYPE_PLAYER = COMBATLOG_OBJECT_TYPE_PLAYER
local COMBATLOG_OBJECT_REACTION_FRIENDLY = COMBATLOG_OBJECT_REACTION_FRIENDLY
local COMBATLOG_OBJECT_AFFILIATION_MINE = COMBATLOG_OBJECT_AFFILIATION_MINE
local COMBATLOG_OBJECT_AFFILIATION_PARTY = COMBATLOG_OBJECT_AFFILIATION_PARTY
local COMBATLOG_OBJECT_AFFILIATION_RAID = COMBATLOG_OBJECT_AFFILIATION_RAID
local COMBATLOG_OBJECT_REACTION_HOSTILE	= COMBATLOG_OBJECT_REACTION_HOSTILE
local GROUP_AFFILIATION = bit.bor(COMBATLOG_OBJECT_AFFILIATION_PARTY, COMBATLOG_OBJECT_AFFILIATION_RAID, COMBATLOG_OBJECT_AFFILIATION_MINE)

local eventRegistered = {["SPELL_CAST_SUCCESS"] = true, ["SPELL_AURA_APPLIED"] = true, ["SPELL_AURA_REMOVED"] = true, ["SPELL_SUMMON"] = true, ["SPELL_CREATE"] = true, ["SPELL_INTERRUPT"] = true, ["SPELL_MISSED"] = true, ["SPELL_DAMAGE"] = true, ["SPELL_DRAIN"] = true, ["SPELL_LEECH"] = true, ["SPELL_DISPEL_FAILED"] = true, ["SPELL_PERIODIC_DISPEL_FAILED"] = true, ["SPELL_AURA_DISPELLED"] = true, ["SPELL_AURA_STOLEN"] = true, ["PARTY_KILL"] = true, ["UNIT_DIED"] = true}
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
			self:ProcessAbility(eventType .. auraType .. "GROUP", spellID, spellName, spellSchool, destGUID, "", destGUID, destName)
			
		-- Enemy gained a buff or debuff
		elseif( isDestEnemy ) then
			self:ProcessAbility(eventType .. auraType .. "ENEMY", spellID, spellName, spellSchool, destGUID, destName, destGUID, destName)
		end
	
	-- Buff faded from an enemy
	elseif( eventType == "SPELL_AURA_REMOVED" and isDestEnemy ) then
		local spellID, spellName, spellSchool, auraType = ...
		self:AbilityEnded(eventType .. auraType .. "ENEMY", spellID, spellName, destGUID, destName)

	-- Spell casted succesfully
	elseif( eventType == "SPELL_CAST_SUCCESS" and isSourceEnemy ) then
		local spellID, spellName, spellSchool, auraType = ...
		self:ProcessAbility(eventType, spellID, spellName, spellSchool, sourceGUID, sourceName, destGUID, destName)
	
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
		if( self.db.profile.interruptEnabled and isDestEnemy and bit.band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) == COMBATLOG_OBJECT_AFFILIATION_MINE ) then
			self:SendMessage(string.format(L["Interrupted %s's %s (%s)"], destName, extraSpellName, spellSchools[extraSpellSchool] or ""), self.db.profile.interruptDest, self.db.profile.interruptColor, extraSpellID)
		
		-- Someone in our group was interrupted
		elseif( isSourceEnemy and isDestGroup ) then
			self:ProcessAbility(eventType, spellID, spellName, spellSchool, sourceGUID, sourceName, destGUID, destName)
		end

	-- Basically we can lump all of these into the same category, spell used/drained/leech/missed
	elseif( eventType == "SPELL_MISSED" or eventType == "SPELL_DAMAGE" or eventType == "SPELL_DRAIN" or eventType == "SPELL_LEECH" ) then
		local spellID, spellName, spellSchool = ...
		if( isSourceEnemy and isDestGroup ) then
			self:ProcessAbility("SPELL_MISC", spellID, spellName, spellSchool, sourceGUID, sourceName, destGUID, destName)
		end
				
	-- We tried to dispel a buff, and failed
	elseif( eventType == "SPELL_DISPEL_FAILED" or eventType == "SPELL_PERIODIC_DISPEL_FAILED" ) then
		local spellID, spellName, spellSchool, extraSpellID, extraSpellName, extraSpellSchool, auraType = ...
		
		if( not isDestEnemy or ( isDestEnemy and self.db.profile.dispelHostile ) ) then
			if( bit.band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) == COMBATLOG_OBJECT_AFFILIATION_MINE ) then
				self:SendMessage(string.format(L["FAILED %s's %s"], self:StripServer(destName), extraSpellName), self.db.profile.dispelDest, self.db.profile.dispelColor, extraSpellID)
			end
		end
	
	-- Managed to dispel or steal a buff
	elseif( eventType == "SPELL_AURA_DISPELLED" or eventType == "SPELL_AURA_STOLEN" ) then
		local spellID, spellName, spellSchool, extraSpellID, extraSpellName, extraSpellSchool, auraType = ...
		
		if( not isDestEnemy or ( isDestEnemy and self.db.profile.dispelHostile ) ) then
			if( bit.band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) == COMBATLOG_OBJECT_AFFILIATION_MINE ) then
				self:SendMessage(string.format(L["Removed %s's %s"], self:StripServer(destName), extraSpellName), self.db.profile.dispelDest, self.db.profile.dispelColor, extraSpellID)
			end
		end
	
	-- Check if we should clear timers
	elseif( eventType == "PARTY_KILL" and isDestEnemy ) then
		self.visual:UnitDied(destGUID, destName)

	-- Don't use UNIT_DIED inside arenas due to accuracy issues, outside of arenas we don't care too much
	elseif( instanceType ~= "arena" and eventType == "UNIT_DIED" and isDestEnemy ) then
		self.visual:UnitDied(destGUID, destName)
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
	local spellData = self.db.profile.spells[spellID] or self.db.profile.spells[spellName]
	-- If it's a number, it means it's a lower ranked spell we want to actually link with the max rank one
	if( type(spellData) == "number" ) then
		spellData = self.db.profile.spells[spellData]
	end
	
	if( not spellData or spellData.disabled or ( eventType ~= "TEST" and not spellData[eventType] ) ) then
		return
	end
	
	-- Check if it matches our target/focus only
	if( self.db.profile.showTarget and UnitGUID("target") ~= sourceGUID and UnitGUID("focus") ~= sourceGUID and eventType ~= "TEST" ) then
		return
	end
	
	local anchor = self.db.profile.anchors[spellData.showIn]
	if( not anchor or not anchor.enabled ) then
		return
	end
	
	-- Trigger limits
	local id = spellID .. sourceGUID
	local debuffID = spellID .. destGUID
	local nameID = spellName .. sourceGUID
	local time = GetTime()
	
	if( ( timerLimits[nameID] and timerLimits[nameID] >= time ) or ( timerLimits[id] and timerLimits[id] >= time ) or ( timerLimits[debuffID] and timerLimits[debuffID] >= time ) or ( timerLimits[spellID] and timerLimits[spellID] >= time ) ) then
		return
	end
	
	if( spellData.singleLimit > 0 ) then
		timerLimits[id] = time + spellData.singleLimit
	end
	
	if( spellData.globalLimit > 0 ) then
		timerLimits[spellID] = time + spellData.globalLimit

		-- Handle the special case of things like Shadowstep, where the spellID's are different, but the names are the same.
		if( eventType == "SPELL_AURA_APPLIEDBUFFENEMY" ) then
			timerLimits[nameID] = time + spellData.globalLimit
		end
	end
		
	-- Linked spells mean that while the timer still exists we don't trigger another of it
	if( spellData.linkedTo and spellData.linkedTo ~= "" and self.visual:TimerExists(spellData, spellID, sourceGUID, destGUID) ) then
		return
	end
	
	-- If we have no icon, or we're using the question mark one then update the SV with the new one
	local icon = spellData.icon
	if( not icon or icon == "" or string.match(icon, "INV_Misc_QuestionMark$") ) then
		local spellIcon = select(3, GetSpellInfo(spellID))
		if( spellIcon ) then
			icon = spellIcon
			spellData.icon = icon
		end
	end
	
	-- Save the spell name if it's a spellID-saved var
	local text = GetSpellInfo(spellID)
	if( text ) then
		spellData.text = text
	end
	
	-- Start it up
	self.visual:CreateTimer(spellData, eventType, spellID, spellName, sourceGUID, sourceName, destGUID)

	-- Announce it
	if( anchor.announce and eventType ~= "TEST" ) then
		-- Work out if we should use a custom message, or a default one
		local msg
		if( spellData.enableCustom ) then
			msg = spellData.triggeredMessage
		elseif( eventType == "SPELL_AURA_APPLIEDDEBUFFGROUP" or eventType == "SPELL_AURA_APPLIEDBUFFENEMY" or eventType == "SPELL_AURA_APPLIEDDEBUFFENEMY" ) then
			msg = anchor.gainMessage
		else
			msg = anchor.usedMessage
		end	
		
		if( not msg or msg == "" ) then
			return
		end
		
		msg = string.gsub(msg, "*spell", spellName)
		msg = string.gsub(msg, "*target", self:StripServer(sourceName))
		
		self:SendMessage(msg, anchor.announceDest, anchor.announceColor, spellID)
	end
end

-- Ability ended due to event, or timers up
function Afflicted:AbilityEnded(eventType, spellID, spellName, sourceGUID, sourceName, isTimedOut)
	local spellData = self.db.profile.spells[spellID] or self.db.profile.spells[spellName]
	-- If it's a number, it means it's a lower ranked spell we want to actually link with the max rank one
	if( type(spellData) == "number" ) then
		spellData = self.db.profile.spells[spellData]
	end

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
	timerLimits[spellID .. sourceGUID] = nil

	-- Announce it
	if( anchor.announce and eventType ~= "TEST" ) then
		-- Work out if we should use a custom message, or a default one
		local msg
		if( spellData.enableCustom ) then
			msg = spellData.fadedMessage
		elseif( eventType == "SPELL_AURA_APPLIEDDEBUFFGROUP" or eventType == "SPELL_AURA_APPLIEDBUFFENEMY" or eventType == "SPELL_AURA_APPLIEDDEBUFFENEMY" or eventType == "SPELL_AURA_REMOVED" ) then
			msg = anchor.fadeMessage
		else
			msg = anchor.readyMessage
		end

		if( not msg or msg == "" ) then
			return
		end
		
		msg = string.gsub(msg, "*spell", spellName)
		msg = string.gsub(msg, "*target", self:StripServer(sourceName))
		
		self:SendMessage(msg, anchor.announceDest, anchor.announceColor, spellID)
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
	DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99Afflicted2|r: " .. msg)
end