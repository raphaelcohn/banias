--[[
This file is part of banias. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT. No part of banias, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of banias. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT.
]]--


function module.default(rawCodeString, attributesTable)
	-- TODO: Consider adding highlighters here, eg using kate
	return potentiallyEmptyXml('pre', potentiallyEmptyXmlWithAttributes('code', escapeRawText(rawCodeString), attributesTable))
end

local functions = setmetatable({}, {
	__index = function(_, key)
		return module.default
	end
})
module.functions = functions

module.register = function(name, someCodeBlockFunction)
	functions[name] = someCodeBlockFunction
end

-- TODO: Load all submodules, do registration, etc
requireChildOrSibling('dot')
