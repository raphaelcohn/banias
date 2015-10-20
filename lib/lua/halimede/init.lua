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


local function essentialGlobalMissingErrorMessage(globalName)
	return "The essential global '" .. globalName .. "' is not present in the Lua environment"
end

-- Best efforts for failing if error is missing
if error == nil then
	local errorMessage = essentialGlobalMissingErrorMessage('error')
	if assert ~= nil then
		assert(false, errorMessage)
	end
	if print ~= nil then
		print(errorMessage)
	end
	if os ~= nil then
		if os.exit ~= nil then
			os.exit(1)
		end
	end
	error("Calling non-existent error should cause the Lua environment to die")
end


-- Embedded type module (logically, type.lua, but functionality is needed during load)
-- Embedded assert module (logically, assert.lua, but functionality is needed during load)

local assertModule = {}
package.loaded[ourModuleName .. '.assert'] = assertModule

if type == nil then
	error(essentialGlobalMissingErrorMessage('type'))
end

if setmetatable == nil then
	error(essentialGlobalMissingErrorMessage('setmetatable'))
end

if getmetatable == nil then
	error(essentialGlobalMissingErrorMessage('getmetatable'))
end

local typeModule = {}
package.loaded[ourModuleName .. '.type'] = assertModule

local function NamedFunction(name, functor)
	return setmetatable({
		name = name
	}, {
		__tostring = function()
			return 'function:' .. name
		end,
		__call = function(table, ...)
			return functor(...)
		end
	})
end

local function is(value, name)
	return type(value) == name
end

local function simpleTypeObject(name)
	return NamedFunction(name, function(...)
		local values = {...}
		for _, value in ipairs(values) do
			if is(value, name) then
				return true
			end
		end
		return false
	end)
end

typeModule.isNil = simpleTypeObject('nil')
typeModule.isNumber = simpleTypeObject('number')
typeModule.isString = simpleTypeObject('string')
typeModule.isBoolean = simpleTypeObject('boolean')
typeModule.isTable = simpleTypeObject('table')
typeModule.isFunction = simpleTypeObject('function')
typeModule.isThread = simpleTypeObject('thread')
typeModule.isUserdata = simpleTypeObject('userdata')

local function functionOrCallTypeObject()
	return NamedFunction('function or _call', function(...)
		local values = {...}
		for _, value in ipairs(values) do
			if is(value, 'function') then
				return true
			end
			if is(getmetatable(value).__call, 'function') then
				return true
			end
		end
		return false
	end)
end
typeModule.isFunctionOrCall = functionOrCallTypeObject()

local function multipleTypesObject(name1, name2)
	return NamedFunction(name1 .. ' or ' .. name2, function(...)
		local values = {...}
		for _, value in ipairs(values) do
			if is(value, name1) then
				return true
			end
			if is(value, name2) then
				return true
			end
		end
		return false
	end)
end
typeModule.isTableOrUserdata = multipleTypesObject('table', 'userdata')

function typeModule.hasPackageChildFieldOfType(isOfType, name, ...)
	assertModule.parameterTypeIsTable(isOfType)
	assertModule.parameterTypeIsString(name)
	
	local package = _G[name]
	if not typeModule.isTable(package) then
		return false
	end
	
	local package = _G[name]
	
	local childFieldNames = {...}
	for _, childFieldName in ipairs(childFieldNames) do
		assertModule.parameterTypeIsString(childFieldName)
		
		local value = package[childFieldName]
		if not isOfType(value) then
			return false
		end
	end
	
	return true
end

function typeModule.hasPackageChildFieldOfTypeString(name, ...)
	return typeModule.hasPackageChildFieldOfType(typeModule.isString, name, ...)
end

function typeModule.hasPackageChildFieldOfTypeFunctionOrCall(name, ...)
	return typeModule.hasPackageChildFieldOfType(typeModule.isFunctionOrCall, name, ...)
end

function typeModule.hasPackageChildFieldOfTypeTableOrUserdata(name, ...)
	return typeModule.hasPackageChildFieldOfType(typeModule.isTableOrUserdata, name, ...)
end


local type = typeModule
ourModule.type = type






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
	
	local errorMessage
	if typeModule.hasPackageChildFieldOfTypeFunctionOrCall('debug', 'traceback') then
		errorMessage = debug.traceback(message, level)
	else
		errorMessage = message
	end
	
	error(errorMessage, level)
end
local withLevel = assertModule.withLevel

local function parameterTypeIs(value, isOfType)
	withLevel(isOfType(value), "Parameter is not a " .. isOfType.name, 4)
end

