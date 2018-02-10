return function(G)
	local ok, package = pcall(require,"package")
	if type(package)~="table" and type(G._LOADED)=="table" then
	--	print("WORKAROUND: lua 5.0 package workaround")
		local loaded = G._LOADED
		local package = loaded.package or {}
		if not package.loaded then
			package.loaded = loaded
		end
		if not loaded.package then
			loaded.package = package
		end
		for _,k in ipairs{"table","string","os","io","math","debug","coroutine","_G"} do
			local v=G[k]
			if loaded[k]==nil then
				loaded[k]=v
			end
		end
		assert(require"string"==G.string) -- self test
		G.package = package

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
	return G
end
