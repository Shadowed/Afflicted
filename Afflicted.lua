Afflicted = {}

local frame = CreateFrame("Frame")
local unusedFrames = {}
local selfFailDispel, selfSuccessDispel, selfInterruptOther, selfGetAfflicted, friendlyGetAfflicted, friendlyResistSpell, selfResistSpell, enemyGainBuff, enemyLoseBuff

local playerName

local L = AfflictedLocals

local ICON_SIZE = 20

function Afflicted:OnInitialize()
	self.defaults = {
		profile = {
			buff = true,
			spell = true,
			locked = true,
			scale = 1.0,
			
			showPurge = false,
			showInterrupt = false,

			announce= {
				buff = true,
				spell = true,
			},

			anchor = {
				spell = "BOTTOMLEFT",
				buff = "BOTTOM",
			},
			
			positions = {},
		},
	}

	self.db = LibStub:GetLibrary("AceDB-3.0"):New("AfflictedDB", self.defaults)
	self.spellList = AfflictedSpells
	
	playerName = UnitName("player")
	
	-- Spell removal + interrupt
	frame:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
	frame:RegisterEvent("CHAT_MSG_SPELL_SELF_BUFF")
	frame:RegisterEvent("CHAT_MSG_SPELL_BREAK_AURA")
	
	-- Interrupts used, or resisted
	frame:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE")
	frame:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE")
	frame:RegisterEvent("CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE")

	-- Buff fade/gains
	frame:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER")
	frame:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_BUFFS")
	frame:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS")

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
	
	-- Create display frames!
	self.buff = self:CreateDisplay("buff")
	self.spell = self:CreateDisplay("spell")
end

-- Process events
function Afflicted:CHAT_MSG_SPELL_SELF_DAMAGE(event, msg)
	if( self.db.profile.showInterrupt and string.match(msg, selfInterruptOther) ) then
		local target, spell = string.match(msg, selfInterruptOther)
		self:Print(string.format(L["Interrupted %s's %s."], target, spell))
	end
end

function Afflicted:CHAT_MSG_SPELL_SELF_BUFF(event, msg)
	if( self.db.profile.showPurge and string.match(msg, selfFailDispel) ) then
		local target, spell = string.match(msg, selfFailDispel)
		self:Print(string.format(L["FAILED %s's %s."], target, spell))
	end
end

function Afflicted:CHAT_MSG_SPELL_BREAK_AURA(event, msg)
	if( self.db.profile.showPurge and string.match(msg, selfSuccessDispel) ) then
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
		self:ProcessAbility(spell, spell, target, "spell")
	

	-- We resisted a spell
	elseif( string.match(msg, selfResistSpell) ) then
		local spell, target = string.match(msg, selfResistSpell)
		self:ProcessAbility(spell, spell, target, "spell")
	end
end

function Afflicted:CHECK_BUFF_GAINS(event, msg)
	-- Enemy player, OR pet gained a buff
	if( string.match(msg, enemyGainBuff) ) then
		local target, spell = string.match(msg, enemyGainBuff)
		self:ProcessAbility(target .. spell, spell, target, "buff")
	end
end

function Afflicted:CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE(event, msg)
	-- Player afflicted by a spell
	if( string.match(msg, selfGetAfflicted) ) then
		local spell = string.match(msg, selfGetAfflicted)
		self:ProcessAbility(spell, spell, nil, "spell")
	end
end

function Afflicted:CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE(event, msg)
	-- Friendly player afflicted
	if( string.match(msg, friendlyGetAfflicted) ) then
		local target, spell = string.match(msg, friendlyGetAfflicted)
		self:ProcessAbility(spell, spell, nil, "spell")
	end
end

function Afflicted:CHAT_MSG_SPELL_AURA_GONE_OTHER(event, msg)
	-- Enemy lost a buff
	if( string.match(msg, enemyLoseBuff) ) then
		local spell, target = string.match(msg, enemyLoseBuff)
		self:ProcessAbility(target .. spell, spell, target, "spell")
	end
