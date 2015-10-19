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

-- Or use style="text-align:VALUE;" Or use class="align-VALUE"
local defaultHtmlAlignment = 'left'
local pandocToHtmlAlignmentLookUp = setmetatable({
		AlignLeft = 'left',
		AlignRight = 'right',
		AlignCenter = 'center',
		AlignDefault = defaultHtmlAlignment
	}, {
		__index = function(tableLookedUp, missingKey)
			return defaultHtmlAlignment
		end
	}
)

function Table(caption, pandocAlignments, widths, headers, rows)

	assert.parameterIsString(caption)
	assert.parameterIsTable(pandocAlignments)
	assert.parameterIsTable(widths)
	assert.parameterIsTable(headers)
	assert.parameterIsTable(rows)
	
	local buffer = tabelize()
	
	local function add(content)
		buffer:insert(content)
	end
	
	add(writeXmlElementOpenTag('table'))
  
	if caption ~= '' then
		add(writeXmlElement('caption', caption))
	end
	
	if widths and widths[1] ~= 0 then
    	for _, width in pairs(widths) do
			assert.parameterIsNumber(width)
			local percentageWidth = string.format('%d%%', width * 100)
			add(writeXmlElement('col', '', {width = percentageWidth}))
		end
	end
	
	local headerRow = tabelize()
	local isHeaderEmpty = true
	for columnIndex, headerCellPhrasedContent in pairs(headers) do
		assert.parameterIsString(headerCellPhrasedContent)
		local align = pandocToHtmlAlignmentLookUp[pandocAlignments[columnIndex]]
		headerRow:insert(writeXmlElement('th', headerCellPhrasedContent, {class = 'align ' .. align}))
		isHeaderEmpty = isHeaderEmpty and headerCellPhrasedContent == ''
	end
	if not isHeaderEmpty then
		add(writeXmlElementOpenTag(writeXmlElementNameWithAttributes('tr', {class = 'header'})))
		for _, thCell in pairs(headerRow) do
			add(thCell)
		end
		add(writeXmlElementCloseTag('tr'))
	end
	
	local class = 'even'
	for _, row in pairs(rows) do
		assert.parameterIsTable(row)
		class = (class == 'even' and 'odd') or 'even'
		add(writeXmlElementOpenTag(writeXmlElementNameWithAttributes('tr', {class = class})))
		for columnIndex, rowCellPhrasedContent in pairs(row) do
			assert.parameterIsString(rowCellPhrasedContent)
			local align = pandocToHtmlAlignmentLookUp[pandocAlignments[columnIndex]]
			add(writeXmlElement('td', rowCellPhrasedContent, {class = 'align ' .. align}))
		end
		add(writeXmlElementCloseTag('tr'))
	end
	
	add(writeXmlElementCloseTag('table'))
	
	return buffer:concat()
end
