
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

		privenv.collectgarbage = _G.collectgarbage

		parent:setup("g.require")
		parent:setup("m.package")
		
		parent:setup("m.global")
		parent:setup("g.global")

		parent:setup("m.io") -- use fs that use direct native io -- UNSAFE

--		parent:setup("id") -- custom format

		parent:setup("g.print")
		parent:setup("g.tostring")

		parent:setup("g.load")
		parent:setup("g.loadfile")
		parent:setup("g.dofile")

		parent:setup("g.getmetatable")
		parent:setup("g.setmetatable")

		parent:setup("m.string")
		parent:setup("g.string")

		parent:setup("m.table")
		parent:setup("g.table")

		parent:setup("m.debug")
	end,
})
