
error("DISABLED", 2)
local class = require "mini.class"

local assertlevel = require "mini.assertlevel"

local function set(self)
	local parent = self.parent

	local privenv = parent.privenv
	privenv.assert = _G.assert
	privenv.pairs  = _G.pairs
	privenv.ipairs = _G.ipairs
	privenv.next   = _G.next
	privenv.tonumber = _G.tonumber

	privenv.print   = _G.print	-- minor unsafe (show 0x value)
	privenv.tostring = _G.tostring -- minor unsafe (show 0x value)

	privenv.table   = _G.table
	privenv.string  = _G.string -- unsafe (side channel attack of string metatable)

	local pkg = parent:addon("pkg")
	pkg._LOADED.table = table
	pkg._LOADED.string = string
end

local unsafe_stdenv = class("box.setup.stdenv.unsafe", {
	init = function(self, parent)
		assert( type(parent) == "table" )
		self.parent = parent
		--parent:addon("pkg")
		set(self)
	end,
})

return unsafe_stdenv

