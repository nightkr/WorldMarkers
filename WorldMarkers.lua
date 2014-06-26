-----------------------------------------------------------------------------------------------
-- Client Lua Script for WorldMarkers
-----------------------------------------------------------------------------------------------

require "Window"

local glog, GeminiGUI

-----------------------------------------------------------------------------------------------
-- WorldMarkers Module Definition
-----------------------------------------------------------------------------------------------
local WorldMarkers = {
	markers = {
		{
			worldLoc = nil,
			pixie = nil,
			sprite = "Icon_Windows_UI_CRB_Marker_Bomb",
			text = "Bomb"
		},
		{
			worldLoc = nil,
			pixie = nil,
			sprite = "Icon_Windows_UI_CRB_Marker_Ghost",
			text = "Ghost"
		},
		{
			worldLoc = nil,
			pixie = nil,
			sprite = "Icon_Windows_UI_CRB_Marker_Mask",
			text = "Mask"
		},
		{
			worldLoc = nil,
			pixie = nil,
			sprite = "Icon_Windows_UI_CRB_Marker_Octopus",
			text = "Octopus"
		},
		{
			worldLoc = nil,
			pixie = nil,
			sprite = "Icon_Windows_UI_CRB_Marker_Pig",
			text = "Pig"
		},
		{
			worldLoc = nil,
			pixie = nil,
			sprite = "Icon_Windows_UI_CRB_Marker_Chicken",
			text = "Chicken"
		},
		{
			worldLoc = nil,
			pixie = nil,
			sprite = "Icon_Windows_UI_CRB_Marker_Toaster",
			text = "Toaster"
		},
		{
			worldLoc = nil,
			pixie = nil,
			sprite = "Icon_Windows_UI_CRB_Marker_UFO",
			text = "UFO"
		}
	},
	currentUpdateMarker = 1
} 
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
-- e.g. local kiExampleVariableMax = 999
 
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function WorldMarkers:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- initialize variables here

    return o
end

function WorldMarkers:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		"Gemini:Logging-1.2"
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 

-----------------------------------------------------------------------------------------------
-- WorldMarkers OnLoad
-----------------------------------------------------------------------------------------------
function WorldMarkers:OnLoad()
	local GeminiLogging = Apollo.GetPackage("Gemini:Logging-1.2").tPackage
    glog = GeminiLogging:GetLogger({
        level = GeminiLogging.DEBUG,
        pattern = "%d %n %c %l - %m",
        appender = "GeminiConsole"
    })

    local GeminiGUI = Apollo.GetPackage("Gemini:GUI-1.0").tPackage

    self.wndPlacement = GeminiGUI:Create(self:GetPlacementWindow()):GetInstance(self, "FixedHudStratum")

    -- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("WorldMarkers.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
	
end

function WorldMarkers:GetPlacementWidgets()
	local out = {}

	local width = 50
	local height = 40

	for i=1,#self.markers do
		local marker = self.markers[i]

		local widget = {
			WidgetType = "CheckBox",
			Base = "CRB_UIKitSprites:btn_square_LARGE_Red",
			RadioGroup = "WorldMarkerPlacement",
			Sprite = marker.sprite,
			DrawAsCheckbox = false,
			PosSize = {10+(i-1)*width,10,width,height},
			Events = {
				ButtonCheck = function(self, _, _, button)
					self:ClearMarker(i)
					self.currentUpdateMarker = i
				end,
				ButtonUncheck = function()
					self.currentUpdateMarker = 0
				end
			}
		}
		out[i] = widget
	end

	-- out[#out+1] = {
	-- 	WidgetType = "PushButton",
	-- 	Base = "CRB_UIKitSprites:btn_square_LARGE_Red",
	-- 	AnchorPoints = {1, 0, 1, 0},
	-- 	AnchorOffsets = {10+width,10,width,height}
	-- }

	out[#out+1] = {
		WidgetType = "PushButton",
		Base = "CRB_UIKitSprites:btn_close",
		AnchorPoints = {1,0,1,0},
		AnchorOffsets = {-30,0,0,height},
		Events = {
			ButtonUp = function()
				for i=1,#self.markers do
					self:ClearMarker(i)
				end
			end
		}
	}

	return out
end

function WorldMarkers:GetPlacementWindow()
	return {
		Name = "World Markers",
		Template = "Holo_InputBox",
		UseTemplateBG = true,
		Border = true,
		AnchorPoints = {0.5,1,1,1},
		AnchorOffsets = {490,-160,-20,-100},
		Children = self:GetPlacementWidgets()
	}
end

-----------------------------------------------------------------------------------------------
-- WorldMarkers OnDocLoaded
-----------------------------------------------------------------------------------------------
function WorldMarkers:OnDocLoaded()

	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
	    self.wndMain = Apollo.LoadForm(self.xmlDoc, "WorldMarkersForm", "InWorldHudStratum", self)
		--self.wndPlacement = Apollo.LoadForm(self.xmlDoc, "WorldMarkersPlacementForm", "FixedHudStratum", self)
		if self.wndMain == nil or self.wndPlacement == nil then
			Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.")
			return
		end
		
	    self.wndMain:Show(true, true)
		self.wndPlacement:Show(true, true)
	
		-- if the xmlDoc is no longer needed, you should set it to nil
		self.xmlDoc = nil
		
		-- Register handlers for events, slash commands and timer, etc.
		-- e.g. Apollo.RegisterEventHandler("KeyDown", "OnKeyDown", self)
		--self.wndMain:Invoke()
		Apollo.RegisterEventHandler("GameClickWorld", "OnGameClickWorld", self)
		self.timer = ApolloTimer.Create(0.01, true, "OnTimer", self)


		-- Do additional Addon initialization here
	end
end

-----------------------------------------------------------------------------------------------
-- WorldMarkers Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here

function WorldMarkers:OnTimer()
	for i=1,#self.markers do
		local m = self.markers[i]
		if m.worldLoc ~= nil then
			local screenPos = GameLib.WorldLocToScreenPoint(m.worldLoc)
			self.wndMain:UpdatePixie(m.pixie, {
				strSprite = m.sprite,
				loc = {
					nOffsets = {screenPos.x-25,screenPos.y-25,screenPos.x+25,screenPos.y+25}
				}
			})
		end
	end
end

function WorldMarkers:OnGameClickWorld(loc)
	local marker = self.markers[self.currentUpdateMarker]
	if marker == nil then
		return
	end
	
	self:SetMarker(self.currentUpdateMarker, loc)
end

function WorldMarkers:ClearMarker(i)
	local marker = self.markers[i]
	self.wndMain:DestroyPixie(marker.pixie)
	marker.pixie = nil
	marker.worldLoc = nil
end

function WorldMarkers:SetMarker(i, loc)
	local marker = self.markers[i]
	self:ClearMarker(i)
	marker.worldLoc = loc
	marker.pixie = self.wndMain:AddPixie(self:GenMarkerPixie(i))
end

function WorldMarkers:GenMarkerPixie(i)
	local marker = self.markers[i]
	local screenPos = GameLib.WorldLocToScreenPoint(marker.worldLoc)
	return {
		strSprite = marker.sprite,
		loc = {
			nOffsets = {screenPos.x-25,screenPos.y-25,screenPos.x+25,screenPos.y+25}
		}
	}
end


-----------------------------------------------------------------------------------------------
-- WorldMarkers Instance
-----------------------------------------------------------------------------------------------
local WorldMarkersInst = WorldMarkers:new()
WorldMarkersInst:Init()
