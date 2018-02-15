
local boxctl_class = require"boxctl"
local G = _G
local table_unpack = assert(table.unpack and table.unpack or _G.unpack)

local boxctl_inst = boxctl_class(G)

boxctl_inst:boximplement("impl.lua52.load")
boxctl_inst:setup_callable()
local x = boxctl_inst()
x:setup()

local modcode = [[return "OK load;".. (_VERSION or "nil") ]]

local code1 = table.concat({
	'return load(',
		"[[", modcode, "]]",
	',nil, "t")()'
}, "")
assert( x:dostring( code1, print ) == "OK load;nil")

local code2 = table.concat({
	'local e = {_VERSION="customEnv"}',
	';',
	'return load(',
		"[[", modcode, "]]",
	',nil, "t", e)()'
}, "")
assert( x:dostring( code2, print ) == "OK load;customEnv")

print("OK")
