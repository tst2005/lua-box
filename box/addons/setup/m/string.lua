
return function(_self, parent)
	assert( type(parent) == "table", "parent" )
	-- register as loaded module
	parent:lowlevel("pkg")._LOADED.string = assert( parent:lowlevel("string").string, "string.string" ) 
end
