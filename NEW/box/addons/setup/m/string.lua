
local class = require "mini.class"

return class("box.setup.m.string", {
	init = function(self, parent)
		self.parent = assert( type(parent) == "table" and table )
		local string = assert( parent:addon("string").string )
		parent:addon("pkg")._LOADED.string = string -- register as loaded module
	end,
})
