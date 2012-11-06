-- Project: Raycasting Engine Demo
-- SDK: Corona - 09/12/11
-- Date: 08/02/2012
-- Site: http://www.biorhythmgames.com
-- Contact: andrew@biorhythmgames.com
-- Note: Map data and variables

module(..., package.seeall)

rowCount = 10
columnCount = 10

mapData = {
	{2,2,2,2,4,4,3,2,2,2},
	{2,0,0,2,0,0,0,0,0,2},
	{3,0,0,2,2,0,0,0,3,3},
	{3,0,0,4,0,0,0,0,0,2},
	{2,0,0,4,2,3,1,0,0,4},
	{2,0,0,0,2,0,0,0,0,3},
	{2,0,0,0,3,0,0,0,1,1},
	{2,4,0,0,0,0,0,0,0,3},
	{2,0,0,0,1,0,0,3,0,3},
	{2,2,2,1,1,1,2,2,2,2},
}

wallDefList = {
	{
		textureId = 'wall1',
		isSolid = true,
	},
	{
		textureId = 'wall2',
		isSolid = true,
	},
	{
		textureId = 'wall3',
		isSolid = true,
	},
	{
		textureId = 'wall4',
		isSolid = true,
	},
	{
		textureId = 'wall5',
		isSolid = true,
	},
}
