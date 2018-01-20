local class = require "mini.class"
local instance = assert(class.instance)

local boxctl_class = class("boxctl")
function boxctl_class:init(env)
--print("boxctl_class:init(env)", env)
	assert(env._G and env.package and env.package.loaded)
	local G = require "uniformapi"({_G=_G._G, package = {loaded = _G.package.loaded}})
	self.G = G

	local ro2rw = require "mini.proxy.ro2rw.with-internalregistry"(G)
	local mkproxies = require "mini.proxy.ro2rw.mkproxies"(G)
	local mkmap = require "mini.proxy.ro2rw.mkmap"(G)

	local mkproxy = mkproxies.mkproxy1
	local map = mkmap({["function"]=mkproxy})
	assert(map["function"]==mkproxy)
	local ro2rw_simple = function(orig, prefix) return ro2rw(orig, map, nil, prefix) end

	local parent = self
	local box_class = class("box")
	self._box_class = box_class
	function box_class:init()
--print("box_class:init()")
--		self._pubprefix = "_pub_"
		self._parent = parent ; self.G = parent.G
		local pubenv, internal = ro2rw_simple(self, "_pub_")
		self._pubenv = pubenv		-- the _G inside the box
		self._internal = internal	-- env function proxies (internal registry)
		pubenv._G = pubenv		-- the _G._G inside the box
	end
	function box_class:dostring(txtlua)
		local e = {}
		e._G=e
		setmetatable(e,{__index=self._pubenv})
		local f = self.G.load(txtlua, nil, "t", e)
		if not f then return nil end
		local ok, ret = self.G.pcall(f)
		if not ok then
			--self._parent.error(ret, 2)
			return nil
		end
		return ret
	end
--[[
	local mt = G.getmetatable(self)
	if not mt then
		mt = {}
		G.setmetatable(self, mt)
	end
	assert(mt._call==nil)
	mt.__call=function(_, ...) return instance(box_class, ...) end
]]--
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

--[[
function boxctl_class:boximplement(cls)
	local pairs = self._G.pairs
	local box = self._box_class
	for k, v in pairs(cls) do
		if box[k] == nil and type(v) == "function" then
			box[k] = v
		end
	end
end
]]--


