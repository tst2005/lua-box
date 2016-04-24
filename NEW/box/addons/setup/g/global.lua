
local class = require "mini.class"

--local assertlevel = require "mini.assertlevel"

return class("box.setup.g.global", {
	init = function(self, parent)
		self.parent = assert( type(parent) == "table" and table )

                -- allow: _G or _G._G
                parent:mk_self_g()
	end,
})
