--[[
This file is part of banias. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT. No part of banias, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of banias. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local markuplanguagewriter = require.markuplanguagewriter
local Html5Writer = markuplanguagewriter.Html5Writer
local writer = markuplanguagewriter.Html5Writer.singleton
local shellLanguage = halimede.io.ShellLanguage.default()
local tabelize = halimede.table.tabelize


function CaptionedImage(url, title, altText)
	assert.parameterTypeIsString('url', url)
	assert.parameterTypeIsString('title', title)
	assert.parameterTypeIsString('altText', altText)
	
	local buffer = tabelize()
	local function add(content)
		buffer:insert(content)
	end
	
	add(writer:writeElementOpenTag('figure'))
	add(Image(altText, url, title))
	add(writer:writeElement('figcaption', altText))
	add(writer:writeElementCloseTag('figure'))
	
	return buffer:concat()
end

assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'gmatch')
function Image(altText, url, titleWithoutSmartQuotes)
	assert.parameterTypeIsString('altText', altText)
	assert.parameterTypeIsString('url', url)
	assert.parameterTypeIsString('titleWithoutSmartQuotes', titleWithoutSmartQuotes)
	
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
	local fileHandleStream = shellLanguage:popenReadingFromSubprocess(shellLanguage.silenced, shellLanguage.silenced, 'jpeginfo', '--info', '--lsstyle', url)
	local line = fileHandleStream:readAllRemainingContentsAndClose()
	
	
	local index = 1
	local jpegInfo = {}
	for fragment in line:gmatch('([^ ]+)') do
		if index > #conversionMapping then
			break
		end
		jpegInfo[conversionMapping[index]] = fragment
		
		index = index + 1
	end
	return writer:writeElementWithoutPhrasingContent('img', {url = url, title = titleWithoutSmartQuotes, alt = altText, width = jpegInfo.width, height = jpegInfo.height})
end
