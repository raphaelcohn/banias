--[[
This file is part of banias. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT. No part of banias, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of banias. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT.
]]--


local halimede = require('halimede')

local assert = {}

function requireSibling(siblingModuleElementName)
	assert.parameterTypeIsString(siblingModuleElementName)
	
	local grandParentModuleName, _ = halimede.parentModuleNameFromModuleName(parentModuleName)
	local requiredModuleName
	if grandParentModuleName == '' then
		requiredModuleName = siblingModuleElementName
	else
		requiredModuleName = grandParentModuleName .. '.' .. siblingModuleElementName
	end
	return require(requiredModuleName)
end

assert = requireSibling('assert')
