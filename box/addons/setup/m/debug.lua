
return function(_self, parent)
	assert( type(parent) == "table", "parent")
	local debug = assert( parent:addon("debug").debug )
	-- register as preload
	parent:addon("pkg")._PRELOAD.debug = function() return debug end
end
