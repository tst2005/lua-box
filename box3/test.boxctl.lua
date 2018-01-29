
local boxctl_class = require"boxctl"
local G = {_G=_G, package={loaded=_G.package.loaded},}
local unpack = table.unpack and table.unpack or _G.unpack

do
	local boxctl_inst = boxctl_class(G)
	local x = boxctl_inst:newbox()
	x._pubenv.foo = function() return "FOO" end
	assert(x:dostring("return foo()")=="FOO")
	assert(x:dostring("return dostring")==nil)
	assert(x:dostring([[k2={};_G[k2]="K";return _G[k2] ]])=="K")
	assert(x._internal.k2==nil and x._internal._G==nil)
end

do
	local boxctl_inst = boxctl_class(G)
	local boxclass = boxctl_inst._box_class
	function boxclass:customprint(...)
--		self.G.print("customprint")
		return self.G.print(...)
	end
	function boxclass:_pub_print(...)
--		self.G.print("_pub_print")
		return self:customprint(...)
	end

	local x = boxctl_inst:newbox()
	assert(x:dostring("return print") ~= print)
	x:dostring("print(1,2,3)")

	local err
	print( x:dostring([[ syntax{error ]], function(x) err=x end), err)
	print( x:dostring([[ NULL() ]], function(x) err=x end), err)
end

do
	local boxctl_inst = boxctl_class(G)
	boxctl_inst:setup_callable()
	local x = boxctl_inst()
	do
		x._pubenv._OK = "ok"
		assert(x:dostring("return _OK")=="ok")
		x._pubenv._OK = nil
	end

	boxctl_inst:boximplement("impl.native.io")
	--x:setup_native_io()
	x:setup()

	x._pubenv.print = print
	x._pubenv.tostring = tostring
	x._pubenv.pairs = pairs
	print(x:dostring("local c = 0 for k, v in pairs(io) do print(k,v) c=c+1 end return c")) -- ro2rw does NOT support pairs
	print((x:dostring([[return io._FAKE]]))=="yes")

	print( unpack( x:dostring([[return {"io.stdin", io.stdin}]]) or {} ) )
end

do
	local boxctl_inst = boxctl_class(G)
	boxctl_inst:setup_callable()
	boxctl_inst:boximplement("impl.native.g")
	boxctl_inst:boximplement("impl.meta")
	local x = boxctl_inst()
	x:setup()
	print(unpack(x:dostring([[return {print,assert,error,pairs,ipairs,_VERSION}]])))
	print(x:dostring([[return debug.getmetatable]]))
end

