--[[
This file is part of banias. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT. No part of banias, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of banias. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT.
]]--


local HtmlWriter = require('markuplanguagewriter.HtmlWriter')
local writeText = HtmlWriter.writeText
local writeElementNameWithAttributes = HtmlWriter.writeElementNameWithAttributes
local writeElementOpenTag = HtmlWriter.writeElementOpenTag
local writeElementEmptyTag = HtmlWriter.writeElementEmptyTag
local writeElementCloseTag = HtmlWriter.writeElementCloseTag
local writeElement = HtmlWriter.writeElement

local assert = require('halimede.assert')

local tabelize = require('halimede.tabelize').tabelize

local exception = require('halimede.exception')

local function htmlSimpleList(elementName, items, attributesTable)
	
	local buffer = tabelize()
	for _, phrasingContent in pairs(items) do
		assert.parameterTypeIsString(phrasingContent)
		buffer:insert(writeElement('li', phrasingContent))
	end
	return writeElement(elementName, buffer:concat(), attributesTable)
end

function BulletList(items)
	assert.parameterTypeIsTable(items)
	
	return htmlSimpleList('ul', items, {})
end

local pandocStyleToOlTypeMapping = setmetatable({
	UpperAlpha = 'a',
	LowerAlpha = 'A',
	UpperRoman = 'i',
	LowerRoman = 'I',
	Decimal = '1',
	DefaultStyle = '1',
	Example = '1' -- Not really right
}, {__index = function(_, key)
	exception.throwWithLevelIncrement(1, "Do not recognise Pandoc ordered list style '%s'", key)
end})

-- TODO: Use delimiter DefaultDelim, Period, OneParen, TwoParens
function OrderedList(items, start, style, delimiter)
	assert.parameterTypeIsTable(items)
	
	local attributesTable = {}
	if start ~= nil and start ~= 1 then
		attributesTable.start = '' .. start
	end
	
	if style ~= nil then
		local type = pandocStyleToOlTypeMapping[style]
		if type ~= '1' then
			attributesTable.type = type
		end
	end
	
	return htmlSimpleList('ol', items, attributesTable)
end
