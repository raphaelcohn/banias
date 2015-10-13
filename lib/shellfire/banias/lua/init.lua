--[[
This file is part of banias. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT. No part of banias, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of banias. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT.
]]--


local function debugIfRequired()

	local environmentVariable = 'PANDOC_LUA_BANIAS_DEBUG'
	local enableDebug = os.getenv(environmentVariable)
	
	if enableDebug == nil then
		return
	end
	
	if enableDebug ~= 'true' then
		return
	end
	
	local hook = function(event)
		local nameInfo = debug.getinfo(2, 'n')
	
		local nameWhat = nameInfo.namewhat
		if nameWhat == '' then
			nameWhat = 'unknown'
		end
	
		local functionName = nameInfo.name
		if functionName == nil then
			functionName = '?'
		end
	
		local sourceInfo = debug.getinfo(2, 'S')
		local language = sourceInfo.what
		local functionKeyword
		if language == 'Lua' then
			functionKeyword = ' function'
		else
			functionKeyword = ''
		end

		local sourceText
		if language == 'C' then
			sourceText = ''
		else
			local source = sourceInfo.source
			local currentLineNumber = debug.getinfo(2, 'l').currentline
			local currentLine
			if currentLineNumber == -1 then
				currentLine = ''
			else
				currentLine = string.format(' at line %d', currentLineNumber)
			end
			sourceText = string.format(' in %s%s', source, currentLine)
		end
		
		local messageTemplate = "Called %s %s%s '%s'%s\n"
		io.stderr:write(messageTemplate:format(language, nameWhat, functionKeyword, functionName, sourceText))
	end
	
	debug.sethook(hook, 'c')
end

local function dirname(path)
	if path:match('.-/.-') then
		return path:gsub('(.*/)(.*)', '%1')
	else
		return ''
	end
end

-- Ideally, we need to use realpath to resolve symlinks
local function findOurPath()
	local arg0 = debug.getinfo(findOurPath, 'S').source
	local parentFolderPath = dirname(arg0)
	if parentFolderPath == '' then
		return './'
	end
	return parentFolderPath
end

local mapping = {
	'folderSeparator', -- eg / on POSIX
	'pathSeparator', -- usually ; (even on POSIX)
	'substitutionPoint', -- usually ?
	'executableDirectory',  -- usually ! (only works on Windows)
	'markToIgnoreTestWhenBuildLuaOpen' -- usually -
}

local function packageConfiguration()
	
	local configuration = {}
	
	local index = 1
	for line in package.config:gmatch('([^\n]+)') do
		configuration[mapping[index]] = line
		index = index + 1
	end
	
	return configuration
end

local function initialiseSearchPath()
	
	local path = findOurPath()
	local configuration = packageConfiguration()
	
	local folderSeparator = configuration.folderSeparator
	local pathSeparator = configuration.pathSeparator
	local substitutionPoint = configuration.substitutionPoint
	local paths = {
		path .. substitutionPoint .. '.lua',
		path .. substitutionPoint .. folderSeparator .. 'init.lua',
		path .. substitutionPoint .. folderSeparator .. substitutionPoint .. '.lua'
	}
	-- '!' for executable's directory?
	package.path = table.concat(paths, pathSeparator)
	-- TODO: Set package.cpath (see http://www.lua.org/manual/5.2/manual.html#pdf-package.searchers); requires knowledge of file extension
	-- TODO: Should we also set LD_LIBRARY_PATH for the cloaders (so that when they wrap, say, OpenSSL, things work)
end

debugIfRequired()
initialiseSearchPath()

require 'banias'