end

-- Dragging functions
local function onDragStart(self)
	self.isMoving = true
	self:StartMoving()
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
	frame:SetWidth(ICON_SIZE)
	frame:SetHeight(ICON_SIZE)
	frame:SetMovable(true)
	frame:SetClampedToScreen(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScale(self.db.profile.scale)
	frame:SetScript("OnDragStart", onDragStart)
	frame:SetScript("OnDragStop", onDragStop)
	
	frame.active = {}
	frame.type = type

	if( not self.db.profile.locked ) then
		frame:EnableMouse(true)
		
		frame.text = frame:CreateFontString(nil, "OVERLAY")
		frame.text:SetPoint("CENTER", frame)
		frame.text:SetFontObject(GameFontNormal)
		frame.text:SetText(L[type])
		
		frame:SetBackdrop(backdrop)
		frame:SetBackdropColor(0.0, 0.0, 0.0, 1.0)
		frame:SetBackdropBorderColor(0.90, 0.90, 0.90, 1.0)
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
		Afflicted:AbilityEnded(self.id, self.spellName, self.target, self.type)
		return
	end
	
	self.text:SetFormattedText("%.1f", self.timeLeft)
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
	frame.text:SetPoint("LEFT", ICON_SIZE + 1, 0)
	
	return frame
end

-- New ability found
function Afflicted:ProcessAbility(id, spellName, target, type)
	-- Unknown spell, or we don't have it enabled
	if( not self.spellList[spellName] or not self.db.profile[type] ) then
		return
	end
	
	local spellData = self.spellList[spellName]

	-- Announce it
	if( type == "buff" ) then
		self:Announce(string.format(L["%s GAINED %s"], target, spellName), type)
	elseif( target ) then
		self:Announce(string.format(L["%s USED %s"], spellName, target), type)
	else
		self:Announce(string.format(L["%s USED %s"], spellName, "" ), type)
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
	
	frame:ClearAllPoints()
	frame:SetPoint(self.db.profile.anchor[type], self[type], self.db.profile.anchor[type], 0, ICON_SIZE * #(self[type].active))
	frame.icon:SetTexture(spellData.icon)
	frame:Show()
end

function Afflicted:AbilityEnded(id, spellName, target, type)
	-- Remove it from our in use list
	for i=#(self[type].active), 1, -1 do
		if( self[type].active[i].id == id ) then
			local frame = table.remove(self[type].active, i)
			
			-- Make it available for use again
			table.insert(unusedFrames, frame)
			break
		end
	end
		
	-- Reposition everything
	for id, frame in pairs(self[type].active) do
		frame:ClearAllPoints()
		frame:SetPoint(self.db.profile.anchor[type], self[type], self.db.profile.anchor[type], 0, ICON_SIZE * id)
	end
	
	-- No more icons, hide the base frame
	if( #(self[type].active) <= 0 ) then
		self[type]:Hide()
	end
	
	-- Announce it
	if( type == "buff" ) then
		self:Announce(string.format(L["%s FADED %s"], target, spellName), type)
	elseif( target ) then
		self:Announce(string.format(L["%s READY %s"], spellName, target), type)
	else
		self:Announce(string.format(L["%s READY %s"], spellName, "" ), type)
	end
end

function Afflicted:Announce(msg, type)
	if( self.db.profile.announce[type] ) then
		DEFAULT_CHAT_FRAME:AddMessage("|cFF33FF99Afflicted|r: " .. msg)
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

-- Event handler
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, ...)
	if( event == "ADDON_LOADED" ) then
		if( select(1, ...) == "Afflicted" ) then
			Afflicted.OnInitialize(Afflicted)
		end
		
		self:UnregisterEvent("ADDON_LOADED")
	elseif( event == "CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_BUFFS" or event == "CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS" ) then
		Afflicted.CHECK_BUFF_GAINS(Afflicted, event, ...)
	else
		Afflicted[event](Afflicted, event, ...)
	end
end)

-- GUI
