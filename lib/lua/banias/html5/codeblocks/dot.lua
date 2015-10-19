--[[
This file is part of banias. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT. No part of banias, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of banias. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT.
]]--


local xmlwriter = require('xmlwriter')
local writeText = xmlwriter.writeText
local writeElementNameWithAttributes = xmlwriter.writeElementNameWithAttributes
local writeElementOpenTag = xmlwriter.writeElementOpenTag
local writeElementCloseTag = xmlwriter.writeElementCloseTag
local writeElementEmptyTag = xmlwriter.writeElementEmptyTag
local writeElement = xmlwriter.writeElement

local assert = require('halimede.assert')
local shell = require('halimede.shell').shell
local tabelize = require('halimede.shell').tabelize

local halimedeIo = require('halimede.io')

-- Runs dot then base64 on 'rawCodeString' to produce a base64-encoded png in a data: URL
-- Added to retain compatibility with JGM's Pandoc
parentModule.register(leafModuleName, function(rawCodeString, attributesTable)
	assert.parameterTypeIsString(rawCodeString)
	assert.parameterTypeIsTable(attributesTable)
	
	local function pipe(outputBytes, ...)
		
		local commandlineArguments = tabelize({...})
		
		halimedeIo.writeToTemporaryFileAllContentsInTextModeAndUse(outputBytes, function(temporaryFileContainingOutputBytes)
			assert.parameterTypeIsString(temporaryFileContainingOutputBytes)
			
			commandLineArguments:insert(temporaryFileContainingOutputBytes)
			return shell(unpack(commandlineArguments))
		end)
	end
	
	-- TODO: Syntax for defining programs needed on the PATH
	local dotted = pipe(rawCodeString, 'dot', '-Tpng')
    local base64EncondedPortalNetworkGraphicsImage = pipe(dotted, 'base64')
	
	return writeElement('img', '', {src = 'data:image/png;base64,' .. base64EncondedPortalNetworkGraphicsImage})
end)
