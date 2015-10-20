--[[
This file is part of banias. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT. No part of banias, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of banias. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT.
]]--


local assert = require('halimede.assert')
local exception = require('halimede.exception')


assert.globalTableHasChieldFieldOfTypeFunction('io', 'open')
function module.openTextModeForWriting(filePath, fileDescription)
	assert.parameterTypeIsString(filePath)
	assert.parameterTypeIsString(fileDescription)
	
	local fileHandle, errorMessage = io.open(filePath, 'w')
	if fileHandle == nil then
		exception.throw("Could not open %s '%s' for text-mode writing because of error '%s'", fileDescription, filePath, errorMessage)
	end
	return fileHandle
end
local openTextModeForWriting = module.openTextModeForWriting

function module.writeToFileAllContentsInTextMode(filePath, fileDescription, contents)
	assert.parameterTypeIsString(filePath)
	assert.parameterTypeIsString(fileDescription)
	assert.parameterTypeIsString(contents)
	
	local fileHandle = openTextModeForWriting(filePath, fileDescription)
	-- No errors from Lua when write or close fail...
	fileHandle:setvbuf('full', 4096)
	fileHandle:write(contents)
	fileHandle:close()
end
local writeToFileAllContentsInTextMode = module.writeToFileAllContentsInTextMode
