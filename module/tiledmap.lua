Map={}

local function parsePath(map)
    local path=map.tilesets[1].image
    if path:sub(1,3)=="../" then
        path=path:sub(4)
        return path
    end
end

local function parseMapData(map,h,w)
    local index=1
    local data={}
    local layer=map.layers[1].data
    for i=0,h-1 do
        local t={}
        data[i]=t
        for j=0,w-1 do
            t[j]=data[index]
            index=index+1
        end
    end
    return data
end

local function createQuads(image,w,h,size)
    local quads={}
    local newQuad=love.graphics.newQuad
    local imgw,imgh=image:getDimensions()
    local index=1
    for i=0,h-1 do
        for j=0,w-1 do
            quads[index]=newQuad(size*j,size*i,size,size,imgw,imgh)
            index=index+1
        end
    end
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
    self.data        = parseMapData(map,self.width,self.height)
    --create quads
    self.quads       = createQuads(self.image,16,16,8)
    return new
end
