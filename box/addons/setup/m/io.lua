
return function(_self, parent)
	assert( type(parent) == "table", "parent")
	-- register as preload
	parent:addon("pkg")._PRELOAD.io = function() return assert( parent:addon("fs").io ) end
end
