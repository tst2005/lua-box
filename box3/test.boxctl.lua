
local boxctl_class = require"boxctl"
local boxctl_inst = boxctl_class({_G=_G, package={loaded=_G.package.loaded},})

do
	local x = boxctl_inst:newbox()
	x._pubenv.foo = function() return "FOO" end
	assert(x:dostring("return foo()")=="FOO")
	assert(x:dostring("return dostring")==nil)
end

local boxclass = boxctl_inst._box_class
function boxclass:customprint(...)
--	self.G.print("customprint")
	return self.G.print(...)
end
function boxclass:_pub_print(...)
--	self.G.print("_pub_print")
	return self:customprint(...)
end

local x = boxctl_inst:newbox()
assert(x:dostring("return print") ~= print)
x:dostring("print(1,2,3)")
