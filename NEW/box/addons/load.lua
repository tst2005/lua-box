
local class = require "mini.class"

local load = assert( require "mini.compat-env".load )

local assertlevel = require "mini.assertlevel"

local load_class = class("box.load", {
	init = function(self, parent)
		assert( type(parent) == "table" )
		self.parent = parent
		self.loadmode = "t"
		parent:addon("fs")
	end,
})

function load_class:set_loadmode(mode)
	self.loadmode = assertlevel(
		(mode == "b" or mode == "t" or mode == "bt") and mode,
		"invalid mode", 2
	)
end

function load_class:get_loadmode()
	return self.loadmode
end

function load_class:load(something) -- return a function to execute
	return load(
		something,
		something,
		assertlevel(self.loadmode,	"virtual mode not set", 2),
		assertlevel(self.parent.pubenv,	"virtual env not set",  2)
	)
end

function load_class:loadfile(filename)
	if filename == nil then
		return nil, "read from stdin is not supported"
	end
	local fs = self.parent:addon("fs")
	local fd, _err = fs:open(filename, "r")
	if not fd then return nil, "" end
	local data=fd:read("*a")
	fd:close()
	local f = self:load(data)
	return f, "no error?"
	--return self:load(data)
end

return load_class

