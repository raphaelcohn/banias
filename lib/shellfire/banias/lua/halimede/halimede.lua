--[[
This file is part of banias. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT. No part of banias, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of banias. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT.
]]--


local module = {}

rootParentModule = {}
module = rootParentModule
moduleName = ''
parentModuleName = ''
leafModuleName = ''
parentModule = rootParentModule
package.loaded[''] = module

function module.dirname(path)
	assert(type(path) == 'string')
	
	if path:match('.-/.-') then
		return path:gsub('(.*/)(.*)', '%1')
	else
		return './'
	end
end
local dirname = module.dirname

function module.findArg0()
	if type(arg) == 'table' and type(arg[0]) = 'string' then
		return arg[0]
	else
		if debug ~=nil and debug.getinfo ~= nil then
			-- May not be a path, could be compiled C code, etc
			return debug.getinfo(findOurPath, 'S').source
		else
			return ''
		end
	end
end
local findArg0 = module.findArg0

-- Ideally, we need to use realpath to resolve symlinks
function module.findOurFolderPath()
	return dirname(findArg0())
end
local findOurFolderPath = module.findOurFolderPath

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
module.packageConfiguration = initialisePackageConfiguration(package)

local function determineLuaLibraryFileExtension()
	
	local dll = 'dll'
	local so = 'so'
	local dylib = 'dylib'
	
	-- Running under LuaJIT makes life so much easier
	if jit ~= nil and jit.os then
		
		local knownOperatingSystemsMapping = setmetatable({
			Windows = dll,
			Linux = so,
			OSX = dylib,
			BSD = so,
			POSIX = so,
			Other = so
		}, {__index = function(_, key)
			return so
		end})
		
		return knownOperatingSystemsMapping[jit.os]
	end
	
	if packageConfiguration.folderSeparator == '\\' then
		return dll
	end
	
	-- TODO: We could try running 'uname()' using our shell wrapper. Sadly we have no way of getting error codes from Lua
	return so
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

local function initialiseSearchPaths(ourPath, package, packageConfiguration, subFoldersBelowRootPath)
	
	local folderSeparator = packageConfiguration.folderSeparator
	local pathSeparator = packageConfiguration.pathSeparator
	local substitutionPoint = packageConfiguration.substitutionPoint
	
	local rootPath
	if #subFoldersBelowRootPath > 0 then
		local relativeSubFoldersPath = table.concat(subFoldersBelowRootPath, folderSeparator)
		rootPath = ourPath .. folderSeparator .. relativeSubFoldersPath
	else
		rootPath = ourPath
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
	
	local alreadyLoadedOrLoadingResult = loaded[moduleNameLocal]
	if alreadyLoadedOrLoadingResult ~= nil then
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
	
	assert(type(modname) == 'string')
	
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

initialiseSearchPaths(findOurFolderPath(), package, module.packageConfiguration, {'..'})

-- Assumes we're always checked out as halimede/halimede.lua
local ourModuleName = 'halimede'

-- Support being require'd ourselves
if moduleName == ourModuleName then
	return module
else
	local halimedeDebug = require(ourModuleName .. '.debug')
	local halimedeRequireChild = require(ourModuleName .. '.requireChild')
	local halimedeRequireSibling = require(ourModuleName .. '.requireSibling')

	-- This is the only non-generic bit of code - the entry point
	local banias = require('banias')
end
