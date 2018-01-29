local class = require "mini.class"
local instance = assert(class.instance)

local boxctl_class = class("boxctl")
function boxctl_class:init(env)
--print("boxctl_class:init(env)", env)
	assert(env._G and env.package and env.package.loaded)
	local G, mods = require "uniformapi"(env._G, env.package.loaded)
	self.G = G
	self.mods = mods

	local ro2rw = require "mini.proxy.ro2rw.with-internalregistry"(G)
	local mkproxies = require "mini.proxy.ro2rw.mkproxies"(G)
	local mkmap = require "mini.proxy.ro2rw.mkmap"(G)

	local mkproxy = mkproxies.mkproxy_inst2env
	local map = mkmap({
		["function"]=mkproxy,
		--["table"]=true,
	})
	assert(map["function"]==mkproxy)
	local ro2rw_simple = function(orig, prefix)
--print("call ro2rw(orig, map, nil, prefix)", "prefix="..tostring(prefix))
		return ro2rw(orig, map, nil, prefix)
	end

	local parent = self
	local box_class = class("box")
	self._box_class = box_class

	function box_class:init()
--print("box_class:init()")
		assert(parent.G)
		self._pubprefix = "_pub_"
		self._parent = parent ; self.G = parent.G
		self.mods = mods
		local pubenv, internal = ro2rw_simple(self, self._pubprefix)	-- create a new empty environment
		self._pubenv = pubenv		-- the _G inside the box
		self._internal = internal	-- env function proxies (internal registry)
		pubenv._G = pubenv		-- the _G._G inside the box
		self:setup()
		local _debug_, _debug_internal = ro2rw_simple(self, "_mods_debug_")
		pubenv.debug = _debug_
	end
	function box_class:dostring(txtlua, errorhandler)
		local f = self.G.load(txtlua, nil, "t", self._pubenv)
		if not f then
			if errorhandler then errorhandler("error") end
			return nil
		end -- txtlua syntax error ?
		local ok, ret = self.G.pcall(f)
		if not ok then
			if errorhandler then errorhandler(ret) end
			return nil
		end
		return ret
	end
	box_class._inits = {}
	function box_class:setup()
		local G = self.G
		for k,v in G.pairs(self._inits) do
			print("INIT: ", k, v)
			v(self)
		end
	end
	
end

-- not really used
function boxctl_class:setup_callable()
	local G = self.G
	local mt = G.getmetatable(self)
	if not mt then
		mt = {}
		G.setmetatable(self, mt)
	end
	assert(mt._call==nil)
	mt.__call=function(_, ...) return instance(self._box_class, ...) end
end

function boxctl_class:boximplement(modname) -- method name must be correctly prepared (with the _pub_ prefix)
	local G = self.G
	local methods = require(modname) --(G)
	local boxclass = self._box_class

	assert(boxclass.init)
	for k, v in G.pairs(methods) do
		if k~="init" and boxclass[k] == nil and G.type(v) == "function" then
			boxclass[k] = v
		end
	end
	assert(G.type(boxclass._inits)=="table")
	boxclass._inits[modname]=methods.init
end

function boxctl_class:newbox(...)
	return instance(self._box_class, ...)
end

local function new(...) return instance(boxctl_class, ...) end
local M = {}
setmetatable(M, { __call=function(_, ...) return new(...) end })
return M

-- run / runf / dostring / dofunction

--[[
function box_class:directaccess(name)
	if self[name]==nil then
		function self[name](_self, ...)
			return self._G[name](...)
		end
	end
end
]]--


