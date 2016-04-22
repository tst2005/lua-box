
local class = require "mini.class"

local assertlevel = require "mini.assertlevel"

local function set(self)
	local parent = self.parent
	local pkg = parent:addon("pkg")

	local require = function(name, ...) return pkg:require(name, ...) end

	local privenv = parent.privenv
	privenv.require = require 

	-- allow: require("_G")
	pkg._LOADED._G = parent.pubenv

	-- allow: _G or _G._G
	parent:mk_self_g()
end

local setup_require = class("box.setup.require", {
	init = function(self, parent)
		assert( type(parent) == "table" )
		self.parent = parent
		--parent:addon("pkg")
		set(self)
	end,
})

return setup_require

