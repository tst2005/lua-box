
local class = require "mini.class"

local eval_class = class("box.eval", {
	init = function(self, parent)
		assert( type(parent) == "table" )
		self.loadaddon = assert( parent:addon("loads") )
		self.parent = parent

		local mt = getmetatable(self) or setmetatable(self, {}) and getmetatable(self)
		mt.__call = function(_self, stuff)
			assert(self==_self)
			if type(stuff) == "table" and #stuff == 1 and type(stuff[1]) == "string" then
				return _self:evalfile(stuff[1])
			else
				return _self:eval(stuff)
			end
		end
	end,
})

function eval_class:eval(something)
	return self.loadaddon:load(something)()
end

function eval_class:evalfile(filename)
	return self.parent:addon("loads"):dofile(filename)
end

-- run
-- runf
-- dostring
-- dofunction

return eval_class

