
local class = require "mini.class"

return class("box.setup.g.dofile", {
	init = function(self, parent)
		assert( type(parent) == "table" )
		self.parent = parent
		local loads = assert( parent:addon("loads") )
                parent.privenv.dofile = function(filename) return loads:dofile(filename) end -- exposed it in global env
	end,
})
