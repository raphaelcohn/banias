--[[
This file is part of banias. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT. No part of banias, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of banias. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT.
]]--


local ourModule = {}
local ourModuleName = 'halimede'

rootParentModule = {}
module = rootParentModule
moduleName = ''
parentModuleName = ''
leafModuleName = ''
parentModule = rootParentModule
package.loaded[''] = module
modulesRootPath = ''


-- Embedded assert module (logically, assert.lua, but functionality is needed during load)

local assertModule = {}
package.loaded[ourModuleName .. '.assert'] = assertModule


-- Best efforts for failing if error is missing
if error == nil then
	if assert ~= nil then
		assert(false, "The global 'error' is not present in the Lua environment")
	end
	if print ~= nil then
		print("The global 'error' is not present in the Lua environment")
	end
	if os ~= nil then
		if os.exit ~= nil then
			os.exit(1)
		end
	end
	error("Calling non-existent error should cause the Lua environment to die")
end

if type == nil then
	error("The global 'type' is not present in the Lua environment")
end

-- Guard for presence of global assert
if assert == nil then
	assert = function(value, message)
		if value == false or value == nil then
			local assertionMessage
			if message == nil then
				assertionMessage = 'assertion failed!'
			else
				assertionMessage = message
			end
			error(assertionMessage)
		else
			return value, optionalMessage
		end
	end
end

function assertModule.withLevel(booleanResult, message, level)
	if booleanResult then
		return
	end
	error(message, level)
end
local withLevel = assertModule.withLevel

local function parameterTypeIs(value, expectation)
	withLevel(type(value) == expectation, "Parameter is not a " .. expectation, 4)
end

-- Would be a bit odd to use this
function assertModule.parameterTypeIsNil(value)
	assertModule.parameterTypeIs(value, 'nil')
end

function assertModule.parameterTypeIsNumber(value)
	parameterTypeIs(value, 'number')
end

function assertModule.parameterTypeIsString(value)
	parameterTypeIs(value, 'string')
end

function assertModule.parameterTypeIsFunction(value)
	parameterTypeIs(value, 'boolean')
end

function assertModule.parameterTypeIsTable(value)
	parameterTypeIs(value, 'table')
end

function assertModule.parameterTypeIsFunction(value)
	parameterTypeIs(value, 'function')
end

function assertModule.parameterTypeIsThread(value)
	parameterTypeIs(value, 'thread')
end

function assertModule.parameterTypeIsUserdata(value)
	parameterTypeIs(value, 'userdata')
end

local function globalTypeIs(expectation, ...)
	assertModule.parameterTypeIsString(expectation)

	if _G == nil then
		error("Global environment '_G' is not present", 3)
	end
	
	-- We do not use ipairs() as we may be checking for its existence!
	local names = {...}
	local index = 1
	local length = #names
	while index <= length do
		local name = names[index]
		assertModule.parameterTypeIsString(name)
		
		local global = _G[name]
		local qualifiedName = "The global '" .. name .. "'"
		withLevel(global ~= nil, qualifiedName .. " is not present in the Lua environment", 4)
		withLevel(type(global) == expectation, qualifiedName .. " is not a " .. expectation, 4)
		
		index = index + 1
	end
end

function assertModule.globalTypeIsTable(...)
	globalTypeIs('table', ...)
end

function assertModule.globalTypeIsFunction(...)
	globalTypeIs('function', ...)
end

function assertModule.globalTypeIsString(...)
	globalTypeIs('string', ...)
end

local function globalTableHasChieldFieldOfType(expectation, name, ...)
	assertModule.parameterTypeIsString(expectation)
	assertModule.parameterTypeIsString(name)
	
	assertModule.globalTypeIsTable(name)
	
	local package = _G[name]
	
	local childFieldNames = {...}
	for _, childFieldName in ipairs(childFieldNames) do
		assertModule.parameterTypeIsString(childFieldName)
		
		local childField = package[childFieldName]
		local qualifiedChildFieldName = "The global '" .. name .. '.' .. childFieldName .. "'"
		withLevel(childField ~= nil, qualifiedChildFieldName .. " is not present in the Lua environment", 4)
		withLevel(type(childField) == expectation, qualifiedChildFieldName .. " is not a " .. expectation, 4)
	end
end

function assertModule.globalTableHasChieldFieldOfTypeString(name, ...)
	globalTableHasChieldFieldOfType('string', name, ...)
