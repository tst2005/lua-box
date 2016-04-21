
----local compat_env = require "featured" "compat-env"
--local load = require "featured" "minimal.compat-env-like52".load or _G.load
local load = require "mini.compat-env".load or _G.load

local class = require "mini.class"
local instance = class.instance

local assertlevel = require "mini.assertlevel"
--local weaktable = require "mini.weaktable"

local function tableproxy(meta)
	return setmetatable({}, meta)
end


-- a basic empty env
local env_class = class("env", {
	init = function(self)
		self.loadmode = "t" -- for load

		local privenv = {} -- create a default empty privenv table
		local pubenv = tableproxy({
			__index = function(_, k)
				return self.privenv[k]
			end,
			__newindex = function(_, k, v)
				self.privenv[k] = v
			end,
			__metatable=false, -- locked
--			__pairs
--			__ipairs
		})
		self.privenv = privenv
		self.pubenv = pubenv
	end
})
-- make a env to setup the virtual global env

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

function env_class:eval(something)
	local f = load(
		something,
		something,
		assertlevel(self.loadmode,	"virtual mode not set", 2),
		assertlevel(self.pubenv,	"virtual env not set",  2)
	)
	return f()
end

function env_class:run(something)
	return self:eval(something)
end

-- run
-- runf
-- dostring
-- dofunction


local function new(...)
	return instance(env_class, ...)
end

local M = {
	new 		= new,

--	load		= compat_env.load,
--	loadluacode     = loadluacode,
--	loadbytecode    = loadbytecode,
--	loadcodefromfunction = loadcodefromfunction,
	_VERSION	= "env v0.1.0",
}
return M

-- TODO: long term: transform to a 'code' class
-- code:new():loadfromdata("data")()
-- code:new():format("luacode"):loadfromdata("print'hello world'")()
-- code:new():format("bytecode"):loadfromfile("file.lua.dump")()
-- code:new():format("luacode"):loadfromstream(fd)()
-- code:new():format("lisp"):loadfromfile("file.lisp")()

