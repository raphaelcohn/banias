--[[
This file is part of banias. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT. No part of banias, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of banias. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT.
]]--


local exception = require('halimede.exception')
local toShellCommand = requireSibling('toShellCommand').toShellCommand
local read = requireSibling('read')
local assert = require('halimede.assert')

assert.globalTableHasChieldFieldOfTypeFunction('io', 'popen')
local function openShellCommand(mode, ...)
	local command = toShellCommand(...)
	local fileHandle = io.popen(command, 'r')
	if fileHandle == nil then
		exception.throw('Could not open shell for command "%s"', command)
	end
	return fileHandle
end

function module.openShellCommandReadingStandardIn(...)
	return openShellCommand('r', ...)
end

function module.openShellCommandWritingStandardOut(...)
	return openShellCommand('w', ...)
end

function module.executeInShellAndReadAllFromStandardIn(...)
	local command = toShellCommand(...)
	local fileHandle = io.popen(command, 'r')
	if fileHandle == nil then
		exception.throw('Could not open shell for command "%s"', command)
	end
	return read.allContentsInTextModeFromFileHandleAndClose(fileHandle)
end