end

function assertModule.globalTableHasChieldFieldOfTypeTable(name, ...)
	globalTableHasChieldFieldOfType('table', name, ...)
end

function assertModule.globalTableHasChieldFieldOfTypeFunction(name, ...)
	globalTableHasChieldFieldOfType('function', name, ...)
end

assertModule.globalTypeIsFunction(
	'assert',
	'error',
	'ipairs',
	'pairs',
	'pcall',
	'setmetatable',
	'type',
	'unpack',
	'xpcall'
)

assertModule.globalTypeIsTable(
	'_G',
	'package',
	'string',
	'table'
)

local assert = assertModule
ourModule.assert = assert

function ourModule.hasPackageChildFieldOfType(expectation, name, ...)
	assert.parameterTypeIsString(expectation)
	assert.parameterTypeIsString(name)
	
	local package = _G[name]
	if package == nil then
		return false
	end
	
	if type(package) ~= 'table' then
		return false
	end
	
	local package = _G[name]
	
	local childFieldNames = {...}
	for _, childFieldName in ipairs(childFieldNames) do
		assertModule.parameterTypeIsString(childFieldName)
		
		local value = package[childFieldName]
		if value == nil then
			return false
		end
		
		if type(value) ~= expectation then
			return false
		end
	end
end

function ourModule.hasPackageChildFieldOfTypeFunction(name, ...)
	ourModule.hasPackageChildFieldOfType('function', name, ...)
end

function ourModule.hasPackageChildFieldOfTypeString(name, ...)
	ourModule.hasPackageChildFieldOfType('string', name, ...)
end

assert.globalTableHasChieldFieldOfTypeFunction('table', 'insert')
assert.globalTableHasChieldFieldOfTypeFunction('string', 'find', 'sub')
function string.split(value, separator)

	local result = {}
	local length = value:len()
	
	local start
	local finish
	local previousFinish = 1
	while true do
		start, finish = value:find(separator, previousFinish, true)
		if start == nil then
			table.insert(result, value:sub(previousFinish))
			break
		end
		table.insert(result, value:sub(previousFinish, start - 1))
		previousFinish = finish + 1
	end

	return result
end

assert.globalTableHasChieldFieldOfTypeFunction('string', 'gmatch')
local function initialisePackageConfiguration(config)
	
	local packageConfigurationMapping = {
		'folderSeparator', -- eg '/' on POSIX
		'pathSeparator', -- usually ';' (even on POSIX)
		'substitutionPoint', -- usually '?'
		'executableDirectory',  -- usually '!' (only works on Windows)
		'markToIgnoreTestWhenBuildLuaOpen' -- usually '-'
	}
	
	local configuration = {}
	
	local index = 1
	for line in config:gmatch('([^\n]+)') do
		configuration[packageConfigurationMapping[index]] = line
		index = index + 1
	end
	
	return configuration
end
assert.globalTableHasChieldFieldOfTypeString('package', 'config')
ourModule.packageConfiguration = initialisePackageConfiguration(package.config)
local packageConfiguration = ourModule.packageConfiguration

