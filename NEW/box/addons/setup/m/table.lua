
local class = require "mini.class"

return class("box.setup.m.table", {
	init = function(self, parent)
		self.parent = assert( type(parent) == "table" and table )
		local table = assert( parent:addon("table").table )
		parent:addon("pkg")._LOADED.table = table -- register as loaded module
	end,
})
