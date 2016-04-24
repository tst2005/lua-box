
local class = require "mini.class"

return class("box.setup.g.getmetatable", {
	init = function(self, parent)
		assert( type(parent) == "table" )
		self.parent = parent

		local meta = parent:addon("meta")
		parent.privenv.getmetatable = function(value, table) return meta:getmetatable(value, table) end
	end,
})
