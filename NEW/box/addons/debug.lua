
local class = require "mini.class"
local tcopy = require "mini.tcopy"
local assertlevel = require "mini.assertlevel"

local native_debug = require "debug"

local c = class("box.debug", {
	init = function(self, parent)
		assertlevel( type(parent) == "table", "parent", 2)
		self.parent = parent

		local meta = parent:addon("meta")
		local getregistry = parent:addon("getregistry")

		--self.debug = tcopy(native_debug, {})
		self.debug = {
			getmetatable = function(value) return meta:debug_getmetatable(value) end,
			setmetatable = function(value, table) return meta:debug_setmetatable(value, table) end,
			getregistry = function() return getregistry.registry end,
			--traceback = native_debug.traceback
		}
	end,
})

return c
