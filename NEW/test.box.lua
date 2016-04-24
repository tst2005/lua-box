local box = require "box"

local e1 = box() -- box.new()

-- load the "eval" addon
e1 "eval"
--e1("eval")
--e1:addon("eval")

assert( e1:addon("eval") == e1("eval") )

-- the default load mode is "t" (no bytecode, only lua code)
assert( e1("loads"):get_loadmode() == "t" )

e1("loads"):set_loadmode("b")
assert( e1("loads"):get_loadmode() == "b" )

e1("loads"):set_loadmode("bt")
assert( e1("loads"):get_loadmode() == "bt" )

e1("loads"):set_loadmode("t")
assert( e1("loads"):get_loadmode() == "t" )


local pe1 = {foo="foo"} -- private env 1
e1:set_privenv(pe1)
assert(e1("eval")("return foo") == "foo")

-- by default the env is really empty, where is no way to go the global table it self
assert(e1("eval")("return _G") == nil)

e1:mk_self_g()
local ge1 = e1("eval")("return _G")
assert( type(ge1) == "table")
assert( ge1._G == ge1 )
assert( ge1 ~= pe1 ) -- the pubenv is not the privenv

local pe1b = {bar="bar"}

e1:set_privenv(pe1b)
e1:mk_self_g()
assert( e1("eval"):eval("return _G") == ge1) -- still the same exposed table
assert( e1("eval"):eval("return bar") == "bar" ) -- bar exists
assert( e1("eval"):eval("return foo") == nil) -- foo does not exists anymore

e1 "fs" -- require "box.addons.fs"


e1 "eval":evalfile("sample/global_write.lua")
assert( e1("eval"):eval("return foo") == "FOO" )

e1("eval")({"sample/global_write.lua"}) -- use a table to get the evalfile


e1 "pkg" -- require "box.addons.pkg"
assert( e1("pkg"):require("sample.a").name == "mod a")

e1.privenv.pairs = _G.pairs


