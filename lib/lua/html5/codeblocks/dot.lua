--[[
This file is part of banias. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT. No part of banias, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of banias. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT.
]]--


-- Runs dot then base64 on 'rawCodeString' to produce a base64-encoded png in a data: URL
-- Added to retain compatibility with JGM
parentModule.register(leafModuleName, function(rawCodeString, attributesTable)
	
	-- TODO: replace os.tmpname with io.tmpfile - http://www.lua.org/manual/5.2/manual.html#6.8 - but no way to get file name...
	local function pipe(programCommandStringWithEscapedData, inputBytes)
		local temporaryFileToWrite = os.tmpname()
		local tmph = io.open(temporaryFileToWrite, 'w')
		tmph:write(inputBytes)
		tmph:close()

		local outh = io.popen(programCommandStringWithEscapedData .. ' ' .. temporaryFileToWrite, 'r')
		local result = outh:read('*all')
		outh:close()

		os.remove(temporaryFileToWrite)
		return result
	end
	
    local base64EncondedPortalNetworkGraphicsImage = pipe('base64', pipe('dot -Tpng', rawCodeString))
	
	return potentiallyEmptyXmlWithAttributes('img', '', {src = 'data:image/png;base64,' .. base64EncondedPortalNetworkGraphicsImage})
end)
