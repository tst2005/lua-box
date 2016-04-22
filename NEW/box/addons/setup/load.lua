
local class = require "mini.class"

local assertlevel = require "mini.assertlevel"

local function set(self)
	local parent = self.parent
	local aoload = parent:addon("load")
	local load = function(a, b, _mode, env) return aoload:load(a, b, "t", env or parent.pubenv) end
	parent.privenv.load = load
end

local setup_load_class = class("box.setup.load", {
	init = function(self, parent)
		assert( type(parent) == "table" )
		self.parent = parent
		--parent:addon("load")
		set(self)
	end,
})

return setup_load_class

