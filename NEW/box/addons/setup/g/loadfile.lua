
return function(self, parent)
	assert( type(parent) == "table", "parent")

	local loads = parent:addon("loads")
	parent.privenv.loadfile = function(filename, _mode, env) return loads:loadfile(filename, "t", env or parent.pubenv) end -- FIXME
end
