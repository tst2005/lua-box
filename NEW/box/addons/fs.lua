local class = require "mini.class"
local assertlevel = require "mini.assertlevel"

local native_io = require "io"

local c = class("fs", {
	init = function(self, parent)
		assertlevel( type(parent) == "table", "parent", 2)
		self.parent = parent
	end,
})


function c:open(filename, mode)
	assertlevel(
		type(self) ~= "string",
		"Use fs:open(), not fs.open()", 2
	)
	return native_io.open(filename, mode)
end

function c:exists(filename)
	assertlevel(
		type(self) ~= "string",
		"Use fs:open(), not fs.open()", 2
	)
	local fd = native_io.open(filename, "r")
	local ok = not not fd
	fd:close()
	return ok
end

return c
