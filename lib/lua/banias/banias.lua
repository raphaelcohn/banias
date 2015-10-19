--[[
This file is part of banias. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT. No part of banias, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of banias. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT.
]]--


local exception = require('halimede.exception')
local assert = require('halimede').assert


assert.globalTableHasChieldFieldOfTypeFunction('os', 'getenv')
assert.globalTypeIsFunction('require')
local function loadWriter()
	local environmentVariable = 'PANDOC_LUA_BANIAS_WRITER'
	local writer = os.getenv(environmentVariable)
	if writer == nil then
		exception.throw("The environment variable '%s' is not set", environmentVariable)
	end
	require('banias.' .. writer)
end

assert.globalTypeIsTable('_G')
assert.globalTypeIsFunction('setmetatable')
local function enableMissingFunctionWarnings()
	setmetatable(_G, {
		__index = function(tableLookedUp, missingFunctionInModule)
			exception.throwWithLevelIncrement(1, "The global function '%s' is missing", missingFunctionInModule)
		end
	})
end

loadWriter()
enableMissingFunctionWarnings()
