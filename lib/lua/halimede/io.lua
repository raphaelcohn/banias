--[[
This file is part of banias. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT. No part of banias, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of banias. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT.
]]--


local assert = require('halimede.assert')
local exception = require('halimede.exception')


-- Defensive checks; fail-fast on initialisation
assert.globalTypeIsTable('io')

assert.globalTableHasChieldFieldOfTypeFunction('io', 'open')
function module.openTextModeForReading(filePath, fileDescription)
	
	assert.parameterTypeIsString(filePath)
	assert.parameterTypeIsString(fileDescription)
	
	local fileHandle, errorMessage = io.open(filePath, 'r')
	if fileHandle == nil then
		exception.throw("Could not open %s '%s' because of error '%s'", fileDescription, filePath, errorMessage)
	end
	return fileHandle
	
end
