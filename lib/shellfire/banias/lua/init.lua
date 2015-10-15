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

local function initialiseSearchPath(subFoldersBelowRootPath)
	
	local configuration = packageConfiguration()
	local folderSeparator = configuration.folderSeparator
	local pathSeparator = configuration.pathSeparator
	local substitutionPoint = configuration.substitutionPoint
		
	local ourPath = findOurPath()
	local rootPath
	if #subFoldersBelowRootPath > 0 then
		local relativeSubFoldersPath = table.concat(subFoldersBelowRootPath, folderSeparator)
		rootPath = ourPath .. folderSeparator .. relativeSubFoldersPath
	else
		rootPath = ourPath
	end
	
	local function determineLuaLibraryFileExtension()
		if configuration.folderSeparator == '\\' then
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
		return folderSeparator .. 'init'
	end
	
	local function namedInFolderPath()
		return substitutionPoint .. folderSeparator .. substitutionPoint
	end
	
	package.path = paths('lua', siblingPath(), initPath(), namedInFolderPath())
	package.cpath = paths(determineLuaLibraryFileExtension(), siblingPath(), initPath(), namedInFolderPath())
	
	-- TODO: Should we also set LD_LIBRARY_PATH for the cloaders (so that when they wrap, say, OpenSSL, things work)?
end

function _G.requireChildOrSibling(childModuleElementName)
	return newRequire(parentModuleName .. childModuleElementName)
end

local originalRequire = _G.require
_G.fullModuleName = ''
local function newRequire(modname)
		
	if type(modname) ~= 'string' then
		error("Please supply a modname to require() that is a string")
	end
	
	if modname:len() == 0 then
		error("Please supply a modname to require() that isn't empty")
	end

	-- Mimics the already-loaded loader, but for '.' delimited names
	if package.loaded[modname] ~= nil then
		io.stderr:write("xxxx\n")
		return package.loaded[modname]
	end
	
	-- Prevent a parent that loads a child then having the parent loaded again in an infinite loop
	local module = {}
	package.loaded[modname] = module
	
	local function requireParentModuleFirst()
		local moduleElementNames = {}
		for moduleElementName in modname:gmatch('[^%.]+') do
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
	
		if size > 1 then
			-- Load the parent; recursion is prevented by checking package.loaded
			return parentModuleName, newRequire(parentModuleName)
		else
			return parentModuleName, {}
		end
	end
	local parentModuleName, parentModule = requireParentModuleFirst()
	
	-- eg html5.code.xxx => html5/code/xxx
	local moduleRelativePath = modname:gsub('[%.]+', packageConfiguration().folderSeparator)
	
	-- What about _REQUIREDNAME ?
	local function newGlobalEnvironment()
		return setmetatable({module = module, parentModule = parentModule, parentModuleName = parentModuleName}, {__index = _G})
	end
		
	local delegateRequire
	
	-- https://github.com/keplerproject/lua-compat-5.3
	if _VERSION == 'Lua 5.1' then
		delegateRequire = setfenv(function()

			io.stderr:write('hello   hello' .. '\n')
			io.stderr:write(type(moduleRelativePath) .. '\n')
			local result = originalRequire(moduleRelativePath)
			io.stderr:write('hello   XXX' .. '\n')
			
			
			
			
			
			
			
			
			
			
			
			return result
			
			pandoc: user error (attempt to call a nil value)
			WHY?
			Try turning on per-line debugging... or function exit debugging
			
		end, newGlobalEnvironment())
	else
		-- Assuming Lua 5.2
		do
			local _ENV = newGlobalEnvironment()
			function delegateRequire()
				return originalRequire(moduleRelativePath)
			end
		end
	end
	
	return delegateRequire()
	
end
_G.require = newRequire

-- Ideas: Using Lua for config with a safe environment https://stackoverflow.com/questions/3098544/lua-variable-scoping-with-setfenv#3099226
debugIfRequired()
initialiseSearchPath({})

-- This is the only non-generic bit of code - the entry point
local banias = require('banias')
