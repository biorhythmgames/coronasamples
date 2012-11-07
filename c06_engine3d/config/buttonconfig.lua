-- Project: 3D Object Demo
-- Date: 02/03/12
-- Site: http://www.biorhythmgames.com
-- Contact: andrew@biorhythmgames.com
-- Note: Button config variables for the demo

module(..., package.seeall)

buttonTop = 10
buttonLeft = 15
buttonWidth = 50
buttonHeight = 20
buttonSpacing = (buttonHeight + 15)
strokeWidth = 3
fontSize = 12

fillColour = {
	r = 0, 
	g = 0, 
	b = 140,
	a = 120,
}

strokeColour = {
	r = 100,
	g = 100,
	b = 220,
	a = 160,
}

demoButtons = {
	{
		text = 'Map',
		params = {
			mode = 'texture',
			removeHiddenSurface = true,
			lightMap = false,
			polyAlpha = 1,
		},
	},
	{
		text = 'Glenz',
		params = {
			mode = 'glenz',
			removeHiddenSurface = false,
			lightMap = false,
			polyAlpha = 0.5,
		},
	},
	{
		text = 'Light',
		params = {
			mode = 'light',
			removeHiddenSurface = true,
			lightMap = true,
			polyAlpha = 1,
		},
	},
	{
		text = 'Flat',
		params = {
			mode = 'flat',
			removeHiddenSurface = true,
			lightMap = false,
			polyAlpha = 1,
		},
	},
	{
		text = 'Wire',
		params = {
			mode = 'wire',
			removeHiddenSurface = true,
			lightMap = false,
			polyAlpha = 1,
		},
	},
	{
		text = 'Vert',
		params = {
			mode = 'vert',
			removeHiddenSurface = false,
			lightMap = false,
		},
	},
}