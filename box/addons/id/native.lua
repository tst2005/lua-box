
local class = require "mini.class"
local instance = assert( class.instance, "class.instance")
local assertlevel = require "mini.assertlevel"
local t_copy = require "mini.tcopy"
local new_weaktable = require "mini.weaktable"

local format = assert( require"string".format, "require 'string'.format")
local native_tostring = _G.tostring -- backup the global original value
local native_print = _G.print
local select = assert(_G.select, "_G.select")

local reg_class = class("reg", {
	init = function(self)
		self.count = 0
--		self.cache = new_weaktable("k")
		self.fmt = "%s: 0x%x"
		self.offset = 0
	end,
})

function reg_class:tostring_with_cache(x)
	return self:tostring(x)
end


local default_dispatch = {
	["nil"]=false, ["number"]=false, ["string"]=false, ["boolean"]=false,
--	['*']="common",
	['*']="separated",
}


local id_class = class("box.id", {
	init = function(self, parent, dispatch, regs)
		self.parent = parent
		if dispatch then
			self.dispatch = dispatch
		else
			self.dispatch = t_copy(default_dispatch, {})
		end
		self.regs = regs or {}
		self.g = {
			print = native_print,
			tostring = native_tostring,
		}
	end,
})

function id_class:getreg(typ)
	return false
end

function id_class:tostring(x)
	return native_tostring(x)
end

function id_class:setdispatch(dispatch)
	self.dispatch = dispatch
end


function id_class:alltostring(...)
	local t = {}
	local n = select("#", ...)
	for i = 1,n do
		t[i] = self:tostring(select(i, ...))
	end
	return t
end

function id_class:setreg(reg)
	self.reg = reg
end

return id_class
