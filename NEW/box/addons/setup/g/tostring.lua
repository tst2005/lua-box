
return function(_self, parent)
	assert( type(parent) == "table", "parent")

	local id = parent:addon("id")
	parent.privenv.tostring = function(x) return id:tostring(x) end
end
