local class = require "mini.class"
local assertlevel = require "mini.assertlevel"

local c = class("box.io", {
	init = function(self, parent)
		assertlevel( type(parent) == "table", "parent", 2)
		self.parent = parent
		self.io = require "io"
	end,
})

return c
