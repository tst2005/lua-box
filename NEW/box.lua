

local class = require "mini.class"
local instance = class.instance

local load = assert( require "mini.compat-env".load )

local assertlevel = require "mini.assertlevel"

local function new_tableproxy(meta)
	return setmetatable({}, meta)
end

local function merge(dest, source)
	for k,v in pairs(source) do
		dest[k] = dest[k]~=nil and dest[k] or v
	end
	return dest
end

local builtin_defaults = {
	"env",
	env="priv-pub",
	"io",
	io="native",
	"id",
	id="virtual",
	"setup",
	setup="default",
}

local box_class = class("box", {
	init = function(self, custom_defaults)
		self.addons = {}

		local mt = getmetatable(self)
		if not mt then mt = {}; setmetatable(self, mt) end

		self.defaults = merge(custom_defaults or {}, builtin_defaults)

		mt.__call = function(_, k)
			assert(_ == self)
			if k == nil then -- load defaults
				return self:loaddefaults()
			end
			return self:addon(k)
		end
	end
})

function box_class:loaddefaults(k)
	for _i, k in ipairs(self.defaults) do
		local v = self.defaults[k]
		if type(v) == "string" then
			self:addon( "want." .. k .. "." .. v )
		end
	end
	return self
end

function box_class:addon(name, ...)
	local ao = self.addons[name]
	if not ao then
		local mod = require("box.addons."..name)
		if type(mod) == "function" then
			mod({}, self)
			ao = true
		else
			ao = instance(
				assertlevel(
					type(mod)=="table" and mod,
					"mod must be class object", 2
				),
				self, ...
			)
		end
		self.addons[name] = ao
	end
	return ao
end

local function new(...)
	return instance(box_class, ...)
end

local M = setmetatable({
	new 		= new,
	_VERSION	= "box v0.1.0",
}, {
	__call=function(_, ...) return new(...) end
})
return M
