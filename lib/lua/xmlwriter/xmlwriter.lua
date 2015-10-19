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

local function constructXmlAttribute(attributesArray, attributeName, attributeValue)
	
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

local function constructHtml5Attribute(attributesArray, attributeName, attributeValue)
	if attributeValue == '' then
		return
	end
	
	-- Omit quotemarks if value is 'safe'
	if attributeValue:find('[ >="\']') == nil then
		attributesArray:insert(' ' .. attributeName .. '=' ..attributeValue)
		return
	end
	
	return constructXmlAttribute(attributesArray, attributeName, attributeValue)
end

io.stderr:write('Optimise away empty global attributes like title, class and id; others check for boolean variants\n')
local function writeAttributes(attributesTable)
	
	local attributesArray = tabelize()

	for attributeName, attributeValue in pairs(attributesTable) do
		assert.parameterTypeIsString(attributeName)
		assert.parameterTypeIsString(attributeValue)
		
		constructHtml5Attribute(attributesArray, attributeName, attributeValue)
	end
	
	-- Sorted to ensure stable, diff-able output
	attributesArray:sort()
	return attributesArray:concat()
end

function module.writeElementNameWithAttributes(elementName, attributesTable)
	assert.parameterTypeIsString(elementName)
	assert.parameterTypeIsTable(attributesTable)
	
	return elementName .. writeAttributes(attributesTable)
end
local writeElementNameWithAttributes = module.writeElementNameWithAttributes

function module.writeElementOpenTag(elementNameOrElementNameWithAttributes)
	assert.parameterTypeIsString(elementNameOrElementNameWithAttributes)
	
	return '<' .. elementNameOrElementNameWithAttributes .. '>'
end
local writeElementOpenTag = module.writeElementOpenTag

function module.writeElementCloseTag(elementNameOrElementNameWithAttributes)
	assert.parameterTypeIsString(elementNameOrElementNameWithAttributes)
	
	return '</' .. elementNameOrElementNameWithAttributes .. '>'
end
local writeElementCloseTag = module.writeElementCloseTag

function module.writeElementEmptyTag(elementNameOrElementNameWithAttributes)
	assert.parameterTypeIsString(elementNameOrElementNameWithAttributes)
	
	return '<' .. elementNameOrElementNameWithAttributes .. '/>'
end
local writeElementEmptyTag = module.writeElementEmptyTag

function module.writeElement(elementName, phrasingContent, optionalAttributesTable)
	assert.parameterTypeIsString(elementName)
	assert.parameterTypeIsString(phrasingContent)
	
	local attributesTable
	if optionalAttributesTable == nil then
		attributesTable = {}
	else
		attributesTable = optionalAttributesTable
	end
	
	element = writeElementNameWithAttributes(elementName, attributesTable)
	if phrasingContent == '' then
		return writeElementEmptyTag(element)
	end
	return writeElementOpenTag(element) .. phrasingContent .. writeElementCloseTag(elementName)
end
local writeElement = module.writeElement
