if( not Afflicted ) then return end

local Icons = Afflicted:NewModule("Icons", "AceEvent-3.0")

local ICON_SIZE = 20
local POSITION_SIZE = ICON_SIZE + 2
local methods = {"CreateDisplay", "ClearTimers", "CreateTimer", "RemoveTimer", "UnitDied", "ReloadVisual"}
local savedGroups = {}

function Icons:OnInitialize()
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

-- Reposition the passed frames timers
local function repositionTimers(type)
	local frame = Icons.groups[type]
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
		
		elseif( Afflicted.db.profile.anchors[type].growUp ) then
			local position = Afflicted.db.profile.anchors[type].position
			icon:ClearAllPoints()
			icon:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, 0)

		else
			local position = Afflicted.db.profile.anchors[type].position
			icon:ClearAllPoints()
			icon:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, 0)
		end
	end
end

-- Sort timers by time left
local function sortTimers(a, b)
	return a.endTime < b.endTime
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
		anchor.position.x = self:GetLeft()
		anchor.position.y = self:GetTop()
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
			
			local anchor = Icons.groups[self.type]
			table.sort(anchor.active, sortTimers)
			repositionTimers(anchor.type)
			return
		end

		if( not self.isCooldown ) then
			Afflicted:AbilityEnded(self.eventType, self.spellID, self.spellName, self.sourceGUID, self.sourceName)
		end

		Icons:RemoveTimer(self.type, self.spellID, self.sourceGUID, self.isCooldown)
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
	--frame.text:SetFont((GameFontHighlight:GetFont()), 12, "OUTLINE")
	frame.text:SetPoint("LEFT", ICON_SIZE + 2, 0)
	
	return frame
end

local function showTooltip(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
	GameTooltip:SetText(AfflictedLocals["ALT + Drag to move the frame anchor."], nil, nil, nil, nil, 1)
end

local function hideTooltip(self)
	GameTooltip:Hide()
end

-- PUBLIC METHODS
-- Create our main display frame
local backdrop = {bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeSize = 0.80,
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
	frame:SetScript("OnEnter", showTooltip)
	frame:SetScript("OnLeave", hideTooltip)

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
	Icons.groups = {}
	for name, data in pairs(Afflicted.db.profile.anchors) do
		if( data.enabled ) then
			Icons.groups[name] = Icons:CreateDisplay(name)
		end
	end
	
	return obj
end

-- Clear all running timers for this anchor type
function Icons:ClearTimers(type)
	local frame = Icons.groups[type]
	if( not frame ) then
		return
	end
	
	for i=#(frame.active), 1, -1 do
		frame.active[i]:Hide()
				
		table.insert(frame.inactive, frame.active[i])
		table.remove(frame.active, i)
	end
end

-- Unit died, remove their timers
function Icons:UnitDied(destGUID)
	-- Loop through all created anchors
	for name, group in pairs(Icons.groups) do
		if( group and #(group.active) > 0 ) then
			-- Now through all active timers
			for i=#(group.active), 1, -1 do
				local row = group.active[i]

				if( ( row.sourceGUID == destGUID or row.destGUID == destGUID ) and not row.dontFade and not row.isCooldown ) then
					row:Hide()

					table.insert(group.inactive, row)
					table.remove(group.active, i)
				end
			end

			-- No more icons, hide the base group
			if( #(group.active) == 0 ) then
				group:Hide()
			end

			-- Reposition everything
			repositionTimers(name)
		end
	end
end

-- Create a new timer
local function createTimer(showIn, eventType, repeating, spellID, spellName, sourceGUID, sourceName, destGUID, icon, seconds, isCooldown)
	local anchorFrame = Icons.groups[showIn]
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
	frame.endTime = GetTime() + seconds
	
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
	createTimer(spellData.showIn, eventType, spellData.repeating, spellID, spellName, sourceGUID, sourceName, destGUID, spellData.icon, spellData.seconds)
	
	if( spellData.cdEnabled and spellData.cooldown > 0 ) then
		createTimer(spellData.cdInside, eventType, false, spellID, spellName, sourceGUID, sourceName, destGUID, spellData.icon, spellData.cooldown, true)
	end
end

-- Remove a specific anchors timer by spellID/sourceGUID
function Icons:RemoveTimer(anchorName, spellID, sourceGUID, isCooldown)
	local anchorFrame = Icons.groups[anchorName]
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
	for name, data in pairs(Afflicted.db.profile.anchors) do
		-- Had a bad anchor that was either enabled recently, or it used to be a bar anchor
		--if( ( data.enabled or data.displayType == "icon" ) and not Icons.groups[name] ) then
		if( data.enabled and not Icons.groups[name] ) then
			Icons.groups[name] = savedGroups[name] or Icons:CreateDisplay(name)
			savedGroups[name] = nil
		
		-- Had a bar anchor that was either disabled recently, or it's not an icon anchor anymore
		--elseif( ( not data.enabled or data.displayType ~= "icon" ) and Icons.groups[name] ) then
		elseif( not data.enabled and Icons.groups[name] ) then
			savedGroups[name] = Icons.groups[name]
			
			Icons.groups[name]:SetAlpha(0)
			Icons.groups[name]:EnableMouse(false)
			Icons.groups[name] = nil
		end
	end

	-- Update anchors and icons inside
	for name, group in pairs(Icons.groups) do
		local data = Afflicted.db.profile.anchors[name]
		
		-- Update group scale
		group:SetScale(data.scale)

		-- Update icon scale
		for _, group in pairs(group.active) do
			group:SetScale(data.scale)
		end

		for _, group in pairs(group.inactive) do
			group:SetScale(data.scale)
		end

		-- Annnd make sure it's shown or hidden
		if( Afflicted.db.profile.showAnchors ) then
			group:SetAlpha(1)
			group:EnableMouse(true)
		else
			group:SetAlpha(0)
			group:EnableMouse(false)
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