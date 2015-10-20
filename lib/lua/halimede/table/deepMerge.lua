--[[
This file is part of banias. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT. No part of banias, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of banias. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT.
]]--


local assert = require('halimede.assert')
local type = require('halimede').type
local isTable = type.isTable

assert.globalTypeIsFunction('type')
local function deepMerge(source, destination)
	assert.parameterTypeIsTable(source)
	assert.parameterTypeIsTable(destination)
	
	for key, value in pairs(source) do
		if not isTable(value) then
			destination[key] = value
			return
		end
		
		local originalDestinationValue = destination[key]
		local mergedDestinationValue
		
		if originalDestinationValue == nil then
			mergedDestinationValue = {}
		elseif isTable(originalDestinationValue) then
			mergedDestinationValue = originalDestinationValue
		else
			destination[key] = value
			return
		end
		destination[key] = deepMerge(mergedDestinationValue, value)
	end
end
module.deepMerge = deepMerge
