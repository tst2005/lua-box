
local class = require "mini.class"

local assertlevel = require "mini.assertlevel"

return class("box.setup.g.require", {
	init = function(self, parent)
		assert( type(parent) == "table" )
		self.parent = parent

		local pkg = parent:addon("pkg")
		local require = function(name, ...) return pkg:require(name, ...) end
		parent.privenv.require = require 
	end,
})
