
return function(_self, parent)
	assert( type(parent) == "table", "parent")

	-- allow: _G or _G._G
	parent:mk_self_g()
end
