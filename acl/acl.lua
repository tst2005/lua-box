
local class = require "mini.class"
local instance = assert(class.instance)

local function uniqvalue() return {} end

local ACCEPT = true
local DROP = false
local NONE = nil  -- use default policy

-- [1] stack A exact
-- [2] stack A default
-- [3] stack B exact
-- [4] stack B default
-- [5] end

-- [1] == NONE => [2]
-- [1] == NEXT => [3]
-- [1] == DEFAULT => [2]
-- [1] == ACCEPT => [5]+accept
-- [1] == DROP   => [5]+drop

-- [2] == NONE => [3]
-- [2] == NEXT (invalid!)
-- [2] == DEFAULT (invalid!)
-- [2] == ACCEPT => [5]+accept


--local NEXT = true -- stop the current stack, go to the next (skip default)
--local ACCEPT_NEXT = uniqvalue() -- continue without default matching, if no exact match, ACCEPT
--local DROP_NEXT = uniqvalue()	-- continue without default matching, if no exact match, DROP
--local ACCEPT_BREAK = uniqvalue() -- Stop with ACCEPT action
--local DROP_BREAK   = uniqvalue() -- Stop the search with DROP action

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
