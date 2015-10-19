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
	assert.parameterTypeIsString(rawText)
	
	return rawText:gsub('[<>&]', function(matchedCharacter)
		return alwaysEscapedCharacters[matchedCharacter]
	end)
end
local writeText = module.writeText

local function constructAttribute(attributesArray, attributeName, attributeValue)
	if attributeValue == '' then
		--io.stderr:write('Empty attribute ' .. attributeName .. '\n')
	end
	
	-- TODO: Clean up empty attributes, default attributes, etc
	if attributeValue == '' then
		return
	end
	
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

io.stderr:write('Optimise away empty global attributes like title, class and id; others check for boolean variants\n')
local function writeAttributes(attributesTable)
	
	local attributesArray = tabelize()

	for attributeName, attributeValue in pairs(attributesTable) do
		assert.parameterTypeIsString(attributeName)
		assert.parameterTypeIsString(attributeValue)
		
		constructAttribute(attributesArray, attributeName, attributeValue)
	end
	
	-- Sorted to ensure stable, diff-able XML output
	attributesArray:sort()
	return attributesArray:concat()
end

function module.writeXmlElementNameWithAttributes(elementName, attributesTable)
	assert.parameterTypeIsString(elementName)
	assert.parameterTypeIsTable(attributesTable)
	
	return elementName .. writeAttributes(attributesTable)
end
local writeXmlElementNameWithAttributes = module.writeXmlElementNameWithAttributes

function module.writeXmlElementOpenTag(elementNameOrElementNameWithAttributes)
	assert.parameterTypeIsString(elementNameOrElementNameWithAttributes)
	
	return '<' .. elementNameOrElementNameWithAttributes .. '>'
end
local writeXmlElementOpenTag = module.writeXmlElementOpenTag

function module.writeXmlElementCloseTag(elementNameOrElementNameWithAttributes)
	assert.parameterTypeIsString(elementNameOrElementNameWithAttributes)
	
	return '</' .. elementNameOrElementNameWithAttributes .. '>'
end
local writeXmlElementCloseTag = module.writeXmlElementCloseTag

function module.writeXmlElementEmptyTag(elementNameOrElementNameWithAttributes)
	assert.parameterTypeIsString(elementNameOrElementNameWithAttributes)
	
	return '<' .. elementNameOrElementNameWithAttributes .. '/>'
end
local writeXmlElementEmptyTag = module.writeXmlElementEmptyTag

function module.writeXmlElement(elementName, phrasingContent, optionalAttributesTable)
	assert.parameterTypeIsString(elementName)
	assert.parameterTypeIsString(phrasingContent)
	
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
