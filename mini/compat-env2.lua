

local function test_load(stuff, mode, env)
	local ok, ret = pcall(load, stuff, nil, mode, env)
	if not ok then return ok end
	ok, ret = pcall(ret)
	if not ok then return ok end
	return ret
end

print( test_load('return foo', "t", {foo="foo"}) == "foo" and "ok" or "nok")