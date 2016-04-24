
local class = require "mini.class"

return class("box.setup.g.string", {
	init = function(self, parent)
		self.parent = assert( type(parent) == "table" and table )
		local string = assert( parent:addon("string").string )
                parent.privenv.string     = string -- exposed it in global env
	end,
})
