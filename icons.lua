if( not Afflicted ) then return end

local Icons = Afflicted:NewModule("Icons", "AceEvent-3.0")

local ICON_SIZE = 20
local POSITION_SIZE = ICON_SIZE + 2
local methods = {"CreateDisplay", "ClearTimers", "CreateTimer", "RemoveTimer", "TimerExists", "UnitDied", "ReloadVisual"}

function Icons:OnInitialize()
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

-- Reposition the passed frames timers
local function repositionTimers(type)
	local frame = Icons[type]
	if( not frame or not Afflicted.db.profile.anchors[type].position ) then
		return
	end
	
	-- Reposition everything
	for id, icon in pairs(frame.active) do
		if( id > 1 ) then
			icon:ClearAllPoints()
			if( not Afflicted.db.profile.anchors[type].growUp ) then
				icon:SetPoint("TOPLEFT", frame.active[id - 1], "BOTTOMLEFT", 0, 0)
			else
				icon:SetPoint("BOTTOMLEFT", frame.active[id - 1], "TOPLEFT", 0, 0)
			end
		else
			local scale = frame:GetEffectiveScale()
			local position = Afflicted.db.profile.anchors[type].position
			local y = position.y / scale
			
			if( Afflicted.db.profile.anchors[type].growUp ) then
				y = y + ICON_SIZE
			else
				y = y - 12
			end
		
			icon:ClearAllPoints()
			icon:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", position.x / scale, y)
		end
	end
end

-- Sort timers by time left
local function sortTimers(a, b)
	return a.timeLeft < b.timeLeft
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
		
		local anchor = Afflicted.db.profile.anchors[self.type]
		if( not anchor.position ) then
			anchor.position = { x = 0, y = 0 }
		end
		
		local scale = self:GetEffectiveScale()
		anchor.position.x = self:GetLeft() * scale
		anchor.position.y = self:GetTop() * scale
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

-- Update icon timer
local function OnUpdate(self, elapsed)
	local time = GetTime()
	self.timeLeft = self.timeLeft - (time - self.lastUpdate)
	self.lastUpdate = time
	
	if( self.timeLeft <= 0 ) then
		-- Check if we should start the timer again
		if( self.repeatTimer ) then
			self.timeLeft = self.startSeconds
			self.lastUpdate = time
			
			local anchor = Icons[self.type]
			table.sort(anchor.active, sortTimers)
			repositionTimers(anchor.type)
			return
		end

		if( not self.isCooldown ) then
			Afflicted:AbilityEnded(self.eventType, self.spellID, self.spellName, self.sourceGUID, self.sourceName, true)
		else
			Icons:RemoveTimer(self.type, self.spellID, self.sourceGUID, true)
		end
		return
	end
	
	if( self.timeLeft > 10 ) then
		self.text:SetFormattedText("%d", self.timeLeft)
	else
		self.text:SetFormattedText("%.1f", self.timeLeft)
	end
end

-- Create our little icon frame
local function createRow(parent)
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetWidth(50)
	frame:SetHeight(ICON_SIZE)
	frame:SetScript("OnUpdate", OnUpdate)
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

-- PUBLIC METHODS
-- Create our main display frame
local backdrop = {bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeSize = 0.6,
		insets = {left = 1, right = 1, top = 1, bottom = 1}}

