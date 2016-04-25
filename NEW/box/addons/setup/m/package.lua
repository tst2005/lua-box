
return function(_self, parent)
	assert( type(parent) == "table" )

	local pkg = parent:addon("pkg")
	local r = parent:addon("getregistry").registry
	r._PRELOAD = pkg._PRELOAD
	r._LOADED = pkg._LOADED
end
