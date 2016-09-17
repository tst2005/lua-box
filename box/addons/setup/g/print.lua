
local assertlevel = require "mini.assertlevel"
--local tcopy = require "mini.table.shallowcopy"

local table_concat = require "table".concat
local native_print = _G.print

return function(_self, parent)
	assert( type(parent) == "table", "parent")

	local id = parent:wanted("id")
	parent.privenv.print = id.g.print 
end
