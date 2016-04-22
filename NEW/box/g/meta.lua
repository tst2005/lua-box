local _M = {}

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

