-- uniformapi({_G=_G, package={loaded=package.loaded}})
local assert = assert
local _G=nil
local print = print
return function(env)
	local G = assert(env._G)
	local assert = assert(G.assert)
	local type = assert(G.type)
	local loaded = assert(env.package and env.package.loaded)
	assert(G~=loaded, "wrong env format env._G is env.package.loaded")
	local mods = {}
	if G == loaded then
		print("missing mods argument ?!")
		mods = G
	else
		for name,mod in G.pairs(loaded) do
			if mod==true and G[name]~=true then
				print("autofix mod value from global env for "..name)
				mods[name] = G[name]
			else
				mods[name]=mod
			end
		end
	end

	local table = mods.table or G.table
	local string = mods.string or G.string

	local function table_update(t_src, t_dst)
		for k,v in G.pairs(t_src) do
			if t_dst[k] ~= v then
				t_dst[k] = v
			end
		end
		return t_dst
	end

	local DEPRECATED = {}
	local M = {
--		require = G.require,
--		print = G.print,
--		assert = G.assert,
--		error = G.error,
--		type = G.type,
--		getmetatable = G.getmetatable,
--		setmetatable = G.setmetatable,
--		pairs = G.pairs, -- TODO
--		ipairs = G.ipairs, -- TODO
	}
	M.DEPRECATED = DEPRECATED
	
	local deny = {}
	local function depreciate(name)
		deny[name]=true
		DEPRECATED[name] = G[name]
	end
	depreciate "setfenv"
	depreciate "getfenv"
	depreciate "module"
	depreciate "unpack"

	for k,v in pairs(G) do
		if type(v)=="function" and not deny[k] then
			M[k]=v
		end
	end
--[[	setmetatable(M, {
		__index=function(_t,k)
			if deny[k] then return nil end
			return G[k]
		end,
		-- __pairs -- not implemented yet !
	})
]]--
	-- DEBUG --
	do
		if G.debug then
			M.debug = G.debug
		else
			if mods.debug==nil and mods.package.preload.debug==nil then
				print("WARNING: the standard debug module seems unavailable")
			end
			-- require the debug module only on demand
			local setmetatable = G.setmetatable
			local debug_
			M.debug = setmetatable({}, {__index=function(_t, k)
				debug_ = assert(G.require "debug")
				return debug_[k]
			end})
		end
	end

	-- IO --
	M.io = {}
	do
		local io = mods.io
		M.io.open   = io.open
		M.io.stdin  = io.stdin
		M.io.stdout = io.stdout
		M.io.stderr = io.stderr
	end

	-- TABLE --
	M.table = {}
	table_update(mods.table, M.table)
	if not M.table.unpack then M.table.unpack = G.unpack end
	--if not M.unpack then M.unpack = table.unpack end

	-- STRING --
	M.string = {}
	table_update(mods.string, M.string)
	M.string.dump = nil

	-- LOAD --
	do
		local load = G.load
		local pcall = G.pcall

		local compat_load
		if pcall(load, '') then -- check if it's lua 5.2+ or LuaJIT's with a compatible load
			compat_load = load
		else
			local loadstring = G.loadstring
			local type = G.type
			local setfenv = G.setfenv
			local byte = mods.string.byte
			local find = mods.string.find

			local native_load = load
			function compat_load(str,src,mode,env)
				local chunk,err
				if type(str) == 'string' then
					if byte(1) == 27 and not find((mode or 'bt'),'b') then
						return nil,"attempt to load a binary chunk"
					end
					chunk,err = loadstring(str,src)
				else
					chunk,err = native_load(str,src)
				end
				if chunk and env then setfenv(chunk,env) end
				return chunk,err
			end
		end
		--assert((function() local v={} return v==(compat_load('return _test', nil, nil, {_test=v})())end)())
		do local v={} assert(v==compat_load('return _test', nil, nil, {_test=v})() and _test~=v, "read access fail") end
		do local e,v={},tostring({}) assert(_test~=v and compat_load('_test="'..v..'";return true', nil, nil, e)(), "write access fail 1") assert(_test~=v and e._test==v,"write access fail 2") end
		assert( "foo"==compat_load('return foo', nil, nil, setmetatable({}, { __index = function(_t,k) return k end}))(),"meta read access fail")
		M.load = compat_load
	end

	-- PACKAGE --
	do
		M.package = {}
		table_update(G.package, M.package)
		-- PACKAGE.searchers --
		if not M.package.searchers and M.package.loaders then
			M.package.searchers = M.package.loaders
			M.package.loaders = nil
		end
		-- PACKAGE.config --
		if not M.package.config then -- package.config seems not documented in lua/5.1 manual 
			print("FIXME: missing package.config")
		end
		-- PACKAGE.searchpath --
		if not M.package.searchpath then
			print("FIXED: missing package.searchpath, workaround!")
			local error = G.error
			local io_open = assert( (mods.io or {}).open)
			local type = G.type
			local gsub = G.string.gsub
			local gmatch = G.string.gmatch
			local format = G.string.format

			--local quote_magics = require "mini.quote_magics"
			local function quote_magics(str)
				local first = str:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%0")
				return first
			end
			
			-- this function is used to get the n-th line of the str, should be improved !!
			local function string_line(str, n)
				if str and n and n >= 1 then
					return string.match(str, ((n >= 2) and (".-\n"):rep(n-1) or "").."(.-)\n")
				end
			end
			local _PACKAGE = M.package

			M.package.searchpath = function(name, path, sep, rep)
				sep = sep or '.'
				rep = rep or string_line(_PACKAGE.config, 1) or '/'
				--assert(rep == '/')
				local LUA_PATH_MARK = '?'
				local LUA_DIRSEP = '/'
				name = gsub(name, quote_magics(sep), LUA_DIRSEP) -- FIXME: use sep ?
				if type(path) ~= "string" then
					error( format("path must be a string, got %s", type(path)), 2 )
				end
			        for c in gmatch(path, "[^;]+") do
			                c = gsub(c, quote_magics(LUA_PATH_MARK), name)
			                local f = io_open(c)
			                if f then
			                        f:close()
			                        return c
			                end
			        end
			        return nil -- not found
			end
		end
	end
	for _,k in ipairs({"coroutine", "io", "math", "os", "utf8",}) do
		local v = G[k]
		if type(v)=="table" then
			M[k]=v
		end
	end
	--M._VERSION=""
	return M
end
