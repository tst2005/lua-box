
local class = require "mini.class"
local assertlevel = require "mini.assertlevel"

return class("box.setup.g.require", {
	init = function(self, parent)
		assertlevel( type(parent) == "table", "parent", 2)
		self.parent = parent

		local pkg = parent:addon("pkg")
		parent.privenv.require = function(name, ...)
			return pkg:require(name, ...)
		end
	end,
})
