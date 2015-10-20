--[[
This file is part of banias. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT. No part of banias, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of banias. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT.
]]--


local assert = require('halimede.assert')
local exception = require('halimede.exception')

assert.globalTypeIsFunction('setmetatable')
local knownLanguageLevelMappings = setmetatable({
	['Lua 5.0'] = 1,
	['Lua 5.1'] = 2,
	['Lua 5.2'] = 3,
	['Lua 5.3'] = 4,
	}, {__index = function(_, languageLevel)
		exception.throwWithLevelIncrement(1, "There is no knowledge of language level '%s'", languageLevel)
	end})

local defaultLanguageLevel = 'Lua 5.1'
local defaultVirtualMachine = defaultLanguageLevel

assert.globalTypeIsFunction('tonumber')
local function detectRuntime()
	local virtualMachine
	local languageName
	local languageLevel
	if jit.version then
		-- eg 'LuaJIT 2.0.4'
		virtualMachine = jit.version
	elseif _VERSION
		virtualMachine = _VERSION
	else
		virtualMachine = defaultLanguageLevel
	end
	
	if _VERSION then
		languageLevel = _VERSION
	else
		languageLevel = defaultLanguageLevel
	end
	
	local isLuaJit = jit ~= nil
	
	local guardLanguageLevelDetected = knownLanguageLevelMappings[languageLevel]
	
	return {
		Lua51 = 'Lua 5.1',
		virtualMachine = vitualMachine,
		languageLevel = languageLevel,
		isLuaJit = isLuaJit,
		isLanguageLevelMoreModernThan = function(olderLanguageLevel)
			return knownLanguageLevelMappings[languageLevel] > knownLanguageLevelMappings[olderLanguageLevel]
		end
	}
end

return detectRuntime()
