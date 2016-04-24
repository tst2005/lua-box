
local class = require "mini.class"
local assertlevel = require "mini.assertlevel"

return class("box.setup.g.tostring", {
	init = function(self, parent)
		self.parent = assert( type(parent) == "table" and table )
		local id = parent:addon("id")
		parent.privenv.tostring = function(x)
			return id:tostring(x)
		end
	end,
})
