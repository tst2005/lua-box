
local class = require "mini.class"

local assertlevel = require "mini.assertlevel"
local tcopy = require "mini.tcopy"
local table_concat = table.concat

local safe_stdenv = class("box.setup.stdenv", {
	init = function(self, parent)
		assert( type(parent) == "table" )
		self.parent = parent
		--parent:addon("pkg")

		local privenv = parent.privenv
		privenv.assert = _G.assert
		privenv.pairs  = _G.pairs
		privenv.ipairs = _G.ipairs
		privenv.next   = _G.next
		privenv.tonumber = _G.tonumber

--		parent:addon("setup.id") -- custom format
		parent:addon("setup.g.print")
		parent:addon("setup.g.tostring")

		local table = tcopy(table, {})
		local string = _G.string -- unsafe (side channel attack of string metatable)

		local pkg = parent:addon("pkg")
		pkg._LOADED.table = table
		privenv.table = table

		pkg._LOADED.string = string
		privenv.string  = _G.string
	end,
})

return safe_stdenv

