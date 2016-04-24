
-- some standard function are able to internaly get some metatable field value
-- *  pairs get the __pairs
-- * ipairs get the __ipairs
-- *   next get the __next (TODO: check if its true)

-- We should use the debug.getmetatable to bypass the internaly hardcoded getmetatable behavior about __metatable field locking...
-- The box must be able to be loaded inside another box.
-- We must provide a debug.getmetatable debug.setmetatable that do some unrestricted action without breaking the current box.

-- we should put in cache/memoize all the low level table used and lock for the box.
-- by this way we should be able inside the local implementation of debug.{get,set}metatable to allow or not to break the __metatable restriction.

-- we also should create an internal uniq value, easy to compare/found, when it is found it means the __metatable is really locked and must returned another value store in cache.

-- we should also take care about rawget and rawset ...

--[[
> t=setmetatable({}, {__metatable=false})
> =getmetatable(t)
false
> return setmetatable(t, {})
stdin:1: cannot change a protected metatable
]]--

local class = require "mini.class"
local assertlevel = require "mini.assertlevel"

local native_getmetatable, native_setmetatable = _G.getmetatable, _G.setmetatable
local native_debug_getmetatable, native_debug_setmetatable
do
	local debug = require "debug"
	native_debug_getmetatable, native_debug_setmetatable = debug.getmetatable, debug.setmetatable
end

local function new_uniqvalue()
	return {}
end

local meta_class = class("box.meta", {
	init = function(self, parent)
		assert( type(parent) == "table" )
		--self.loads = assert( parent:addon("loads") )
		self.parent = parent
		self.shadowvalue = new_uniqvalue() -- an uniq value used for detection
	end,
})


function meta_class:getmetatable(x)
	-- no x type check
	local debug_mt = native_debug_getmetatable(x) -- the real meta, do not expose it without care!
	if type(debug_mt) == "table" then
		if debug_mt.__metatable == self.shadowvalue then
			error("TODO: This is a shadowed metatable... must return something else like a catched value...", 2)
			--return cache[x] -- we can return a cached value.
		end
		--FIXME: also check if the returned value contains a protected __metatable == self.shadowvalue ?
		--return debug_mt.__metatable ~= nil and debug_mt.__metatable or debug_mt
	end
	--return debug_mt
	return native_getmetatable(x)
end

function meta_class:debug_getmetatable(x)
	
end


function meta_class:setmetatable(x, newmt)
	assertlevel(
		type(x) == "table",
		"bad argument #1 to 'setmetatable' (table expected, got "..type(x)..")", 2
	)
	assertlevel(
		newmt == nil or type(newmt) == "table",
		"bad argument #2 to 'setmetatable' (nil or table expected)", 2
	)
	local debug_mt = native_debug_getmetatable(x)
	if type(debug_mt) == "table" and debug_mt.__metatable == self.shadowdvalue then
		error("box: cannot change a protected metatable", 2)
	end
	-- TODO: check protected _G / _G._G / string ...
	native_setmetatable(x, newmt) -- lua 5.1 setmetatable does not return x
	return x
end

function meta_class:debug_setmetatable(x, newmt)
	-- there is no x type check
	assertlevel(
		newmt == nil or type(newmt) == "table",
		"bad argument #2 to 'setmetatable' (nil or table expected)", 2
	)
	-- box protection --
	-- protected value should be: nil,false,true and someting about _G, _G._G and string(?)
	assertlevel(
		x~=nil and x~=false and x~=true and x~=self.parent.privenv and x~=self.parent.privenv._G, -- FIXME: add the string protection ?
		"box: cannot change a protected metatable", 2
	)
	-- overwrite the metatable of x
	native_debug_setmetatable(x, newmt)
	return x
end

--function meta_class:getmetafield(x, k)
--end

--function meta_class:debug_getmetafield(x)	
--end



-- getmetatable - UNSAFE
-- - Note that getmetatable"" returns the metatable of strings.
--   Modification of the contents of that metatable can break code outside the sandbox that relies on this string behavior.
--   Similar cases may exist unless objects are protected appropriately via __metatable. Ideally __metatable should be immutable.
-- UNSAFE : http://lua-users.org/wiki/SandBoxes
local function make_safe_getsetmetatable(unsafe_getmetatable, unsafe_setmetatable)
	local safe_getmetatable, safe_setmetatable
	do
		local mt_string = unsafe_getmetatable("")
		safe_getmetatable = function(t)
			local mt = unsafe_getmetatable(t)
			if mt_string == mt then
				return false
			end
			return mt
		end
		safe_setmetatable = function(t, mt)
			if mt_string == t or mt_string == mt then
				return t
			end
			return unsafe_setmetatable(t, mt)
		end
	end
	return safe_getmetatable, safe_setmetatable
end

return meta_class

