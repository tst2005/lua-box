local class = require "mini.class"
local fs_class = class("fs", {})

local io = require "io"

function fs_class:open(filename, mode)
	assert( type(self) ~= "string", "Use fs:open(), not fs.open()")
	return io.open(filename, mode)
end

function fs_class:exists(filename)
	assert( type(self) ~= "string", "Use fs:open(), not fs.open()")
	local fd = io.open(filename, "r")
	local ok = not not fd
	fd:close()
	return ok
end

return fs_class
