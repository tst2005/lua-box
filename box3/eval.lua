
local class = require "mini.class"
local assertlevel = require "mini.assertlevel"

local c = class("box.eval", {
	init = function(self, parent)
		assertlevel( type(parent) == "table", "parent", 2)
		self.parent = parent

		parent:lowlevel("loads") -- deps
		local mt = getmetatable(self) or setmetatable(self, {}) and getmetatable(self)
		mt.__call = function(_self, stuff)
			assertlevel( self==_self, "self!=_self", 2)
			if type(stuff) == "table" and #stuff == 1 and type(stuff[1]) == "string" then
				return _self:evalfile(stuff[1])
			else
				return _self:eval(stuff)
			end
		end
	end,
})

function c:dostring(txtlua)
	local f, err = self.parent:lowlevel("loads"):load(txtlua, txtlua, "t", self._pubenv)
	if not f then
		error(err, 2)
	end
	return f()
end

function c:evalfile(filename)
	return self.parent:lowlevel("loads"):dofile(filename)
end

-- run
-- runf
-- dostring
-- dofunction

return c

