
local class = require "mini.class"
local assertlevel = require "mini.assertlevel"

return class("box.setup.g.loadfile", {
	init = function(self, parent)
		assertlevel( type(parent) == "table", "parent", 2)
		self.parent = parent

		local loads = parent:addon("loads")
		parent.privenv.loadfile = function(filename, _mode, env) return loads:loadfile(filename, "t", env or parent.pubenv) end -- FIXME
	end,
})
