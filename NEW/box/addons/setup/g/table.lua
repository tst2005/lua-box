
return function(_self, parent)
	assert( type(parent) == "table", "parent")

	-- exposed it in global env
	parent.privenv.table = assert( parent:addon("table").table, 'parent:addon("table").table')
end
