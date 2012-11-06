-- Class: Input Handler
-- SDK: Corona - 09/12/11
-- Date: 08/02/12
-- Site: http://www.biorhythmgames.com
-- Contact: andrew@biorhythmgames.com
-- Note: Process touch events to handle input for the camera
--

local abs = math.abs
local max = math.max
local min = math.min
local _ipairs = ipairs

local Input = {}
local Input_mt = {__index = Input}

function Input.new(params)
	local displayGroup = display.newGroup()

	local input = {
		displayGroup = displayGroup,
	}
	
	return setmetatable(input, Input_mt)
end

function Input:initialise(params)
	local displayGroup = self.displayGroup
	
	local displayWidth = params.displayWidth
	local buttonWidth = params.buttonWidth
	local buttonHeight = params.buttonHeight
	local sideBorder = params.sideBorder
	local turnAcceleration = params.turnAcceleration
	local movementAcceleration = params.movementAcceleration

	local rightButtonSetX = displayWidth - sideBorder - buttonWidth
	
	local phaseStateMap = {
		['began'] = true,
		['moved'] = true,
		['ended'] = false,
		['cancelled'] = false,
	}
	
	local buttonConfig = {
		{
			x = sideBorder,
			y = 240,
			modifierName = 'turnAcceleration',
			modiferValue = -turnAcceleration,
			stateName = 'isTurning',
		},
		{
			x = 80,
			y = 240,
			modifierName = 'turnAcceleration',
			modiferValue = turnAcceleration,
			stateName = 'isTurning',
		},
		{
			x = rightButtonSetX,
			y = 200,
			modifierName = 'movementAcceleration',
			modiferValue = movementAcceleration,
			stateName = 'isMoving',
		},
		{
			x = rightButtonSetX,
			y = 260,
			modifierName = 'movementAcceleration',
			modiferValue = -movementAcceleration,
			stateName = 'isMoving',
		},
	}		
	
	for _, v in _ipairs(buttonConfig) do
		local button = display.newRoundedRect(displayGroup, v.x, v.y, buttonWidth, buttonHeight, 4)
		button.strokeWidth = 2
		button:setFillColor(140, 140, 140, 100)
		button:setStrokeColor(180, 180, 180, 100)
		button:addEventListener('touch', function(event)
									local phase = event.phase
									local state = phaseStateMap[phase] 
									
									local modifierName = v.modifierName
									local modiferValue = v.modiferValue
									local stateName = v.stateName
									
									self[modifierName] = state and modiferValue or nil
									self[stateName] = state
									
									return true
								end)
	end
	
	self.movementSpeed = 0
	self.turnSpeed = 0		
end

function Input:update(dt, time, params)
	local isMoving = self.isMoving
	local movementSpeed = self.movementSpeed
	if isMoving then
		local movementAcceleration = self.movementAcceleration
		local maxMovementSpeed = params.maxMovementSpeed
		local newSpeed = movementSpeed + movementAcceleration
		newSpeed = max(min(newSpeed, maxMovementSpeed), -maxMovementSpeed)
		self.movementSpeed = newSpeed
	end
	
	if not isMoving and movementSpeed ~= 0 then
		local moveDeccelerateFactor = params.moveDeccelerateFactor
		local newSpeed = movementSpeed * moveDeccelerateFactor
		if abs(newSpeed) < 0.1 then
			newSpeed = 0
		end
		
		self.movementSpeed = newSpeed
	end

	local isTurning = self.isTurning
	local turnSpeed = self.turnSpeed
	if isTurning then
		local turnAcceleration = self.turnAcceleration
		local maxTurnSpeed = params.maxTurnSpeed
		local newSpeed = turnSpeed + turnAcceleration
		newSpeed = max(min(newSpeed, maxTurnSpeed), -maxTurnSpeed)
		self.turnSpeed = newSpeed
	end
	
	if not isTurning and turnSpeed ~= 0 then
		local turnDeccelerateFactor = params.turnDeccelerateFactor
		local newSpeed = turnSpeed * turnDeccelerateFactor
		if abs(newSpeed) < 0.1 then
			newSpeed = 0
		end
		
		self.turnSpeed = newSpeed
	end	
end

function Input:registerWithParent(parentDisplayGroup)
	parentDisplayGroup:insert(self.displayGroup)
end

function Input:toFront()
	self.displayGroup:toFront()
end

function Input:getTurnSpeed()
	return self.turnSpeed
end

function Input:getMovementSpeed()
	return self.movementSpeed
end


return Input