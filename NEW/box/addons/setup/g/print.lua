
local class = require "mini.class"

local assertlevel = require "mini.assertlevel"
local tcopy = require "mini.tcopy"
local table_concat = table.concat

return class("box.setup.print", {
	init = function(self, parent)
		self.parent = assert( type(parent) == "table" and table )
		local privenv = parent.privenv

--		parent:addon("setup.id")

		local id = parent:addon("id")
		privenv.print = function(...)
			print( table_concat( id:alltostring(...), "\t") )
		end
	end,
})
