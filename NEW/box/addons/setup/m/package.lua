
local class = require "mini.class"

--local assertlevel = package "mini.assertlevel"

return class("box.setup.m.package", {
	init = function(self, parent)
		assert( type(parent) == "table" )
		self.parent = parent

		local pkg = parent:addon("pkg")
		local r = parent:addon("getregistry").registry
		r._PRELOAD = pkg._PRELOAD
		r._LOADED = pkg._LOADED
	end,
})
