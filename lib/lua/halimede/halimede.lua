--[[
This file is part of banias. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT. No part of banias, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of banias. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT.
]]--


local module = {}
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

function assertModule.parameterTypeIs(value, expectation)
	assert(type(expectation) == 'string', 'Parameter is not a string')
	
	assert(type(value) == expectation, "Parameter is not a " .. expectation)
end

-- Would be a bit odd to use this
function assertModule.parameterTypeIsNil(value)
	assertModule.parameterTypeIs(value, 'nil')
end

function assertModule.parameterTypeIsNumber(value)
	assertModule.parameterTypeIs(value, 'number')
end

function assertModule.parameterTypeIsString(value)
	assertModule.parameterTypeIs(value, 'string')
end

function assertModule.parameterTypeIsFunction(value)
	assertModule.parameterTypeIs(value, 'boolean')
end

function assertModule.parameterTypeIsTable(value)
	assertModule.parameterTypeIs(value, 'table')
end

function assertModule.parameterTypeIsFunction(value)
	assertModule.parameterTypeIs(value, 'function')
end

function assertModule.parameterTypeIsThread(value)
	assertModule.parameterTypeIs(value, 'thread')
end

function assertModule.parameterTypeIsUserdata(value)
	assertModule.parameterTypeIs(value, 'userdata')
end

function assertModule.globalTypeIs(expectation, ...)
	assertModule.parameterTypeIsString(expectation)

	assert(_G ~= nil, "Global environment '_G' is not present")
	
	-- We do not use ipairs() as we may be checking for its existence!
	local names = {...}
	local index = 1
	local length = #names
	while index <= length do
		local name = names[index]
		assertModule.parameterTypeIsString(name)
		
		local value = _G[name]
		local qualifiedName = "The global '" .. name .. "'"
		assert(value ~= nil, qualifiedName .. " is not present in the Lua environment")
		assert(type(value) == expectation, qualifiedName .. " is not a " .. expectation)	
	end
end

function assertModule.globalTypeIsTable(...)
	assertModule.globalTypeIs('table', ...)
end

function assertModule.globalTypeIsFunction(...)
	assertModule.globalTypeIs('function', ...)
end

function assertModule.globalTypeIsString(...)
	assertModule.globalTypeIs('string', ...)
end

function assertModule.globalTableHasChieldFieldOfType(expectation, name, ...)
	assertModule.parameterTypeIsString(expectation)
	assertModule.parameterTypeIsString(name)
	
	assertModule.globalTypeIsTable(name)
	
	local package = _G[name]
	
	local childFieldNames = {...}
	for _, childFieldName in ipairs(childFieldNames) do
		assertModule.parameterTypeIsString(childFieldName)
		
		local qualifiedChildFieldName = "The global '" .. name .. '.' .. childFieldName .. "'"
		assert(potentialFunction ~= nil, qualifiedChildFieldName .. " is not present in the Lua environment")
		assert(type(potentialFunction) == expectation, qualifiedChildFieldName .. " is not a " .. expectation)
	end
end

function assertModule.globalTableHasChieldFieldOfTypeString(name, ...)
	assertModule.globalTableHasChieldFieldOfType('string', name, ...)
end

function assertModule.globalTableHasChieldFieldOfTypeTable(name, ...)
	assertModule.globalTableHasChieldFieldOfType('table', name, ...)
end

function assertModule.globalTableHasChieldFieldOfTypeFunction(name, ...)
	assertModule.globalTableHasChieldFieldOfType('function', name, ...)
end
	
