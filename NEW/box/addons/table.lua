

-- require "table" => a table with key+value, no metatable

local class = require "mini.class"
local tcopy = require "mini.tcopy"

local native_table = require "table"

local table_class = class("box.table", {
	init = function(self, parent)
		assert( type(parent) == "table" )
		self.parent = parent

		self.table = tcopy(native_table, {})
	end,
})

return table_class

