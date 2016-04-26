
return function(_self, parent)
	assert( type(parent) == "table", "parent")
	-- register as preload
	parent:lowlevel("pkg")._PRELOAD.io = function() return assert( parent:lowlevel("fs").io ) end
end
