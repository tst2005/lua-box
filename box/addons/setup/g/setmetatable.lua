
return function(_self, parent)
	assert( type(parent) == "table", "parent")

	local meta = parent:lowlevel("meta")
	parent.privenv.setmetatable = function(value, table) return meta:setmetatable(value, table) end
end
