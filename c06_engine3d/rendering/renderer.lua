-- Class: 3D Object Renderer
-- SDK: Corona - 09/12/11
-- Date: 02/03/12
-- Site: http://www.biorhythmgames.com
-- Contact: andrew@biorhythmgames.com
-- Note: Renders a 3D object to screen using various methods

local vector = require('math.vector')

local floor = math.floor
local mathmax = math.max
local _ipairs = ipairs


local Renderer = {}
local Renderer_mt = {__index = Renderer}

function Renderer.new(params)
	local displayGroup = display.newGroup()
	
	local class = {
		displayGroup = displayGroup,
	}
	
	return setmetatable(class, Renderer_mt)
end

function Renderer:initialise(params)
	local displayGroup = self.displayGroup
	
	-- used for vertex only rendering
	local vertObjects = {}
	local maxVerts = 8
	for i = 1, maxVerts do
		local circle = display.newCircle(displayGroup, 0, 0, 3)
		circle:setFillColor(200, 200, 200)
		circle.isVisible = false
		vertObjects[#vertObjects + 1] = circle
	end
	
	-- used for rendering polygons
	local polyLines = {}
	local maxLines = 580
	for i = 1, maxLines do
		local slice = display.newRect(displayGroup, 0, 0, 4, 1)
		slice:setFillColor(0, 0, 0)
		slice.isVisible = false
		polyLines[#polyLines + 1] =  slice
	end
	
	-- used for rendering textured polys
	local textureObjects = {}
	local maxTextureObjects = 11180
	for i = 1, maxTextureObjects do
		local dot = display.newRect(displayGroup, 0, 0, 1, 1)
		dot:setFillColor(0, 0, 0)
		dot.isVisible = false
		textureObjects[#textureObjects + 1] = dot
	end
	
	self.maxVerts = maxVerts
	self.maxLines = maxLines
	self.polyLines = polyLines
	self.vertObjects = vertObjects
	self.textureObjects = textureObjects
	self.wireLines = {}
end

function Renderer:setRenderMode(mode)
	self.renderMode = mode
	
	local polyFillModes = {
		['flat'] = true,
		['glenz'] = true,
		['light'] = true,
	}

	-- reset poly lines
	local polyLines = self.polyLines
	local polyLineCount = #polyLines
	for i = 1, polyLineCount do
		local line = polyLines[i]
		line.isVisible = polyFillModes[mode] or false
		line.alpha = 0
	end
	
	-- reset vert objects
	local vertObjects = self.vertObjects
	for _, v in _ipairs(vertObjects) do
		v.isVisible = mode == 'vert'
	end
	
	-- reset texture objects
	local textureObjects = self.textureObjects
	for _,v in _ipairs(textureObjects) do
		v.isVisible = mode == 'texture'
		v.alpha = 0
	end
	
	-- clear wireframe lines
	local wireLines = self.wireLines
	local displayGroup = self.displayGroup
	for _, v in _ipairs(wireLines) do
		displayGroup:remove(v)
	end
	
	self.wireLines = {}
end

function Renderer:renderObject(params)
	local mode = self.renderMode

	if mode == 'wire' then	
		self:renderObjectWireframe(params)
	elseif mode == 'vert' then
		self:renderObjectVerts(params)
	elseif mode == 'texture' then
		self:renderObjectTexturedPolys(params)
	else
		self:renderObjectPolys(params)
	end
end

function Renderer:renderObjectPolys(params)
	local polyLines = self.polyLines

	local displayWidth = params.displayWidth
	local displayHeight = params.displayHeight
	local object = params.object
	local useLightMap = params.lightMap
	local lightVector = params.lightVector
	local alpha = params.polyAlpha

	local renderPolys = self:buildRenderPolys(params)

	local lineIndex = 1
	
	for _, poly in _ipairs(renderPolys) do
		local xlist = {}
		local verts = poly.vertList
		local miny = displayHeight
		local maxy = 0
		for _, vert in _ipairs(verts) do
			miny = vert.y < miny and vert.y or miny
			maxy = vert.y > maxy and vert.y or maxy
		end
		
		for i = 1, 4 do
			local index1 = i
			local index2 = i == 4 and 1 or i + 1
			self:scanEdge(xlist, {
						displayWidth = displayWidth, 
						vert1 = {x = verts[index1].x, y = verts[index1].y}, 
						vert2 = {x = verts[index2].x, y = verts[index2].y}, 
						ignoreUV = true,
					})
		end

		local faceColour = poly.faceColour
		local red = faceColour.r
		local green = faceColour.g
		local blue = faceColour.b
		if useLightMap then
			local normal = poly.normal
		    local lightFactor = (normal.x * lightVector.x) + (normal.y * lightVector.y) + (normal.z * lightVector.z)
		    red = red * lightFactor
		    green = green * lightFactor
		    blue = blue * lightFactor
		end
		for y = miny, maxy do
			local line = polyLines[lineIndex]
			local lineInfo = xlist[y]
			local min = lineInfo.min
			local max = lineInfo.max
			local lineLength = max.x - min.x

			if lineLength > 0 then
				local x = min.x + (lineLength  * 0.5)
				line:setFillColor(red, green , blue)
				line.x = x
				line.y = y
				line.width = lineLength
				line.alpha = alpha
				
				lineIndex = lineIndex + 1
			end
		end
	end

	local linesUsed = lineIndex - 1
	local lastUsedLineCount = self.lastUsedLineCount or 0
	if linesUsed < lastUsedLineCount then
		for i = lineIndex, lastUsedLineCount do
			local line = polyLines[i + 1]
			line.alpha = 0
		end
	end

	self.lastUsedLineCount = lineIndex
end

function Renderer:renderObjectTexturedPolys(params)
	local textureObjects = self.textureObjects

	local displayWidth = params.displayWidth
	local displayHeight = params.displayHeight
	local textureData = params.textureData
	local textCords = params.textCords
	local object = params.object
	
	local renderPolys = self:buildRenderPolys(params)

	local textureObjectIndex = 1
	local maxResourced = #textureObjects

	for _, poly in _ipairs(renderPolys) do
		local xlist = {}

		local verts = poly.vertList
		local miny = displayHeight
		local maxy = 0
		for _, vert in _ipairs(verts) do
			miny = vert.y < miny and vert.y or miny
			maxy = vert.y > maxy and vert.y or maxy
		end
		
		for i = 1, 4 do
			local index1 = i
			local index2 = i == 4 and 1 or i + 1
			self:scanEdge(xlist, {
						displayWidth = displayWidth, 
						vert1 = {x = verts[index1].x, y = verts[index1].y}, 
						vert2 = {x = verts[index2].x, y = verts[index2].y}, 
						uv1 = {x = textCords[index1].x, y = textCords[index1].y},
						uv2 = {x = textCords[index2].x, y = textCords[index2].y},
					})
		end
		
		for y = miny, maxy do
			local scanLineInfo = xlist[y]
			local min = scanLineInfo.min
			local max = scanLineInfo.max
			local lineLength = max.x - min.x
			
			if lineLength > 0 then
				local u = min.tx
				local v = min.ty
				local ustep = (max.tx - min.tx) / lineLength
				local vstep = (max.ty - min.ty) / lineLength

				for x = 0, lineLength - 1 do
					local obj = textureObjects[textureObjectIndex]
					local tu = floor(u)
					local tv = floor(v)
					local c = textureData[tv][tu]
					obj:setFillColor(c.r, c.g , c.b)
					obj.x = min.x + x
					obj.y = y
					obj.isVisible = true
					obj.alpha = 1
				
					textureObjectIndex = textureObjectIndex + 1
					u = u + ustep
					v = v + vstep
				end
			end
		end
	end
	
	local resourcesUsed = textureObjectIndex - 1
	local lastUsedTextureCount = self.lastUsedTextureCount or 0
	if resourcesUsed < lastUsedTextureCount then
		for i = textureObjectIndex, lastUsedTextureCount do
			local obj = textureObjects[i + 1]
			obj.isVisible = false
		end
	end

	self.lastUsedTextureCount = textureObjectIndex	
end

function Renderer:scanEdge(xlist, params)
	local displayWidth = params.displayWidth
	local vert1 = params.vert1
	local vert2 = params.vert2
	local uv1 = params.uv1
	local uv2 = params.uv2
	local ignoreuv = params.ignoreuv

	if vert1.y == vert2.y then
		return 
	end

	if vert1.y > vert2.y then
		local vt = vert2
		vert2 = vert1
		vert1 = vt
		local uvt = uv2
		uv2 = uv1
		uv1 = uvt
	end

	local scanLineCount = vert2.y - vert1.y
	local xstep = ((vert2.x - vert1.x) * 256) / scanLineCount
	local xpos = vert1.x * 256

	local txstep = 0
	local tystep = 0
	local tx = 0
	local ty = 0

	local ignoreUV = params.ignoreUV
	if not ignoreUV then
		txstep = (uv2.x - uv1.x) / scanLineCount
		tystep = (uv2.y - uv1.y) / scanLineCount
		tx = uv1.x
		ty = uv1.y
	end
	
	for i = vert1.y, vert2.y do
		local xfloor = floor(xpos / 256)
		if not xlist[i] then
			xlist[i] = {
				min = {
					x = displayWidth,
					tx = 0,
					ty = 0,
				},
				max = {
					x = -displayWidth,
					tx = 0,
					ty = 0,
				},
			}
		end
		
		local min = xlist[i].min
		local max = xlist[i].max
		if xfloor < min.x then 
			min.x = xfloor
			
			if not ignoreUV then
				min.tx = mathmax(floor(tx), 0)
				min.ty = mathmax(floor(ty), 0)
			end
		end
		
		if xfloor > max.x then
			max.x = xfloor

			if not ignoreUV then
				max.tx = mathmax(floor(tx), 0)
				max.ty = mathmax(floor(ty), 0)
			end
		end

		tx = tx + txstep
		ty = ty + tystep		
		xpos = xpos + xstep
	end
end

function Renderer:buildRenderPolys(params)
	local object = params.object
	local faceColours = params.faceColours
	local removeHiddenSurface = params.removeHiddenSurface

	local polyList = object:getSortedPolyList()
	local vertList = object:getRotatedVertList()
	local faceNormals = object:getRotatedFaceNormals()

	local xoffset = object:getAxisOffset('x')
	local yoffset = object:getAxisOffset('y')
	local zoffset = object:getAxisOffset('z')
	
	local renderPolys = {}
	for _, poly in _ipairs(polyList) do
		local transformedVerts = {}
		local polyVerts = poly.verts

		for i, vertIndex in _ipairs(polyVerts) do
			local vert = vertList[vertIndex]
			local z = vert.z + zoffset
			local x = floor((256 * vert.x / z) + xoffset)
			local y = floor((256 * vert.y / z) + yoffset)
			
			transformedVerts[i] = {
								x = x,
								y = y,
								z = z,
							}
		end

		local isVisible = true		
		if removeHiddenSurface then
			local faceNormal = vector.faceZNormal3(transformedVerts)
	    	isVisible = faceNormal > 0
	    end

	    if isVisible then
	    	renderPolys[#renderPolys + 1] = { 
	    			vertList = transformedVerts, 
	    			faceColour = faceColours[poly.id], 
	    			normal = poly.normal,
	    		}
	  	end
	end
	
	return renderPolys
end

function Renderer:renderObjectWireframe(params)
	local displayGroup = self.displayGroup
	local wireLines = self.wireLines

	-- clear existing lines
	for i = 1, #wireLines do
		local line = wireLines[i]
		displayGroup:remove(line)
		wireLines[i] = nil
	end	
	
	local renderPolys = self:buildRenderPolys(params)	

	for _, v in _ipairs(renderPolys) do
		local vertList = v.vertList
		local vertCount = #vertList
		for i = 1, vertCount do
			local v1 = i
			local v2 = i == vertCount and 1 or i + 1
			local x1 = vertList[v1].x
			local y1 = vertList[v1].y
			local x2 = vertList[v2].x
			local y2 = vertList[v2].y
			
			local line = display.newLine(displayGroup, x1, y1, x2, y2)
			line:setColor(200, 200, 200)
			line.strokeWidth = 2
			
			wireLines[#wireLines + 1] = line
		end
	end
end

function Renderer:renderObjectVerts(params)
	local vertObjects = self.vertObjects

	local displayWidth = params.displayWidth
	local displayHeight = params.displayHeight
	local object = params.object

	local xoffset = object:getAxisOffset('x')
	local yoffset = object:getAxisOffset('y')
	local zoffset = object:getAxisOffset('z')

	local rotatedVerts = object:getRotatedVertList()
	
	for i, vert in _ipairs(rotatedVerts) do
		local z = vert.z + zoffset
		local zClipped = z >= 0
		local renderObject = vertObjects[i]
		renderObject.alpha = zClipped and 0 or 1
		
		if not zClipped then
			renderObject.x = floor(256 * vert.x / z) + xoffset
			renderObject.y = floor(256 * vert.y / z) + yoffset
		end
	end	
end

return Renderer