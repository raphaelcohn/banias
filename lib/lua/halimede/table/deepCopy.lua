--[[
This file is part of banias. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT. No part of banias, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of banias. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT.
]]--


local assert = require('halimede.assert')
local type = require('halimede').type
local isTable = type.isTable


assert.globalTypeIsFunction('type', 'setmetatable', 'getmetatable', 'next')
local function deepCopyWithState(original, encountered)
	if not isTable(original) then
		return original
	end
	
	local alreadyCopied = encountered[original]
	if alreadyCopied then
		return alreadyCopied
	end

	local copy = {}
	for key, value in next, original do
		copy[deepCopyWithState(key, encountered)] = deepCopyWithState(value, encountered)
	end
	setmetatable(copy, deepCopyWithState(getmetatable(original), encountered))
	
	encountered[original] = copy
	return copy
end

function module.deepCopy(original)	
	return deepCopyWithState(original, {})
end
