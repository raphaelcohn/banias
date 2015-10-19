--[[
This file is part of banias. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT. No part of banias, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of banias. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT.
]]--


local assert = requireSibling('assert')
local tabelize = requireSibling('tabelize').tabelize
local exception = requireSibling('exception')

function module.shell(...)
	
	local arguments = {...}
	
	local commandBuffer = tabelize()
	
	for _, argument in ipairs(arguments) do
		assert.parameterTypeIsString(argument)
		commandBuffer:insert("'" .. argument:gsub("'", "''") .. "'")
	end
	
	local command = commandBuffer:concat(' ')
	local fileHandle = io.popen(command, 'r')
	if fileHandle == nil then
		exception.throw("Could not open shell for command '%s'", command)
	end
	local standardOutCaptured = fileHandle:read('*all')
	fileHandle:close()
	
	return standardOutCaptured
end
