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

function default(rawCodeString, attributesTable)
	
	assert.parameterIsString(rawCodeString)
	assert.parameterIsTable(attributesTable)
	
	-- TODO: Consider adding highlighters here, eg using kate
	return potentiallyEmptyXml('pre', potentiallyEmptyXmlWithAttributes('code', escapeRawText(rawCodeString), attributesTable))
end
module.default = default

local functions = setmetatable({}, {
	__index = function(_, key)

		assert.parameterIsTable(_)
		assert.parameterIsString(key)
		
		return default
	end
})
module.functions = functions

module.register = function(name, someCodeBlockFunction)
	
	assert.parameterIsString(name)
	assert.parameterIsFunction(someCodeBlockFunction)
	
	functions[name] = someCodeBlockFunction
end

-- TODO: Load all submodules that are present!
requireChild('dot')
