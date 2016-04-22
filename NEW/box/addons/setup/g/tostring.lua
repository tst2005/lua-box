
local class = require "mini.class"
local assertlevel = require "mini.assertlevel"

return class("box.setup.print", {
	init = function(self, parent)
		self.parent = assert( type(parent) == "table" and table )
		local privenv = parent.privenv

--		parent:addon("setup.id")

		local id = parent:addon("id")
		privenv.tostring = function(x)
			return id:tostring(x)
		end
	end,
})
