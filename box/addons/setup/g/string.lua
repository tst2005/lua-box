
return function(_self, parent)
	assert( type(parent) == "table", "parent")

	-- exposed it in global env
	parent.privenv.string = assert( parent:lowlevel("string").string, "parent:adddon('string').string")
end
