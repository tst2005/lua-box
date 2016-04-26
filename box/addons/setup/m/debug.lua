
return function(_self, parent)
	assert( type(parent) == "table", "parent")
	local debug = assert( parent:lowlevel("debug").debug )
	-- register as preload
	parent:lowlevel("pkg")._PRELOAD.debug = function() return debug end
end
