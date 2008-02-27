Afflicted = LibStub("AceAddon-3.0"):NewAddon("Afflicted", "AceEvent-3.0")

local L = AfflictedLocals

local instanceType
local playerName

local playerLimit = {}
local globalLimit = {}

local ICON_SIZE = 20
local POSITION_SIZE = ICON_SIZE + 2

function Afflicted:OnInitialize()
	self.defaults = {
		profile = {
			showAnchors = true,
			showIcon = true,
			dispelEnabled = true,
			dispelHostile = true,
			dispelDest = "1",
			dispelColor = { r = 1, g = 1, b = 1 },
			interruptEnabled = true,
			interruptDest = "rwframe",
			interruptColor = { r = 1, g = 1, b = 1 },
			anchors = {
				["Spell"] = {
					enabled = true,
					announce = true,
					growUp = false,
					announceColor = { r = 1.0, g = 1.0, b = 1.0 },
					announceDest = "1",
					scale = 1.0,
					abbrev = "S",
					text = L["Spells"],
				},
				["Buff"] = {
					enabled = true,
					announce = true,
					growUp = false,
					announceColor = { r = 1.0, g = 1.0, b = 1.0 },
					announceDest = "1",
					scale = 1.0,
					abbrev = "B",
					text = L["Buffs"],
				},
			},
			spells = {},
			inside = {["arena"] = true, ["pvp"] = true},
			spellDefault = {
				seconds = 0,
				icon = "Interface\\Icons\\INV_Misc_QuestionMark",
				showIn = "spell",
				linekdTo = "",
			},
		},
	}

	self.db = LibStub:GetLibrary("AceDB-3.0"):New("AfflictedDB", self.defaults)
	self.revision = tonumber(string.match("$Revision$", "(%d+)") or 1)
	
	playerName = UnitName("player")
		
	-- Create display frames!
	for key in pairs(self.db.profile.anchors) do
		if( not self[key] ) then
			self[key] = self:CreateDisplay(key)
		end
	end
	
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
	
	-- Update anchors and icons inside
	for key, data in pairs(self.db.profile.anchors) do
		local frame = self[key]
		if( frame ) then
			-- Update frame scale
			frame:SetScale(data.scale)

			-- Update icon scale
			for _, frame in pairs(frame.active) do
				frame:SetScale(data.scale)
			end

			for _, frame in pairs(frame.inactive) do
				frame:SetScale(data.scale)
			end

			-- Update anchor visibility
			self:UpdateAnchor(frame)

			-- Annnd make sure it's shown or hidden
			if( self.db.profile.showAnchors ) then
				frame:Show()
			elseif( #(frame.active) == 0 ) then
				frame:Hide()
			end
		end
	end

	-- Mergy
	self:UpdateSpellList()
end

local GROUP_AFFILIATION = bit.bor(COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_TYPE_PLAYER, COMBATLOG_OBJECT_AFFILIATION_MINE, COMBATLOG_OBJECT_AFFILIATION_PARTY, COMBATLOG_OBJECT_AFFILIATION_RAID)

--[31:58] <Elsia> i.e. something like if band(flags,hostile) == hostile and band(flags,npc+object)==0 then
-- Need to clean this up a bit
function Afflicted:COMBAT_LOG_EVENT_UNFILTERED(event, timestamp, eventType, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, ...)			
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
	elseif( eventType == "SPELL_AURA_REMOVED" ) then
		local spellID, spellName, spellSchool, auraType = ...
		if( auraType == "BUFF" and isDestEnemy ) then
			self:AbilityEnded(eventType, spellId, spellName, destGUID, destName)
		end
	
	-- We got interrupted, or we interrupted someone else
	elseif( eventType == "SPELL_INTERRUPT" ) then
		local spellID, spellName, spellSchool, extraSpellID, extraSpellName, extraSpellSchool = ...
	
		-- We interrupted an enemy
		if( isDestEnemy and bit.band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) == COMBATLOG_OBJECT_AFFILIATION_MINE ) then
			self:SendMessage(string.format(L["Interrupted %s's %s (%s)"], destName, spellName, spellSchool), self.db.profile.interruptDest, self.db.profile.interruptColor, spellID)
		
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
				self:SendMessage(string.format(L["FAILED %s's %s"], self:StripServer(destName), extraSpellName, spellName), self.db.profile.dispelDest, self.db.profile.dispelColor, extraSpellID)
			end
		end
	
	-- Managed to dispel or steal a buff
	elseif( eventType == "SPELL_AURA_DISPELLED" or eventType == "SPELL_AURA_STOLEN" ) then
		local spellID, spellName, spellSchool, extraSpellID, extraSpellName, extraSpellSchool, auraType = ...
		
		if( not isDestEnemy or ( isDestEnemy and not self.db.profile.dispelHostile ) ) then
			if( bit.band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) == COMBATLOG_OBJECT_AFFILIATION_MINE ) then
				self:SendMessage(string.format(L["Removed %s's %s"], self:StripServer(destName), extraSpellName, spellName), self.db.profile.dispelDest, self.db.profile.dispelColor, extraSpellID)
			end
		end
	end
