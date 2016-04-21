local acl = require "acl"
local ACCEPT,DROP,NONE = acl.ACCEPT,acl.DROP,acl.NONE

-- default policy drop
local a = acl.new(DROP)
assert( a("foo") == DROP) -- match the default


a:set("foo", ACCEPT)
assert( a("foo") == ACCEPT)

a:set("bar", DROP)
assert( a("foo") == ACCEPT)


local b = acl()

b:import(
{
[1]="defpol",
foo="foo",
bar=false,
})

assert( b("x") == "defpol" )
assert( b("foo") == "foo" )
assert( b("bar") == false )


