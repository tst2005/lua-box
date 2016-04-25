local box = require "box"

local boxes = {}

--loop to make lot of box instances
for n=1,100 do
	local e1 = box()
	e1 "want.id.virtual"
	e1 "setup.stdenv"
	boxes[#boxes+1] = e1

	e1.privenv._BOXLEVEL = (_BOXLEVEL or 0)+1

	e1("setup.id"):configure(function(id)
		local orig = id:getreg("table").fmt

		id:getreg("table").fmt = orig.." [_G pub]"
		id:tostring(e1.pubenv)

		id:getreg("table").fmt = orig

		--id:getreg("table").offset = 0x14b1e00 -- 0xtable00
		id:getreg("table").fmt = "%s: 0x%08x"
		id:getreg("table").offset = 0x10000 * e1.privenv._BOXLEVEL
		--id:getreg("function").offset = 0x133700
		id:getreg("function").offset = 0x13370000 + 0x100 * e1.privenv._BOXLEVEL
	end)

	collectgarbage() collectgarbage()
	print("inception( "..#boxes.."): "..("%1.1f MB"):format(collectgarbage("count")/1024))
end -- loop

collectgarbage() collectgarbage()
print("boxes( "..#boxes.."): "..("%1.1f MB"):format(collectgarbage("count")/1024))

