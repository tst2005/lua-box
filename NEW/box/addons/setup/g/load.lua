
local class = require "mini.class"

return class("box.setup.g.load", {
	init = function(self, parent)
		assert( type(parent) == "table" )
		self.parent = parent
		local loads = parent:addon("loads")
		parent.privenv.load = function(a, b, mode, env) return loads:load(a, b, mode, env or parent.pubenv) end
	end,
})
