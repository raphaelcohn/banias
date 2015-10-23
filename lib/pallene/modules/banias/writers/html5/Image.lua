--[[
This file is part of banias. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT. No part of banias, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of banias. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT.
]]--


local executeInShellAndReadAllFromStandardIn = require('halimede.io.shell').executeInShellAndReadAllFromStandardIn
local shellLanguage = require('halimede.ShellLanguage').Default
local tabelize = require('halimede.tabelize').tabelize

local Html5Writer = require('markuplanguagewriter.Html5Writer')
local writeText = Html5Writer.writeText
local writeElementNameWithAttributes = Html5Writer.writeElementNameWithAttributes
local writeElementOpenTag = Html5Writer.writeElementOpenTag
local writeElementEmptyTag = Html5Writer.writeElementEmptyTag
local writeElementCloseTag = Html5Writer.writeElementCloseTag
local writeElement = Html5Writer.writeElement

local assert = require('halimede.assert')


function CaptionedImage(url, title, altText)
	assert.parameterTypeIsString(url)
	assert.parameterTypeIsString(title)
	assert.parameterTypeIsString(altText)
	
	local buffer = tabelize()
	local function add(content)
		buffer:insert(content)
	end
	
	add(writeElementOpenTag('figure'))
	add(Image(altText, url, title))
	add(writeElement('figcaption', altText))
	add(writeElementCloseTag('figure'))
	
	return buffer:concat()
end

function Image(altText, url, titleWithoutSmartQuotes)
	assert.parameterTypeIsString(altText)
	assert.parameterTypeIsString(url)
	assert.parameterTypeIsString(titleWithoutSmartQuotes)
	
	
	local conversionMapping = {
		'width',
		'x',
		'height'
	}
	
	-- TODO: If URL doesn't start with '/' then embed? Or does the symlink point to a FOLDER?
	
	-- jpeginfo --info --lsstyle html5/banias-spring.jpg
	-- 2592 x 1944 24bit Exif  Normal Huffman 1303996 html5/banias-spring.jpg
	-- TODO: Check if jpeg using file xxx, may be it's a PNG or GIF
	-- TODO: Test converting to PNG or GIF for smaller sizes
	-- TODO: Don't base64 encode unless necessary
	local line = executeInShellAndReadAllFromStandardIn(shellLanguage, 'jpeginfo', '--info', '--lsstyle', url)
	local index = 1
	local jpegInfo = {}
	for fragment in line:gmatch('([^ ]+)') do
		if index > #conversionMapping then
			break
		end
		jpegInfo[conversionMapping[index]] = fragment
		
		index = index + 1
	end
	return writeElement('img', '', {url = url, title = titleWithoutSmartQuotes, alt = altText, width = jpegInfo.width, height = jpegInfo.height})
end
