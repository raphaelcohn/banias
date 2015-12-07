--[[
This file is part of banias. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT. No part of banias, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of banias. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local markuplanguagewriter = require('markuplanguagewriter')
local Html5Writer = markuplanguagewriter.Html5Writer
local writer = markuplanguagewriter.Html5Writer.singleton


function default(rawCodeString, attributesTable)
	assert.parameterTypeIsString('rawCodeString', rawCodeString)
	assert.parameterTypeIsTable('attributesTable', attributesTable)
	
	-- TODO: Consider adding highlighters here, eg using kate
	return writer:writeElement('pre', writer:writeElement('code', writer:writeText(rawCodeString), attributesTable))
end
module.default = default

assert.globalTypeIsFunction('setmetatable')
local functions = setmetatable({}, {
	__index = function(_, key)
		assert.parameterTypeIsTable('_', _)
		assert.parameterTypeIsString('key', key)
		
		return default
	end
})
module.functions = functions

module.register = function(name, someCodeBlockFunction)
	assert.parameterTypeIsString('name', name)
	assert.parameterTypeIsFunction('someCodeBlockFunction', someCodeBlockFunction)
	
	functions[name] = someCodeBlockFunction
end

-- TODO: Load all submodules that are present!
require(moduleName .. '.' .. 'dot')
