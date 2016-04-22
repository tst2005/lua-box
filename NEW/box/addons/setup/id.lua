
local class = require "mini.class"

local assertlevel = require "mini.assertlevel"

local c = class("box.setup.id", {
	init = function(self, parent, dispatch, regs)
		assert( type(parent) == "table" )
		self.parent = parent

		local id = parent:addon("id")

--		id:getreg("table").offset = 0x14b1e00 -- 0xtable00
--		id:getreg("function").offset = 0x133700
	end,
})

function c:configure(handler)
	assert(handler)
	local id = self.parent:addon("id")
	handler(id)
end

return c
