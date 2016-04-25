
local assertlevel = require "mini.assertlevel"
local tcopy = require "mini.tcopy"

local table_concat = require "table".concat
local native_print = _G.print

return function(_self, parent)
	assert( type(parent) == "table", "parent")

	local id = parent:addon("id")
	parent.privenv.print = function(...)
		native_print( table_concat( id:alltostring(...), "\t") )
	end
end
