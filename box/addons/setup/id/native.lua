
local class = require "mini.class"

local assertlevel = require "mini.assertlevel"

local c = class("box.setup.native-id", {
	init = function(self, parent)
		assertlevel( type(parent) == "table", "parent", 2)
		self.parent = parent
		parent.addons.id = parent:wanted("id.native")
	end,
})

function c:configure(handler)
	assertlevel(handler, "handler", 2)
end

return c
