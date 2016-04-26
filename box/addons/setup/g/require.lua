
return function(_self, parent)
	assert( type(parent) == "table", "parent")

	local pkg = parent:addon("pkg")
	parent.privenv.require = function(name, ...)
		return pkg:require(name, ...)
	end
end
