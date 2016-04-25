
return function(_self, parent)
	assert( type(parent) == "table", "parent")
	parent.addons["wanted.env"] = parent:addon("env.priv-pub")
end
