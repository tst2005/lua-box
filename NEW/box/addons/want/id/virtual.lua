
return function(_self, parent)
	assert( type(parent) == "table", "parent")
	-- register as preload
	parent.addons["wanted.id"] = parent:addon("id.virtual")
end
