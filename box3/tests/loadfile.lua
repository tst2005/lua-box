
local boxctl_class = require"boxctl"
local G = _G
local table_unpack = assert(table.unpack and table.unpack or _G.unpack)

local boxctl_inst = boxctl_class(G)

boxctl_inst:boximplement("impl.lua52.loadfile")
boxctl_inst:setup_callable()
local x = boxctl_inst()
x:setup()

print( table_unpack( x:dostring([[return {loadfile("loadfile-sample.lua", "t")()}]] )))
print( table_unpack( x:dostring([[local e = {_VERSION="customEnv"}; return {loadfile("loadfile-sample.lua", "t", e)()}]] )))

