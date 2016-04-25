
return function(_self, parent)
	assert( type(parent) == "table", "parent")
	-- register as preload
	parent.addons["wanted.io"] = {io = require "io"}
end
