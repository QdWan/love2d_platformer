Map={}

function Map:new(mapfile)
    local map = require(mapfile)
    local new={}
    setmetatable(new,self)
    self.__index=self
    self.width = map.width
    self.height = map.height
    self.tilesize = map.tilewidth
    --deal with tileset file path
    self.tileset=(function(path)
            if path:sub(1,3)=="../" then
                path=path:sub(4)
                return path
            end
        end)(map.tilesets[1].image)
    --load tileset image
    self.image=love.graphics.newImage(self.tileset)
    --load map from map file
    self.data={}
    local index=1
    local data=map.layers[1].data
    for i=0,self.height-1 do
        local t={}
        self.data[i]=t
        for j=0,self.width-1 do
            t[j]=data[index]
            index=index+1
        end
    end
    --create quads
    self.quads={}
    local t=self.tilesize
    local f=love.graphics.newQuad
    local imgw,imgh=self.image:getDimensions()
    index=1
    for i=0,15 do
        for j=0,15 do
            self.quads[index]=f(t*j,t*i,t,t,imgw,imgh)
            index=index+1
        end
    end
    return new
end
