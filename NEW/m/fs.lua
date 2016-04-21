local io = require "io"
return {
	new = function()
		return {
			open = io.open,
		}
	end,
}
