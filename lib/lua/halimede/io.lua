--[[
This file is part of banias. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT. No part of banias, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of banias. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT.
]]--


local assert = require('halimede.assert')
local exception = require('halimede.exception')


assert.globalTableHasChieldFieldOfTypeFunction('io', 'open')
function module.openTextModeForReading(filePath, fileDescription)
	assert.parameterTypeIsString(filePath)
	assert.parameterTypeIsString(fileDescription)
	
	local fileHandle, errorMessage = io.open(filePath, 'r')
	if fileHandle == nil then
		exception.throw("Could not open %s '%s' for text-mode reading because of error '%s'", fileDescription, filePath, errorMessage)
	end
	return fileHandle
	
end
local openTextModeForReading = module.openTextModeForReading

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

-- TODO: replace os.tmpname with io.tmpfile - http://www.lua.org/manual/5.2/manual.html#6.8 - but no way to get file name...
assert.globalTableHasChieldFieldOfTypeFunction('os', 'tmpname')
function module.writeToTemporaryFileAllContentsInTextMode(contents)
	assert.parameterTypeIsString(contents)

	local temporaryFileToWrite = os.tmpname()
	writeToFileAllContentsInTextMode(temporaryFileToWrite, 'temporary file', contents)
	return temporaryFileToWrite
end
local writeToTemporaryFileAllContentsInTextMode = module.writeToTemporaryFileAllContentsInTextMode

assert.globalTableHasChieldFieldOfTypeFunction('os', 'remove')
function module.writeToTemporaryFileAllContentsInTextModeAndUse(contents, user)
	assert.parameterTypeIsString(contents)
	assert.parameterTypeIsFunction(user)

	local temporaryFileToWrite = writeToTemporaryFileAllContentsInTextMode(contents)
	local ok, result = pcall(user, temporaryFileToWrite)
	os.remove(temporaryFileToWrite)
	if not ok then
		error(result)
	end
	
	return result
end
