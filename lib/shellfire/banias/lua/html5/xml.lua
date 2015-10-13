--[[
This file is part of banias. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT. No part of banias, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of banias. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT.
]]--


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

function escapeRawText(rawText)
	return rawText:gsub('[<>&]', function(matchedCharacter)
		return alwaysEscapedCharacters[matchedCharacter]
	end)
end

function attributes(attributesTable)
	
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

function xmlElementNameWithAttributes(elementName, attributesTable)
	return elementName .. attributes(attributesTable)
end

function xmlElementOpenTag(elementNameOrElementNameWithAttributes)
	return '<' .. elementNameOrElementNameWithAttributes .. '>'
end

function xmlElementCloseTag(elementNameOrElementNameWithAttributes)
	return '</' .. elementNameOrElementNameWithAttributes .. '>'
end

function xmlElementEmptyTag(elementNameOrElementNameWithAttributes)
	return '<' .. elementNameOrElementNameWithAttributes .. '/>'
end

function potentiallyEmptyXml(elementName, phrasingContent)
	if phrasingContent == '' then
		return xmlElementEmptyTag(elementName)
	end
	return xmlElementOpenTag(elementName) .. phrasingContent .. xmlElementCloseTag(elementName)
end

function potentiallyEmptyXmlWithAttributes(elementName, phrasingContent, attributesTable)
	element = xmlElementNameWithAttributes(elementName, attributesTable)
	if phrasingContent == '' then
		return xmlElementEmptyTag(element)
	end
	return xmlElementOpenTag(element) .. phrasingContent .. xmlElementCloseTag(elementName)
end

function htmlSimpleList(elementName, items)
	local buffer = tabelize({})
	for _, phrasingContent in pairs(items) do
		buffer:insert(potentiallyEmptyXml('li', phrasingContent))
	end
	return potentiallyEmptyXml(elementName, buffer:concat())
end
