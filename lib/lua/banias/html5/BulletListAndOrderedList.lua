--[[
This file is part of banias. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT. No part of banias, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of banias. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT.
]]--


local xml = require('xml')
local escapeRawText = xml.escapeRawText
local attributes = xml.attributes
local xmlElementNameWithAttributes = xml.xmlElementNameWithAttributes
local xmlElementOpenTag = xml.xmlElementOpenTag
local xmlElementCloseTag = xml.xmlElementCloseTag
local xmlElementEmptyTag = xml.xmlElementEmptyTag
local potentiallyEmptyXml = xml.potentiallyEmptyXml
local potentiallyEmptyXmlWithAttributes = xml.potentiallyEmptyXmlWithAttributes

local tabelize = require('halimede.tabelize').tabelize

local function htmlSimpleList(elementName, items)
	local buffer = tabelize()
	for _, phrasingContent in pairs(items) do
		buffer:insert(potentiallyEmptyXml('li', phrasingContent))
	end
	return potentiallyEmptyXml(elementName, buffer:concat())
end
local htmlSimpleList = module.htmlSimpleList

function BulletList(items)
	return htmlSimpleList('ul', items)
end

-- TODO: Use numer, style and delimiter
function OrderedList(items, number, style, delimiter)
	return htmlSimpleList('ol', items)
end
