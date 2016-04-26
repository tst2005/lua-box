
return function(_self, parent)
	assert( type(parent) == "table", "parent")
	parent.addons["wanted.setup"] = parent:addon("setup.default")
end
