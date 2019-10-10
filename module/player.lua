--Player<Scene
Player={}

function Player:new()
    local new={}
    setmetatable(new,Player)
    self.__index=self
    self.scene=Scene
    self.x=0
    self.y=0            --坐标
    self.vx=0
    self.vy=0           --速度
    self.jumping=0      --跳跃时间
    self.onGround=false
    self.canJump=false
    self.hitbox={}
    self.attackbox={}
    self.act=1
    self.actTimer=0
    self.image=nil      --贴图
    self.quads=nil      --切片
    self.aniMove=true   --行走动画
    self.aniStand=false --踏步动画
    self.aniSpeed=6     --动画速度
    return new
end

function Player:jump()
    if self.canJump then
        self.vy=-5
    end
end

function Player:loadData(datafile)
    local data=require(datafile)
    self.image=love.graphics.newImage(data.image)
    self.quads=data.quads
    self.hitbox=data.hitbox
    self.attackbox=data.attackbox
end

function Scene:addPlayer(player)
    player.scene=self
    table.insert(self.player,player)
end

function Player:isInMap()
    local map=self.scene.map
    return self.x>0 and self.x<map.pixelWidth and self.y>0 and self.y<map.pixelHeight
end

function Player:update()
    if not self.scene then return end
    local tilesize=self.scene.map.tilesize
    local map=self.scene.map
    local int=math.floor
    local hitbox=self.hitbox[self.act]
    local x1,y1=self.x+hitbox.x,self.y+hitbox.y
    local x2,y2=x1+hitbox.w,y1+hitbox.h
    --print(x1,y1,x2,y2)
    --self.vy=self.vy+0.02
    self.x=self.x+self.vx
    self.y=self.y+self.vy
    if self.vx>0 then--检测右侧碰撞
        if x2<map.pixelWidth then
            local m,n,x=int(y1/tilesize),int(y2/tilesize),int(x2/tilesize)
            for i=m,n do
                box(self.scene.camera,x,i)
                if map:notPassable(x,i) then
                    local bump=x2-x*tilesize+1
                    if bump>0 then--如果发生了碰撞
                        self.x=self.x-bump
                    end
                    --break
                end
            end
        end
    elseif self.vx<0 then--检测左侧碰撞
        if x1>=0 then
            local m,n,x=int(y1/tilesize),int(y2/tilesize),int(x1/tilesize)
            for i=m,n do
                box(self.scene.camera,x,i)
                if map:notPassable(x,i) then
                    local bump=(x+1)*tilesize-x1+1
                    if bump>0 then--如果发生了碰撞
                        self.x=self.x+bump
                    end
                    --break
                end
            end
        end
    end
    if self.vy>0 then--检测下方碰撞
        if y2<map.pixelHeight then
            local m,n,y=int(x1/tilesize),int(x2/tilesize),int(y2/tilesize)
            for i=m,n do
                box(self.scene.camera,i,y)
                if map:notPassable(i,y) then
                    local bump=y2-y*tilesize+1
                    if bump>0 then
                        self.y=self.y-bump
                        self.vy=0
                    end
                    --break
                end
            end
        end
    elseif self.vy<0 then--检测上方碰撞
        if y1>=0 then
            local m,n,y=int(x1/tilesize),int(x2/tilesize),int(y1/tilesize)
            for i=m,n do
                box(self.scene.camera,i,y)
                if map:notPassable(i,y) then
                    local bump=(y+1)*tilesize-y1+1
                    if bump>0 then
                        self.y=self.y+bump
                    end
                    --break
                end
            end
        end
    end
end

local function box(camera,i,j)
    local x,y=camera:Transform(i*16,j*16)
    love.graphics.setColor(1,0,0,1)
    love.graphics.rectangle("line",x,y,camera.z*16,camera.z*16)
end

function Player:draw()
    local camera=self.scene.camera
    local x,y=camera:Transform(self.x-64,self.y-64)
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(self.image,self.quads[self.act],x,y,0,camera.z)
end

function Player:setPosition(x,y)
    self.x,self.y=x,y
end
