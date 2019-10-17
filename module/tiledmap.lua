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
    return self.data[int(y/self.tilesize)][int(x/self.tilesize)]>0
end

function Map:isInMap(x,y)
    return x>=0 and x<self.pixelWidth and y>=0 and y<self.pixelHeight
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
