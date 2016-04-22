
----local compat_env = require "featured" "compat-env"
--local load = require "featured" "minimal.compat-env-like52".load or _G.load
local load = require "mini.compat-env".load or _G.load

local class = require "mini.class"
local instance = class.instance

-- a basic empty env
local env_class = require "box.env_class"

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