-- Would be a bit odd to use this
function assertModule.parameterTypeIsNil(value)
	assertModule.parameterTypeIs(value, typeModule.isNil)
end

function assertModule.parameterTypeIsNumber(value)
	return parameterTypeIs(value, typeModule.isNumber)
end

function assertModule.parameterTypeIsString(value)
	return parameterTypeIs(value, typeModule.isString)
end

function assertModule.parameterTypeIsFunction(value)
	return parameterTypeIs(value, typeModule.isBoolean)
end

function assertModule.parameterTypeIsTable(value)
	return parameterTypeIs(value, typeModule.isTable)
end

function assertModule.parameterTypeIsFunction(value)
	return parameterTypeIs(value, typeModule.isFunction)
end

function assertModule.parameterTypeIsThread(value)
	return parameterTypeIs(value, typeModule.isThread)
end

function assertModule.parameterTypeIsUserdata(value)
	return parameterTypeIs(value, typeModule.isUserdata)
end

function assertModule.parameterTypeIsFunctionOrCall(value)
	return parameterTypeIs(value, typeModule.isFunctionOrCall)
end

function assertModule.parameterTypeIsTableOrUserdata(value)
	return parameterTypeIs(value, typeModule.isTableOrUserdata)
end

local function globalTypeIs(isOfType, ...)

	if _G == nil then
		error(essentialGlobalMissingErrorMessage('_G'), 3)
	end
	
	-- We do not use ipairs() as we may be checking for its existence!
	local names = {...}
	local index = 1
	local length = #names
	while index <= length do
		local name = names[index]
		assertModule.parameterTypeIsString(name)
		
		local global = _G[name]
		withLevel(global ~= nil, essentialGlobalMissingErrorMessage(name), 4)
		withLevel(isOfType(global), "The global '" .. name .. "'" .. " is not a " .. isOfType.name, 4)
		
		index = index + 1
	end
end

function assertModule.globalTypeIsTable(...)
	return globalTypeIs(typeModule.isTable, ...)
end

function assertModule.globalTypeIsFunction(...)
	return globalTypeIs(typeModule.isFunction, ...)
end

function assertModule.globalTypeIsString(...)
	return globalTypeIs(typeModule.isString, ...)
end

local function globalTableHasChieldFieldOfType(isOfType, name, ...)
	assertModule.globalTypeIsTable(name)
	
	local package = _G[name]
	
	local childFieldNames = {...}
	for _, childFieldName in ipairs(childFieldNames) do
		assertModule.parameterTypeIsString(childFieldName)
		
		local childField = package[childFieldName]
		local qualifiedChildFieldName = "The global '" .. name .. '.' .. childFieldName .. "'"
		withLevel(childField ~= nil, essentialGlobalMissingErrorMessage(name .. '.' .. childFieldName), 4)
		withLevel(isOfType(childField), qualifiedChildFieldName .. " is not a " .. isOfType.name, 4)
	end
end

function assertModule.globalTableHasChieldFieldOfTypeTable(name, ...)
	return globalTableHasChieldFieldOfType(typeModule.isTable, name, ...)
end

function assertModule.globalTableHasChieldFieldOfTypeFunction(name, ...)
	return globalTableHasChieldFieldOfType(typeModule.isFunction, name, ...)
end

function assertModule.globalTableHasChieldFieldOfTypeString(name, ...)
	return globalTableHasChieldFieldOfType(typeModule.isString, name, ...)
end

assertModule.globalTypeIsFunction(
	'assert',
	'error',
	'ipairs',
	'pairs',
	'pcall',
	'select',
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



assert.globalTableHasChieldFieldOfTypeFunction('table', 'insert')
assert.globalTableHasChieldFieldOfTypeFunction('string', 'find', 'sub')
function string.split(value, separator)
	assert.parameterTypeIsString(value)
	assert.parameterTypeIsString(separator)
	
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
		return '.'
	end
end
local dirname = ourModule.dirname

assert.globalTableHasChieldFieldOfTypeFunction('string', 'sub')
function ourModule.findArg0()
	if typeModule.isTable(arg) and typeModule.isString(arg[0]) then
		return arg[0]
	else
		if typeModule.hasPackageChildFieldOfTypeFunctionOrCall('debug', 'getinfo') then
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
	if type.hasPackageChildFieldOfTypeString('jit', 'os') then
		
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
		if typeModule.isFunction(moduleLoaderOrFailedToFindExplanationString) then
			local result = moduleLoaderOrFailedToFindExplanationString()
		
			local ourResult
			if result == nil then
				ourResult = module
			else
				if typeModule.isTable(result) then
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
