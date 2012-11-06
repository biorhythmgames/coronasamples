-- Project: Raycasting Engine Demo
-- SDK: Corona - 09/12/11
-- Author: Andrew Burch
-- Date: 8/02/2012
-- Site: http://www.biorhythmgames.com
-- Contact: andrew@biorhythmgames.com
-- Note: Ported basic aspects from my C++ version of a simple raycasting engine

local map = require('config.map')
local button = require('core.button')
local input = require('input.input')
local renderer = require('rendering.renderer')
local raycastengine = require('raycast')

local floor = math.floor
local min = math.min


-- hide the status bar
display.setStatusBar(display.HiddenStatusBar)

local contentTop = 0
local contentLeft = 0
local contentWidth = display.contentWidth
local contentHeight = display.contentHeight
local horizon = contentTop + (contentHeight * 0.5)

-- setup background
local displayGroup = display.newGroup()
local ceiling = display.newRect(displayGroup, 0, 0, contentWidth, horizon)
ceiling:setFillColor(20,20,200)
local ground = display.newRect(displayGroup, 0, horizon, contentWidth, horizon)
ground:setFillColor(100,100,100)

--initialise camera
local mapCellSize = 64
local halfCellSize = mapCellSize * 0.5
local startingColumn = 2
local startingRow = 2
local startX = (startingColumn * mapCellSize) + halfCellSize
local startY = (startingRow * mapCellSize) + halfCellSize

local cameraInfo = {
	eyeLevel = halfCellSize,
	viewAngle = 0,
	xpos = startX,
	ypos = startY,
	mapX = startingColumn,
	mapY = startingRow,	
}

-- initialise the engine
local fov = 60
local maxRayDepth = 2

local engine = raycastengine.new()
engine:initialise { 
			visibleWidth = contentWidth,
			visibleHeight = contentHeight,
			mapRowCount = map.rowCount,
			mapColumnCount = map.columnCount,
			mapCellSize = mapCellSize,
			fov = fov,
			maxRayDepth = maxRayDepth,
			commonAngleList = {
				0, 30, 45, 90, 
				180, 270, 330, 360,
			},
		}

-- initialise rendering system
local renderingSystem = renderer.new()
renderingSystem:initialise {
			displayGroup = displayGroup,
			displayWidth = contentWidth,
			displayHeight = contentHeight,
			horizon = horizon,
			columnWidth = 1,
		}
					
-- initialise input system
local inputSystem = input.new()
inputSystem:initialise {
			buttonWidth = 36,
			buttonHeight = 36,
			displayWidth = contentWidth,
			sideBorder = 20,
			turnAcceleration = 2.0,
			movementAcceleration = 0.9,
		}
		
inputSystem:registerWithParent(displayGroup)

-- setup render mode button
local btn = button.new()
btn:initialise {
			top = 10,
			left = 10,
			width = 35,
			height = 20,
			strokeWidth = 2,
			fontSize = 10,
			fillColour = {r = 180, g = 180, b = 180, a = 150},
			strokeColour = {r = 220, g = 220, b = 220, a = 150},
			text = 'mode',
		}

btn:registerWithParent(displayGroup)

local renderModeTexture = 1
local renderModeSolid = 2
local renderMode = renderModeTexture

btn:addEventListener('touch', function(event)
							local phase = event.phase
							if phase ~= 'began' then
								return
							end 
					
							if renderMode == renderModeTexture then
								renderMode = renderModeSolid
							else
								renderMode = renderModeTexture
							end
									
							renderingSystem:setRenderMode(renderMode)

							return true
						end)

-- ensure input buttons on top
inputSystem:toFront()
btn:toFront()

-- movement variables
local maxTurnSpeed = 13.5
local maxMovementSpeed = 13.5
local turnDeccelerateFactor = 0.6	
local moveDeccelerateFactor = 0.82


local lastUpdateTime = 0
local fps = 50
local displayInfo = display.newText(displayGroup, "FPS: " .. fps, 30, 2, native.systemFont, 12)
displayInfo:toFront()

-- register main update listener
Runtime:addEventListener("enterFrame", function(event) 
											local time = event.time
											local dt = (time - lastUpdateTime) / 1000

											inputSystem:update(dt, time, {
																maxTurnSpeed = maxTurnSpeed,
																maxMovementSpeed = maxMovementSpeed,
																turnDeccelerateFactor = turnDeccelerateFactor,	
																moveDeccelerateFactor = moveDeccelerateFactor,	
															})
											
											local movementSpeed = inputSystem:getMovementSpeed()
											local turnSpeed = inputSystem:getTurnSpeed()
											
											engine:updateCameraPosition { 
																cameraInfo = cameraInfo,
																movementSpeed = movementSpeed,
																turnSpeed = turnSpeed,
																worldMap = map.mapData,
															}
															
											local sceneInfo = engine:processFrame(dt, time, {
																xpos = cameraInfo.xpos,
																ypos = cameraInfo.ypos,
																viewAngle = cameraInfo.viewAngle,
																worldMap = map.mapData,
																wallDefList = map.wallDefList,
																visibleWidth = contentWidth,
																maxRayDepth = maxRayDepth,
															})
											
											renderingSystem:renderScene { 
																displayGroup = displayGroup,
																sceneInfo = sceneInfo,
																horizon = horizon,
															}
															
								       		fps = floor(1 / dt)
								        	displayInfo.text = "FPS: " .. fps
																						
											lastUpdateTime = time											
										end)
