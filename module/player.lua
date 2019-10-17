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

function Player:collide()
    if not self.scene then return end
    local map=self.scene.map
    local int=math.floor
    local tilesize=self.scene.map.tilesize
    local hitbox=self.hitbox[self.act]
    local xNew,yNew=self.x+self.vx,self.y+self.vy
    local x1,y1=xNew+hitbox.x,self.y+hitbox.y
    local x2,y2=x1+hitbox.w-1,y1+hitbox.h-1
    if self.vx>0 then
        if self.x<map.pixelWidth then
            if map:notPassable(x2,y1) or map:notPassable(x2,y2) or map:notPassable(x2,y1+1)then
                xNew=int(x2/tilesize)*tilesize-hitbox.w-hitbox.x
                self.vx=0
            end
        end
    elseif self.vx<0 then
        if self.x>0 then
            if map:notPassable(x1,y1) or map:notPassable(x1,y2) or map:notPassable(x1,y1+1) then
                xNew=int(x1/tilesize+1)*tilesize-hitbox.x
                self.vx=0
            end
        end
    end
    x1,y1=xNew+hitbox.x,yNew+hitbox.y
    x2,y2=x1+hitbox.w-1,y1+hitbox.h-1
    if self.vy>0 then
        if self.x<map.pixelHeight then
            if map:notPassable(x1,x2) or map:notPassable(x2,y2) then
                yNew=int(y2/tilesize)*tilesize-hitbox.h-hitbox.y
                self.onGround=true
                self.vy=0
            end
        end
    elseif self.vy<0 then
        if self.y>0 then
            if map:notPassable(x1,y1) or map:notPassable(x2,y1) then
                yNew=int(y1/tilesize+1)*tilesize-hitbox.y
                self.vy=0
            end
        end
    end
    self.x=int(xNew)
    self.y=int(yNew)
end

function Player:update()
    player.vy=player.vy+0.2;
    self:collide()
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
    --绘制hitbox
    local hitbox=self.hitbox[self.act]
    local x1,y1=self.x+hitbox.x,self.y+hitbox.y
    x,y=camera:Transform(x1,y1)
    love.graphics.rectangle("line",x,y,camera.z*hitbox.w,camera.z*hitbox.h)
end

function Player:setPosition(x,y)
    self.x,self.y=x,y
end
