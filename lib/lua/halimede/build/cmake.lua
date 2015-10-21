--[[
This file is part of banias. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT. No part of banias, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of banias. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT.
]]--


--- Hmmm, how about we go for luadist.org? Seems to be designed to include third-party dependencies

local halimede = require('halimede')
local assert = require('halimede.assert')
local type = require('halimede').type
local tabelize = require('halimede').tabelize
local exception = require('halimede.exception')
local writeToFileAllContentsInTextMode = require('halimede.io.write').writeToFileAllContentsInTextMode

local cmakeEnvironmentVariables = {
	'CMAKE_MODULE_PATH',
	'CMAKE_LIBRARY_PATH',
	'CMAKE_INCLUDE_PATH'
}

local function assertTableOrEmpty(value)
	if value == nil then
		return {}
	end
	assert.parameterTypeIsTable(value)
	return value
end

assert.globalTableHasChieldFieldOfTypeFunction('os', 'getenv')
assert.globalTypeIsFunction('tostring')
function module.cmakebuild(rockspec, rockspecFilePath)
	assert.parameterTypeIsTable(rockspec)
	assert.parameterTypeIsString(rockspecFilePath)
	
	local build = assertTableOrEmpty(rockspec.build)
	
	local buildVariables = assertTableOrEmpty(build.variables)
	
	for _, environmentVariable in ipairs(cmakeEnvironmentVariables) do
		buildVariables[environmentVariable] = os.getenv(environmentVariable)
	end
	
	local rockspecVariables = assertTableOrEmpty(rockspec.variables)
	makeStyleVariableSubstitutions(buildVariables, assertTableOrEmpty(rockspecVariables))
	
	local function createCMakeListsIfRequired()
		local cmakeListsContent = build.cmake
		if type.isString(cmakeListsContent) then
			-- Ought to be $(pwd)/; not necessarily path to rockspec...
			local cmakeListsFilePath = halimede.concatenateToPath(halimede.dirname(rockspecFilePath), 'CMakeLists.txt')
			writeToFileAllContentsInTextMode(cmakeListsFilePath, 'CMakeLists file', cmakeListsContent)
		end
	end
	createCMakeListsIfRequired()
	
	local function guardCmakeBinaryExists()
		local cmakeBinaryName = rockspecVariables.CMAKE
		programExists(cmakeBinaryName, '--version')
		return cmakeBinaryName
	end
	local cmakeBinaryName = guardCmakeBinaryExists()
	
	local function executeCmake()
		local cmakeArguments = tabelize()
	
		cmakeArguments:insert(cmakeBinaryName)
	
		cmakeArguments:insert('-H.')
		cmakeArguments:insert('-Bbuild.luarocks')
		-- seems to get this from cfg, with a weird windows hack
		local cmakeGenerator = ?
		cmakeArguments:insert('-G' .. cmakeGenerator)
		for key, value in buildVariables do
			cmakeArguments:insert('-D' .. key .. '=' .. tostring(value))
		end
		
		executeAndDisplayOutputOnFailure(cmakeArguments)
	end
	
	local function buildCmake()
		executeAndDisplayOutputOnFailure(cmakeBinaryName, '--build', 'build.luarocks', '--config', 'Release')
	end
	buildCmake()
	
	local function installCmake()
		executeAndDisplayOutputOnFailure(cmakeBinaryName, '--build', 'build.luarocks', '--config', 'Release', '--target', 'install')
	end
	installCmake()
	
end

function module.commandbuild(rockspec, rockspecFilePath)
	assert.parameterTypeIsTable(rockspec)
	assert.parameterTypeIsString(rockspecFilePath)
	
	local build = assertTableOrEmpty(rockspec.build)
	
end



-- "$(XYZ)" will have this substring replaced by vars["XYZ"]
local makeVariableFormatPattern = '%$%((%a[%a%d_]+)%)'
assert.globalTableHasChieldFieldOfTypeFunction('string', 'gsub')
function module.makeStyleVariableSubstitutions(makeReplacementsIntoHereWith, variables)
	assert.parameterTypeIsTable(makeReplacementsIntoHereWith)
	assert.parameterTypeIsTable(variables)
   
    local updated = {}
    for key, value in pairs(makeReplacementsIntoHereWith) do
		if type.isString(value) then
			local line = value:gsub(makeVariableFormatPattern, variables)
			throwExceptionIfThereAreFailingMatches(line)
			updated[key] = line
		end
	end
	for key, value in pairs(updated) do
		makeReplacementsIntoHereWith[key] = value
	end
end

assert.globalTableHasChieldFieldOfTypeFunction('string', 'match', 'gmatch')
local function throwExceptionIfThereAreFailingMatches(line)
	local hasFailingMatches = false
	local failingMatches = tabelize()
	for unmatchedMakeVariable in line:gmatch(makeVariableFormatPattern) do
		failingMatches:insert(unmatchedMakeVariable)
	end
	
	local numberOfFailingMatches = #failingMatches
	if numberOfFailingMatches ~= 0 then
		local plural
		if numberOfFailingMatches == 1 then
			plural = 'es'
		else
			plural = ''
		end
		exception.throw("There are %s failing match%s: '%s'", numberOfFailingMatches, plural, failingMatches:concat(", "))
	end
end

-- Need to execute quietly...
-- 1>/dev/null 2>/dev/null   or   2> NUL 1> NUL (windows)
-- Also prefix   'type NUL && ' on Windows...
-- See also http://lua-users.org/lists/lua-l/2013-11/msg00367.html
-- call os.execute() and check return code
local function programExists(....)
	error("Implement me!")
end

-- Write to a temporary file or two
local function executeAndDisplayOutputOnFailure(....)
	error("Implement me!")
end
