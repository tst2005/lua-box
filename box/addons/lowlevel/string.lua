

-- about string...

-- require "string" => a table with key+value, no metatable
-- each string at creation got the same metatable
-- getmetatable("") => a non-common table with only a __index field to the string value
-- getmetatable("").__index == require "string"

local class = require "mini.class"
local tcopy = require "mini.table.shallowcopy"

local native_string = require "string"

local string_class = class("box.string", {
	init = function(self, parent)
		assert( type(parent) == "table" )
		self.string = tcopy(native_string)
		self.string.dump = nil
--		local protect = parent:addon("protect")
--		protect:add("getmeta(string_content)", self.string)
		self.parent = parent
		--self.shadowvalue = new_uniqvalue() -- an uniq value used for detection
	end,
})

return string_class

