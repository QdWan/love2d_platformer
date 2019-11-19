Editor={}

function Editor:new(Scene)
    local new={}
    setmetatable(new,Editor)
    self.__index=self
    self.scene=Scene
    self.box={i=0,j=0,x=0,y=0,w=0}
    return new
end

function Editor:update()
    local int=math.floor
    local b=self.box
    local x,y=love.mouse.getPosition()
    local ts=self.scene.map.tilesize
    local camera=self.scene.camera
    local z=camera.z
    local mapx,mapy=camera:InvTransform(x,y)
    b.i,b.j=int(mapy/ts)*ts,int(mapx/ts)*ts
    b.x,b.y=camera:Transform(b.j,b.i)
    b.w=ts*z
end

function Editor:draw()
    local b=self.box
    love.graphics.setColor(1,1,1,1)
    love.graphics.rectangle("line",b.x,b.y,b.w,b.w)
end