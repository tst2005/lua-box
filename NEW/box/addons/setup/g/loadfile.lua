
local class = require "mini.class"

return class("box.setup.g.loadfile", {
	init = function(self, parent)
		assert( type(parent) == "table" )
		self.parent = parent
		local loads = parent:addon("loads")
		parent.privenv.loadfile = function(filename, _mode, env) return loads:loadfile(filename, "t", env or parent.pubenv) end
	end,
})
