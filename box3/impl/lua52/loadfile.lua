
local M = {}
function M:init()
	local G = self.G
	local type = G.type
	local io = G.assert(type(G.io)=="table" and io)
	assert(self._pubenv)
	assert(G.load)
	--print( self._pubenv.loadfile)
	--self._pubenv.io = require"mini.proxy.ro2rw"(G.io) -- simple stupid table wrapper
end
function M:_pub_loadfile(filename, mode, env)
	local io = self.G.require"io" -- self._internal.io.open ??
	local open = assert(io.open)
	local fd
	if filename ==nil then
		fd = io.stdin
	else
		fd = open(filename, "r")
		assert(fd)
	end
	local data = fd:read("*a")
	if fd ~= io.stdin then fd:close() end

	-- in the box, the global env is self._pubenv
	if env==nil then env = self._pubenv end
	return load(data, "@"..(filename or "stdin"), mode, env)
end
return M
