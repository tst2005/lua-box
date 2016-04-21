
----local compat_env = require "featured" "compat-env"
--local load = require "featured" "minimal.compat-env-like52".load or _G.load
local load = require "mini.compat-env".load or _G.load

local class = require "mini.class"

local assertlevel = require "mini.assertlevel"
--local weaktable = require "mini.weaktable"

local function tableproxy(meta)
	return setmetatable({}, meta)
end

-- a basic empty env
local env_class = class("env", {
	init = function(self)
		self.loadmode = "t" -- for load

		self.privenv = {} -- create a default empty privenv table
		local mt = {
			__index = function(_, k)
				return self.privenv[k]
			end,
			__newindex = function(_, k, v)
				self.privenv[k] = v
			end,
			__metatable=false, -- locked
--			__pairs
--			__ipairs
		}
		self.pubenv = tableproxy(mt)
		self.pubmeta = mt -- allow to internal modification even the metatable has a __metatable
		self.addons = {}
	end
})
-- make a env to setup the virtual global env

function env_class:load_addon(name, mod, ...)
	local ao = self.addons[name]
	if ao then
		return ao
	end
	ao = assertlevel(
		type(mod)=="table" and type(mod.new) == "function" and mod.new,
		"mod must be a table and mod.new must be a function", 2
	)(self, ...)
	self.addons[name] = ao
	return ao
end

function env_class:set_privenv(env)
	self.privenv = assertlevel(
		type(env)=="table" and env,
		"invalid env, must be a table",2
	)
end

function env_class:mk_self_g()
	self.privenv._G = self.pubenv -- expose the public env, not the private one
end



function env_class:set_loadmode(mode)
	self.loadmode = assertlevel( (mode == "b" or mode == "t" or mode == "bt") and mode, "invalid mode", 2)
end

function env_class:get_loadmode()
	return self.loadmode
end

function env_class:load(something) -- return a function to execute
	return load(
		something,
		something,
		assertlevel(self.loadmode,	"virtual mode not set", 2),
		assertlevel(self.pubenv,	"virtual env not set",  2)
	)
end


function env_class:eval(something)
	return self:load(something)()
end

function env_class:loadfile(filename)
	if filename == nil then
		return nil, "read from stdin no supported"
	end
	local io = self.addons.fs
	local fd, _err = io.open(filename, "r")
	if not fd then return nil end
	local data=fd:read("*a")
	fd:close()
	return self:load(data)
end


function env_class:evalfile(filename)
	return self:loadfile(filename)()
end

-- run
-- runf
-- dostring
-- dofunction

return env_class

