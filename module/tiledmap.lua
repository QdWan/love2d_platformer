Map={}
local int=math.floor
local function parsePath(map)
    local path=map.tilesets[1].image
    if path:sub(1,3)=="../" then
        path=path:sub(4)
        return path
    end
end

local function parseMapData(map)
    local index=1
    local data={}
    local layer=map.layers[1].data
    for i=0,map.height-1 do
        local t={}
        for j=0,map.width-1 do
            t[j]=layer[index]
            index=index+1
        end
        data[i]=t
    end
    return data
end

local function createQuads(image,size)
    local quads={}
    local newQuad=love.graphics.newQuad
    local imgw,imgh=image:getDimensions()
    local w,h=imgw/size,imgh/size
    local index=1
    for i=0,h-1 do
        for j=0,w-1 do
            quads[index]=newQuad(size*j,size*i,size,size,imgw,imgh)
            index=index+1
        end
    end
    return quads
end

function Map:isPassable(x,y)
    return self.data[y][x]==0
end

function Map:notPassable(x,y)
    if x<0 or x>=self.pixelWidth or y<0 or y>=self.pixelHeight then return false end
    return self.data[int(y/self.tilesize)][int(x/self.tilesize)]>0
end

function Map:isInMap(x,y)
    return x>=0 and x<self.pixelWidth and y>=0 and y<self.pixelHeight
end

function Map:draw()
    local gc,scene=love.graphics,self.scene
    local camera=scene.camera
    local ds,ts=camera.z*self.tilesize,self.tilesize
    local image,quads,data=self.image,self.quads,self.data
    local mx,my=camera:InvTransform(0,0)
    local sx,sy=int(mx/ts),int(my/ts)
    local ox,oy=camera:Transform(sx*ts,sy*ts)
    local dx,dy=int(self.scene.width/ds)+1,int(self.scene.height/ds)+1
    local cx,cy=ox,oy
    local id=0
    for i=sy,sy+dy do
        cx=ox
        for j=sx,sx+dx do
            if i>=0 and j>=0 and i<self.height and j<self.width then
                id=data[i][j]
                if id>0 then
                    gc.draw(image,quads[id],cx,cy,0,camera.z)
                end
            end
            cx=cx+ds
        end
        cy=cy+ds
    end
end

function Scene:loadMap(mapfile)
    map=Map:new(mapfile)
    map.scene=self
    self.map=map
end

function Map:new(mapfile)
    local new={}
    setmetatable(new,self)
    self.__index=self
    --成员变量开始
    local map        = require(mapfile)
    self.width       = map.width
    self.height      = map.height
    self.tilesize    = map.tilewidth
    self.pixelWidth  = self.width*self.tilesize
    self.pixelHeight = self.height*self.tilesize
    self.tileset     = parsePath(map)
    --读取地图图像
    self.image       = love.graphics.newImage(self.tileset)
    --读取地图数据
    self.data        = parseMapData(map)
    --create quads
    self.quads       = createQuads(self.image,16)
    return new
end
