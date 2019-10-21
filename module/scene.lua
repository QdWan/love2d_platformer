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
    self.weather=Weather:new()
    self.frames=0
    self.player={}
    return new
end

function Scene:loadMap(map)
    self.map=Map:new(map)
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
        camera.y=360/camera.y
    end
    if (self.map.pixelHeight-player.y)*camera.z<360 then
        camera.y=self.map.pixelHeight-360/camera.z
    end
end

function Scene:update()
    self.weather:update()
    updateCamera(self)
    for i=1,#self.player do
        self.player[i]:update()
    end
    self.frames=self.frames+1
end

function Scene:drawMap()
    local map,zoom=self.map,self.camera.z
    local ds,ts=zoom*map.tilesize,map.tilesize
    local image,quads,data=map.image,map.quads,map.data
    local mx,my=self.camera:InvTransform(0,0)             --计算窗口左上角的世界坐标
    local sx,sy=int(mx/ts),int(my/ts)                     --计算窗口左上角的地图坐标
    local ox,oy=self.camera:Transform(sx*ts,sy*ts)        --计算第一块地图的偏移坐标
    local dx,dy=int(self.width/ds)+1,int(self.height/ds)+1--计算需要绘制的格数
    local cx,cy=ox,oy                                     --绘制用临时变量
    local id=0                                            --图块id临时变量
    for i=sy,sy+dy do
        cx=ox
        for j=sx,sx+dx do
            if i>=0 and j>=0 and i<map.height and j<map.width then
                id=data[i][j]
                if id>0 then
                    gc.draw(image,quads[id],cx,cy,0,zoom)
                end
            end
            cx=cx+ds
        end
        cy=cy+ds
    end
end

function Scene:draw()
    self:drawMap()
    for i=1,#self.player do
        self.player[i]:draw()
    end
    self.weather:draw()
end
