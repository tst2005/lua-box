
local class = require "mini.class"

return class("box.setup.m.global", {
	init = function(self, parent)
		self.parent = assert( type(parent) == "table" and table )
		local g = assert( parent.pubenv )
		-- allow: require("_G")
		parent:addon("pkg")._LOADED._G = g -- register as loaded module
	end,
})
