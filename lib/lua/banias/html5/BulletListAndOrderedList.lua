--[[
This file is part of banias. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT. No part of banias, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of banias. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT.
]]--


local xmlwriter = require('xmlwriter')
local writeText = xmlwriter.writeText
local writeXmlElementNameWithAttributes = xmlwriter.writeXmlElementNameWithAttributes
local writeXmlElementOpenTag = xmlwriter.writeXmlElementOpenTag
local writeXmlElementCloseTag = xmlwriter.writeXmlElementCloseTag
local writeXmlElementEmptyTag = xmlwriter.writeXmlElementEmptyTag
local writeXmlElement = xmlwriter.writeXmlElement

local assert = require('halimede.assert')

local tabelize = require('halimede.tabelize').tabelize

local function htmlSimpleList(elementName, items)
	
	local buffer = tabelize()
	for _, phrasingContent in pairs(items) do
		assert.parameterTypeIsString(phrasingContent)
		buffer:insert(writeXmlElement('li', phrasingContent))
	end
	return writeXmlElement(elementName, buffer:concat())
end

function BulletList(items)
	assert.parameterTypeIsTable(items)
	
	return htmlSimpleList('ul', items)
end

-- TODO: Use number, style and delimiter
function OrderedList(items, number, style, delimiter)
	assert.parameterTypeIsTable(items)
	
	return htmlSimpleList('ol', items)
end
