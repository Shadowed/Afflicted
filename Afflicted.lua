Afflicted = LibStub("AceAddon-3.0"):NewAddon("Afflicted", "AceEvent-3.0")

local L = AfflictedLocals

local selfFailDispel, selfSuccessDispel, selfInterruptOther, selfGetAfflicted, friendlyGetAfflicted, friendlyResistSpell, selfResistSpell, enemyGainBuff, enemyLoseBuff

local instanceType
local playerName

local unusedFrames = {}

local ICON_SIZE = 20
local POSITION_SIZE = ICON_SIZE + 2

function Afflicted:OnInitialize()
	self.defaults = {
		profile = {
			buff = true,
			spell = true,
			
			anchor = true,
			scale = 1.0,
			
			arenaOnly = false,
			
			showPurge = false,
			showInterrupt = false,
			
			alertChat = 1,
			timerChat = 1,
			
			announce = {
				buff = true,
				spell = true,
			},

			growup = {
				buff = false,
				spell = false,
			},
			
			positions = {},
		},
	}

	self.db = LibStub:GetLibrary("AceDB-3.0"):New("AfflictedDB", self.defaults)
	self.spellList = AfflictedSpells
	self.revision = tonumber(string.match("$Revision$", "(%d+)") or 1)
	
	playerName = UnitName("player")
		
	-- Create display frames!
	self.buff = self:CreateDisplay("buff")
	self.spell = self:CreateDisplay("spell")

	-- Parse combat log messages for matching
	selfInterruptOther = self:Format(SPELLINTERRUPTSELFOTHER)
	selfGetAfflicted = self:Format(AURAADDEDSELFHARMFUL)
	selfResistSpell = self:Format(SPELLRESISTOTHERSELF)
	selfFailDispel = self:Format(DISPELFAILEDSELFOTHER)
	selfSuccessDispel = self:Format(AURADISPELOTHER3)
	
	friendlyGetAfflicted = self:Format(AURAADDEDOTHERHARMFUL)
	friendlyResistSpell = self:Format(SPELLRESISTOTHEROTHER)
	
	enemyGainBuff = self:Format(AURAADDEDOTHERHELPFUL)
	enemyLoseBuff = self:Format(AURAREMOVEDOTHER)

	-- Monitor for zone change
	if( self.db.profile.arenaOnly ) then
		self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
		self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS", "ZONE_CHANGED_NEW_AREA")
	end
end

function Afflicted:OnEnable()
	-- Not inside an arena, so don't register anything
	if( self.db.profile.arenaOnly and not IsActiveBattlefieldArena() ) then
		self.spell:Hide()
		self.buff:Hide()
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
	
	if( self.db.profile.arenaOnly ) then
		self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
		self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS", "ZONE_CHANGED_NEW_AREA")
	end
end

