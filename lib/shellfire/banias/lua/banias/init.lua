--[[
This file is part of banias. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT. No part of banias, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of banias. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT.
]]--


-- Causes any missing function in the future to cause a warning; should be made into generic code (ie pre-pended)
-- setmetatable(_G, {
-- 	__index = function(tableLookedUp, missingFunctionInModule)
-- 		local messageTemplate = "WARN: Missing required function '%s'\n"
--
-- 		io.stderr:write(messageTemplate:format(missingFunctionInModule))
-- 		return function()
-- 			return ''
-- 		end
-- 	end
-- })

local function loadWriter()
	local environmentVariable = 'PANDOC_LUA_BANIAS_WRITER'
	local writer = os.getenv(environmentVariable)
	if writer == nil then
		error("The environment variable '" .. environmentVariable .. "' is not set")
	end
	require(writer)
end

-- Adds the table.concat, table.insert, etc methods to tableLiteral
function module.tabelize(tableLiteral)
	assert(type(tableLiteral) == 'table')
	
	setmetatable(tableLiteral, {__index = table})
	return tableLiteral
end
local tabelize = module.tabelize

function module.shell(...)
	
	local arguments = {...}
	
	local commandBuffer = tabelize({})
	
	for _, argument in ipairs(arguments) do
		assert(type(argument) == 'string')
		commandBuffer:insert("'" .. argument:gsub("'", "''") .. "'")
	end
	
	local fileHandle = io.popen(commandBuffer:concat(' '), 'r')
	assert(fileHandle)
	local standardOutCaptured = fileHandle:read('*all')
	fileHandle:close()
	
	return standardOutCaptured
end

loadWriter()

return module
