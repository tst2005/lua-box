
return function(_self, parent)
	assert( type(parent) == "table", "parent")
	-- allow: require("_G")
	parent:lowlevel("pkg")._LOADED._G = assert( parent.pubenv ) -- register as loaded module
end
