
local class = require "mini.class"

return class("box.setup.stdenv", {
	init = function(self, parent)
		assert( type(parent) == "table" )
		self.parent = parent

		local privenv = parent.privenv

		privenv.assert = _G.assert
		privenv.error = _G.error
		privenv.pcall = _G.pcall
		privenv.type = _G.type
		privenv.pairs  = _G.pairs
		privenv.ipairs = _G.ipairs
		privenv.next   = _G.next
		privenv.tonumber = _G.tonumber
		privenv.select = _G.select

		parent:addon("setup.g.require")
		parent:addon("setup.m.package")
		
		parent:addon("setup.m.global")
		parent:addon("setup.g.global")

		privenv.io = require "io" -- UNSAFE !
		parent:addon("pkg")._LOADED.io = require "io" -- UNSAFE !

--		parent:addon("setup.id") -- custom format

		parent:addon("setup.g.print")
		parent:addon("setup.g.tostring")

		parent:addon("setup.g.load")
		parent:addon("setup.g.loadfile")
		parent:addon("setup.g.dofile")

		parent:addon("setup.g.getmetatable")
		parent:addon("setup.g.setmetatable")

		parent:addon("setup.m.string")
		parent:addon("setup.g.string")

		parent:addon("setup.m.table")
		parent:addon("setup.g.table")

		parent:addon("setup.m.debug")
	end,
})
