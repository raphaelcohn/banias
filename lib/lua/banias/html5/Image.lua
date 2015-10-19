--[[
This file is part of banias. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT. No part of banias, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of banias. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT.
]]--


local shell = require('halimede.shell').shell
local tabelize = require('halimede.tabelize').tabelize

local xmlwriter = require('xmlwriter')
local writeText = xmlwriter.writeText
local writeXmlElementNameWithAttributes = xmlwriter.writeXmlElementNameWithAttributes
local writeXmlElementOpenTag = xmlwriter.writeXmlElementOpenTag
local writeXmlElementCloseTag = xmlwriter.writeXmlElementCloseTag
local writeXmlElementEmptyTag = xmlwriter.writeXmlElementEmptyTag
local writeXmlElement = xmlwriter.writeXmlElement

local assert = require('halimede.assert')


function CaptionedImage(url, title, altText)

	assert.parameterIsString(url)
	assert.parameterIsString(title)
	assert.parameterIsString(altText)
	
	local buffer = tabelize()
	local function add(content)
		buffer:insert(content)
	end
	
	add(writeXmlElementOpenTag('figure'))
	add(Image(altText, url, title))
	add(writeXmlElement('figcaption', altText))
	add(writeXmlElementCloseTag('figure'))
	
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
	return writeXmlElement('img', '', {url = url, title = titleWithoutSmartQuotes, alt = altText, width = jpegInfo.width, height = jpegInfo.height})
end
