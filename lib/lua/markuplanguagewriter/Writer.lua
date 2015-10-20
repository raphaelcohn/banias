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

function module.new(_constructAttribute)
	assert.parameterTypeIsFunction(_constructAttribute)
	
	-- Could use a closure, but that prevents access to a parent's _constructAttribute
	local functions = {
		_constructAttribute = _constructAttribute
	}
	
	function functions.writeText(rawText)
		assert.parameterTypeIsString(rawText)
	
		return rawText:gsub('[<>&]', function(matchedCharacter)
			return alwaysEscapedCharacters[matchedCharacter]
		end)
	end

	function functions._writeAttributes(attributesTable)
		local attributesArray = tabelize()

		for attributeName, attributeValue in pairs(attributesTable) do
			assert.parameterTypeIsString(attributeName)
			assert.parameterTypeIsString(attributeValue)
	
			functions._constructAttribute(alwaysEscapedCharacters, attributesArray, attributeName, attributeValue)
		end

		-- Sorted to ensure stable, diff-able output
		attributesArray:sort()
		return attributesArray:concat()
	end

	function functions.writeElementNameWithAttributes(elementName, attributesTable)
		assert.parameterTypeIsString(elementName)
		assert.parameterTypeIsTable(attributesTable)
	
		return elementName .. functions._writeAttributes(attributesTable)
	end

	function functions.writeElementOpenTag(elementNameOrElementNameWithAttributes)
		assert.parameterTypeIsString(elementNameOrElementNameWithAttributes)
	
		return '<' .. elementNameOrElementNameWithAttributes .. '>'
	end

	function functions.writeElementEmptyTag(elementNameOrElementNameWithAttributes)
		assert.parameterTypeIsString(elementNameOrElementNameWithAttributes)
	
		return '<' .. elementNameOrElementNameWithAttributes .. '/>'
	end

	function functions.writeElementCloseTag(elementName)
		assert.parameterTypeIsString(elementName)
	
		return '</' .. elementName .. '>'
	end

	function functions.writeElement(elementName, phrasingContent, optionalAttributesTable)
		assert.parameterTypeIsString(elementName)
		assert.parameterTypeIsString(phrasingContent)
	
		local attributesTable
		if optionalAttributesTable == nil then
			attributesTable = {}
		else
			attributesTable = optionalAttributesTable
		end
	
		element = functions.writeElementNameWithAttributes(elementName, attributesTable)
		if phrasingContent == '' then
			return functions.writeElementEmptyTag(element)
		end
		return functions.writeElementOpenTag(element) .. phrasingContent .. functions.writeElementCloseTag(elementName)
	end
	
	return functions
end
