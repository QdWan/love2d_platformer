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
    self.jumpTimer=0
    self.jumping=false
    self.onGround=false
    self.hitbox={}
    self.attackbox={}
    self.injuryNum={}
    self.injuryTimer=0
    self.act=1
    self.actTimer=0
    self.image=nil      --贴图
    self.quads=nil      --切片
    self.aniMove=true   --行走动画
    self.aniStand=false --踏步动画
    self.aniSpeed=10     --动画速度
    return new
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
    table.insert(self.players,player)
end

function Player:isInMap()
    local map=self.scene.map
    return self.x>=0 and self.x<map.pixelWidth and self.y>=0 and self.y<map.pixelHeight
end

local function getRect(hitbox,x,y)
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
    local x1,y1,x2,y2=getRect(hitbox,xNew,self.y)
    local collide=Map.notPassable
    if self.vx>0 then
        --右侧碰撞
        if collide(map,x2,y1) or collide(map,x2,y2) or collide(map,x2,y1+16) then
            xNew=int(x2/tilesize)*tilesize-hitbox.w-hitbox.x
            self.vx=0
        end
    elseif self.vx<0 then
        --左侧碰撞
        if collide(map,x1,y1) or collide(map,x1,y2) or collide(map,x1,y1+16) then
            xNew=int(x1/tilesize+1)*tilesize-hitbox.x
            self.vx=0
        end
    end
    x1,y1,x2,y2=getRect(hitbox,xNew,yNew)
    self.onGround=false
    if self.vy>0 then
        --下侧碰撞
        if collide(map,x1,y2) or collide(map,x2,y2) then
            yNew=int(y2/tilesize)*tilesize-hitbox.h-hitbox.y
            self.onGround=true
            self.vy=0
        end
    elseif self.vy<0 then
        --上侧碰撞
        if collide(map,x1,y1) or collide(map,x2,y1) then
            yNew=int(y1/tilesize+1)*tilesize-hitbox.y
            self.jumping=false
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
    local k=control.key
    --重力加速度
    self.vy=self.vy+0.3;
    if k.right and self.vx<self.vMax and self.act<5 then
        --向右移动
        self.vx=self.vx+0.5
    elseif k.left and self.vx>-self.vMax and self.act<5 then
        --向左移动
        self.vx=self.vx-0.5
    else
        --没按键的时候减速
        if self.vx>-0.2 and self.vx<0.2 then
            --速度不大的时候直接停下
            self.vx=0
        elseif self.vx>0 then
            self.vx=self.vx-0.2
        elseif self.vx<0 then
            self.vx=self.vx+0.2
        end
    end
    --跳跃
    if k.jump then
        if (not control.okey.jump and self.onGround) or (self.jumping and self.jumpTimer<16) then
            self.jumpTimer=self.jumpTimer+1
            self.jumping=true
            self.vy=-4
        end
    else
        self.jumping=false
        self.jumpTimer=0
    end
    if k.attack and self.onGround and self.act<5 then
        if k.up then
            self.act=11
        else
            --普通攻击
            self.act=5
        end
        self.actTimer=0
    end
end

local function processAct(self)
    --处理特殊动作
    if self.act>=5 and self.act<=10 then
        --普通攻击
        self.actTimer=self.actTimer+1
        if self.actTimer>3 then
            self.act=self.act+1
            self.actTimer=0
            if self.act>10 then
                self.act=4
            end
        end
    elseif self.act>=11 and self.act<=16 then
        --上挑攻击
        self.actTimer=self.actTimer+1
        if self.actTimer>3 then
            self.act=self.act+1
            self.actTimer=0
            if self.act>16 then
                self.act=4
            end
        end
    else
        if self.onGround then
            --只有在地面的时候行走动画有效
            if self.vx~=0 and self.aniMove then
                self.act=math.floor(self.scene.frames/self.aniSpeed)%4+1
            end
        else
            self.act=1
        end
    end
end

local function processInjure(self)
    local injury=self.injuryNum
    local new,_={},1
    for i=1,#injury do
        local t=injury[i]
        if t[4]<60 then
            new[_],_=t,_+1
        end
        t[2],t[4]=t[2]-2,t[4]+1
    end
    self.injuryNum=new
    if self.injuryTimer>0 then
        self.injuryTimer=self.injuryTimer-1
    end
end

function Player:update()
    processDir(self)
    processKey(self)
    collideMap(self)
    processAct(self)
    processInjure(self)
end

function Player:injure(n)
    local x,y=self.scene.camera:Transform(self.x,self.y-20)
    if self.injuryTimer==0 then
        local t=self.injuryNum
        t[#t+1]={x,y,n,0}
        self.injuryTimer=2
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

function Player:drawInjury()
    local injury=self.injuryNum
    local print=love.graphics.print
    local color=love.graphics.setColor
    for i=1,#injury do
        local d=injury[i]
        if d[4]<40 then
            color(0,0,0,1)
            print(d[3],d[1],d[2],0,2,2,10,10)
            color(1,1,1,1)
            print(d[3],d[1],d[2],0,2,2,10,10)
        else
            local z=.066*(70-d[4])
            color(0,0,0,1)
            print(d[3],d[1],d[2],0,z,z,10,10)
            color(1,1,1,1)
            print(d[3],d[1],d[2],0,z,z,10,10)
        end
    end
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
