-- Project: 3D Object Demo
-- SDK: Corona - 09/12/11
-- Author: Andrew Burch
-- Date: 02/03/12
-- Site: http://www.biorhythmgames.com
-- Contact: andrew@biorhythmgames.com
-- Note: 3D Object Rendering Demo

local tablex = require('core.tablex')
local button = require('core.button')
local cubedata = require('data.cubedata')
local engine = require('engine.engine')
local shape3d = require('objects.shape3d')
local renderer = require('rendering.renderer')
local buttonconfig = require('config.buttonconfig')


-- hide the status bar
local displayGroup = display.newGroup()
display.setStatusBar(display.HiddenStatusBar)

local contentWidth = display.contentWidth
local contentHeight = display.contentHeight
local halfContentWidth = math.floor(contentWidth * 0.5)
local halfContentHeight = math.floor(contentHeight * 0.5)

-- setup background
local background = display.newRect(0, 0, contentWidth, contentHeight)
background:setFillColor(0, 0, 0)


-- initialise render system
local renderSystem = renderer.new()
renderSystem:initialise()

-- initialise the engine
local engine3d = engine.new()
engine3d:initialise()

-- initiaise a 3d object
local cube = shape3d.new()
cube:initialise {
			vertList = cubedata.vertList,
			polyList = cubedata.polyList,
			xoffset = halfContentWidth,
			yoffset = halfContentHeight,
			zoffset = -64,
			zang = 0,
		}

engine3d:registerObject {
			id = 'cube', 
			object = cube, 
			rotationSequence = cubedata.rotationSequence,
		}

renderSystem:setRenderMode('glenz')

local removeHiddenSurface = false
local lightMap = false
local polyAlpha = 0.5
local lightVector = {x = 0, y = 0, z = -1}


-- setup demo buttons
local demoButtons = buttonconfig.demoButtons
local buttonTop = buttonconfig.buttonTop
local buttonLeft = buttonconfig.buttonLeft
local buttonSpacing = buttonconfig.buttonSpacing

for i, v in ipairs(demoButtons) do
	local top = buttonTop + (i * buttonSpacing)
	local buttonText = v.text
	local customParams = v.params

	local btn = button.new()
	btn:initialise {
				top = top,
				left = buttonLeft,
				width = buttonconfig.buttonWidth,
				height = buttonconfig.buttonHeight,
				strokeWidth = buttonconfig.strokeWidth,
				fontSize = buttonconfig.fontSize,
				fillColour = buttonconfig.fillColour,
				strokeColour = buttonconfig.strokeColour,
				text = buttonText,
			}
			
	btn:addEventListener('touch', function(event)
								local phase = event.phase
								if phase ~= 'began' then
									return
								end 
								
								local selectedMode = customParams.mode
								
								if renderMode ~= selectedMode then
									removeHiddenSurface = customParams.removeHiddenSurface
									lightMap = customParams.lightMap
									polyAlpha = customParams.polyAlpha
								
									renderSystem:setRenderMode(selectedMode)
								end
								
								return true
							end)
end


local faceColours = cubedata.faceColours
local textureData = cubedata.textureData
local textureCords = cubedata.textureCords
local lastUpdateTime = 0

local floor = math.floor
local fpsText = display.newText('fps: 0', contentWidth - 50, 30, native.systemFont, 10)
local dtAccumulate = 0
local dtIterations = 0


-- register main update listener
Runtime:addEventListener("enterFrame", function(event) 
											local time = event.time
											local dt = (time - lastUpdateTime) / 1000

											engine3d:update(dt, time)
											
											renderSystem:renderObject {
															object = engine3d:getObject('cube'),
															renderMode = renderMode,
															faceColours = faceColours,
															textureData = textureData,
															textCords = textureCords,
															removeHiddenSurface = removeHiddenSurface,
															lightMap = lightMap,
															polyAlpha = polyAlpha,
															lightVector = lightVector,
															displayWidth = contentWidth,
															displayHeight = contentHeight,
														}
														
											dtAccumulate = dtAccumulate + dt
											dtIterations = dtIterations + 1
											if dtAccumulate >= 1 then
												fpsText.text = 'fps: ' .. (dtIterations)
												dtAccumulate = 0
												dtIterations = 0
											end
											
											lastUpdateTime = time											
										end)