assert.globalTypeIsFunction(
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

assert.globalTypeIsTable(
	'_G',
	'package',
	'string',
	'table'
)

local assert = assertModule


function module.hasPackageChildFieldOfType(expectation, name, ...)
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

function module.hasPackageChildFieldOfTypeFunction(name, ...)
	module.hasPackageChildFieldOfType('function', name, ...)
end

function module.hasPackageChildFieldOfTypeString(name, ...)
	module.hasPackageChildFieldOfType('string', name, ...)
end

assert.globalTableHasChieldFieldOfTypeTable('table', 'insert')
assert.globalTableHasChieldFieldOfTypeTable('string', 'find', 'sub')
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

assert.globalTableHasChieldFieldOfTypeTable('string', 'gmatch')
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
assert.globalTableHasChieldFieldOfTypeTable('package', 'config')
module.packageConfiguration = initialisePackageConfiguration(package.config)
local packageConfiguration = module.packageConfiguration

assert.globalTableHasChieldFieldOfTypeTable('string', 'match', 'gsub', 'sub')
function module.dirname(path, folderSeparator)
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
local dirname = module.dirname

assert.globalTableHasChieldFieldOfTypeTable('string', 'sub')
function module.findArg0()
	if type(arg) == 'table' and type(arg[0]) == 'string' then
		return arg[0]
	else
		if module.hasPackageChildFieldOfTypeFunction('debug', 'getinfo') then
			-- May not be a path, could be compiled C code, etc
			local withLeadingAt = debug.getinfo(initialisePackageConfiguration, 'S').source
			return withLeadingAt:sub(2)
		else
			return ''
		end
	end
end
local findArg0 = module.findArg0

assert.globalTableHasChieldFieldOfTypeTable('table', 'concat')
function module.concatenateToPath(parentPath, ...)
	assert.parameterTypeIsString(arentPath)
	
	local subFolders = {...}
	local folderSeparator = packageConfiguration.folderSeparator
	
	local rootPath
	if #subFolders == 0 then
		return parentPath
	end
	
	local relativeSubFoldersPath = table.concat(subFolders, folderSeparator)
	return parentPath .. folderSeparator .. relativeSubFoldersPath
end
local concatenateToPath = module.concatenateToPath

-- Ideally, we need to use realpath to resolve symlinks
local function findOurFolderPath()
	return dirname(findArg0(), packageConfiguration.folderSeparator)
end

local function determineLuaLibraryFileExtension(folderSeparator)
	
	local dll = 'dll'
	local so = 'so'
	local dylib = 'dylib'
	
	-- Running under LuaJIT makes life so much easier
	if module.hasPackageChildFieldOfTypeString('jit', 'os') then
		
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

assert.globalTableHasChieldFieldOfTypeTable('string', 'gmatch')
assert.globalTableHasChieldFieldOfTypeTable('table', 'insert')
function module.parentModuleNameFromModuleName(moduleName)
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
local parentModuleNameFromModuleName = module.parentModuleNameFromModuleName

local function requireParentModuleFirst(ourParentModuleName)
	if ourParentModuleName == '' then
		return rootParentModule
	else
		-- Load the parent; recursion is prevented by checking package.loaded
		return require(ourParentModuleName)
	end
end

assert.globalTableHasChieldFieldOfTypeTable('table', 'insert')
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

assert.globalTableHasChieldFieldOfTypeTable('table', 'insert', 'concat')
local function initialiseSearchPaths(moduleNameLocal, searchPathGenerators)

	local folderSeparator = packageConfiguration.folderSeparator
	local pathSeparator = packageConfiguration.pathSeparator
	
	local mappings = {
		path = 'lua',
		cpath = determineLuaLibraryFileExtension(folderSeparator)
	}	
	
	for key, fileExtension in pairs(mappings) do
		local paths = {}
		for _, searchPathGenerator in moduleNameLocal, searchPathGenerators do
			table.insert(paths, concatenateToPath(modulesRootPath, searchPathGenerator(moduleNameLocal) .. '.' .. fileExtension)
		end
		package[key] = table.concat(paths, pathSeparator)
	end
end

assert.globalTableHasChieldFieldOfTypeTable('string', 'gsub')
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

assert.globalTableHasChieldFieldOfTypeTable('string', 'len')
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
	return usefulRequire(modname, package.loaded, searchers, packageConfiguration.folderSeparator)
end


-- Support being require'd ourselves
if moduleName == '' then
	
	modulesRootPath = concatenateToPath(findOurFolderPath(), '..')
	
	package.loaded[ourModuleName] = module
	local halimedeTrace = require(ourModuleName .. '.trace')
	local halimedeRequireChild = require(ourModuleName .. '.requireChild')
	local halimedeRequireSibling = require(ourModuleName .. '.requireSibling')
else
	return module
end