function Icons:CreateDisplay(type)
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetWidth(120)
	frame:SetHeight(12)
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:SetClampedToScreen(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScale(Afflicted.db.profile.anchors[type].scale)
	frame:SetBackdrop(backdrop)
	frame:SetBackdropColor(0, 0, 0, 1.0)
	frame:SetBackdropBorderColor(0.75, 0.75, 0.75, 1.0)
	frame:SetScript("OnDragStart", OnDragStart)
	frame:SetScript("OnDragStop", OnDragStop)
	frame:SetScript("OnShow", OnShow)
	frame:Hide()
	
	frame.active = {}
	frame.inactive = {}
	frame.type = type
	
	if( Afflicted.db.profile.showAnchors ) then
		frame:Show()
	end
	
	-- Display name
	frame.text = frame:CreateFontString(nil, "OVERLAY")
	frame.text:SetPoint("CENTER", frame)
	frame.text:SetFontObject(GameFontHighlight)
	frame.text:SetText(Afflicted.db.profile.anchors[type].text)
	
	return frame
end

-- Return an object to access our visual style
function Icons:LoadVisual()
	local obj = {}
	for _, func in pairs(methods) do
		obj[func] = Icons[func]
	end
	
	-- Create anchors
	for name, data in pairs(Afflicted.db.profile.anchors) do
		if( data.enabled ) then
			Icons[name] = obj:CreateDisplay(name)
		end
	end
	
	return obj
end

-- Clear all running timers for this anchor type
function Icons:ClearTimers(type)
	local frame = Icons[type]
	if( not frame ) then
		return
	end
	
	for i=#(frame.active), 1, -1 do
		frame.active[i]:Hide()
				
		table.insert(frame.inactive, frame.active[i])
		table.remove(frame.active, i)
	end
end

-- Check if we have a tiemr running for this person
function Icons:TimerExists(spellData, spellID, sourceGUID, destGUID)
	local anchorFrame = Icons[spellData.showIn]
	if( anchorFrame ) then
		for i=#(anchorFrame.active), 1, -1 do
			local row = anchorFrame.active[i]
			if( ( row.spellName == spellData.linkedTo or row.spellID == spellData.linkedTo ) and row.destGUID == destGUID ) then
				return true
			end
		end
	end
	
	return nil
end

-- Unit died, remove their timers
function Icons:UnitDied(destGUID)
	-- Loop through all created anchors
	for anchorName in pairs(Afflicted.db.profile.anchors) do
		local frame = Icons[anchorName]
		if( frame and #(frame.active) > 0 ) then
			-- Now through all active timers
			for i=#(frame.active), 1, -1 do
				local row = frame.active[i]

				if( ( row.sourceGUID == destGUID or row.destGUID == destGUID ) and not row.dontFade and not row.isCooldown ) then
					row:Hide()

					table.insert(frame.inactive, row)
					table.remove(frame.active, i)
				end
			end

			-- No more icons, hide the base frame
			if( #(frame.active) == 0 ) then
				frame:Hide()
			end

			-- Reposition everything
			repositionTimers(anhorName)
		end
	end
end

-- Create a new timer
local function createTimer(showIn, eventType, repeating, spellID, spellName, sourceGUID, sourceName, destGUID, icon, seconds, isCooldown)
	local anchorFrame = Icons[showIn]
	if( not anchorFrame ) then
		return
	end	

	-- Check if we need to create a new row
	local frame = table.remove(anchorFrame.inactive, 1)
	if( not frame ) then
		frame = createRow(anchorFrame)
	end

	-- Set it for when it fades
	frame.id = id
	frame.eventType = eventType
	frame.repeatTimer = repeating
	frame.isCooldown = isCooldown
	
	frame.spellID = spellID
	frame.spellName = spellName

	frame.sourceGUID = sourceGUID
	frame.sourceName = sourceName
	frame.destGUID = destGUID

	frame.startSeconds = seconds
	frame.timeLeft = seconds
	frame.lastUpdate = GetTime()
	
	frame.type = anchorFrame.type
	frame.icon:SetTexture(icon)
	frame:Show()
	
	-- Change this icon to active
	table.insert(anchorFrame.active, frame)
	table.sort(anchorFrame.active, sortTimers)

	-- Reposition
	repositionTimers(anchorFrame.type)
end

function Icons:CreateTimer(spellData, eventType, spellID, spellName, sourceGUID, sourceName, destGUID)
	createTimer(spellData.showIn, eventType, spellData.repeatTimer, spellID, spellName, sourceGUID, sourceName, destGUID, spellData.icon, spellData.seconds)
	
	if( spellData.cdEnabled and spellData.cooldown > 0 ) then
		createTimer(spellData.cdInside, eventType, false, spellID, spellName, sourceGUID, sourceName, destGUID, spellData.icon, spellData.cooldown, true)
	end
end

-- Remove a specific anchors timer by spellID/sourceGUID
function Icons:RemoveTimer(anchorName, spellID, sourceGUID, isCooldown)
	local anchorFrame = Icons[anchorName]
	if( not anchorFrame ) then
		return nil
	end
	
	-- Remove the icon timer
	local removed
	for i=#(anchorFrame.active), 1, -1 do
		local row = anchorFrame.active[i]
		if( row.spellID == spellID and row.sourceGUID == sourceGUID and ( ( isCooldown and row.isCooldown ) or ( not isCooldown and not row.isCooldown ) ) ) then
			row:Hide()
			
			table.insert(anchorFrame.inactive, row)
			table.remove(anchorFrame.active, i)
			
			removed = true
			break
		end
	end
	
	-- Didn't remove anything, nothing to change
	if( not removed ) then
		return nil
	end
	
	-- Reposition everything
	repositionTimers(anchorFrame.type)
	
	return true
end

function Icons:ReloadVisual()
	-- Update anchors and icons inside
	for key, data in pairs(Afflicted.db.profile.anchors) do
		local frame = Icons[key]
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

			-- Annnd make sure it's shown or hidden
			if( Afflicted.db.profile.showAnchors ) then
				frame:Show()
			else
				frame:Hide()
			end
		end
	end
end


-- We delay this until PEW to fix UIScale issues
function Icons:PLAYER_ENTERING_WORLD()
	for key, data in pairs(Afflicted.db.profile.anchors) do
		local frame = self[key]
		if( frame ) then
			OnShow(frame)
		end
	end
	
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end