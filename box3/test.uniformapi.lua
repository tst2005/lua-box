local G=_G
if string.sub(_VERSION,1,7)=="Lua 5.0" then
	G=require"uniformapi/lua50"(G)
end
local uniformapi = require "uniformapi"
local package = require"package"
local A = uniformapi(G, package.loaded)
assert(A.string.dump==nil)
do
	local env = {}
	local y = assert(A.load("return function() X=123 end", nil, nil, env))()
	y()
	assert(env.X==123)
end
assert(A.print == print)
assert(A.error == error)
assert(A.setfenv == nil)
--for k,v in pairs(A) do print(k,v)end
print("ok")

do -- test if debug.setmetatable(x,y) returns x ?
	local mt2={}
	local mt={__metatable=mt2}
	local x={}
	assert(A.setmetatable(x,mt)==x)
	assert(A.getmetatable(x)==mt2)
	assert(not pcall(A.setmetatable, x,{}))
	assert(type(A.debug.setmetatable({}, {}))=="table")
	assert(A.debug.getmetatable(x)==mt)
	assert(pcall(A.debug.setmetatable,x,nil))
end
