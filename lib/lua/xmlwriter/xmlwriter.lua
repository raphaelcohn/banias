--[[
This file is part of banias. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT. No part of banias, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of banias. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT.
]]--


local tabelize = require('halimede.tabelize').tabelize
local assert = require('halimede.assert')

local alwaysEscapedCharacters = {}
alwaysEscapedCharacters['<'] = '&lt;'
alwaysEscapedCharacters['>'] = '&gt;'
alwaysEscapedCharacters['&'] = '&amp;'
alwaysEscapedCharacters = setmetatable(alwaysEscapedCharacters, {
		__index = function(_, matchedCharacter)
			return matchedCharacter
		end
	}
)

function module.writeText(rawText)
	assert.parameterIsString(rawText)
	
	return rawText:gsub('[<>&]', function(matchedCharacter)
		return alwaysEscapedCharacters[matchedCharacter]
	end)
end
local writeText = module.writeText

local function writeAttributes(attributesTable)
	assert.parameterIsTable(attributesTable)
	
	local attributesArray = tabelize()

	for attributeName, attributeValue in pairs(attributesTable) do
		
		-- There is no continue in Lua, a serious omission that makes fail-fast harder than it needs to be: https://stackoverflow.com/questions/3524970/why-does-lua-have-no-continue-statement
		-- Hence the double-negation test here, which I despise
		if attributeValue ~= nil and attributeValue ~= '' then
			
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
	end
	
	return attributesArray:concat()
end

function module.writeXmlElementNameWithAttributes(elementName, attributesTable)
	assert.parameterIsString(elementName)
	assert.parameterIsTable(attributesTable)
	
	return elementName .. writeAttributes(attributesTable)
end
local writeXmlElementNameWithAttributes = module.writeXmlElementNameWithAttributes

function module.writeXmlElementOpenTag(elementNameOrElementNameWithAttributes)
	assert.parameterIsString(elementNameOrElementNameWithAttributes)
	
	return '<' .. elementNameOrElementNameWithAttributes .. '>'
end
local writeXmlElementOpenTag = module.writeXmlElementOpenTag

function module.writeXmlElementCloseTag(elementNameOrElementNameWithAttributes)
	assert.parameterIsString(elementNameOrElementNameWithAttributes)
	
	return '</' .. elementNameOrElementNameWithAttributes .. '>'
end
local writeXmlElementCloseTag = module.writeXmlElementCloseTag

function module.writeXmlElementEmptyTag(elementNameOrElementNameWithAttributes)
	assert.parameterIsString(elementNameOrElementNameWithAttributes)
	
	return '<' .. elementNameOrElementNameWithAttributes .. '/>'
end
local writeXmlElementEmptyTag = module.writeXmlElementEmptyTag

function module.writeXmlElement(elementName, phrasingContent, optionalAttributesTable)
	assert.parameterIsString(elementName)
	assert.parameterIsString(phrasingContent)
	assert.parameterIsTable(attributesTable)
	
	local attributesTable
	if optionalAttributesTable == nil then
		attributesTable = {}
	else
		attributesTable = optionalAttributesTable
	end
	
	element = writeXmlElementNameWithAttributes(elementName, attributesTable)
	if phrasingContent == '' then
		return writeXmlElementEmptyTag(element)
	end
	return writeXmlElementOpenTag(element) .. phrasingContent .. writeXmlElementCloseTag(elementName)
end
local writeXmlElement = module.writeXmlElement