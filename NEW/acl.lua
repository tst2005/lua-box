
local class = require "mini.class"
local instance = assert(class.instance)

local ACCEPT = true
local DROP = false
local NONE = nil


local function validpolicy(policy)
	if not (policy == ACCEPT or policy == DROP or policy == NONE) then
		error("invalid policy", 2+1)
	end
end

local acl_class = class("acl", {
	init = function(self, defpolicy)
		self.stacks = {}
		validpolicy(defpolicy)
		self:newstack(defpolicy)

		-- allow to call the instance instead of using the check method
		local mt = getmetatable(self)
		mt.__call = function(self, key)
			return self:check(key)
		end
	end,
})

local function validstacklevel(n, self)
	if not( 1 <= n and n <= #self.stacks) then
		error("invalid stacklevel", 2+1)
	end
end


function acl_class:newstack(policy)
	validpolicy(policy)
	self.stacks[#self.stacks+1] = {policy}
	self.current = #self.stacks
	return self.current
end

function acl_class:policy(policy, n)
	validpolicy(policy)
	n = n or self.current
	validstacklevel(n, self)
	self.stacks[n][1] = policy
end

function acl_class:stack(n)
	if n == nil then
		return self.current
	end
	validstacklevel(n,self)
	self.current = n
	return n
end

function acl_class:stackreset(n)
	n = n or self.current
	validstacklevel(n, self)
	self.stacks[n] = {NONE}
end

function acl_class:import(from)
	local n = self.current
	local stack = self.stacks[n]
	for k,v in pairs(from) do
		stack[k] = v
	end
end

function acl_class:set(key, allowed, stacklevel)
	validpolicy(allowed)
	stacklevel = stacklevel or #self.stacks -- by default the latest stack
	validstacklevel(stacklevel, self)
	self.stacks[stacklevel][key] = allowed
end

function acl_class:get(key, stacklevel)
	stacklevel = stacklevel or self.current
	validstacklevel(stacklevel, self)
	return self.stacks[stacklevel][key]
end

function acl_class:checkthisstack(key, stacklevel)
	validstacklevel(stacklevel, self)
	return self.stacks[stacklevel][key]
end

function acl_class:check(key)
	for i, stack in ipairs(self.stacks) do
		local pol = stack[key]
		if pol ~= NONE then return pol end
		local defpol = stack[1]
		if defpol ~= NONE then
			return defpol
		end
	end
end

local new = function(...)
	return instance(acl_class, ...)
end

return setmetatable({
	new = new,
	ACCEPT = ACCEPT,
	DROP = DROP,
	NONE = NONE,
}, {
	__call = function(_, ...)
		return new(...)
	end,
})