end

-- Update anchor visibility
function Afflicted:UpdateAnchor(frame)
	if( self.db.profile.showAnchors ) then
		frame:EnableMouse(true)
		frame:SetBackdropColor(0.0, 0.0, 0.0, 1.0)
		frame:SetBackdropBorderColor(0.90, 0.90, 0.90, 1.0)
		frame.text:Show()
	else
		frame:EnableMouse(false)
		frame:SetBackdropColor(0.0, 0.0, 0.0, 0.0)
		frame:SetBackdropBorderColor(0.90, 0.90, 0.90, 0.0)
		frame.text:Hide()
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
			if( self[key] ) then
				self:ClearTimers(self[key])
			end
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

-- Dragging functions
local function OnDragStart(self)
	if( IsAltKeyDown() ) then
		self.isMoving = true
		self:StartMoving()
	end
end

local function OnDragStop(self)
	if( self.isMoving ) then
		self.isMoving = nil
		self:StopMovingOrSizing()
		
		if( not Afflicted.db.profile.anchors[self.type].position ) then
			Afflicted.db.profile.anchors[self.type].position = { x = 0, y = 0 }
		end
		
		local scale = self:GetEffectiveScale()
		Afflicted.db.profile.anchors[self.type].position.x = self:GetLeft() * scale
		Afflicted.db.profile.anchors[self.type].position.y = self:GetTop() * scale
	end
end

local function OnShow(self)
	local position = Afflicted.db.profile.anchors[self.type].position
	

	if( position ) then
		local scale = self:GetEffectiveScale()
		self:ClearAllPoints()
		self:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", position.x / scale, position.y / scale)
	else
		self:ClearAllPoints()
		self:SetPoint("CENTER", UIParent, "CENTER")
	end
end

-- Create our main display frame
local backdrop = {bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		tileSize = 9,
		edgeSize = 9,
		insets = { left = 2, right = 2, top = 2, bottom = 2 }}

