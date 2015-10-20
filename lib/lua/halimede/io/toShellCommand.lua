--[[
This file is part of banias. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT. No part of banias, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of banias. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT.
]]--


local assert = require('halimede.assert')
local tabelize = require('halimede.tabelize').tabelize


assert.globalTableHasChieldFieldOfTypeFunction('string', 'gsub')
function module.toShellCommand(...)
	
	local arguments = {...}
	
	local commandBuffer = tabelize()
	
	for _, argument in ipairs(arguments) do
		assert.parameterTypeIsString(argument)
		commandBuffer:insert("'" .. argument:gsub("'", "''") .. "'")
	end
	
	local command = commandBuffer:concat(' ')
	return command
end
