
local class = require "mini.class"

local eval_class = class("box.eval", {
	init = function(self, parent)
		assert( type(parent) == "table" )
		self.loadaddon = assert( parent:addon("load") )
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
--	local p = self.parent
--	local l = assert(p:addon("load"))
--	assert(l.loadfile)
--	return assert( l:loadfile(filename), "loadfile fail")()
	return self.parent:addon("load"):loadfile(filename)()
end

-- run
-- runf
-- dostring
-- dofunction

return eval_class

