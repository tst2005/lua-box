
local class = require "mini.class"
local assertlevel = require "mini.assertlevel"

return class("box.setup.g.string", {
	init = function(self, parent)
		assertlevel( type(parent) == "table", "parent", 2)
		self.parent = parent

		local string = assert( parent:addon("string").string, "parent:adddon('string').string")
                parent.privenv.string     = string -- exposed it in global env
	end,
})
