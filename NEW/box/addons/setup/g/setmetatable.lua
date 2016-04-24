
local class = require "mini.class"
local assertlevel = require "mini.assertlevel"

return class("box.setup.g.setmetatable", {
	init = function(self, parent)
		assertlevel( type(parent) == "table", "parent", 2)
		self.parent = parent

		local meta = parent:addon("meta")
		parent.privenv.setmetatable = function(value, table) return meta:setmetatable(value, table) end
	end,
})