function Afflicted:Reload()
	self:OnDisable()
	self:OnEnable()
	
	-- Scale
	self.buff:SetScale(self.db.profile.scale)
	self.spell:SetScale(self.db.profile.scale)
	
	-- Anchor visibility
	if( not self.db.profile.anchor ) then
		self.spell:EnableMouse(false)
		self.spell:SetBackdropColor(0.0, 0.0, 0.0, 0)
		self.spell:SetBackdropBorderColor(0.90, 0.90, 0.90, 0)
		self.spell.text:Hide()

		if( #(self.spell.active) == 0 ) then
			self.spell:Hide()
		end

		self.buff:EnableMouse(false)
		self.buff:SetBackdropColor(0.0, 0.0, 0.0, 0)
		self.buff:SetBackdropBorderColor(0.90, 0.90, 0.90, 0)
		self.buff.text:Hide()

		if( #(self.buff.active) == 0 ) then
			self.buff:Hide()
		end
	else
		self.spell:EnableMouse(true)
		self.spell:Show()
		self.spell:SetBackdropColor(0.0, 0.0, 0.0, 1.0)
		self.spell:SetBackdropBorderColor(0.90, 0.90, 0.90, 1.0)
		self.spell.text:Show()

		self.buff:EnableMouse(true)
		self.buff:Show()
		self.buff:SetBackdropColor(0.0, 0.0, 0.0, 1.0)
		self.buff:SetBackdropBorderColor(0.90, 0.90, 0.90, 1.0)
		self.buff.text:Show()
	end
end

-- Process events
-- Check if we're in an arena
function Afflicted:ZONE_CHANGED_NEW_AREA()
	local type = select(2, IsInInstance())
	-- Inside an arena, but wasn't already
	if( type == "arena" and type ~= instanceType ) then
		self:OnEnable()

	-- Was in an arena, but left it
	elseif( type ~= "arena" and instanceType == "arena" ) then
		self:OnDisable()
	end
	
	instanceType = type
end

function Afflicted:CHAT_MSG_SPELL_SELF_DAMAGE(event, msg)
	if( string.match(msg, selfInterruptOther) ) then
		local target, spell = string.match(msg, selfInterruptOther)
		self:Print(string.format(L["Interrupted %s's %s."], target, spell))
	end
end

function Afflicted:CHAT_MSG_SPELL_SELF_BUFF(event, msg)
	if( string.match(msg, selfFailDispel) ) then
		local target, spell = string.match(msg, selfFailDispel)
		self:Print(string.format(L["FAILED %s's %s."], target, spell))
	end
end

function Afflicted:CHAT_MSG_SPELL_BREAK_AURA(event, msg)
	if( string.match(msg, selfSuccessDispel) ) then
		local target, spell, caster = string.match(msg, selfSuccessDispel)
		if( caster == playerName ) then
			self:Print(string.format(L["Removed %s's %s."], target, spell))
		end
	end
end

function Afflicted:CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE(event, msg)
	-- Friendly player resisted a spell
	if( string.match(msg, friendlyResistSpell) ) then
		local _, spell, target = string.match(msg, friendlyResistSpell)
		self:ProcessAbility(spell, spell, target)
	

	-- We resisted a spell
	elseif( string.match(msg, selfResistSpell) ) then
		local spell, target = string.match(msg, selfResistSpell)
		self:ProcessAbility(spell, spell, target)
	end
end

function Afflicted:CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE(event, msg)
	-- Player afflicted by a spell
	if( string.match(msg, selfGetAfflicted) ) then
		local spell = string.match(msg, selfGetAfflicted)
		self:ProcessAbility(spell, spell, nil)
	end
end

function Afflicted:CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE(event, msg)
	-- Friendly player afflicted
	if( string.match(msg, friendlyGetAfflicted) ) then
		local target, spell = string.match(msg, friendlyGetAfflicted)
		self:ProcessAbility(spell, spell, nil)
	end
end

function Afflicted:CHECK_BUFF_GAINS(event, msg)
	-- Enemy player, OR pet gained a buff
	if( string.match(msg, enemyGainBuff) ) then
		local target, spell = string.match(msg, enemyGainBuff)
		self:ProcessAbility(target .. spell, spell, target)
	end
end

function Afflicted:CHAT_MSG_SPELL_AURA_GONE_OTHER(event, msg)
	-- Enemy lost a buff
	if( string.match(msg, enemyLoseBuff) ) then
		local spell, target = string.match(msg, enemyLoseBuff)
		self:ProcessAbility(target .. spell, spell, target)
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
	frame:SetBackdrop(backdrop)
	frame:SetClampedToScreen(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScale(self.db.profile.scale)
	frame:SetScript("OnDragStart", onDragStart)
	frame:SetScript("OnDragStop", onDragStop)
	frame:Hide()
	
	frame.active = {}
	frame.type = type	

	-- Display name
	frame.text = frame:CreateFontString(nil, "OVERLAY")
	frame.text:SetPoint("CENTER", frame)
	frame.text:SetFontObject(GameFontHighlight)
	frame.text:SetText(L[type] or "?")
	frame.text:Hide()

	if( self.db.profile.anchor ) then
		frame:EnableMouse(true)
		frame:SetBackdropColor(0.0, 0.0, 0.0, 1.0)
		frame:SetBackdropBorderColor(0.90, 0.90, 0.90, 1.0)
		
		frame.text:Show()
	end

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
		Afflicted:AbilityEnded(self.id, self.spellName, self.target, self.type, self.suppress)
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
	frame:Hide()
	
	frame.icon = frame:CreateTexture(nil, "BACKGROUND")
	frame.icon:SetWidth(ICON_SIZE)
	frame.icon:SetHeight(ICON_SIZE)
	frame.icon:SetPoint("LEFT")
	
	frame.text = frame:CreateFontString(nil, "OVERLAY")
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
		local frame = table.remove(parent.active, i)
		frame:Hide()

		table.insert(unusedFrames, frame)
	end
	
	parent:Hide()
end

-- Sort timers by time left
local function sortTimers(a, b)
	return a.timeLeft < b.timeLeft
end

-- New ability found
function Afflicted:ProcessAbility(id, spellName, target, type, suppress)
	-- We're not monitoring this spell
	if( not self.spellList[spellName] ) then
		return
	end	

	local spellData = self.spellList[spellName]

	-- Use spell data type if the one we gave is unavailable
	type = type or spellData.type
	
	-- Unknown spell, or we don't have it enabled
	if( not self.db.profile[type] ) then
		return
	end
	
	-- Announce it
	if( not suppress ) then
		if( type == "buff" ) then
			self:Announce(string.format(L["%s GAINED %s"], target, spellName), type)
		--elseif( target ) then
		--	self:Announce(string.format(L["%s USED %s"], spellName, target), type)
		else
			self:Announce(string.format(L["%s USED %s"], spellName, "" ), type)
		end
	end
	
	local frame
	-- Check if we can recycle a frame
	if( #(unusedFrames) > 0 ) then
		frame = table.remove(unusedFrames, 1)
	else
		frame = self:CreateRow(self[type])
	end
	
	-- Show base frame
	table.insert(self[type].active, frame)
	self[type]:Show()
	
	-- Setup
	frame.timeLeft = spellData.seconds
	frame.lastUpdate = GetTime()
	frame.id = id
	frame.spellName = spellName

	frame.target = target
	frame.type = type
	frame.suppress = suppress
	frame.icon:SetTexture(spellData.icon)
	frame:Show()
	
	table.sort(self[type].active, sortTimers)
	self:RepositionTimers(self[type])
end

function Afflicted:AbilityEnded(id, spellName, target, type, suppress)
	-- Remove it from our in use list
	for i=#(self[type].active), 1, -1 do
		if( self[type].active[i].id == id ) then
			local frame = table.remove(self[type].active, i)
			frame:Hide()
			
			-- Make it available for use again
			table.insert(unusedFrames, frame)
			break
		end
	end
		
	-- No more icons, hide the base frame
	if( #(self[type].active) <= 0 ) then
		self[type]:Hide()
	end
	
	-- Reposition everything
	self:RepositionTimers(self[type])
	
	-- Announce it
	if( not suppress ) then
		if( type == "buff" ) then
			self:Announce(string.format(L["%s FADED %s"], target, spellName), type)
		--elseif( target ) then
		--	self:Announce(string.format(L["%s READY %s"], spellName, target), type)
		else
			self:Announce(string.format(L["%s READY %s"], spellName, "" ), type)
		end
	end
end

function Afflicted:Announce(msg, type)
	if( self.db.profile.announce[type] ) then
		local frame = getglobal("ChatFrame" .. self.db.profile.timerChat)
		if( not frame ) then
			frame = DEFAULT_CHAT_FRAME
		end
		
		frame:AddMessage("|cFF33FF99Afflicted|r: " .. msg)
	end
end

function Afflicted:Print(msg)
	local frame = getglobal("ChatFrame" .. self.db.profile.alertChat)
	if( not frame ) then
		frame = DEFAULT_CHAT_FRAME
	end

	frame:AddMessage("|cFF33FF99Afflicted|r: " .. msg)
end

function Afflicted:Format(text)
	text = string.gsub(text, "([%^%(%)%.%[%]%*%+%-%?])", "%%%1")
	text = string.gsub(text, "%%s", "(.+)")
	text = string.gsub(text, "%%d", "(%-?%%d+)")
	return text
end
