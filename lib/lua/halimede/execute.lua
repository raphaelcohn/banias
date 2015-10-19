--[[
This file is part of banias. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT. No part of banias, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of banias. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT.
]]--


local exception = requireSibling('exception')
local toShellCommand = requireSibling('toShellCommand').toShellCommand


assert.globalTableHasChieldFieldOfTypeFunction('os', 'execute')
function module.execute(...)
	local command = toShellCommand(...)
	return os.execute(command)
end

assert.globalTableHasChieldFieldOfTypeFunction('os', 'execute')
function module.shellIsAvailable()
	return os.execute()
end
