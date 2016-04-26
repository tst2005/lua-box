
return function(_self, parent)
	assert( type(parent) == "table", "parent")
	local loads = assert( parent:lowlevel("loads"), "loads")
	parent.privenv.dofile = function(filename) return loads:dofile(filename) end -- exposed it in global env
end
