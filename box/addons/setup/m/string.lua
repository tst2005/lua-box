
return function(_self, parent)
	assert( type(parent) == "table", "parent" )
	-- register as loaded module
	parent:addon("pkg")._LOADED.string = assert( parent:addon("string").string, "string.string" ) 
end
