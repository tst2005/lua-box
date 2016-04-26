
return function(_self, parent)
	assert( type(parent) == "table" )

	local pkg = parent:lowlevel("pkg")
	local r = parent:lowlevel("debug.getregistry").registry
	r._PRELOAD = pkg._PRELOAD
	r._LOADED = pkg._LOADED
end
