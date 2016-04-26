
return function(_self, parent)
	assert( type(parent) == "table", "parent")

	local meta = parent:lowlevel("meta")
	parent.privenv.getmetatable = function(value, table) return meta:getmetatable(value, table) end
end
