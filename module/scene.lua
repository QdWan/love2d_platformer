Scene={}
local int=math.floor
local gc=love.graphics

function Scene:new()
    local new={};
    setmetatable(new,Scene)
    self.__index=self
    self.width,self.height=gc.getPixelDimensions()
    self.map=Map
    self.camera=Camera:new()
    self.weather=Weather and Weather:new()
    self.frames=0
    self.players={}
    self.objects={}
    return new
end

local function updateCamera(self)
    camera=self.camera
    camera.x=player.x
    camera.y=player.y
    if camera.x*camera.z<640 then
        camera.x=640/camera.z
    end
    if (self.map.pixelWidth-player.x)*camera.z<640 then
        camera.x=self.map.pixelWidth-640/camera.z
    end
    if camera.y*camera.z<360 then
        camera.y=360/camera.z
    end
    if (self.map.pixelHeight-player.y)*camera.z<360 then
        camera.y=self.map.pixelHeight-360/camera.z
    end
end

function Scene:update()
    for i=1,#self.players do
        self.players[i]:update()
    end
    updateCamera(self)
    if self.weather then
        self.weather:update()
    end
    self.frames=self.frames+1
end

function Scene:draw()
    self.map:draw()
    enemy:draw()
    for i=1,#self.players do
        self.players[i]:draw()
    end
	enemy:drawDanmaku()
	text:draw()
	editor:draw()
	control:draw()
    if self.weather then
        self.weather:update()
    end
end
