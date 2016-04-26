local class = require "mini.class"
local assertlevel = require "mini.assertlevel"

local c = class("fs", {
	init = function(self, parent)
		assertlevel( type(parent) == "table", "parent", 2)
		self.parent = parent
		self.io = assert( parent:addon("wanted.io").io, "wanted.io.io")
	end,
})

function c:open(filename, mode)
	local io = self.io
	assertlevel(
		type(self) ~= "string",
		"Use fs:open(), not fs.open()", 2
	)
	return io.open(filename, mode)
end

function c:exists(filename)
	local io = self.io
	assertlevel(
		type(self) ~= "string",
		"Use fs:exists(), not fs.exists()", 2
	)
	local fd = io.open(filename, "r")
	local ok = not not fd
	fd:close()
	return ok
end

return c
