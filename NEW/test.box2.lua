local box = require "box"

local e1 = box()

e1 "setup.stdenv.unsafe"
e1 "setup.require"

local test = [[
assert(_G._G == _G)

print( "_G =", _G, "require =", require, "require('package') =", require "package")

local function keys(t)
	local r = {}
	for k in pairs(t) do r[#r+1] = k end
	table.sort(r)
	return table.concat(r, " ")
end

print("_G content:", keys(_G))
print("package content:", keys(require"package"))
print("package.loaded:", keys(require"package".loaded))

assert( require "sample.a".name == "mod a" )
]]

print("==== inside box ====")
e1 "eval" (test)

--print("==== native env ====")
--_G.load(test)()


--[[ result with lua 5.2
==== inside box ====
_G =    table: 0x6e5c20 require =       function: 0x6f60a0      require('package') =    table: 0x6f4de0
_G content:     _G assert ipairs next pairs print require string table tonumber tostring
package content:        loaded path preload searchers searchpath
package.loaded: _G package string table
]]--