assert.globalTableHasChieldFieldOfTypeFunction('string', 'match', 'gsub', 'sub')
function ourModule.dirname(path, folderSeparator)
	assert.parameterTypeIsString(path)
	assert.parameterTypeIsString(folderSeparator)
	
	local regexSeparator
	if folderSeparator == '\\' then
		regexSeparator = '\\\\'
	else
		regexSeparator = folderSeparator
	end
	
	if path:match('.-' .. regexSeparator .. '.-') then
		local withTrailingSlash = path:gsub('(.*' .. regexSeparator .. ')(.*)', '%1')
		return withTrailingSlash:sub(1, #withTrailingSlash - 1)
	else
		return './'
	end
end
local dirname = ourModule.dirname

assert.globalTableHasChieldFieldOfTypeFunction('string', 'sub')
function ourModule.findArg0()
	if type(arg) == 'table' and type(arg[0]) == 'string' then
		return arg[0]
	else
		if ourModule.hasPackageChildFieldOfTypeFunction('debug', 'getinfo') then
			-- May not be a path, could be compiled C code, etc
			local withLeadingAt = debug.getinfo(initialisePackageConfiguration, 'S').source
			return withLeadingAt:sub(2)
		else
			return ''
		end
	end
end
local findArg0 = ourModule.findArg0

assert.globalTableHasChieldFieldOfTypeFunction('table', 'concat')
function ourModule.concatenateToPath(parentPath, ...)
	assert.parameterTypeIsString(parentPath)
	
	local subFolders = {...}
	local folderSeparator = packageConfiguration.folderSeparator
	
	local rootPath
	if #subFolders == 0 then
		return parentPath
	end
	
	local relativeSubFoldersPath = table.concat(subFolders, folderSeparator)
	return parentPath .. folderSeparator .. relativeSubFoldersPath
end
local concatenateToPath = ourModule.concatenateToPath

-- Ideally, we need to use realpath to resolve symlinks
local function findOurFolderPath()
	return dirname(findArg0(), packageConfiguration.folderSeparator)
end

local function determineLuaLibraryFileExtension(folderSeparator)
	
	local dll = 'dll'
	local so = 'so'
	local dylib = 'dylib'
	
	-- Running under LuaJIT makes life so much easier
	if ourModule.hasPackageChildFieldOfTypeString('jit', 'os') then
		
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
	
	if folderSeparator == '\\' then
		return dll
	end
	
	return so
end

assert.globalTableHasChieldFieldOfTypeFunction('string', 'gmatch')
assert.globalTableHasChieldFieldOfTypeFunction('table', 'insert')
function ourModule.parentModuleNameFromModuleName(moduleName)
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
local parentModuleNameFromModuleName = ourModule.parentModuleNameFromModuleName

local function requireParentModuleFirst(ourParentModuleName)
	if ourParentModuleName == '' then
		return rootParentModule
	else
		-- Load the parent; recursion is prevented by checking package.loaded
		return require(ourParentModuleName)
	end
end

assert.globalTableHasChieldFieldOfTypeFunction('table', 'insert')
local searchPathGenerators = {
	function(moduleName)
		return packageConfiguration.substitutionPoint
	end,
	function(moduleName)
		return packageConfiguration.substitutionPoint, 'init'
	end,
	function(moduleName)
		-- eg banias.html5 => banias/html5/html5.lua (modname is then irrelevant to searcher)
		local subFolders = moduleName:split('.')
		table.insert(subFolders, subFolders[#subFolders])
		return unpack(subFolders)
	end
}

assert.globalTableHasChieldFieldOfTypeFunction('table', 'insert', 'concat')
local function initialiseSearchPaths(moduleNameLocal, searchPathGenerators)

	local folderSeparator = packageConfiguration.folderSeparator
	local pathSeparator = packageConfiguration.pathSeparator
	
	local mappings = {
		path = 'lua',
		cpath = determineLuaLibraryFileExtension(folderSeparator)
	}	
	
	for key, fileExtension in pairs(mappings) do
		local paths = {}
		for _, searchPathGenerator in ipairs(searchPathGenerators) do
			table.insert(paths, concatenateToPath(modulesRootPath, searchPathGenerator(moduleNameLocal)) .. '.' .. fileExtension)
		end
		package[key] = table.concat(paths, pathSeparator)
	end
end

assert.globalTableHasChieldFieldOfTypeFunction('string', 'gsub')
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
	
	initialiseSearchPaths(moduleNameLocal, searchPathGenerators)
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

assert.globalTableHasChieldFieldOfTypeFunction('string', 'len')
assert.globalTableHasChieldFieldOfTypeTable('package', 'loaded')
function require(modname)
	assert.parameterTypeIsString(modname)
	
	if modname:len() == 0 then
		error("Please supply a modname to require() that isn't empty")
	end
	
	-- Lua 5.1 / 5.2 compatibility
	local searchers = package.searchers
	if searchers == nil then
		searchers = package.loaders
	end
	if searchers == nil then
		error("Please ensure 'package.searchers' or 'package.loaders' exists")
	end
	return usefulRequire(modname, package.loaded, searchers, packageConfiguration.folderSeparator)
end

-- Support being require'd ourselves
if moduleName == '' then
	
	modulesRootPath = concatenateToPath(findOurFolderPath(), '..')
	
	package.loaded[ourModuleName] = ourModule
	local halimedeTrace = require(ourModuleName .. '.trace')
	local halimedeRequireChild = require(ourModuleName .. '.requireChild')
	local halimedeRequireSibling = require(ourModuleName .. '.requireSibling')
else
	return ourModule
end
