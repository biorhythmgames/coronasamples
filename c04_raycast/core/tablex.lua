-- Module: TableX
-- Date: 14/01/2012
-- Site: http://www.biorhythmgames.com
-- Contact: andrew@biorhythmgames.com
-- Notes: Table extension functions
--

module(..., package.seeall)

local _pairs = pairs
local _ipairs = ipairs

-- removes all entries from a table
function clear(table)
	for k, v in _pairs(table) do
		table[k] = nil	
	end
	return table
end

function count(t)
	local count = 0
	for _,v in _pairs(t) do
		count = count + 1
	end
	return count
end

function icount(t)
	local i = 0
	for _, v in _ipairs(t) do
		i = i + 1
	end
	return i
end	
