
local class = require "mini.class"

----local compat_env = require "featured" "compat-env"
--local load = require "featured" "minimal.compat-env-like52".load or _G.load
local load = require "mini.compat-env".load or _G.load

local assertlevel = require "mini.assertlevel"

local load_class = class("box.addon.load", {
	init = function(self, parent)
		assert( type(parent) )
		self.parent = parent
		self.loadmode = "t"
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


function load_class:eval(something)
	return self:load(something)()
end

function load_class:loadfile(filename)
	if filename == nil then
		return nil, "read from stdin no supported"
	end
	local fs = self.parent.addons.fs
	local fd, _err = fs:open(filename, "r")
	if not fd then return nil end
	local data=fd:read("*a")
	fd:close()
	return self:load(data)
end


function load_class:evalfile(filename)
	return self:loadfile(filename)()
end

-- run
-- runf
-- dostring
-- dofunction

return load_class

