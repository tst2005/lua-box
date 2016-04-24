
local class = require "mini.class"
local assertlevel = require "mini.assertlevel"
local load = assert( require "mini.compat-env".load )

local c = class("box.loads", {
	init = function(self, parent)
		assert( type(parent) == "table" )
		self.parent = parent
		self.loadmode = "t"
		parent:addon("fs")
	end,
})

function c:set_loadmode(mode)
	self.loadmode = assertlevel(
		(mode == "b" or mode == "t" or mode == "bt") and mode,
		"invalid mode", 2
	)
end

function c:get_loadmode()
	return self.loadmode
end

function c:load(something, source, _mode, env) -- return a function to execute
	return load(
		something,
		source ~= nil and source or something,
		assertlevel(
			self.loadmode,
			"box: virtual mode not set", 2
		),
		env ~= nil and env or assertlevel(
			self.parent.pubenv,
			"box: virtual env not set", 2
		)
	)
end

local function file_read_content(self, filename)
	local fs = self.parent:addon("fs")
	local fd, _err = fs:open(filename, "r")
	if not fd then return nil, "box: can not open" end
	local data=fd:read("*a")
	fd:close()
	return data
end

function c:loadfile(filename, mode, env)
	assertlevel(
		filename ~= nil,
		"box: read from stdin is not supported", 2
	)
	assertlevel(
		type(filename) == "string",
		"bad argument #1 to 'loadfile' (string expected, got "..type(filename)..")", 2
	)
	local data, err = file_read_content(self, filename)
	if not data then
		return nil, err
	end
	return self:load(data, data, mode, env) -- FIXME: is an error point to the loadfile call or this line ?
end

function c:dofile(filename)
	assertlevel(
		type(filename) == "string",
		"box: read from stdin is not supported", 2
	)
	return self:loadfile(filename)()
end

return c

