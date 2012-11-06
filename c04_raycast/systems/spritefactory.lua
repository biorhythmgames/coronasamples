-- Class: SpriteFactory
-- SDK: Corona - 09/12/11
-- Date: 10/03/2012
-- Site: http://www.biorhythmgames.com
-- Contact: andrew@biorhythmgames.com
-- Notes: Handle construction and cleanup of game sprite sets & sequences
--

local sprite = require('sprite')
local tablex = require('core.tablex')

local SpriteFactory = {}
local SpriteFactory_mt = {__index = SpriteFactory}

function SpriteFactory.new(params)
	local class = {
		library = {},
	}
	
	return setmetatable(class, SpriteFactory_mt)
end

function SpriteFactory:initialiseFromConfig(config)
	for _, sheet in ipairs(config) do
		self:newUniformSpriteSheet(sheet)

		for _, set in ipairs(sheet.sets) do
			self:createSet {
					id = sheet.id,
					setId = set.id,
					startFrame = set.startFrame,
					frameCount = set.frameCount,
				}
						
			for _, sequence in ipairs(set.sequences) do
				self:createSequence {
						id = sheet.id,
						setId = set.id,
						sequenceName = sequence.name,
						startFrame = sequence.startFrame,
						frameCount = sequence.frameCount,
						duration = sequence.duration,
						loop = 0,
					}
			end
		end
	end
end

function SpriteFactory:newUniformSpriteSheet(params)
	local id = params.id
	local filename = params.filename
	local frameWidth = params.frameWidth
	local frameHeight = params.frameHeight

	local newSheet = sprite.newSpriteSheet(filename, frameWidth, frameHeight)
	assert(newSheet)
	
	self.library[id] = {
		sheet = newSheet,
		sets = {},
		sequences = {},
	}
end

function SpriteFactory:createSet(params)
	local id = params.id
	local setId = params.setId
	
	local library = self.library
	local info = library[id]

	local sets = info.sets
	
	local sheet = info.sheet
	local startFrame = params.startFrame
	local frameCount = params.frameCount
	local set = sprite.newSpriteSet(sheet, startFrame, frameCount)
	
	local sets = info.sets
	sets[setId] = set
end

function SpriteFactory:createSequence(params)
	local id = params.id
	local setId = params.setId
	
	local library = self.library
	local info = library[id]
	
	local sets = info.sets
	local set = sets[setId]
	
	local sequenceName = params.sequenceName
	local startFrame = params.startFrame
	local frameCount = params.frameCount
	local duration = params.duration
	local loop = params.loop
	
	sprite.add(set, sequenceName, startFrame, frameCount, duration, loop)
	
	local sequences = info.sequences
	sequences[sequenceName] = true
end

function SpriteFactory:createInstance(id, setId)
	local library = self.library
	local info = library[id]
	local sets = info.sets
	local set = sets[setId]
	local instance = sprite.newSprite(set)

	return instance
end

function SpriteFactory:disposeSheet(id)
	local library = self.library
	local info = library[id]
	if info then
		local sheet = info.sheet
		sheet:dispose()
		
		library[id] = nil
	end
end

function SpriteFactory:disposeAll()
	local library = self.library
	for id, info in pairs(library) do
		local sheet = info.sheet
		sheet:dispose()
	end
	
	tablex.clear(self.library)
end

return SpriteFactory