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

local Writer = {}

assert.globalTypeIsFunction('setmetatable')
function Writer:new(state)
	local newObject
	if state == nil then
		newObject = {}
	else
		assert.parameterTypeIsTable(state)
		newObject = state
	end
	
	-- self will be 'Writer'
	setmetatable(newObject, self)
	self.__index = self
	return newObject
end

function Writer:writeText(rawText)
	assert.parameterTypeIsString(rawText)
	
	return rawText:gsub('[<>&]', function(matchedCharacter)
		return alwaysEscapedCharacters[matchedCharacter]
	end)
end

function Writer:_constructAttribute(attributesArray, attributeName, attributeValue)
	error("Abstract method")
end

function Writer:_writeAttributes(attributesTable)
		local attributesArray = tabelize()

		for attributeName, attributeValue in pairs(attributesTable) do
			assert.parameterTypeIsString(attributeName)
			assert.parameterTypeIsString(attributeValue)
		
			self._constructAttribute(attributesArray, attributeName, attributeValue)
		end
	
		-- Sorted to ensure stable, diff-able output
		attributesArray:sort()
		return attributesArray:concat()
	end
	
	constructAttribute = function(attributesArray, attributeName, attributeValue)
		error('Abstract method')
	end
}

function Writer:writeElementNameWithAttributes(elementName, attributesTable)
	assert.parameterTypeIsString(elementName)
	assert.parameterTypeIsTable(attributesTable)
	
	return elementName .. self._writeAttributes(attributesTable)
end

function Writer:writeElementOpenTag(elementNameOrElementNameWithAttributes)
	assert.parameterTypeIsString(elementNameOrElementNameWithAttributes)
	
	return '<' .. elementNameOrElementNameWithAttributes .. '>'
end

function Writer:writeElementEmptyTag(elementNameOrElementNameWithAttributes)
	assert.parameterTypeIsString(elementNameOrElementNameWithAttributes)
	
	return '<' .. elementNameOrElementNameWithAttributes .. '/>'
end

function Writer:writeElementCloseTag(elementName)
	assert.parameterTypeIsString(elementName)
	
	return '</' .. elementName .. '>'
end

function Writer:writeElement(elementName, phrasingContent, optionalAttributesTable)
	assert.parameterTypeIsString(elementName)
	assert.parameterTypeIsString(phrasingContent)
	
	local attributesTable
	if optionalAttributesTable == nil then
		attributesTable = {}
	else
		attributesTable = optionalAttributesTable
	end
	
	element = self.writeElementNameWithAttributes(elementName, attributesTable)
	if phrasingContent == '' then
		return self.writeElementEmptyTag(element)
	end
	return self.writeElementOpenTag(element) .. phrasingContent .. self.writeElementCloseTag(elementName)
end