function Afflicted:CreateDisplay(type)
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetWidth(ICON_SIZE + 2)
	frame:SetHeight(ICON_SIZE + 2)
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:SetClampedToScreen(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScale(self.db.profile.anchors[type].scale)
	frame:SetBackdrop(backdrop)
	frame:SetBackdropColor(0.0, 0.0, 0.0, 1.0)
	frame:SetBackdropBorderColor(0.90, 0.90, 0.90, 1.0)
	frame:SetScript("OnDragStart", OnDragStart)
	frame:SetScript("OnDragStop", OnDragStop)
	frame:SetScript("OnShow", OnShow)
	frame:Hide()
	
	frame.active = {}
	frame.inactive = {}
	frame.type = type	

	-- Display name
	frame.text = frame:CreateFontString(nil, "OVERLAY")
	frame.text:SetPoint("CENTER", frame)
	frame.text:SetFontObject(GameFontHighlight)
	frame.text:SetText(self.db.profile.anchors[type].abbrev)
	
	self:UpdateAnchor(frame)
	return frame
end

-- Update icon timer
local function onUpdate(self, elapsed)
	local time = GetTime()
	self.timeLeft = self.timeLeft - (time - self.lastUpdate)
	self.lastUpdate = time
	
	if( self.timeLeft <= 0 ) then
		Afflicted:AbilityEnded(self.eventType, self.spellID, self.spellName, self.sourceGUID, self.sourceName, true)
		return
	end
	
	if( self.timeLeft > 10 ) then
		self.text:SetFormattedText("%d", self.timeLeft)
	else
		self.text:SetFormattedText("%.1f", self.timeLeft)
	end
end

-- Create our little icon frame
function Afflicted:CreateRow(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetWidth(50)
	frame:SetHeight(ICON_SIZE)
	frame:SetScript("OnUpdate", onUpdate)
	frame:SetScale(parent:GetScale())
	frame:SetClampedToScreen(true)
	frame:Hide()
	
	frame.icon = frame:CreateTexture(nil, "BACKGROUND")
	frame.icon:SetWidth(ICON_SIZE)
	frame.icon:SetHeight(ICON_SIZE)
	frame.icon:SetPoint("LEFT")
	
	frame.text = frame:CreateFontString(nil, "BACKGROUND")
	frame.text:SetFontObject(GameFontHighlight)
	frame.text:SetPoint("LEFT", ICON_SIZE + 2, 0)
	
	return frame
end

-- Reposition the passed frames timers
function Afflicted:RepositionTimers(parent)
	-- Flip the modifier so we can change between going top -> bottom and bottom -> top
	local mod = -1
	if( self.db.profile.anchors[parent.type].growUp ) then
		mod = 1
	end

	-- Reposition everything
	for id, frame in pairs(parent.active) do
		frame:ClearAllPoints()
		frame:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 2, mod * POSITION_SIZE * id)
	end
end

-- Remove every timer
function Afflicted:ClearTimers(parent)
	for i=#(parent.active), 1, -1 do
		parent.active[i]:Hide()
		
		playerLimit[parent.active[i].id] = nil
		
		table.insert(parent.inactive, parent.active[i])
		table.remove(parent.active, i)
	end
	
	parent:Hide()
end

-- Sort timers by time left
local function sortTimers(a, b)
	return a.timeLeft < b.timeLeft
end

-- New ability found
function Afflicted:ProcessAbility(eventType, spellID, spellName, spellSchool, sourceGUID, sourceName, destGUID, destName)
	local spellData = self.spellList[spellID] or self.spellList[spellName]
	
	-- Check if we're monitoring this spell
	if( not spellData or spellData.disabled or ( eventType == "SPELL_AURA_APPLIEDDEBUFF" and not spellData.checkDebuff ) ) then
		return
	end
	
	local anchor = self.db.profile.anchors[spellData.showIn]
	local anchorFrame = self[spellData.showIn]
	
	-- Check if this spell is enabled, and the anchors enabled
	if( not anchor or not anchor.enabled or not anchorFrame ) then
		return
	end
					
	local id = spellID .. sourceGUID
	local globalID = spellID .. destGUID
	local time = GetTime()
		
	-- Check/set single trigger limits
	if( playerLimit[id] and playerLimit[id] >= time ) then
		return
	end

	if( spellData.singleLimit and spellData.singleLimit > 0 ) then
		playerLimit[id] = time + spellData.singleLimit
	end	
	
	-- Check/set global trigger limits

	if( globalLimit[globalID] and globalLimit[globalID] >= time ) then
		return
	end

	if( spellData.globalLimit and spellData.globalLimit > 0 ) then
		globalLimit[globalID] = time + spellData.globalLimit
	end
	
	-- Spell interrupts generally have another component that you see after, like damage or a debuff. So don't let two timers show
	if( eventType == "SPELL_INTERRUPT" and ( not spellData.singleLimit or spellData.singleLimit < 2 ) ) then
		playerLimit[id] = time + 1
	end
	
	-- If we have to check debuffs, it means we need a global limit on the specific spellID + destGUId to prevent two timers
	if( spellData.checkDebuff and ( not spellData.globalLimit or spellData.globalLimit < 1.5 ) ) then
		globalLimit[globalID] = GetTime() + 1
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

	-- Check if we need to create a new row
	local frame = table.remove(anchorFrame.inactive, 1)
	if( not frame ) then
		frame = self:CreateRow(anchorFrame)
	end
	
	-- Setup
	frame.timeLeft = spellData.seconds
	frame.lastUpdate = GetTime()

	-- Spell info
	local icon = spellData.icon
	--[[
	-- Linked spell, show the icon for that instead if we can
	if( spellData.linkedTo and self.spellList[spellData.linkedTo] ) then
		-- Make sure we aren't using default still
		local linkedIcon = self.spellList[spellData.linkedTo].icon
		if( linkedIcon and not string.match(icon, "INV_Misc_QuestionMark$") ) then
			icon = linkedIcon
		end
	end
	]]
	
	-- If we're using the question mark still, then get the spell info ID
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
	
	-- Set it for when it fades
	frame.id = id
	frame.eventType = eventType
	frame.spellID = spellID
	frame.spellName = spellName
	frame.sourceGUID = sourceGUID
	frame.sourceName = sourceName
	frame.destGUID = destGUID
	frame.icon:SetTexture(icon)
	frame:Show()
	
	-- Show base frame + resort/reposition
	anchorFrame:Show()
	
	if( #(anchorFrame.active) == 0 ) then
		self:UpdateAnchor(anchorFrame)
	end
	
	-- Change this icon to active
	table.insert(anchorFrame.active, frame)
	table.sort(anchorFrame.active, sortTimers)

	self:RepositionTimers(anchorFrame)

	-- Announce it
	if( anchor.announce ) then
		if( spellData.type == "buff" ) then
			self:SendMessage(string.format(L["GAINED %s (%s)"], spellName, self:StripServer(sourceName)), anchor.announceDest, anchor.announceColor, spellID)
		else
			self:SendMessage(string.format(L["USED %s (%s)"], spellName, self:StripServer(sourceName)), anchor.announceDest, anchor.announceColor, spellID)
		end
	end
end

function Afflicted:AbilityEnded(eventType, spellID, spellName, sourceGUID, sourceName, isTimedOut)
	local spellData = self.spellList[spellID] or self.spellList[spellName]
	if( not spellData ) then
		return
	end
	
	local anchor = self.db.profile.anchors[spellData.showIn]
	local anchorFrame = self[spellData.showIn]
	
	if( not anchor or not anchorFrame or not anchor.enabled or spellData.disabled or (spellData.dontFade and not isTimedOut) ) then
		return
	end
		
	local removed
	for i=#(anchorFrame.active), 1, -1 do
		local row = anchorFrame.active[i]
		if( row.spellID == spellID and row.sourceGUID == sourceGUID ) then
			row:Hide()
			
			table.insert(anchorFrame.inactive, row)
			table.remove(anchorFrame.active, i)
			
			-- Remove the limiter for this id, but don't do it globally
			playerLimit[row.id] = nil
			removed = true
			break
		end
	end
	
	-- Didn't remove anything, nothing to change
	if( not removed ) then
		return
	end
	
	-- No more icons, hide the base frame
	if( #(anchorFrame.active) == 0 ) then
		anchorFrame:Hide()
	end
	
	-- Reposition everything
	self:RepositionTimers(anchorFrame)
	
	-- Announce it
	if( anchor.announce ) then
		if( spellData.type == "buff" ) then
			self:SendMessage(string.format(L["FADED %s (%s)"], spellName, self:StripServer(sourceName)), anchor.announceDest, anchor.announceColor, spellID)
		else
			self:SendMessage(string.format(L["READY %s (%s)"], spellName, self:StripServer(sourceName)), anchor.announceDest, anchor.announceColor, spellID)
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
	if( not self.db.profile.showIcon or not spellID ) then
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

	return string.format("|T%s:%d:%d:0:-1|t %s", icon, size, size, msg)
end

function Afflicted:SendMessage(msg, dest, color, spellID)
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