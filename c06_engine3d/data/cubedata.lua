-- Project: 3D Object Demo
-- Date: 02/03/12
-- Site: http://www.biorhythmgames.com
-- Contact: andrew@biorhythmgames.com
-- Note: 3D object data

module(..., package.seeall)

-- raw verts
vertList = {
	{x = -10, y = -10, z = 10},
	{x = 10, y = -10, z = 10},
	{x = 10, y = 10, z = 10},
	{x = -10, y = 10, z = 10},
	{x = -10, y = -10, z = -10},
	{x = 10, y = -10, z = -10},
	{x = 10, y = 10, z = -10},
	{x = -10, y = 10, z = -10},
}

-- object polygons (4 points)
polyList = {
	{
		id = 1, 		--front
		verts = {4, 3, 2, 1},
	},
	{
		id = 2, 		--back
		verts = {7, 8, 5, 6},
	},
	{
		id = 3, 		--top
		verts = {8, 7, 3, 4},
	},
	{
		id = 4, 		--base
		verts = {1, 2, 6, 5},
	},
	{
		id = 5,			--right
		verts = {8, 4, 1, 5},
	},
	{
		id = 6, 		--left
		verts = {2, 3, 7, 6},
	},
}

-- render colours for face polys
faceColours = {
	{r = 200, g = 0, b = 0},
	{r = 0, g = 200, b = 0},
	{r = 0, g = 0, b = 200},
	{r = 200, g = 200, b = 0},
	{r = 0, g = 200, b = 200},
	{r = 200, g = 0, b = 200},
}

-- rotation sequence for the object
rotationSequence = {
	{
		axis = 'z',
		angleStep = 1.0,
	},
	{
		axis = 'x',
		angleStep = 2.5
	},
}

-- texture coordinates
textureCords = {
	{x = 0, y = 0},
	{x = 63, y = 0},
	{x = 63, y = 63},
	{x = 0, y = 63},
}

-- pregenerate texture for testing
textureData = {}
for y = 0, 63 do
	local data = {}
	for x = 0, 63 do
		if x == 0 or x == 63 or y == 0 or y == 63 then
			data[x] = {
				r = 230,
				g = 0,
				b = 0,
			}
		elseif x % 10 == 0 then
			data[x] = {
				r = 250,
				g = 250,
				b = 250,
			}
		else
			data[x] = {
				r = 0,
				g = 180,
				b = 0,
			}
		end
	end
	textureData[y] = data
end