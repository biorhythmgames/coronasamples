-- Class: Basic Button
-- SDK: Corona - 09/12/11
-- Date: 14/01/2012
-- Site: http://www.biorhythmgames.com
-- Contact: andrew@biorhythmgames.com
-- Notes: Basic button with text and support for an event listener
--

local ceil = math.ceil

local Button = {}
local Button_mt = {__index = Button}

function Button.new(params)
	local displayGroup = display.newGroup()
	
	local button = {
		displayGroup = displayGroup,
	}
	
	return setmetatable(button, Button_mt)
end

function Button:initialise(params)
	local displayGroup = self.displayGroup
	
	local width = params.width
	local height = params.height
	local top = params.top
	local left = params.left
	local text = params.text
	local fill = params.fillColour
	local stroke = params.strokeColour
	local strokeWidth = params.strokeWidth
	local fontSize = params.fontSize
	
	local backRect = display.newRoundedRect(displayGroup, left, top, width, height, strokeWidth)
	backRect:setReferencePoint(display.TopLeftReferencePoint)
	backRect:setFillColor(fill.r, fill.g, fill.b, fill.a)
	backRect:setStrokeColor(stroke.r, stroke.g, stroke.b, stroke.a)
	backRect.strokeWidth = 2

	local text = display.newText(displayGroup, text, left, top + 3, native.systemFont, fontSize)
	text:setReferencePoint(display.TopLeftReferencePoint)
	text:setTextColor(220, 220, 220)
	text.x = left + ceil((width - text.width) * 0.5) + 1
	
	self.backRect = backRect
end

function Button:addEventListener(event, fn)
	self.backRect:addEventListener(event, fn)
end

function Button:registerWithParent(parentDisplayGroup)
	parentDisplayGroup:insert(self.displayGroup)
end

function Button:toFront()
	self.displayGroup:toFront()
end

return Button