
local class = require "mini.class"
local assertlevel = require "mini.assertlevel"

return class("box.setup.g.load", {
	init = function(self, parent)
		assertlevel( type(parent) == "table", "parent", 2)
		self.parent = parent

		local loads = parent:addon("loads")
		parent.privenv.load = function(a, b, mode, env) return loads:load(a, b, mode, env or parent.pubenv) end -- FIXME the env is already protected or not ?
	end,
})
