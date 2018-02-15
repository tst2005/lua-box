
local M = {}
function M:init()
	local G = self.G
	assert(G.load)
	assert(self._pubenv)
end
function M:_pub_load(chunk, chunkname, mode, env)
	-- in the box, the global env is self._pubenv
	if env==nil then env = self._pubenv end
	return self.G.load(chunk, chunkname, mode, env)
end
return M
