
return function(_self, parent)
	assert( type(parent) == "table", "parent")
	-- register as loaded module
	parent:addon("pkg")._LOADED.table = assert( parent:addon("table").table, "table.table")
end
