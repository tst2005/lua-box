

local class = require "mini.class"
local instance = class.instance

local load = assert( require "mini.compat-env".load )

local assertlevel = require "mini.assertlevel"

local function new_tableproxy(meta)
	return setmetatable({}, meta)
end

-- a basic empty env
local box_class = class("box", {
	init = function(self)

		self.privenv = {} -- create a default empty privenv table
		local mt = {
			__index = function(_, k)
				return self.privenv[k]
			end,
			__newindex = function(_, k, v)
				self.privenv[k] = v
			end,
			__metatable=false, -- locked
		}
		self.pubenv = new_tableproxy(mt)
		self.pubmeta = mt -- allow to internal modification even the metatable has a __metatable

		self.addons = {}
		local mt = getmetatable(self)
		if not mt then mt = {}; setmetatable(self, mt) end

		mt.__call = function(_, k)
			assert(_ == self)
			return self:addon(k)
		end
	end
})

function box_class:_load_addon(name, mod)
	local ao = self.addons[name]
	if not ao then
		ao = instance(
			assertlevel(
				type(mod)=="table" and mod,
				"mod must be class object", 2
			),
			self
		)
		self.addons[name] = ao
	end
	return ao
end

function box_class:addon(name)
	local ao = self.addons[name]
	return ao or self:_load_addon(name, require("box.addons."..name))
end

function box_class:set_privenv(env)
	self.privenv = assertlevel(
		type(env)=="table" and env,
		"invalid env, must be a table",2
	)
end

function box_class:mk_self_g()
	self.privenv._G = self.pubenv -- expose the public env, not the private one
end

local function new(...)
	return instance(box_class, ...)
end

local M = setmetatable({
	new 		= new,
	_VERSION	= "env v0.1.0",
}, {
	__call=function(_, ...) return new(...) end
})
return M

