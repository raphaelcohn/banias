--[[
This file is part of banias. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT. No part of banias, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of banias. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT.
]]--


local banias = require('banias')
local tabelize = banias.tabelize

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

function module.escapeRawText(rawText)
	return rawText:gsub('[<>&]', function(matchedCharacter)
		return alwaysEscapedCharacters[matchedCharacter]
	end)
end
local escapeRawText = module.escapeRawText

function module.attributes(attributesTable)
	
	local attributesArray = tabelize({})

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
local attributes = module.attributes

function module.xmlElementNameWithAttributes(elementName, attributesTable)
	return elementName .. attributes(attributesTable)
end
local xmlElementNameWithAttributes = module.xmlElementNameWithAttributes

function module.xmlElementOpenTag(elementNameOrElementNameWithAttributes)
	return '<' .. elementNameOrElementNameWithAttributes .. '>'
end
local xmlElementOpenTag = module.xmlElementOpenTag

function module.xmlElementCloseTag(elementNameOrElementNameWithAttributes)
	return '</' .. elementNameOrElementNameWithAttributes .. '>'
end
local xmlElementCloseTag = module.xmlElementCloseTag

function module.xmlElementEmptyTag(elementNameOrElementNameWithAttributes)
	return '<' .. elementNameOrElementNameWithAttributes .. '/>'
end
local xmlElementEmptyTag = module.xmlElementEmptyTag

function module.potentiallyEmptyXml(elementName, phrasingContent)
	if phrasingContent == '' then
		return module.xmlElementEmptyTag(elementName)
	end
	return module.xmlElementOpenTag(elementName) .. phrasingContent .. xmlElementCloseTag(elementName)
end
local potentiallyEmptyXml = module.potentiallyEmptyXml

function module.potentiallyEmptyXmlWithAttributes(elementName, phrasingContent, attributesTable)
	element = xmlElementNameWithAttributes(elementName, attributesTable)
	if phrasingContent == '' then
		return xmlElementEmptyTag(element)
	end
	return xmlElementOpenTag(element) .. phrasingContent .. xmlElementCloseTag(elementName)
end
local potentiallyEmptyXmlWithAttributes = module.potentiallyEmptyXmlWithAttributes

function module.htmlSimpleList(elementName, items)
	local buffer = tabelize({})
	for _, phrasingContent in pairs(items) do
		buffer:insert(potentiallyEmptyXml('li', phrasingContent))
	end
	return potentiallyEmptyXml(elementName, buffer:concat())
end
local htmlSimpleList = module.htmlSimpleList
