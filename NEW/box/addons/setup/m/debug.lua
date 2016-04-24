
local class = require "mini.class"

return class("box.setup.m.debug", {
	init = function(self, parent)
		self.parent = assert( type(parent) == "table" and table )
		local debug = assert( parent:addon("debug").debug )
		parent:addon("pkg")._PRELOAD.debug = function() return debug end -- register as preload 
	end,
})
