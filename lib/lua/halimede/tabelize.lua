--[[
This file is part of banias. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT. No part of banias, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of banias. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT.
]]--


local assert = requireSibling('assert')


assert.globalTypeIsTable('table')

-- maxn is dead 5.2/5.3
-- we also gain pack, move and unpack in 5.3
assert.globalTableHasChieldFieldOfTypeFunction('table', 'concat', 'insert', 'remove', 'sort')

-- Adds the table.concat, table.insert, etc methods to optionalValueToTabelize, or returns an empty table with them added
function module.tabelize(optionalValueToTabelize)
	
	local valueToTabelize
	if tableLiteral ~= nil then
		assert.parameterTypeIsTable(optionalValueToTabelize)
		valueToTabelize = optionalValueToTabelize
	else
		valueToTabelize = {}
	end
	
	return setmetatable(valueToTabelize, {__index = table})
end
