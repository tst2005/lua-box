
local function weak_table(mode)
	return setmetatable({}, {mode=assert(mode==nil and "k" or mode=="k" or mode=="v" or mode=="kv" and mode, "invalid mode")
end

return weak_table

