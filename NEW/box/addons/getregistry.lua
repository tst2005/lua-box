
local class = require "mini.class"

return class("box.getregistry", {
	init = function(self, parent)
		assert( type(parent) == "table" )
		self.parent = parent
		self.registry = {} -- a empty registry to allow other modules to inject their info.
	end,
})
