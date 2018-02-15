
local boxctl_class = require"boxctl"
local G = _G
local table_unpack = assert(table.unpack and table.unpack or _G.unpack)

local boxctl_inst = boxctl_class(G)

boxctl_inst:boximplement("impl.lua52.loadfile")
boxctl_inst:setup_callable()
local box = boxctl_inst()
box:setup()

local code = [[return loadfile("loadfile-sample.lua", "t")()]]
assert( box:dostring(code) == "OK loadfile;nil" )

local code = [[local e = {_VERSION="customEnv"}; return loadfile("loadfile-sample.lua", "t", e)()]]
assert( box:dostring(code) == "OK loadfile;customEnv")

print("OK")
