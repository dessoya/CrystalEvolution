
require("Control")

require("AppMessages")
require("AppConst")

local ThreadChild = require("Thread\\PumpChild")
local Server = ThreadChild:extend()

function Server:start()

	self:setMessageNames({
		[#M_Quit]		= "onQuit",
		[#M_SetScale]	= "onSetScale"
	})

	self.rmap = _get(#G_RMAP)
	self.terrainMap = _get(#G_TERRAINMAP)

	-- generate map


	self:poolMessageLoop(0)

end

function Server:onQuit()
	self.work = false

end

function Server:onSetScale(_scale)
	self.rmap:set(#RMF_CURSCALE, _scale)
	self.rmap:setViewSize(self.rmap:get(#RMF_CURW, 2))
	-- resend objects

end

return Server