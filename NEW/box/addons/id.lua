
local class = require "mini.class"
local instance = assert( class.instance, "class.instance")
local assertlevel = require "mini.assertlevel"
local t_copy = require "mini.tcopy"
local new_weaktable = require "mini.weaktable"

local format = assert( require"string".format, "require 'string'.format")
local native_tostring = _G.tostring -- backup the global original value
local select = assert(_G.select, "_G.select")

local reg_class = class("reg", {
	init = function(self)
		self.count = 0
		self.cache = new_weaktable("k")
		self.fmt = "%s: 0x%x"
		self.offset = 0
	end,
})

function reg_class:tostring_with_cache(x)
	local v = self.cache[x] -- get from cache
	if not v then
		self.count = self.count + 1
		v = format(self.fmt or "%s: 0x%x", type(x), (self.offset or 0)+self.count)
		self.cache[x] = v -- write to cache
	end
	return v -- return the cached value
end
--[[
function reg_class:tostring_with_cache(x)
        local v = self.cache[x] -- get from cache
        if not v then
                self.count = self.count + 1
		v = self.count
                self.cache[x] = v -- write to cache 
        end
        if type(v) == "string" then return v end
        return format(self.fmt or "%s: 0x%x", type(x), (self.offset or 0)+v)
end
]]--


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
	end,
})

function id_class:getreg(typ)
	local want
	local dispatch = self.dispatch
	if dispatch then
		want = dispatch[typ]
	end
	if want == nil then
		want = default_dispatch[typ]
	end
	if dispatch then
		if want == nil then
			want = dispatch['*']
		end
	end
	if want == nil then
		want = default_dispatch['*']
	end
	if want == "separated" then
		want = typ
	end
	if want then
		local reg = self.regs[want]
		if not reg then
			reg = instance(reg_class)
			self.regs[want] = reg
		end
		return reg
	end
	return false
end

function id_class:tostring(x)
	local reg = self:getreg(type(x))
	if reg then
		return reg:tostring_with_cache(x)
	end
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
