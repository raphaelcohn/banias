--[[
This file is part of banias. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT. No part of banias, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of banias. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert

local function traceIfRequired()
	
	local environmentVariable = 'LUA_HALIMEDE_TRACE'
	
	-- Check for functions in the global namespace that we rely on that might have been removed in a sandbox; don't enable tracing if they're not present.
	if not halimede.hasPackageChildFieldOfTypeString('os', 'getenv') then
		return
	end
	
	if not halimede.hasPackageChildFieldOfTypeString('debug', 'sethook', 'getinfo') then
		return
	end
	
	if not halimede.hasPackageChildFieldOfTypeString('string', 'format') then
		return
	end
	
	if not halimede.hasPackageChildFieldOfTypeString('io', 'stderr') then
		return
	end
	
	local write = io.stderr.write
	if write == nil then
		return
	end
	if type(write) ~= 'function' then
		return
	end
	
	local enableTracing = os.getenv(environmentVariable)
	
	if enableTracing == nil then
		return
	end
	
	if enableTracing ~= 'true' then
		return
	end
	
	local stderr = io.stderr
	local getinfo = debug.getinfo
	local format = string.format
	
	debug.sethook(function(event)
		
		assert.parameterIsString(event)
		
		local nameInfo = getinfo(2, 'n')
	
		local nameWhat = nameInfo.namewhat
		if nameWhat == '' then
			nameWhat = 'unknown'
		end
	
		local functionName = nameInfo.name
		if functionName == nil then
			functionName = '?'
		end
	
		local sourceInfo = getinfo(2, 'S')
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
			local currentLineNumber = getinfo(2, 'l').currentline
			local currentLine
			if currentLineNumber == -1 then
				currentLine = ''
			else
				currentLine = format(' at line %d', currentLineNumber)
			end
			sourceText = format(' in %s%s', source, currentLine)
		end
		
		local messageTemplate = "%s %s %s%s '%s'%s\n"
		stderr:write(messageTemplate:format(event, language, nameWhat, functionKeyword, functionName, sourceText))
	end, 'cr')
end

traceIfRequired()
