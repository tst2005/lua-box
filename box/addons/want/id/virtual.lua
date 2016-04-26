
return function(_self, parent)
	assert( type(parent) == "table", "parent")
	parent:setwanted("id", parent:lowlevel("id.virtual"))
end
