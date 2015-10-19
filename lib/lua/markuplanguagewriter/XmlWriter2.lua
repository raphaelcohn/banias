--[[
This file is part of banias. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT. No part of banias, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of banias. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT.
]]--


local tabelize = require('halimede.tabelize').tabelize
local assert = require('halimede.assert')
local AbstractWriter = requireSibling('AbstractWriter')

module = AbstractWriter:new()
function module:constructAttribute(attributesArray, attributeName, attributeValue)
	
	local quotationMark = '"'
	local doubleQuotesPresent = false
	local singleQuotePresent = false
	
	local escapedAttributeValue = attributeValue:gsub('[<>&"\']', function(matchedCharacter)
		local result = alwaysEscapedCharacters[matchedCharacter]
		if result ~= matchedCharacter then
			return result
		end
		
		if matchedCharacter == '"' then
			quotationMark = "'"
			doubleQuotesPresent = true
		elseif matchedCharacter == '\'' then
			singleQuotePresent = true
		end
		
		return matchedCharacter
	end)

	local reEscapeBecauseBothDoubleAndSingleQuotesArePresent = doubleQuotesPresent and singleQuotePresent
	if reEscapeBecauseBothDoubleAndSingleQuotesArePresent then
		quotationMark = '"'
		
		escapedAttributeValue = attributeValue:gsub('[<>&"]', function(matchedCharacter)
			local result = alwaysEscapedCharacters[matchedCharacter]
			if result ~= matchedCharacter then
				return result
			end
			
			if matchedCharacter == '"' then
				-- We do not return '&quot;' as it is more verbose; we save a byte
				return '&#38;'
			else
				return matchedCharacter
			end
		end)
	
	end
	
	attributesArray:insert(' ' .. attributeName .. '=' .. quotationMark .. escapedAttributeValue .. quotationMark)
end
