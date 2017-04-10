installModule("terrain_map")
local Object = require("Object")

local Const = require("AppConst")
local scale = require("scale")
local Control = require("Control")
local RendererHost = require("DD\\Renderer\\Host")
local ThreadHost = require("Thread\\Host")

local Game = Object:extend()

function Game:initialize(mapLayer, queue, pump)

	self.mapLayer = mapLayer

	self.map = TerrainMap:new()
	_set(#G_TERRAINMAP, self.map)

	
	self.map:expand(#MAP_MID + 2, #MAP_MID)
	local b = self.map:getBlock(#MAP_MID + 2, #MAP_MID)
	b:set(#MAP_MID + 2, #MAP_MID, 1)
	local id, flag = self.map:getCell(#MAP_MID, #MAP_MID)
	

	local WRMap = Control.makeWrap(RMap)
	WRMap:addEvents({
		onAdd = function(self)
			self:setViewSize(RendererHost.getViewSize())
		end,
		onViewSize = function(self, w, h)
			self:setViewSize(w, h)
		end
	})

	local t = Const.TerrainImages
	self.rmap = WRMap:new(self.map, scale.count, table.getn(t) + 1)
	_set(#G_RMAP, self.rmap)

	self.scale = 0
	local images = _get(#IMAGES)
	for i = 1, scale.count do
		local scaleIndex = i - 1
		local m, d = unpack(scale.d[i])

		self.rmap:setScaleInfo(scaleIndex, 200 * m / d, 200 * m /d)
		for j = 1, table.getn(t) do
			local item = t[j]
			self.rmap:setCellImage(scaleIndex, item.id, images:get(item.name .. "_" .. scaleIndex))
		end
	end

	self.rmap:setCoords(#MAP_MID * 1024, #MAP_MID * 1024)
	
	self.mapLayer:add(self.rmap)

	self.server = ThreadHost:new("Server\\Server", queue)

	pump:addNames({
		[#WM_MOUSEWHEEL]		= "onMouseWheel"
	})
	pump:registerReciever(self)
	

end

function Game:onMouseWheel(dir)
	if dir < 0 then
		-- forward
		if self.scale ~= scale.count - 1 then
			self:setScale(self.scale + 1)
		end
	else
		if self.scale ~= 0 then
			self:setScale(self.scale - 1)
		end
	end
end

function Game:setScale(_scale)
	self.scale = _scale
	self.server:send(#M_SetScale, _scale)
	-- send to server
	--[[
	self.rmap:set(#RMF_CURSCALE, _scale)
	self.rmap:setViewSize(RendererHost.getViewSize())
	]]
end

return Game 