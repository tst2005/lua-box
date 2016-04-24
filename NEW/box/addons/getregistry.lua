
local class = require "mini.class"
local assertlevel = require "mini.assertlevel"

return class("box.getregistry", {
	init = function(self, parent)
		assertlevel( type(parent) == "table", "parent", 2)
		self.parent = parent

		self.registry = {} -- a empty registry to allow other modules to inject their info.
	end,
})
