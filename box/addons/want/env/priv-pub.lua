
return function(_self, parent)
	assert( type(parent) == "table", "parent")
	parent:setwanted("env", parent:lowlevel("env.priv-pub"))
end
