
local class = require "mini.class"

local assertlevel = require "mini.assertlevel"

local c = class("box.setup.id", {
	init = function(self, parent, dispatch, regs)
		assertlevel( type(parent) == "table", "parent", 2)
		self.parent = parent
	end,
})

function c:configure(handler)
	assertlevel(handler, "handler", 2)
	local id = self.parent:wanted("id")
	handler(id)
end

return c
