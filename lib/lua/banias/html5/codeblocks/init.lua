--[[
This file is part of banias. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT. No part of banias, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of banias. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT.
]]--


local HtmlWriter = require('markuplanguagewriter.htmlwriter')
local writeText = HtmlWriter.writeText
local writeElementNameWithAttributes = HtmlWriter.writeElementNameWithAttributes
local writeElementOpenTag = HtmlWriter.writeElementOpenTag
local writeElementEmptyTag = HtmlWriter.writeElementEmptyTag
local writeElementCloseTag = HtmlWriter.writeElementCloseTag
local writeElement = HtmlWriter.writeElement

local assert = require('halimede.assert')

function default(rawCodeString, attributesTable)
	assert.parameterTypeIsString(rawCodeString)
	assert.parameterTypeIsTable(attributesTable)
	
	-- TODO: Consider adding highlighters here, eg using kate
	return writeElement('pre', writeElement('code', writeText(rawCodeString), attributesTable))
end
module.default = default

local functions = setmetatable({}, {
	__index = function(_, key)
		assert.parameterTypeIsTable(_)
		assert.parameterTypeIsString(key)
		
		return default
	end
})
module.functions = functions

module.register = function(name, someCodeBlockFunction)
	assert.parameterTypeIsString(name)
	assert.parameterTypeIsFunction(someCodeBlockFunction)
	
	functions[name] = someCodeBlockFunction
end

-- TODO: Load all submodules that are present!
requireChild('dot')
