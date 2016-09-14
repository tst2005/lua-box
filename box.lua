

--- the box module
-- This is my first documentation made with LDoc
-- @module box

-----
--TODO spoke about dependencies ?

--class
local class = require "mini.class"
--instance
local instance = class.instance

local load = assert( require "mini.load" )

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

--- some ordered defaults, overwritable
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
--- the box class
-- something...
-- @function box_class
-- @field custom_defaults
-- @return a box
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

---
-- Load/Get any box's addon
-- @param name the addon name
-- @param ... optionnal instance constructor argument(s)
-- @return the addon instance
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

---
-- Load/Get a low level box's addon
-- @param name the `low level` addon
-- @param ... optionnal instance constructor argument(s)
-- @return the addon instance
function box_class:lowlevel(name, ...)
	return self:addon("lowlevel."..name, ...)
end

---
-- Load/Get a "want" box's addon
-- @param name the `want` addon
-- @param ... optionnal instance constructor argument(s)
-- @return the addon instance
function box_class:want(name, ...)
	return self:addon("want."..name, ...)
end

---
-- Get a meta box's addon, a "wanted" loaded addon.
-- @param name the `wanted` addon
-- @param ... optionnal instance constructor argument(s)
-- @return the addon instance
function box_class:wanted(name, ...)
	return self:addon("wanted."..name, ...)
end

---
-- Register a loaded addon as meta/"wanted" addon
function box_class:setwanted(name, mod)
	self.addons["wanted."..name] = mod
end

---
-- Load/Get a `setup` box's addon.
-- @param name the `setup` addon
-- @param ... optionnal instance constructor argument(s)
-- @return the addon instance
function box_class:setup(name, ...)
	return self:addon("setup."..name, ...)

end

---
-- internal function used during the instance initialization to setup the wanted setup to load...
-- @return self
function box_class:loaddefaults()
	for _i, k in ipairs(self.defaults) do
		local v = self.defaults[k]
		if type(v) == "string" then
			self:want( k .. "." .. v )
		end
	end
	return self
end

local function new(...)
	return instance(box_class, ...)
end

--- A callable table module
-- @function box
-- @param ... optionnal box instance constructor argument(s)
-- @return a new box_class's instance
-- @usage local b1 = require "box"(...)
-- @usage local b2 = require "box".new(...)
local M = setmetatable({
	new 		= new,
--- module version.
-- @field _VERSION
	_VERSION	= "box v0.1.0",
}, {
	__call=function(_, ...) return new(...) end
})
return M
