local modname = (... or "") --:gsub("%-auto$", "")

local dispatch = {
--	["setfenv"] = "-like51",
--	["getfenv"] = "-like51",
	["load"]    = "-like52",
}

return setmetatable({}, {
	__index = function(self, k)
		if dispatch[k] then
			return require(modname..dispatch[k])[k]
		end
	end,
})
