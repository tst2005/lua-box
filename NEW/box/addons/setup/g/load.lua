
return function(_self, parent)
	assert( type(parent) == "table", "parent")

	local loads = parent:addon("loads")
	parent.privenv.load = function(a, b, mode, env) return loads:load(a, b, mode, env or parent.pubenv) end -- FIXME the env is already protected or not ?
end
