--[[
This file is part of banias. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT. No part of banias, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of banias. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT.
]]--


local packageConfiguration
rootParentModule = {}
module = rootParentModule
moduleName = ''
parentModuleName = ''
leafModuleName = ''
parentModule = rootParentModule
package.loaded[''] = module

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
			if nameWhat ==  'upvalue' then
				functionKeyword = ''
			else
				functionKeyword = ' function'
			end
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
		
		local messageTemplate = "%s %s %s%s '%s'%s\n"
		io.stderr:write(messageTemplate:format(event, language, nameWhat, functionKeyword, functionName, sourceText))
	end
	
	debug.sethook(hook, 'cr')
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

local function initialisePackageConfiguration(package)
	
	local packageConfigurationMapping = {
		'folderSeparator', -- eg '/' on POSIX
		'pathSeparator', -- usually ';' (even on POSIX)
		'substitutionPoint', -- usually '?'
		'executableDirectory',  -- usually '!' (only works on Windows)
		'markToIgnoreTestWhenBuildLuaOpen' -- usually '-'
	}
	
	local configuration = {}
	
	local index = 1
	for line in package.config:gmatch('([^\n]+)') do
		configuration[packageConfigurationMapping[index]] = line
		index = index + 1
	end
	
	return configuration
end

local function initialiseSearchPath(package, packageConfiguration, subFoldersBelowRootPath)
	
	local folderSeparator = packageConfiguration.folderSeparator
	local pathSeparator = packageConfiguration.pathSeparator
	local substitutionPoint = packageConfiguration.substitutionPoint
	
	local ourPath = findOurPath()
	local rootPath
	if #subFoldersBelowRootPath > 0 then
		local relativeSubFoldersPath = table.concat(subFoldersBelowRootPath, folderSeparator)
		rootPath = ourPath .. folderSeparator .. relativeSubFoldersPath
	else
		rootPath = ourPath
	end
	
	local function determineLuaLibraryFileExtension()
		if packageConfiguration.folderSeparator == '\\' then
			return 'dll'
		end
		
		-- Maybe dylib on Mac OS X, but there's a good chance uname() is available if we want to try...; the default Lua 5.1 interpreter seems to use 'so'
		return 'so'
	end
	
	local function paths(fileExtension, ...)
		
		local function makeAbsolutePath(path)
			return rootPath .. path .. '.' .. fileExtension
		end
		
		local paths = {}
		for _, path in ipairs({...}) do
			table.insert(paths, makeAbsolutePath(path))
		end
		return table.concat(paths, pathSeparator)
	end
	
	local function siblingPath()
		return substitutionPoint
	end
	
	local function initPath()
		return substitutionPoint .. folderSeparator .. 'init'
	end
	
	local function namedInFolderPath()
		return substitutionPoint .. folderSeparator .. substitutionPoint
	end
	
	package.path = paths('lua', siblingPath(), initPath(), namedInFolderPath())
	package.cpath = paths(determineLuaLibraryFileExtension(), siblingPath(), initPath(), namedInFolderPath())
	
	-- TODO: Should we also set LD_LIBRARY_PATH for the csearchers (so that when they wrap, say, OpenSSL, things work)?
end

local function parentModuleNameFromModuleName(moduleName)
	local moduleElementNames = {}
	for moduleElementName in moduleName:gmatch('[^%.]+') do
		table.insert(moduleElementNames, moduleElementName)
	end

	local size = #moduleElementNames
	local index = 1
	local parentModuleName = ''
	while index < size do
		if parentModuleName ~= '' then
			parentModuleName = parentModuleName .. '.'
		end
		parentModuleName = parentModuleName .. moduleElementNames[index]
		index = index + 1
	end
	
	return parentModuleName, moduleElementNames[size]
end

local function requireParentModuleFirst(ourParentModuleName)
	if ourParentModuleName == '' then
		return rootParentModule
	else
		-- Load the parent; recursion is prevented by checking package.loaded
		return require(ourParentModuleName)
	end
end

local function usefulRequire(moduleNameLocal, loaded, searchers, folderSeparator)
	
	-- Mimics the already-loaded loader, but for '.' delimited names
	-- Turns non-table results into tables; turns nil results into existing tables
	local alreadyLoadedOrLoadingResult = loaded[moduleNameLocal]
	if alreadyLoadedOrLoadingResult ~= nil then
		--print("ALREADY LOADED Or Loading " .. moduleNameLocal, alreadyLoadedOrLoadingResult)
		return alreadyLoadedOrLoadingResult
	end
	
	local moduleOriginal = module
	local moduleNameOriginal = moduleName
	local parentModuleNameOriginal = parentModuleName
	local leafModuleNameOriginal = leafModuleName
	local parentModuleOriginal = parentModule
	
	-- Prevent a parent that loads a child then having the parent loaded again in an infinite loop
	local moduleLocal = {}
	loaded[moduleNameLocal] = moduleLocal
	local parentModuleNameLocal, leafModuleNameLocal = parentModuleNameFromModuleName(moduleNameLocal)
	local parentModuleLocal = requireParentModuleFirst(parentModuleNameLocal)
	
	local function resetModuleGlobals()
		module = moduleOriginal
		moduleName = moduleNameOriginal
		parentModuleName = parentModuleNameOriginal
		leadModuleName = leafModuleNameOriginal
		parentModule = parentModuleOriginal
	end
	
	module = moduleLocal
	moduleName = moduleNameLocal
	parentModuleName = moduleNameLocal
	leafModuleName = leafModuleNameLocal
	parentModule = loaded[parentModuleNameLocal]
	
	for _, searcher in ipairs(searchers) do
		-- filePath only in Lua 5.2+, and not set by the preload searcher
		local moduleLoaderOrFailedToFindExplanationString, filePath = searcher(moduleNameLocal)
		if type(moduleLoaderOrFailedToFindExplanationString) == 'function' then
			local result = moduleLoaderOrFailedToFindExplanationString()
			
			local ourResult
			if result == nil then
				ourResult = moduleLocal
			else
				if type(result) == 'table' then
					ourResult = result
				else
					ourResult = {result}
				end
			end
			loaded[moduleNameLocal] = ourResult
			resetModuleGlobals()
			return ourResult
		end
	end
	
	loaded[moduleNameLocal] = nil
	resetModuleGlobals()
	error(string.format("Could not load module '%s' ", moduleNameLocal))
end

function require(modname)
	
	if type(modname) ~= 'string' then
		error("Please supply a modname to require() that is a string")
	end
	
	if modname:len() == 0 then
		error("Please supply a modname to require() that isn't empty")
	end
	
	-- Lua 5.1 / 5.2 compatibility
	local searchers = package.searchers
	if searchers == nil then
		searchers = package.loaders
	end
	return usefulRequire(modname, package.loaded, searchers, packageConfiguration.folderSeparator)
end

function requireChild(childModuleElementName)
	return require(parentModuleName .. '.' .. childModuleElementName)
end

function requireSibling(siblingModuleElementName)
	local grandParentModuleName, _ = parentModuleNameFromModuleName(parentModuleName)
	local requiredModuleName
	if grandParentModuleName == '' then
		requiredModuleName = siblingModuleElementName
	else
		requiredModuleName = grandParentModuleName .. '.' .. siblingModuleElementName
	end
	return require(requiredModuleName)
end

debugIfRequired()
packageConfiguration = initialisePackageConfiguration(package)
initialiseSearchPath(package, packageConfiguration, {})

-- This is the only non-generic bit of code - the entry point
local banias = require('banias')
