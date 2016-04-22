
-- ----------------------------------------------------------

--local loadlib = loadlib
--local setmetatable = setmetatable
--local setfenv = setfenv

--local assert =  assert
local error, ipairs, type = error, ipairs, type
--local find, format, gmatch, gsub, sub = string.find, string.format, string.gmatch or string.gfind, string.gsub, string.sub
local format, gmatch, gsub = string.format, string.gmatch or string.gfind, string.gsub


local class = require "mini.class"
local assertlevel = require "mini.assertlevel"
local quote_magics = require "mini.quote_magics"

-- this function is used to get the n-th line of the str, should be improved !!
local function string_line(str, n)
	if str and n and n >= 1 then
		return string.match(str, ((n >= 2) and (".-\n"):rep(n-1) or "").."(.-)\n")
	end
end
if true then -- self test
	assert( string_line("aa\n", 1) == "aa")
	assert( string_line("aa\nbb\n", 2) == "bb")
	assert( string_line("aa\nbb\ncc\n", 2) == "bb")
	assert( string_line("aa\n\nbb\ncc\n", 3) == "bb")
end


--local function hide_self_proxy(self, meth)
--	return function(...) return self[meth](self, ...) end
--end

local pkg_class = class("box.pkg", {
	init = function(self, parent)
		self.parent = assertlevel(
			parent,
			"you must provide the parent instance", 2
		)
		parent:addon("fs")	-- for :exists()
		parent:addon("load")	-- for :loadfile()

		local _PACKAGE = {}
		local _LOADED = {}
		local _PRELOAD = {}
		local _SEARCHERS  = {}
		_SEARCHERS[#_SEARCHERS+1] = function(...) return self:searcher_preload(...) end
		_SEARCHERS[#_SEARCHERS+1] = function(...) return self:searcher_Lua(...) end
		--_SEARCHERS[#_SEARCHERS+1] = function(...) return self:searcher_C(...) end
		--_SEARCHERS[#_SEARCHERS+1] = function(...) return self:searcher_Croot(...) end

		self._PACKAGE = _PACKAGE
		self._PRELOAD = _PRELOAD
		self._LOADED = _LOADED
		self._SEARCHERS = _SEARCHERS

		_LOADED.package = _PACKAGE
		local package = _PACKAGE

		--package.config	= nil -- setup by parent
		--package.cpath		= "" -- setup by parent
		package.loaded		= _LOADED
		--package.loadlib
		package.path		= "./?.lua;./?/init.lua" -- setup by parent
		package.preload		= _PRELOAD
		package.searchers	= _SEARCHERS
		package.searchpath	= function(...) return self:_searchpath(...) end
		assert(#_SEARCHERS==2)
	end,
})

--
-- looks for a file `name' in given path
--
function pkg_class:_searchpath(name, path, sep, rep)
	local _PACKAGE = self._PACKAGE
	sep = sep or '.'
	rep = rep or string_line(_PACKAGE.config, 1) or '/'
assert(rep == '/')
	local LUA_PATH_MARK = '?'
	local LUA_DIRSEP = '/'
	name = gsub(name, quote_magics(sep), LUA_DIRSEP) -- FIXME: use sep ?
	assertlevel(
		type(path) == "string",
		format("path must be a string, got %s", type(path)), 2
	)
	for c in gmatch(path, "[^;]+") do
		c = gsub(c, quote_magics(LUA_PATH_MARK), name)
		local f = self.parent:addon("fs"):open(c)
		if f then
			f:close()
			return c
		end
	end
	return nil -- not found
end


--
-- check whether library is already loaded
--
function pkg_class:searcher_preload(name)
	local _PRELOAD = self._PRELOAD
	assertlevel(
		type(name) == "string",
		format("bad argument #1 to `require' (string expected, got %s)", type(name)), 2
	)
	assertlevel(
		type(_PRELOAD) == "table",
		"`package.preload' must be a table", 2
	)
	return _PRELOAD[name]
end

--
-- Lua library searcher
--
function pkg_class:searcher_Lua(name)
	local _PACKAGE = self._PACKAGE
	assertlevel(
		type(name) == "string",
		format("bad argument #1 to `require' (string expected, got %s)", type(name)), 2
	)
	local filename = self:_searchpath(name, _PACKAGE.path)
	if not filename then
		return false
	end
	local f, err = self.parent:addon("load"):loadfile(filename)
	assertlevel(
		f,
		format("error loading module `%s' (%s)", name, tostring(err)), 2
	)
	return f
end

--
-- iterate over available searchers
--
local function iload(modname, searchers)
	assertlevel(type(searchers) == "table", "`package.searchers' must be a table", 2)
	local msg = ""
	for _, searcher in ipairs(searchers) do
		local loader, param = searcher(modname)
		if type(loader) == "function" then
			return loader, param -- success
		end
		if type(loader) == "string" then
			-- `loader` is actually an error message
			msg = msg .. loader
		end
	end
	error("module `" .. modname .. "' not found: "..msg, 2)
end

--
-- new require
--
function pkg_class:require(modname)
	local function checkmodname(s)
		local t = type(s)
		return assertlevel(
			t == "string" and s
			or s == "number" and tostring(s)
			or false,
			"bad argument #1 to `require' (string expected, got "..t..")", 2
		)
	end

	modname = checkmodname(modname)
	local _LOADED = self._LOADED
	local p = _LOADED[modname]
	if p then -- is it there?
		return p -- package is already loaded
	end

	local loader, param = iload(modname, self._SEARCHERS)

	local res = loader(modname, param)
	if res ~= nil then
		p = res
	elseif not _LOADED[modname] then
		p = true
	else
		p = _LOADED[name]
	end
-- If the loader returns any non-nil value,		=> true/false/{}/*~=nil
-- require assigns the returned value to package.loaded[modname].	=> assign !

-- If the loader does not return a non-nil value	=> nil
-- and has not assigned any value to package.loaded[modname], => le module peux avoir injecté une valeure
-- then require assigns true to this entry. In any case, require returns the final value of package.loaded[modname].

	_LOADED[modname] = p
	return p
end

return pkg_class

-- ----------------------------------------------------------

-- make the list of currently loaded modules (without restricted.*)
--local package = require("package")
--local loadlist = {}
--for modname in pairs(package.loaded) do
--	if not modname:find("^restricted%.") then
--		loadlist[#loadlist+1] = modname
--	end
--end

--[[ lua 5.1
cpath   ./?.so;/usr/local/lib/lua/5.1/?.so;/usr/lib/x86_64-linux-gnu/lua/5.1/?.so;/usr/lib/lua/5.1/?.so;/usr/local/lib/lua/5.1/loadall.so
path    ./?.lua;/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua;/usr/local/lib/lua/5.1/?.lua;/usr/local/lib/lua/5.1/?/init.lua;/usr/share/lua/5.1/?.lua;/usr/share/lua/5.1/?/init.lua
config  "/\n;\n?\n!\n-\n"
preload table: 0x3865c40
loaded  table: 0x3863bd0
loaders table: 0x38656b0
loadlib function: 0x38655f0
seeall  function: 0x3865650
]]--
--[[ lua 5.2
cpath   /usr/local/lib/lua/5.2/?.so;/usr/lib/x86_64-linux-gnu/lua/5.2/?.so;/usr/lib/lua/5.2/?.so;/usr/local/lib/lua/5.2/loadall.so;./?.so
path    /usr/local/share/lua/5.2/?.lua;/usr/local/share/lua/5.2/?/init.lua;/usr/local/lib/lua/5.2/?.lua;/usr/local/lib/lua/5.2/?/init.lua;./?.lua;/usr/share/lua/5.2/?.lua;/usr/share/lua/5.2/?/init.lua;./?.lua
config  "/\n;\n?\n!\n-\n"
preload table: 0x3059560
loaded  table: 0x3058840
loaders table: 0x3059330 <- compat stuff ??? == searchers
loadlib function: 0x4217d0
seeall  function: 0x4213c0

searchpath      function: 0x421b10
searchers       table: 0x3059330
]]--

--
-- new package.seeall function
--
--function _package_seeall(module)
--	local t = type(module)
--	assert(t == "table", "bad argument #1 to package.seeall (table expected, got "..t..")")
--	local meta = getmetatable(module)
--	if not meta then
--		meta = {}
--		setmetatable(module, meta)
--	end
--	meta.__index = _G
--end

--
-- new module function
--
--local function _module(modname, ...)
--	local ns = _LOADED[modname]
--	if type(ns) ~= "table" then
--		-- findtable
--		local function findtable(t, f)
--			assert(type(f)=="string", "not a valid field name ("..tostring(f)..")")
--			local ff = f.."."
--			local ok, e, w = find(ff, '(.-)%.', 1)
--			while ok do
--				local nt = rawget(t, w)
--				if not nt then
--					nt = {}
--					t[w] = nt
--				elseif type(t) ~= "table" then
--					return sub(f, e+1)
--				end
--				t = nt
--				ok, e, w = find(ff, '(.-)%.', e+1)
--			end
--			return t
--		end
--		ns = findtable(_G, modname)
--		if not ns then
--			error(format("name conflict for module '%s'", modname), 2)
--		end
--		_LOADED[modname] = ns
--	end
--	if not ns._NAME then
--		ns._NAME = modname
--		ns._M = ns
--		ns._PACKAGE = gsub(modname, "[^.]*$", "")
--	end
--	setfenv(2, ns)
--	for i, f in ipairs(arg) do
--		f(ns)
--	end
--end


--local POF = 'luaopen_'
--local LUA_IGMARK = ':'
--
--local function mkfuncname(name)
--	local LUA_OFSEP = '_'
--	name = gsub(name, "^.*%"..LUA_IGMARK, "")
--	name = gsub(name, "%.", LUA_OFSEP)
--	return POF..name
--end
--
--local function old_mkfuncname(name)
--	local OLD_LUA_OFSEP = ''
--	--name = gsub(name, "^.*%"..LUA_IGMARK, "")
--	name = gsub(name, "%.", OLD_LUA_OFSEP)
--	return POF..name
--end
--
----
---- C library searcher
----
--local function searcher_C(name)
--	assertlevel(type(name) == "string", format(
--		"bad argument #1 to `require' (string expected, got %s)", type(name)), 2)
--	local filename = _searchpath(name, _PACKAGE.cpath)
--	if not filename then
--		return false
--	end
--	local funcname = mkfuncname(name)
--	local f, err = loadlib(filename, funcname)
--	if not f then
--		funcname = old_mkfuncname(name)
--		f, err = loadlib(filename, funcname)
--		if not f then
--			error(format("error loading module `%s' (%s)", name, err))
--		end
--	end
--	return f
--end
--
--local function searcher_Croot(name)
--	local p = gsub(name, "^([^.]*).-$", "%1")
--	if p == "" then
--		return
--	end
--	local filename = _searchpath(p, "cpath")
--	if not filename then
--		return
--	end
--	local funcname = mkfuncname(name)
--	local f, err, where = loadlib(filename, funcname)
--	if f then
--		return f
--	elseif where ~= "init" then
--		error(format("error loading module `%s' (%s)", name, err))
--	end
--end


