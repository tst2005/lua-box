
local class = require "mini.class"

local assertlevel = require "mini.assertlevel"

local c = class("box.setup.id", {
	init = function(self, parent, dispatch, regs)
		assert( type(parent) == "table" )
		self.parent = parent
	end,
})

function c:configure(handler)
	assert(handler)
	local id = self.parent:addon("id")
	handler(id)
end

return c
