local uniformapi = require "uniformapi"
local A = uniformapi(_G,assert(package.loaded))
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
