
return function(_self, parent)
	assert( type(parent) == "table", "parent")

	local id = parent:addon("wanted.id")
	parent.privenv.tostring = id.g.tostring
end
