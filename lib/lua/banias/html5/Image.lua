--[[
This file is part of banias. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT. No part of banias, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of banias. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT.
]]--


local shell = require('halimede.shell').shell
local tabelize = require('halimede.tabelize').tabelize

local xml = require('xml')
local escapeRawText = xml.escapeRawText
local attributes = xml.attributes
local xmlElementNameWithAttributes = xml.xmlElementNameWithAttributes
local xmlElementOpenTag = xml.xmlElementOpenTag
local xmlElementCloseTag = xml.xmlElementCloseTag
local xmlElementEmptyTag = xml.xmlElementEmptyTag
local potentiallyEmptyXml = xml.potentiallyEmptyXml
local potentiallyEmptyXmlWithAttributes = xml.potentiallyEmptyXmlWithAttributes

local assert = require('halimede.assert')


function CaptionedImage(url, title, altText)

	assert.parameterIsString(url)
	assert.parameterIsString(title)
	assert.parameterIsString(altText)
	
	local buffer = tabelize()
	local function add(content)
		buffer:insert(content)
	end
	
	add(xmlElementOpenTag('figure'))
	add(Image(altText, url, title))
	add(potentiallyEmptyXml('figcaption', altText))
	add(xmlElementCloseTag('figure'))
	
	return buffer:concat()
end

function Image(altText, url, titleWithoutSmartQuotes)
	
	assert.parameterIsString(altText)
	assert.parameterIsString(url)
	assert.parameterIsString(titleWithoutSmartQuotes))
	
	
	local conversionMapping = {
		'width',
		'x',
		'height'
	}
	
	-- TODO: If URL doesn't start with '/' then embed? Or does the symlink point to a FOLDER?
	
	-- TODO: this is where we can embed our size logic with jpeginfo
	local shell = require('banias').shell
	-- jpeginfo --info --lsstyle html5/banias-spring.jpg
	-- 2592 x 1944 24bit Exif  Normal Huffman 1303996 html5/banias-spring.jpg
	-- TODO: Check if jpeg using file xxx, may be it's a PNG or GIF
	-- TODO: Test converting to PNG or GIF for smaller sizes
	-- TODO: Don't base64 encode unless necessary
	local line = shell('jpeginfo', '--info', '--lsstyle', url)
	local index = 1
	local jpegInfo = {}
	for fragment in line:gmatch('([^ ]+)') do
		if index > #conversionMapping then
			break
		end
		jpegInfo[conversionMapping[index]] = fragment
		
		index = index + 1
	end
	return potentiallyEmptyXmlWithAttributes('img', '', {url = url, title = titleWithoutSmartQuotes, alt = altText, width = jpegInfo.width, height = jpegInfo.height})
end
