
return function(_self, parent)
	assert( type(parent) == "table", "parent")
	-- register as loaded module
	parent:lowlevel("pkg")._LOADED.table = assert( parent:lowlevel("table").table, "table.table")
end
