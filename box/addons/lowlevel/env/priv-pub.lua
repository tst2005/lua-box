

local class = require "mini.class"
local assertlevel = require "mini.assertlevel"

local function new_tableproxy(meta)
	return setmetatable({}, meta)
end

local c = class("env", {
	init = function(self, parent)
		self.parent = parent

		local self = parent
		self.privenv = {} -- create a default empty privenv table
		local pubmeta = {
			__index = function(_, k)
				return self.privenv[k]
			end,
			__newindex = function(_, k, v)
				self.privenv[k] = v
			end,
			__metatable=false, -- locked
--			__pairs = function() return pairs(self.privenv) end,
		}
		self.pubenv = new_tableproxy(pubmeta)
		self.pubmeta = pubmeta -- allow to internal modification even the metatable has a __metatable
	end
})


function c:set_privenv(env)
	local self = self.parent
	sefl.privenv = assertlevel(
		type(env)=="table" and env,
		"invalid env, must be a table",2
	)
end

function c:mk_self_g()
	local self = self.parent
	self.privenv._G = self.pubenv -- expose the public env, not the private one
end

return c
