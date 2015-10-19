--[[
This file is part of banias. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT. No part of banias, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of banias. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT.
]]--


local xmlwriter = require('xmlwriter')
local escapeRawText = xmlwriter.escapeRawText
local attributes = xmlwriter.attributes
local xmlElementNameWithAttributes = xmlwriter.xmlElementNameWithAttributes
local xmlElementOpenTag = xmlwriter.xmlElementOpenTag
local xmlElementCloseTag = xmlwriter.xmlElementCloseTag
local xmlElementEmptyTag = xmlwriter.xmlElementEmptyTag
local potentiallyEmptyXml = xmlwriter.potentiallyEmptyXml
local potentiallyEmptyXmlWithAttributes = xmlwriter.potentiallyEmptyXmlWithAttributes

local assert = require('halimede.assert')

local tabelize = require('halimede.tabelize').tabelize

local function htmlSimpleList(elementName, items)
	
	local buffer = tabelize()
	for _, phrasingContent in pairs(items) do
		assert.parameterIsString(phrasingContent)
		buffer:insert(potentiallyEmptyXml('li', phrasingContent))
	end
	return potentiallyEmptyXml(elementName, buffer:concat())
end
local htmlSimpleList = module.htmlSimpleList

function BulletList(items)
	
	assert.parameterIsTable(items)
	
	return htmlSimpleList('ul', items)
end

-- TODO: Use number, style and delimiter
function OrderedList(items, number, style, delimiter)
	
	assert.parameterIsTable(items)
	
	return htmlSimpleList('ol', items)
end
