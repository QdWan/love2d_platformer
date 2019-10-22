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
    self.vMax=2         --最大速度
    self.isRight=true
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
    self.aniSpeed=10     --动画速度
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

local function getRect(self,x,y,hitbox)
    local hitbox=self.hitbox[self.act]
    local x1,y1=x+hitbox.x,y+hitbox.y
    return x1,y1,x1+hitbox.w-0.1,y1+hitbox.h-0.1
end

local function collideMap(self)
    if not self.scene then return end
    local map=self.scene.map
    local int=math.floor
    local tilesize=self.scene.map.tilesize
    local hitbox=self.hitbox[self.act]
    local xNew,yNew=self.x+self.vx,self.y+self.vy
    local x1,y1,x2,y2=getRect(self,xNew,self.y)
    if self.vx>0 then
        if map:notPassable(x2,y1) or map:notPassable(x2,y2) or map:notPassable(x2,y1+16) then
            xNew=int(x2/tilesize)*tilesize-hitbox.w-hitbox.x
            self.vx=0
        end
    elseif self.vx<0 then
        if map:notPassable(x1,y1) or map:notPassable(x1,y2) or map:notPassable(x1,y1+16) then
            xNew=int(x1/tilesize+1)*tilesize-hitbox.x
            self.vx=0
        end
    end
    x1,y1,x2,y2=getRect(self,xNew,yNew)
    self.onGround=false
    if self.vy>0 then
        if map:notPassable(x1,y2) or map:notPassable(x2,y2) then
            yNew=int(y2/tilesize)*tilesize-hitbox.h-hitbox.y
            self.onGround=true
            self.vy=0
        end
    elseif self.vy<0 then
        if map:notPassable(x1,y1) or map:notPassable(x2,y1) then
            yNew=int(y1/tilesize+1)*tilesize-hitbox.y
            self.vy=0
        end
    end
    self.x,self.y=xNew,yNew
end
local function processDir(self)
    if self.vx>0 then
        self.isRight=true
    elseif self.vx<0 then
        self.isRight=false
    end
end

local function processKey(self)
    local keyDown=love.keyboard.isDown
    self.vy=self.vy+0.3;
    if keyDown("d") and self.vx<self.vMax and self.act<5 then
        self.vx=self.vx+0.5
    elseif keyDown("a") and self.vx>-self.vMax and self.act<5 then
        self.vx=self.vx-0.5
    else
        if self.vx>-0.2 and self.vx<0.2 then
            self.vx=0
        elseif self.vx>0 then
            self.vx=self.vx-0.2
        elseif self.vx<0 then
            self.vx=self.vx+0.2
        end
    end
    if keyDown("j") and self.onGround then
        self.vy=-6.4
    end
    if keyDown("k") and self.onGround and self.act<5 then
        self.act=5
        self.actTimer=0
    end
end

function Player:update()
    processDir(self)
    processKey(self)
    collideMap(self)
    --处理特殊动作
    if self.act>=5 and self.act<=10 then
        self.actTimer=self.actTimer+1
        if self.actTimer>3 then
            self.act=self.act+1
            self.actTimer=0
            if self.act>10 then
                self.act=4
            end
        end
    else
        if self.onGround then
            if self.vx~=0 and self.aniMove then
                self.act=math.floor(self.scene.frames/self.aniSpeed)%4+1
            end
        else
            self.act=1
        end
    end
end

local function drawHitbox(self)
    local camera=self.scene.camera
    local hitbox=self.hitbox[self.act]
    
    local x1,y1=self.x+hitbox.x,self.y+hitbox.y
    x,y=camera:Transform(x1,y1)
    love.graphics.setColor(1,1,1,1)
    love.graphics.rectangle("line",x,y,camera.z*hitbox.w,camera.z*hitbox.h)
end

function Player:draw()
    local camera=self.scene.camera
    local scale=camera.z
    local x,y=camera:Transform(self.x,self.y)
    love.graphics.setColor(1,1,1,1)
    if self.isRight then
        love.graphics.draw(self.image,self.quads[self.act],x,y,0,scale,scale,64,64)
    else
        love.graphics.draw(self.image,self.quads[self.act],x,y,0,-scale,scale,64,64)
    end
end

function Player:setPosition(x,y)
    self.x,self.y=x,y
end
