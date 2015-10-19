--[[
This file is part of banias. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT. No part of banias, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of banias. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT.
]]--


local tabelize = require('halimede.tabelize').tabelize
local assert = require('halimede.assert')
local XmlWriter = requireSibling('xmlwriter')

module = XmlWriter:new()
function module:constructAttribute(attributesArray, attributeName, attributeValue)
	if attributeValue == '' then
		return
	end
	
	-- Omit quotemarks if value is 'safe'
	if attributeValue:find('[ >="\']') == nil then
		attributesArray:insert(' ' .. attributeName .. '=' ..attributeValue)
		return
	end
	
	return XmlWriter.constructAttribute(self, attributesArray, attributeName, attributeValue)
end
