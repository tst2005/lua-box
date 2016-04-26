
return function(_self, parent)
	assert( type(parent) == "table", "parent")
	parent.addons["wanted.io"] = {io = require "io"}
end
