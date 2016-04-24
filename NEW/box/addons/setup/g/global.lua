
local class = require "mini.class"
local assertlevel = require "mini.assertlevel"

return class("box.setup.g.global", {
	init = function(self, parent)
		assertlevel( type(parent) == "table", "parent", 2)
		self.parent = parent

                -- allow: _G or _G._G
                parent:mk_self_g()
	end,
})
