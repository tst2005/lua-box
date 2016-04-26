
local class = require "mini.class"
local assertlevel = require "mini.assertlevel"
local load = assert( require "mini.compat-env".load, "mini.compat-env.load")

local c = class("box.loads", {
	init = function(self, parent)
		assert( type(parent) == "table" , "parent")
		self.parent = parent

		self.loadmode = "t"
		parent:addon("fs")
	end,
})

function c:set_loadmode(mode)
	--self.loadmode = 
	assertlevel(
		(mode == "b" or mode == "t" or mode == "bt"),
		"invalid mode", 2
	)
	self.loadmode = mode
end

function c:get_loadmode()
	return self.loadmode
end

function c:load(something, source, _mode, env) -- return a function to execute

--print("@load@", "mode=", self.loadmode, "original_in_env=", env, "use_in_env=", env ~= nil and env or self.parent.pubenv)
--print("------------>8---------")
--local prefix = "\tcode:\t"
--print(prefix..something:gsub("\n", "\n"..prefix))
--print("------------>8---------")
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
	return self:load(data, "@"..filename, mode, env) -- FIXME: is an error point to the loadfile call or this line ?
end

function c:dofile(filename)
	assertlevel(
		type(filename) == "string",
		"box: read from stdin is not supported", 2
	)
	local f, err = self:loadfile(filename)
	assertlevel(f, err, 2)
	return f()
end

return c

