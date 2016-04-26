
return function(_self, parent)
	assert( type(parent) == "table", "parent")

	-- exposed it in global env
	parent.privenv.table = assert( parent:lowlevel("table").table, 'parent:lowlevel("table").table')
end
