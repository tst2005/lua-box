local box = require "box"

local e1 = box()
e1 "setup.stdenv"

e1.privenv._BOXLEVEL = (_BOXLEVEL or 0)+1

e1("setup.id"):configure(function(id)
	local orig = id:getreg("table").fmt

	id:getreg("table").fmt = orig.." [_G pub]"
	id:tostring(e1.pubenv)

--	id:getreg("table").fmt = orig.." [_G priv]"
--	id:tostring(e1.privenv)

	id:getreg("table").fmt = orig

	--id:getreg("table").offset = 0x14b1e00 -- 0xtable00
	id:getreg("table").fmt = "%s: 0x%08x"
	id:getreg("table").offset = 0x10000 * e1.privenv._BOXLEVEL
	--id:getreg("function").offset = 0x133700
	id:getreg("function").offset = 0x13370000 + 0x100 * e1.privenv._BOXLEVEL
end)


--print("NATIVE", "_G =", _G)
--print("NATIVE", "privenv =", e1.privenv, "box pubenv _G =", e1.pubenv)

--e1 "loads":dofile("test3.lua")

--if _BOXLEVEL == 1 then
if not _memstat then
	local mem = {}
	_memstat = _memstat or function(act)
		if act == nil then
			collectgarbage() collectgarbage()
			mem[#mem+1] = collectgarbage("count")
		elseif act == "show" then
			for i,v in ipairs(mem) do
				print("inception: "..i..("%1.1f MB"):format(v/1024))
			end
		end
	end
end
e1.privenv._memstat = _memstat


-------------------------------------------------------------------------------
local testcontent = [=[
-- testcontent
assert(_G._G == _G)

print( "_G =", _G, "require =", require, "require('package') =", require "package")

local function keys(t)
	local r = {}
	for k in pairs(t) do r[#r+1] = k end
	table.sort(r)
	return table.concat(r, " ")
end
--[[
print("_G content:", keys(_G))
print("package content:", keys(require"package"))
print("package.loaded:", keys(require"package".loaded))
print("package.preload:", keys(require"package".preload))
]]--

foo = "inside box"
assert( load("return foo", nil, "t")() == "inside box")
assert( load("return foo", nil, "t", {foo="sub env"})() == "sub env" )
assert( load("return foo", nil, "t", {})() == nil )

--local box = require "box"()

if _BOXLEVEL < 10 then
	_memstat()
	dofile("test.box.inception.lua")
end
--print("inception: "..(" "):rep(_BOXLEVEL or 0).."END ".._BOXLEVEL)
]=]
-------------------------------------------------------------------------------

e1 "eval"(testcontent)

if _BOXLEVEL == 1 then
	print("=============")
	_memstat("show")
end
