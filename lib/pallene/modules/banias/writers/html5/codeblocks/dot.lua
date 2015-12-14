--[[
This file is part of banias. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT. No part of banias, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of banias. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local markuplanguagewriter = require('markuplanguagewriter')
local Html5Writer = markuplanguagewriter.Html5Writer
local writer = markuplanguagewriter.Html5Writer.singleton

local tabelize = halimede.table.tabelize
local shellLanguage = halimede.io.ShellLanguage.default()
local useTemporaryTextFileAfterWritingAllContentsAndClosing = halimede.io.temporary.useTemporaryTextFileAfterWritingAllContentsAndClosing

-- TODO: Syntax for defining programs needed on the PATH


-- Runs dot then base64 on 'rawCodeString' to produce a base64-encoded png in a data: URL
-- Added to retain compatibility with JGM's Pandoc
assert.globalTypeIsFunctionOrCall('unpack')
local function dot(rawCodeString, attributesTable)
	assert.parameterTypeIsString('rawCodeString', rawCodeString)
	assert.parameterTypeIsTable('attributesTable', attributesTable)
	
	local function pipe(outputBytes, ...)
		local commandlineArguments = tabelize({...})
		
		temporaryWrite.useTemporaryTextFile()
	
		useTemporaryTextFileAfterWritingAllContentsAndClosing(shellLanguage.shellScriptFileExtensionIncludingLeadingPeriod, outputBytes, function(temporaryFilePath)
			commandLineArguments:insert(temporaryFilePath)
			local fileHandleStream = shellLanguage:popenReadingFromSubprocess(shellLanguage.silenced, shellLanguage.silenced, unpack(commandlineArguments))
			return fileHandleStream:readAllRemainingContentsAndClose()
		end)
	end
	
	local dotted = pipe(rawCodeString, 'dot', '-Tpng')
    local base64EncondedPortalNetworkGraphicsImage = pipe(dotted, 'base64')
	
	return writer:writeElementWithoutPhrasingContent('img', {src = 'data:image/png;base64,' .. base64EncondedPortalNetworkGraphicsImage})
end

modulefunction(dot)
