if( not Afflicted ) then return end

local Bars = Afflicted:NewModule("Bars", "AceEvent-3.0")
local methods = {"CreateDisplay", "ClearTimers", "CreateTimer", "RemoveTimer", "ReloadVisual", "TimerExists"}
local SML, GTBLib
local barData = {}

function Bars:OnInitialize()
	SML = Afflicted.SML
	GTBLib = LibStub:GetLibrary("GTB-Beta1")
	self.GTB = GTBLib

	self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

-- We delay this until PEW to fix UIScale issues
function Bars:PLAYER_ENTERING_WORLD()
	for key, data in pairs(Afflicted.db.profile.anchors) do
		local frame = Bars[key]
		if( frame ) then
			frame:Show()
		end
	end
	
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
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

-- PUBLIC METHODS
-- Create our main display frame
local backdrop = {bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeSize = 0.6,
		insets = {left = 1, right = 1, top = 1, bottom = 1}}

function Bars:CreateDisplay(type)
	local anchorData = Afflicted.db.profile.anchors[type]
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetWidth(Afflicted.db.profile.barWidth)
	frame:SetHeight(12)
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:SetClampedToScreen(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScale(anchorData.scale)
	frame:SetBackdrop(backdrop)
	frame:SetBackdropColor(0, 0, 0, 1.0)
	frame:SetBackdropBorderColor(0.75, 0.75, 0.75, 1.0)
	frame:SetScript("OnDragStart", OnDragStart)
	frame:SetScript("OnDragStop", OnDragStop)
	frame:SetScript("OnShow", OnShow)
	frame:Hide()
	frame.type = type

	-- Display name
	frame.text = frame:CreateFontString(nil, "OVERLAY")
	frame.text:SetPoint("CENTER", frame)
	frame.text:SetFontObject(GameFontHighlight)
	frame.text:SetText(anchorData.text)

	-- Visbility
	if( not Afflicted.db.profile.showAnchors ) then
		frame:SetAlpha(0)
		frame:EnableMouse(false)
	end
	

	-- Create the group instance for this anchor
	frame.group = GTBLib:RegisterGroup(string.format("Afflicted (%s)", anchorData.text), SML:Fetch(SML.MediaType.STATUSBAR, Afflicted.db.profile.barName))
	frame.group:RegisterOnFade(Bars, "OnBarFade")
	frame.group:SetScale(anchorData.scale)
	frame.group:SetWidth(Afflicted.db.profile.barWidth)
	frame.group:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, 0)
	frame.group:SetDisplayGroup(anchorData.redirectTo ~= "" and anchorData.redirectTo or nil)
	
	return frame
end

-- Return an object to access our visual style
function Bars:LoadVisual()
	if( not GTBLib ) then
		SML = Afflicted.SML
		GTBLib = LibStub:GetLibrary("GTB-Beta1")
		self.GTB = GTBLib
	end

	local obj = {}
	for _, func in pairs(methods) do
		obj[func] = self[func]
	end
	
	-- Create anchors
	for name, data in pairs(Afflicted.db.profile.anchors) do
		if( data.enabled ) then
			Bars[name] = obj:CreateDisplay(name)
		end
	end
	
	return obj
end

-- Clear all running timers for this anchor type
function Bars:ClearTimers(type)
	local anchorFrame = Bars[type]
	if( not anchorFrame ) then
		return
	end
	
	anchorFrame.group:UnregisterAllBars()
end

function Bars:TimerExists(spellData, spellID, sourceGUID, destGUID)
	return (barData[spellID .. sourceGUID])
end

-- Create a new timer
function Bars:CreateTimer(spellData, eventType, spellID, spellName, sourceGUID, sourceName, destGUID)
	local anchorFrame = Bars[spellData.showIn]
	if( not anchorFrame ) then
		return
	end
		
	local id = spellID .. sourceGUID
	local text = spellName
	if( sourceName and sourceName ~= "" ) then
		text = string.format("%s - %s", spellName, sourceName)
	end
	
	-- We can only pass one argument, so we do this to prevent creating and dumping tables and such
	barData[id] = string.format("%s,%d,%s,%s,%s,true", eventType, spellID, spellName, sourceGUID, sourceName)

	anchorFrame.group:SetTexture(SML:Fetch(SML.MediaType.STATUSBAR, Afflicted.db.profile.barName))
	anchorFrame.group:RegisterBar(id, spellData.seconds, text, spellData.icon)
	anchorFrame.group:SetRepeatingTimer(id, spellData.repeating or false)
end

-- Bar timer ran out
function Bars:OnBarFade(barID)
	if( barID and barData[barID] ) then
		Afflicted:AbilityEnded(string.split(",", barData[barID]))

		barData[barID] = nil
	end
end

-- Remove a specific anchors timer by spellID/sourceGUID
function Bars:RemoveTimer(anchorName, spellID, sourceGUID)
	local anchorFrame = Bars[anchorName]
	if( not anchorFrame ) then
		return
	end

	return anchorFrame.group:UnregisterBar(spellID .. sourceGUID)
end

function Bars:ReloadVisual()
	-- Update anchors and icons inside
	for key, data in pairs(Afflicted.db.profile.anchors) do
		local frame = Bars[key]
		if( frame ) then
			frame.group:SetScale(data.scale)
			frame.group:SetWidth(Afflicted.db.profile.barWidth)
			frame.group:SetDisplayGroup(data.redirectTo ~= "" and data.redirectTo or nil)

			frame:SetWidth(Afflicted.db.profile.barWidth)
			frame:SetScale(data.scale)
		
			if( not Afflicted.db.profile.showAnchors ) then
				frame:SetAlpha(0)
				frame:EnableMouse(false)
			else
				frame:SetAlpha(1)
				frame:EnableMouse(true)
			end
		end
	end
end