
local class = require "mini.class"

--local assertlevel = require "mini.assertlevel"

return class("box.setup.g.table", {
	init = function(self, parent)
		self.parent = assert( type(parent) == "table" and table )
		local table = assert( parent:addon("table").table )
                parent.privenv.table = table -- exposed it in global env
	end,
})
