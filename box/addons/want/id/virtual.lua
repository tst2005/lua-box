
return function(_self, parent)
	assert( type(parent) == "table", "parent")
	parent.addons["wanted.id"] = parent:addon("id.virtual")
end
