--[[
This file is part of banias. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT. No part of banias, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of banias. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local tabelize = halimede.table.tabelize
local markuplanguagewriter = require('markuplanguagewriter')
local Html5Writer = markuplanguagewriter.Html5Writer
local writer = markuplanguagewriter.Html5Writer.singleton


-- Or use style="text-align:VALUE;" Or use class="align-VALUE"
assert.globalTypeIsFunctionOrCall('setmetatable')
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

assert.globalTypeIsFunctionOrCall('pairs')
function Table(caption, pandocAlignments, widths, headers, rows)
	assert.parameterTypeIsString('caption', caption)
	assert.parameterTypeIsTable('pandocAlignments', pandocAlignments)
	assert.parameterTypeIsTable('widths', widths)
	assert.parameterTypeIsTable('headers', headers)
	assert.parameterTypeIsTable('rows', rows)
	
	local buffer = tabelize()
	
	local function add(content)
		buffer:insert(content)
	end
	
	add(writer:writeElementOpenTag('table'))
  
	if caption ~= '' then
		add(writer:writeElement('caption', caption))
	end
	
	if widths and widths[1] ~= 0 then
    	for _, width in pairs(widths) do
			assert.parameterTypeIsNumber('width', width)
			
			local percentageWidth = string.format('%d%%', width * 100)
			add(writer:writeElementWithoutPhrasingContent('col', {width = percentageWidth}))
		end
	end
	
	local headerRow = tabelize()
	local isHeaderEmpty = true
	for columnIndex, headerCellPhrasedContent in pairs(headers) do
		assert.parameterTypeIsString('headerCellPhrasedContent', headerCellPhrasedContent)
		
		local align = pandocToHtmlAlignmentLookUp[pandocAlignments[columnIndex]]
		headerRow:insert(writer:writeElement('th', headerCellPhrasedContent, {class = 'align ' .. align}))
		isHeaderEmpty = isHeaderEmpty and headerCellPhrasedContent == ''
	end
	if not isHeaderEmpty then
		add(writer:writeElementOpenTag(writer:writeElementNameWithAttributes('tr', {class = 'header'})))
		for _, thCell in pairs(headerRow) do
			add(thCell)
		end
		add(writer:writeElementCloseTag('tr'))
	end
	
	local class = 'even'
	for _, row in pairs(rows) do
		assert.parameterTypeIsTable('row', row)
		
		class = (class == 'even' and 'odd') or 'even'
		add(writer:writeElementOpenTag(writer:writeElementNameWithAttributes('tr', {class = class})))
		for columnIndex, rowCellPhrasedContent in pairs(row) do
			assert.parameterTypeIsString('rowCellPhrasedContent', rowCellPhrasedContent)
			
			local align = pandocToHtmlAlignmentLookUp[pandocAlignments[columnIndex]]
			add(writer:writeElement('td', rowCellPhrasedContent, {class = 'align ' .. align}))
		end
		add(writer:writeElementCloseTag('tr'))
	end
	
	add(writer:writeElementCloseTag('table'))
	
	return buffer:concat()
end
