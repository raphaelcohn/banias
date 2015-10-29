--[[
This file is part of banias. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT. No part of banias, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of banias. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT.
]]--


local Html5Writer = require('markuplanguagewriter.Html5Writer')
local writeText = Html5Writer.writeText
local writeElementNameWithAttributes = Html5Writer.writeElementNameWithAttributes
local writeElementOpenTag = Html5Writer.writeElementOpenTag
local writeElementEmptyTag = Html5Writer.writeElementEmptyTag
local writeElementCloseTag = Html5Writer.writeElementCloseTag
local writeElement = Html5Writer.writeElement

local assert = require('halimede.assert')

local tabelize = require('halimede.table.tabelize').tabelize

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
	assert.parameterTypeIsString(caption)
	assert.parameterTypeIsTable(pandocAlignments)
	assert.parameterTypeIsTable(widths)
	assert.parameterTypeIsTable(headers)
	assert.parameterTypeIsTable(rows)
	
	local buffer = tabelize()
	
	local function add(content)
		buffer:insert(content)
	end
	
	add(writeElementOpenTag('table'))
  
	if caption ~= '' then
		add(writeElement('caption', caption))
	end
	
	if widths and widths[1] ~= 0 then
    	for _, width in pairs(widths) do
			assert.parameterTypeIsNumber(width)
			local percentageWidth = string.format('%d%%', width * 100)
			add(writeElement('col', '', {width = percentageWidth}))
		end
	end
	
	local headerRow = tabelize()
	local isHeaderEmpty = true
	for columnIndex, headerCellPhrasedContent in pairs(headers) do
		assert.parameterTypeIsString(headerCellPhrasedContent)
		local align = pandocToHtmlAlignmentLookUp[pandocAlignments[columnIndex]]
		headerRow:insert(writeElement('th', headerCellPhrasedContent, {class = 'align ' .. align}))
		isHeaderEmpty = isHeaderEmpty and headerCellPhrasedContent == ''
	end
	if not isHeaderEmpty then
		add(writeElementOpenTag(writeElementNameWithAttributes('tr', {class = 'header'})))
		for _, thCell in pairs(headerRow) do
			add(thCell)
		end
		add(writeElementCloseTag('tr'))
	end
	
	local class = 'even'
	for _, row in pairs(rows) do
		assert.parameterTypeIsTable(row)
		class = (class == 'even' and 'odd') or 'even'
		add(writeElementOpenTag(writeElementNameWithAttributes('tr', {class = class})))
		for columnIndex, rowCellPhrasedContent in pairs(row) do
			assert.parameterTypeIsString(rowCellPhrasedContent)
			local align = pandocToHtmlAlignmentLookUp[pandocAlignments[columnIndex]]
			add(writeElement('td', rowCellPhrasedContent, {class = 'align ' .. align}))
		end
		add(writeElementCloseTag('tr'))
	end
	
	add(writeElementCloseTag('table'))
	
	return buffer:concat()
end
