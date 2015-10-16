--[[
This file is part of banias. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT. No part of banias, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of banias. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT.
]]--


local xml = require('xml')
local escapeRawText = xml.escapeRawText
local attributes = xml.attributes
local xmlElementNameWithAttributes = xml.xmlElementNameWithAttributes
local xmlElementOpenTag = xml.xmlElementOpenTag
local xmlElementCloseTag = xml.xmlElementCloseTag
local xmlElementEmptyTag = xml.xmlElementEmptyTag
local potentiallyEmptyXml = xml.potentiallyEmptyXml
local potentiallyEmptyXmlWithAttributes = xml.potentiallyEmptyXmlWithAttributes

function default(rawCodeString, attributesTable)
	-- TODO: Consider adding highlighters here, eg using kate
	return potentiallyEmptyXml('pre', potentiallyEmptyXmlWithAttributes('code', escapeRawText(rawCodeString), attributesTable))
end
module.default = default

local functions = setmetatable({}, {
	__index = function(_, key)
		return default
	end
})
module.functions = functions

module.register = function(name, someCodeBlockFunction)
	functions[name] = someCodeBlockFunction
end

-- TODO: Load all submodules, do registration, etc
requireChild('dot')
