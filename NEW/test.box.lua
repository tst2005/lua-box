local box = require "box"

local e1 = box.new()
e1:set_loadmode("b")
e1:set_loadmode("bt")
e1:set_loadmode("t")
assert( e1:get_loadmode() == "t" )

local pe1 = {foo="foo"} -- private env 1
e1:set_privenv(pe1)
assert(e1:eval "return foo" == "foo")

assert(e1:eval "return _G" == nil)

e1:mk_self_g()
local ge1 = e1:eval "return _G"
assert( type(ge1) == "table")
assert( ge1._G == ge1 )
assert( ge1 ~= pe1 ) -- the pubenv is not the privenv

local pe1b = {bar="bar"}

e1:set_privenv(pe1b)
e1:mk_self_g()
assert( e1:eval("return _G") == ge1) -- still the same exposed table
assert( e1:eval("return bar") == "bar" ) -- bar exists
assert( e1:eval("return foo") == nil) -- foo does not exists anymore
