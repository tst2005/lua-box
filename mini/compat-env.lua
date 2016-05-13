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

if compat.lua51 then
	if not tostring(assert):match 'builtin' then -- but LuaJIT's load _is_ compatible
		local lua51_load = load
		function compat.load(str,src,mode,env)
			local chunk,err
			if type(str) == 'string' then
				if str:byte(1) == 27 and not (mode or 'bt'):find 'b' then
					return nil,"attempt to load a binary chunk"
				end
				chunk,err = loadstring(str,src)
			else
				chunk,err = lua51_load(str,src)
			end
			if chunk and env then setfenv(chunk,env) end
			return chunk,err
		end
	else
		compat.load = _G.load
	end
--	compat.setfenv, compat.getfenv = setfenv, getfenv
else
	compat.load = _G.load
end

return compat
