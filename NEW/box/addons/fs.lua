local class = require "mini.class"
local fs_class = class("fs", {})

local io = require "io"

function fs_class:open(...)
	-- fs.open(filename, mode)
	if type(self) == "string" then
		return io.open(self, ...)
	end
	-- fs:open(filename, mode)
	return io.open(...)
end

return fs_class
