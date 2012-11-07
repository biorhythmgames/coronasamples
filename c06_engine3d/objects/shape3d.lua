-- Class: Shape3D
-- Date: 02/03/12
-- Site: http://www.biorhythmgames.com
-- Contact: andrew@biorhythmgames.com
-- Note: 3D Object

local vector = require('math.vector')

local Shape3d = {}
local Shape3d_mt = {__index = Shape3d}

function Shape3d.new(params)
	local class = {
		vertList = {},
		polyList = {},
		faceNormals = {},
		rotatedVertList = {},
		rotatedFaceNormals = {},
		sortedPolys = {},
		rotationAngles = {
			x = 0,
			y = 0, 
			z = 0,
		},
		axisOffsets = {
			x = 0,
			y = 0,
			z = 0,
		},
	}
	
	return setmetatable(class, Shape3d_mt)
end

function Shape3d:initialise(params)
	local polyList = params.polyList
	local vertList = params.vertList

	-- face normals
	local faceNormals = {}
	for i, polyInfo in ipairs(polyList) do
		local polyVerts = polyInfo.verts
		local vert1 = vertList[polyVerts[1]]
		local vert2 = vertList[polyVerts[2]]
		local vert3 = vertList[polyVerts[3]]
		local vert4 = vertList[polyVerts[4]]
		
		local vect1 = vector.subtract3(vert2, vert1)
		local vect2 = vector.subtract3(vert3, vert1)
		local vect3 = vector.cross3(vect1, vect2)

		local normal = vector.normalise3(vect3)

		table.insert(faceNormals, normal)
	end	
	
	local rotationAngles = self.rotationAngles
	rotationAngles.x = params.xang or 0
	rotationAngles.y = params.yang or 0
	rotationAngles.z = params.zang or 0
	
	local axisOffsets = self.axisOffsets	
	axisOffsets.x = params.xoffset or 0
	axisOffsets.y = params.yoffset or 0
	axisOffsets.z = params.zoffset or 0
	
	self.vertList = vertList
	self.polyList = polyList	
	self.faceNormals = faceNormals
end

function Shape3d:getRotationAngle(axis)
	local rotationAngles = self.rotationAngles
	return rotationAngles[axis]
end

function Shape3d:updateRotationAngle(axis, step)
	local rotationAngles = self.rotationAngles
	local old = rotationAngles[axis]
	local new = old + step
	if new > 360 then 
		new = new - 360
	end
	
	rotationAngles[axis] = new
end

function Shape3d:resetRotation()
	local rotationAngles = self.rotationAngles
	for k,v in pairs(rotationAngles) do
		rotationAngles[k] = 0
	end
end

function Shape3d:getRotation()
	return self.rotationAngles
end

function Shape3d:getVertList()
	return self.vertList
end

function Shape3d:getFaceNormals()
	return self.faceNormals
end

function Shape3d:getPolyList()
	return self.polyList
end

function Shape3d:setRotatedVertList(verts)
	self.rotatedVerts = verts
end

function Shape3d:setRotatedFaceNormals(normals)
	self.rotatedFaceNormals = normals
end

function Shape3d:setSortedPolyList(polys)
	self.sortedPolys = polys
end

function Shape3d:getSortedPolyList()
	return self.sortedPolys
end

function Shape3d:getRotatedVertList()
	return self.rotatedVerts
end

function Shape3d:getRotatedFaceNormals()
	return self.rotatedFaceNormals
end

function Shape3d:getAxisOffset(axis)
	return self.axisOffsets[axis]
end

return Shape3d