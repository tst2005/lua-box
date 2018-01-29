local uniformapi = require "uniformapi"
local ok, package = pcall(require,"package")
local G=_G
if type(package)~="table" and type(_G._LOADED)=="table" then
	print("WORKAROUND: lua 5.0 package workaround")
	local loaded = _G._LOADED
	if loaded.package then
		package=loaded.package
	else
		for _,k in ipairs{"table","string","os","io","math","debug","coroutine","_G"} do
			local v=_G[k]
			if loaded[k]==nil then
				loaded[k]=v
			end
		end
		assert(require"string"==_G.string)
		package={loaded = _G._LOADED}
		loaded.package=package
	end
	if loaded.debug.setmetatable==nil then
		local A=loaded._G
		local mt2={}
		local mt={__metatable=mt2}
		local x={}
		assert(A.setmetatable(x,mt)==x)
		assert(A.getmetatable(x)==mt2)
		assert(not pcall(A.setmetatable, x, {}))
		-- lua 5.0 debug.getmetatable/setmetatable pourrait etre emuler en modifiant _G.setmetatable pour memoriser la table reelle pour que debug.getmetatable puisse la restituer
		local native_getmetatable,native_setmetatable=getmetatable,setmetatable
		local realmt=native_setmetatable({},{__mode="k"}) -- weak table
		local debug=loaded.debug
		
		debug.setmetatable=function(t,newmt)
			local mt=realmt[t]
			if mt and mt.__metatable then
				local mtmt=mt.__metatable
				mt.__metatable=nil
				native_setmetatable(t,nil)
				mt.__metatable=mtmt
			end
			native_setmetatable(t,newmt)
			realmt[t]=newmt
			return t
		end
		debug.getmetatable=function(t)
			return realmt[t] or native_getmetatable(t)
		end
		local new_setmetatable=function(t,mt)
			native_setmetatable(t,mt)
			realmt[t]=mt
			return t
		end
		--G={setmetatable=new_setmetatable}
		--G._G=G
		--native_setmetatable(G,{__index=_G})
		_G.setmetatable=new_setmetatable
		G=_G
	end
end
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
