----------------
--- Lua 5.1/5.2 compatibility
-- The exported function `load` is Lua 5.2 compatible.
-- `compat.setfenv` and `compat.getfenv` are available for Lua 5.2, although
-- they are not always guaranteed to work.
-- @module pl.compat

local compat = {}

compat.lua51 = _VERSION == 'Lua 5.1'

----------------
-- Load Lua code as a text or binary chunk.
-- @param ld code string or loader
-- @param[opt] source name of chunk for errors
-- @param[opt] mode 'b', 't' or 'bt'
-- @param[opt] env environment to load the chunk in
-- @function compat.load

---------------
-- Get environment of a function.
-- With Lua 5.2, may return nil for a function with no global references!
-- Based on code by [Sergey Rozhenko](http://lua-users.org/lists/lua-l/2010-06/msg00313.html)
-- @param f a function or a call stack reference
-- @function compat.setfenv

---------------
-- Set environment of a function
-- @param f a function or a call stack reference
-- @param env a table that becomes the new environment of `f`
-- @function compat.setfenv

if not compat.lua51 then
	local debug = require "debug"
	assert(debug.getinfo)
	assert(debug.getupvalue)
	assert(debug.upvaluejoin) -- does not exists in Lua 5.1
	assert(debug.setupvalue)
--	compat.load = load
	-- setfenv/getfenv replacements for Lua 5.2
	-- by Sergey Rozhenko
	-- http://lua-users.org/lists/lua-l/2010-06/msg00313.html
	-- Roberto Ierusalimschy notes that it is possible for getfenv to return nil
	-- in the case of a function with no globals:
	-- http://lua-users.org/lists/lua-l/2010-06/msg00315.html
	function compat.setfenv(f, t)
		f = (type(f) == 'function' and f or debug.getinfo(f + 1, 'f').func)
		local name
		local up = 0
		repeat
			up = up + 1
			name = debug.getupvalue(f, up)
		until name == '_ENV' or name == nil
		if name then
			debug.upvaluejoin(f, up, function() return name end, 1) -- use unique upvalue
			debug.setupvalue(f, up, t)
		end
		if f ~= 0 then return f end
	end

	function compat.getfenv(f)
		local f = f or 0
		f = (type(f) == 'function' and f or debug.getinfo(f + 1, 'f').func)
		local name, val
		local up = 0
		repeat
			up = up + 1
			name, val = debug.getupvalue(f, up)
		until name == '_ENV' or name == nil
		return val
	end
end

return compat
