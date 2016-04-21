


----local compat_env = require "featured" "compat-env"
--local load = require "featured" "minimal.compat-env-like52".load or _G.load
local load = require "mini.compat-env".load or _G.load

local assertlevel = require "mini.assertlevel"

local env_class = require "box.env_class.base"

function env_class:set_loadmode(mode)
	self.loadmode = assertlevel( (mode == "b" or mode == "t" or mode == "bt") and mode, "invalid mode", 2)
end

function env_class:get_loadmode()
	return self.loadmode
end

function env_class:eval(something)
	local f = load(
		something,
		something,
		assertlevel(self.loadmode,	"virtual mode not set", 2),
		assertlevel(self.pubenv,	"virtual env not set",  2)
	)
	return f()
end

function env_class:run(something)
	return self:eval(something)
end

-- run
-- runf
-- dostring
-- dofunction

return env_class

