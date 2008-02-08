Afflicted = LibStub("AceAddon-3.0"):NewAddon("Afflicted", "AceEvent-3.0")

local L = AfflictedLocals

local selfFailDispel, selfSuccessDispel, selfInterruptOther, selfGetAfflicted, selfSpellRemoved, friendlyGetAfflicted, friendlyResistSpell, selfResistSpell, enemyGainBuff, enemyLoseBuff
local selfInterrupted, friendlyInterrupted

local instanceType
local playerName

local blockSpells = {}
local anchors = {["spell"] = "spell", ["buff"] = "buff", ["debuff"] = "spell"}

local ICON_SIZE = 20
local POSITION_SIZE = ICON_SIZE + 2

function Afflicted:OnInitialize()
	self.defaults = {
		profile = {
			buff = true,
			spell = true,
			anchor = true,
			scale = 1.0,
			showPurge = false,
			showInterrupt = false,
			alertOutput = 1,
			timerOutput = 1,
			alertColor = { r = 1.0, g = 0.0, b = 0.0 },
			timerColor = { r = 1.0, g = 0.0, b = 0.0 },
			announce = { buff = true, spell = true, },
			growup = { buff = false, spell = false, },
			positions = {},
			spells = {},
			inside = {["arena"] = true},
			spellDefault = {
				seconds = 0,
				limit = 0,
				icon = "Interface\\Icons\\INV_Misc_QuestionMark",
				afflicted = false,
				type = "spell",
			},
		},
	}

	self.db = LibStub:GetLibrary("AceDB-3.0"):New("AfflictedDB", self.defaults)
	self.revision = tonumber(string.match("$Revision$", "(%d+)") or 1)
	
	playerName = UnitName("player")
		
	-- Create display frames!
	self.anchors = anchors
	for _, key in pairs(anchors) do
		if( not self[key] ) then
			self[key] = self:CreateDisplay(key)
		end
	end

	-- Parse combat log messages for matching
	selfInterruptOther = self:Format(SPELLINTERRUPTSELFOTHER)
	selfGetAfflicted = self:Format(AURAADDEDSELFHARMFUL)
	selfResistSpell = self:Format(SPELLRESISTOTHERSELF)
	selfFailDispel = self:Format(DISPELFAILEDSELFOTHER)
	selfSuccessDispel = self:Format(AURADISPELOTHER3)
	selfSpellRemoved = self:Format(AURADISPELSELF3)
	selfInterrupted = self:Format(SPELLINTERRUPTOTHERSELF)
	
	friendlyInterrupted = self:Format(SPELLINTERRUPTOTHEROTHER)
	friendlyGetAfflicted = self:Format(AURAADDEDOTHERHARMFUL)
	friendlyResistSpell = self:Format(SPELLRESISTOTHEROTHER)
	
	enemyGainBuff = self:Format(AURAADDEDOTHERHELPFUL)
	enemyLoseBuff = self:Format(AURAREMOVEDOTHER)
	
	-- Update the spell list with the default and manual
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
	
	-- We interrupted a spell of theirs
	if( self.db.profile.showInterrupt ) then
		self:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
	end

	-- Spells we removed
	if( self.db.profile.showPurge ) then
		self:RegisterEvent("CHAT_MSG_SPELL_SELF_BUFF")
		self:RegisterEvent("CHAT_MSG_SPELL_BREAK_AURA")
	end
	
	-- Interrupts used, or resisted
	if( self.db.profile.spell ) then
		self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE")
		self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE")
		self:RegisterEvent("CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE")
		self:RegisterEvent("CHAT_MSG_SPELL_BREAK_AURA")
	end

	-- Buff fade/gains
	if( self.db.profile.buff ) then
		self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER")
		self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_BUFFS", "CHECK_BUFF_GAINS")
		self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "CHECK_BUFF_GAINS")
	end
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
	for key in pairs(anchors) do
		if( self[key] ) then
			-- Update frame scale
			self[key]:SetScale(self.db.profile.scale)

			-- Update icon scale
			for _, frame in pairs(self[key].active) do
				frame:SetScale(self.db.profile.scale)
			end

			for _, frame in pairs(self[key].inactive) do
				frame:SetScale(self.db.profile.scale)
			end

			-- Update anchor visibility
			self:UpdateAnchor(self[key])

			-- Annnd make sure it's shown or hidden
			if( self.db.profile.anchor ) then
				self[key]:Hide()
			elseif( #(self[key].active) == 0 ) then
				self[key]:Hide()
			end
		end
	end

	-- Mergy
	self:UpdateSpellList()
end

-- Update anchor visibility
function Afflicted:UpdateAnchor(frame)
	if( self.db.profile.anchor ) then
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

-- Process events
-- Check if we're in an arena
function Afflicted:ZONE_CHANGED_NEW_AREA()
	local type = select(2, IsInInstance())

	if( type ~= instanceType ) then
		-- Clear anchors because we changed zones
		for key in pairs(anchors) do
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

function Afflicted:CHAT_MSG_SPELL_SELF_DAMAGE(event, msg)
	local target, spell = string.match(msg, selfInterruptOther)
	if( spell and target ) then
		self:SendMessage(string.format(L["Interrupted %s's %s."], target, spell), "alert")
	end
end

function Afflicted:CHAT_MSG_SPELL_SELF_BUFF(event, msg)
	local target, spell = string.match(msg, selfFailDispel)
	if( spell and target ) then
		self:SendMessage(string.format(L["FAILED %s's %s."], target, spell), "alert")
	end
end

function Afflicted:CHAT_MSG_SPELL_BREAK_AURA(event, msg)
	if( self.db.profile.spell ) then
		local removed, caster, spell = string.match(msg, selfSpellRemoved)
		if( removed and caster and spell ) then
			self:ProcessAbility(spell, caster)
			return
		end
	end

	if( self.db.profile.showPurge ) then
		local target, spell, caster = string.match(msg, selfSuccessDispel)
		if( caster == playerName ) then
			self:SendMessage(string.format(L["Removed %s's %s."], target, spell), "alert")
		end
	end
end

function Afflicted:CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE(event, msg)
	-- Friendly player resisted a spell
	local _, spell, target = string.match(msg, friendlyResistSpell)
	if( spell and target ) then
		self:ProcessAbility(spell, target)
		return
	end

	-- We resisted a spell
	local spell, target = string.match(msg, selfResistSpell)
	if( spell and target ) then
		self:ProcessAbility(spell, target)
		return
	end
	
	-- Dodged/Parried/Blocked an ability
	local target, spell = string.match(msg, L["(.+)'s (.+) was"])
	if( spell and target ) then
		self:ProcessAbility(spell, target)
		return
	end
	
	-- Hit
	local target, spell = string.match(msg, L["(.+)'s (.+) hit"])
	if( spell and target ) then
		self:ProcessAbility(spell, target)
		return
	end
	
	-- Crit
	local target, spell = string.match(msg, L["(.+)'s (.+) crit"])
	if( spell and target ) then
		self:ProcessAbility(spell, target)
		return
	end
	
	-- Absorbed
	local target, spell = string.match(msg, L["(.+)'s (.+) is"])
	if( spell and target ) then
		self:ProcessAbility(spell, target)
		return
	end
	
	-- Missed
	local target, spell = string.match(msg, L["(.+)'s (.+) miss"])
	if( spell and target ) then
		self:ProcessAbility(spell, target)
		return
	end
end

function Afflicted:CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE(event, msg)
	-- Player afflicted by a spell
	local spell = string.match(msg, selfGetAfflicted)
	if( spell and self.spellList[spell] and self.spellList[spell].type == "debuff" ) then
		self:ProcessAbility(spell)
	end
end

function Afflicted:CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE(event, msg)
	-- Friendly player afflicted
	local target, spell = string.match(msg, friendlyGetAfflicted)
	if( spell and self.spellList[spell] and self.spellList[spell].type == "debuff" ) then
		self:ProcessAbility(spell)
	end
end

function Afflicted:CHECK_BUFF_GAINS(event, msg)
	-- Enemy player, OR pet gained a buff
	local target, spell = string.match(msg, enemyGainBuff)
	if( spell and target ) then
		self:ProcessAbility(spell, target)
	end
end

function Afflicted:CHAT_MSG_SPELL_AURA_GONE_OTHER(event, msg)
	-- Enemy lost a buff
	local spell, target = string.match(msg, enemyLoseBuff)
	if( spell and target ) then
		self:AbilityEnded(nil, spell, target, nil, true)
	end
end

-- Dragging functions
local function onDragStart(self)
	if( IsAltKeyDown() ) then
		self.isMoving = true
		self:StartMoving()
	end
end

local function onDragStop(self)
	if( self.isMoving ) then
		self.isMoving = nil
		self:StopMovingOrSizing()
		
		local db = Afflicted.db.profile
		if( not db.positions[self.type] ) then
			db.positions[self.type] = {}
		end
		
		db.positions[self.type].x = self:GetLeft()
		db.positions[self.type].y = self:GetTop()
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
	frame:SetScale(self.db.profile.scale)
	frame:SetBackdrop(backdrop)
	frame:SetBackdropColor(0.0, 0.0, 0.0, 1.0)
	frame:SetBackdropBorderColor(0.90, 0.90, 0.90, 1.0)
	frame:SetScript("OnDragStart", onDragStart)
	frame:SetScript("OnDragStop", onDragStop)
	frame:Hide()
	
	frame.active = {}
	frame.inactive = {}
	frame.type = type	

	-- Display name
	frame.text = frame:CreateFontString(nil, "OVERLAY")
	frame.text:SetPoint("CENTER", frame)
	frame.text:SetFontObject(GameFontHighlight)
	frame.text:SetText(L[type] or "?")
	
	self:UpdateAnchor(frame)

	if( self.db.profile.positions[type] ) then
		frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", self.db.profile.positions[type].x, self.db.profile.positions[type].y)
	else
		frame:SetPoint("CENTER", UIParent, "CENTER")
	end
	
	return frame
end

-- Update icon timer
local function onUpdate(self, elapsed)
	local time = GetTime()
	self.timeLeft = self.timeLeft - (time - self.lastUpdate)
	self.lastUpdate = time
	
	if( self.timeLeft <= 0 ) then
		Afflicted:AbilityEnded(self.id, self.spellName, self.target, self.suppress)
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
	frame:SetScale(self.db.profile.scale)
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
	if( self.db.profile.growup[parent.type] ) then
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
		
		blockSpells[parent.active[i].id] = nil
		
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
function Afflicted:ProcessAbility(spellName, target, suppress)
	-- We're not monitoring this spell
	if( not self.spellList[spellName] or (self.spellList[spellName] and self.spellList[spellName].disabled) ) then
		return
	end
	
	local spellData = self.spellList[spellName]
	local id = spellData.id .. tostring(target)
	local type = anchors[spellData.type]
	local parent = self[type]
		
	-- Unknown spell, or we don't have it enabled
	if( not self.db.profile[type] ) then
		return
	end

	-- Check if we need to set a trigger limit
	if( spellData.limit and spellData.limit > 0 ) then
		local time = GetTime()
		if( blockSpells[id] and blockSpells[id] >= time ) then
			return
		end
		
		blockSpells[id] = time + spellData.limit
	end

	local frame = table.remove(parent.inactive, 1)
	if( not frame ) then
		frame = self:CreateRow(parent)
	end
	
	-- Setup
	frame.timeLeft = spellData.seconds
	frame.lastUpdate = GetTime()

	-- Spell info
	frame.id = id
	frame.spellName = spellName
	frame.target = target
	frame.suppress = suppress
	frame.type = type

	frame.icon:SetTexture(spellData.icon)
	frame:Show()
	
	-- Show base frame + resort/reposition
	parent:Show()
	
	if( #(parent.active) == 0 ) then
		self:UpdateAnchor(parent)
	end

	table.insert(parent.active, frame)
	table.sort(parent.active, sortTimers)

	self:RepositionTimers(parent)

	-- Announce it
	if( not suppress and self.db.profile.announce[type] ) then
		if( type == "buff" ) then
			self:SendMessage(string.format(L["GAINED %s (%s)"], spellName, target), "timer")
		elseif( target ) then
			self:SendMessage(string.format(L["USED %s (%s)"], spellName, target), "timer")
		else
			self:SendMessage(string.format(L["USED %s"], spellName), "timer")
		end
	end
end

function Afflicted:AbilityEnded(id, spellName, target, suppress, isFade)
	if( not self.spellList[spellName] or (self.spellList[spellName] and self.spellList[spellName].disabled) ) then
		return
	end
	
	local spellData = self.spellList[spellName]
	local type = anchors[spellData.type]
	local parent = self[type]
	
	-- This means things like Shadowstep won't be removed from the timer since we
	-- want it to keep ticking, down and not remove after the speed boost fades
	if( spellData.dontFade and isFade ) then
		return
	end

	id = id or (spellData.id .. tostring(target))
	
	-- Remove it from display
	local removed
	for i=#(parent.active), 1, -1 do
		if( parent.active[i].id == id and parent.active[i].type == type ) then
			parent.active[i]:Hide()
			
			table.insert(parent.inactive, parent.active[i])
			table.remove(parent.active, i)
			
			blockSpells[id] = nil
			removed = true
			break
		end
	end
	
	-- If we didn't remove anything, then it means we never had a timer
	-- OR, it means the timer already ran out
	if( not removed ) then
		return
	end
	
	-- No more icons, hide the base frame
	if( #(parent.active) == 0 ) then
		parent:Hide()
	end
	
	-- Reposition everything
	self:RepositionTimers(parent)
	
	-- Announce it
	if( not suppress and self.db.profile.announce[type] ) then
		if( type == "buff" ) then
			self:SendMessage(string.format(L["FADED %s (%s)"], spellName, target), "timer")
		elseif( target ) then
			self:SendMessage(string.format(L["READY %s (%s)"], spellName, target), "timer")
		else
			self:SendMessage(string.format(L["READY %s"], spellName), "timer")
		end
	end
end

function Afflicted:SendMessage(msg, var)
	local outputVar = var .. "Output"

	-- Specific chat frame
	if( type(self.db.profile[outputVar]) == "number" ) then
		local frame = getglobal("ChatFrame" .. self.db.profile[outputVar])
		if( not frame ) then
			frame = DEFAULT_CHAT_FRAME
		end

		frame:AddMessage("|cFF33FF99Afflicted|r: " .. msg)

	-- Raid warning announcement to raid/party
	elseif( self.db.profile[outputVar] == "rw" ) then
		SendChatMessage(msg, "RAID_WARNING")

	-- Raid warning frame, will not send it out to the party
	elseif( self.db.profile[outputVar] == "rwframe" ) then
		local color = var .. "Color"
		self.alertFrame:AddMessage(msg, self.db.profile[color].r, self.db.profile[color].g, self.db.profile[color].b)

	-- Party chat
	elseif( self.db.profile[outputVar] == "party" ) then
		SendChatMessage(msg, "PARTY")
	
	-- Combat text
	elseif( self.db.profile[outputVar] == "ct" ) then
		self:CombatText(msg, var)

	-- Default to default!
	else
		self:Print(msg)
	end
end

function Afflicted:CombatText(text, var)	
	var = var .. "Color"
	
	-- SCT
	if( IsAddOnLoaded("sct") ) then
		SCT:DisplayText(text, self.db.profile[var], nil, "event", 1)
	
	-- MSBT
	elseif( IsAddOnLoaded("MikScrollingBattleText") ) then
		MikSBT.DisplayMessage(text, MikSBT.DISPLAYTYPE_NOTIFICATION, false, self.db.profile[var].r * 255, self.db.profile[var].g * 255, self.db.profile[var].b * 255)		
	
	-- Blizzard Combat Text
	elseif( IsAddOnLoaded("Blizzard_CombatText") ) then
		-- Haven't cached the movement function yet
		if( not COMBAT_TEXT_SCROLL_FUNCTION ) then
			CombatText_UpdateDisplayedMessages()
		end
		
		CombatText_AddMessage(text, COMBAT_TEXT_SCROLL_FUNCTION, self.db.profile[var].r, self.db.profile[var].g, self.db.profile[var].b)
	end
end

function Afflicted:Print(msg)
	DEFAULT_CHAT_FRAME:AddMessage("|cFF33FF99Afflicted|r: " .. msg)
end

function Afflicted:Format(text)
	text = string.gsub(text, "([%^%(%)%.%[%]%*%+%-%?])", "%%%1")
	text = string.gsub(text, "%%s", "(.+)")
	text = string.gsub(text, "%%d", "(%-?%%d+)")
	return text
end
