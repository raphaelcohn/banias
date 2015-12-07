--[[
This file is part of banias. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT. No part of banias, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of banias. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local exception = halimede.exception


assert.globalTableHasChieldFieldOfTypeFunction('os', 'getenv')
local function loadWriter()
	local environmentVariable = 'LUA_BANIAS_WRITER'
	local writer = os.getenv(environmentVariable)
	if writer == nil then
		exception.throw("The environment variable '%s' is not set", environmentVariable)
	end
	require('banias.writers.' .. writer)
end

loadWriter()
