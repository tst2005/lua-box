local box = require "box"

local e1 = box()

e1 "setup.stdenv"
--e1 "setup.require"
--e1 "setup.load"

e1("setup.id"):configure(function(id)
	id:getreg("table").offset = 0x14b1e00 -- 0xtable00
	id:getreg("function").offset = 0x133700
end)
	


-----------------------------------------------------------
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
print("package.preload:", keys(require"package".preload))

assert( require "sample.a".name == "mod a" )

foo = "inside box"
print( load("return foo", nil, "bt")() )

_BOX = (_BOX or 0)+1
print("box inception:", _BOX)
if _BOX <= 2 then
	dofile("test.box2.lua")
end
print("END")
]]
-----------------------------------------------------------

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
