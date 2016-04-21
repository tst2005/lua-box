local box = require "box"
local env_class = assert(box.env_class)

local class = require "mini.class"
local instance = assert(class.instance)

local env2 = class("env2", {
	init = function(self, ...)
		local parent = env_class
		parent.init(self)
		assert(self.privenv and self.pubenv)
		self:mk_self_g()
		assert(self.pubmeta)

		self.pubmeta.__tostring = function() return "the _G" end
	end,
}, env_class)

return instance(env2)
