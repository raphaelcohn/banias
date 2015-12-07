--[[
This file is part of banias. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT. No part of banias, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of banias. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local markuplanguagewriter = require('markuplanguagewriter')
local Html5Writer = markuplanguagewriter.Html5Writer
local writer = markuplanguagewriter.Html5Writer.singleton
local executeInShellAndReadAllFromStandardIn = halimede.io.shell.executeInShellAndReadAllFromStandardIn
local shellLanguage = halimede.io.ShellLanguage.Default
local tabelize = halimede.table.tabelize
local halimedeIo = halimede.io.temporaryWrite

-- Runs dot then base64 on 'rawCodeString' to produce a base64-encoded png in a data: URL
-- Added to retain compatibility with JGM's Pandoc
parentModule.register(leafModuleName, function(rawCodeString, attributesTable)
	assert.parameterTypeIsString('rawCodeString', rawCodeString)
	assert.parameterTypeIsTable('attributesTable', attributesTable)
	
	local function pipe(outputBytes, ...)
		
		local commandlineArguments = tabelize({...})
		
		halimedeIo.toTemporaryFileAllContentsInTextModeAndUse(outputBytes, shellLanguage.shellScriptFileExtensionIncludingLeadingPeriod, function(temporaryFileContainingOutputBytes)
			assert.parameterTypeIsString('temporaryFileContainingOutputBytes', temporaryFileContainingOutputBytes)
			
			commandLineArguments:insert(temporaryFileContainingOutputBytes)
			commandLineArguments:insert(shellLanguage.silenceStandardError)
			return executeInShellAndReadAllFromStandardIn(shellLanguage, unpack(commandlineArguments))
		end)
	end
	
	-- TODO: Syntax for defining programs needed on the PATH
	local dotted = pipe(rawCodeString, 'dot', '-Tpng')
    local base64EncondedPortalNetworkGraphicsImage = pipe(dotted, 'base64')
	
	return writer:writeElement('img', '', {src = 'data:image/png;base64,' .. base64EncondedPortalNetworkGraphicsImage})
end)
