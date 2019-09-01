Scene={}
local int=math.floor

function Scene:new()
    local new={};
    setmetatable(new,Scene)
    self.__index=self
    self.width,self.height=love.graphics.getPixelDimensions()
    self.map=nil
    self.camera=Camera:new()
    self.weather=Weather:new()
    self.player={}
    return new
end

function Scene:addPlayer(player)
    player.scene=self
    table.insert(self.player,player)
end

function Scene:loadMap(map)
    self.map=Map:new(map)
end

function Scene:update()
    self.weather:update()
    for i=1,#self.player do
        self.player[i]:update()
    end
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
                    love.graphics.draw(image,quads[id],cx,cy,0,zoom)
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
