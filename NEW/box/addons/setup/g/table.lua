
local class = require "mini.class"
local assertlevel = require "mini.assertlevel"

return class("box.setup.g.table", {
	init = function(self, parent)
		assertlevel( type(parent) == "table", "parent", 2)
		self.parent = parent

		local table = assert( parent:addon("table").table, 'parent:addon("table").table')
                parent.privenv.table = table -- exposed it in global env
	end,
})
