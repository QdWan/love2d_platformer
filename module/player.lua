local gc=love.graphics
local draw,line,color,text=gc.draw,gc.line,gc.setColor,gc.print
local rect,mask=gc.rectangle,gc.setScissor
local rand,int=math.random,math.floor
Player={}

function Player:new()
    local new={}
    setmetatable(new,Player)
    self.__index=self
    new.scene=Scene
    new.hpmax=800
    new.hp=800
    new.x=0
    new.y=0            --坐标
    new.vx=0
    new.vy=0           --速度
    new.vMax=2         --最大速度
    new.isRight=true
    new.jumpTimer=0
    new.jumping=false
    new.onGround=false
    new._hitbox={}
    new._attackbox={}
    new.hitbox={x=0,y=0,w=0,h=0}
    new.attackbox={x=0,y=0,w=0,h=0}
    new.injuryNum={}
    new.injuryTimer=0
    new.act=1
    new.actTimer=0
    new.image=nil      --贴图
    new.quads=nil      --切片
    new.aniMove=true   --行走动画
    new.aniStand=false --踏步动画
    new.aniSpeed=10     --动画速度
    new.img_hpbar=gc.newImage("img/player_hpbar.png")
    return new
end

function Player:loadData(datafile)
    local data=require(datafile)
    self.image=gc.newImage(data.image)
    self.quads=data.quads
    self._hitbox=data.hitbox
    self._attackbox=data.attackbox
end

function Scene:addPlayer(player)
    player.scene=self
    table.insert(self.players,player)
end

function Player:isInMap()
    local map=self.scene.map
    return self.x>=0 and self.x<map.pixelWidth and self.y>=0 and self.y<map.pixelHeight
end

local function collideMap(self)
    if not self.scene then return end
    local map=self.scene.map
    local int=math.floor
    local tilesize=self.scene.map.tilesize
    local hitbox=self._hitbox[self.act]
    local xNew,yNew=self.x+self.vx,self.y+self.vy
    local x1,y1=xNew+hitbox.x,self.y+hitbox.y
    local x2,y2=x1+hitbox.w-.1,y1+hitbox.h-.1
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
    x1,y1=xNew+hitbox.x,yNew+hitbox.y
    x2,y2=x1+hitbox.w-.1,y1+hitbox.h-.1
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
    -- 储存当前的hitbox和attackbox
    local attackbox=self._attackbox[self.act]
    local hb,ab=self.hitbox,self.attackbox
    hb.w,hb.h,hb.y=hitbox.w,hitbox.h,yNew+hitbox.y
    ab.w,ab.h,ab.y=attackbox.w,attackbox.h,yNew+attackbox.y
    if self.isRight then
        hb.x=xNew+hitbox.x
        ab.x=xNew+attackbox.x
    else
        hb.x=xNew-hitbox.x-hitbox.w
        ab.x=xNew-attackbox.x-attackbox.w
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

local function collideBox(box1,box2)
    return box1.x<box2.x+box2.w and box1.x+box1.w>box2.x and box1.y<box2.y+box2.h and box1.y+box1.h>box2.y
end

local function updateAct(self)
    --处理特殊动作
    if self.act>=5 and self.act<=10 then
        --普通攻击
        local attackbox=self.attackbox
        local enemys=self.scene.enemys
        if attackbox.w>0 then
            for i=1,#enemys do
                local enemy=enemys[i]
                local hitbox=enemy.hitbox
                if collideBox(attackbox,hitbox) then
                    enemy:injure(20)
                end
            end
        end
        self.actTimer=self.actTimer+1
        if self.actTimer>3 then
            self.act,self.actTimer=self.act+1,0
            if self.act>10 then self.act=4 end
        end
    elseif self.act>=11 and self.act<=16 then
        --上挑攻击
        local attackbox=self.attackbox
        local enemys=self.scene.enemys
        if attackbox.w>0 then
            for i=1,#enemys do
                local enemy=enemys[i]
                local hitbox=enemy.hitbox
                if collideBox(attackbox,hitbox) then
                    enemy:injure(20)
                end
            end
        end
        self.actTimer=self.actTimer+1
        if self.actTimer>3 then
            self.act,self.actTimer=self.act+1,0
            if self.act>16 then self.act=4 end
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
    if self.vx>0 then
        self.isRight=true
    elseif self.vx<0 then
        self.isRight=false
    end
end

local function updateInjure(self)
    local injury=self.injuryNum
    local new,_={},1
    for i=1,#injury do
        local t=injury[i]
        if t[4]<60 then
            new[_],_=t,_+1
        end
        t[2],t[4]=t[2]-1,t[4]+1
    end
    self.injuryNum=new
    if self.injuryTimer>0 then
        self.injuryTimer=self.injuryTimer-1
    end
end

function Player:update()
    processKey(self)
    updateAct(self)
    collideMap(self)
    updateInjure(self)
end

function Player:injure(n)
    if self.injuryTimer==0 then
        local t=self.injuryNum
        t[#t+1]={self.x,self.y,n,0}
        self.injuryTimer=10
        self.hp=self.hp-n
        if self.hp<0 then
            self.hp=0
        end
    end
end

local function drawHitbox(self)
    local camera=self.scene.camera
    local hitbox=self.hitbox
    local x1,y1=self.x+hitbox.x,self.y+hitbox.y
    x,y=camera:Transform(x1,y1)
    color(1,1,1,1)
    gc.rectangle("line",x,y,camera.z*hitbox.w,camera.z*hitbox.h)
end

local function drawAttackbox(self)
    local camera=self.scene.camera
    local attackbox=self.attackbox
    color(1,0,0,0.4)
    if attackbox.w>0 then
        x,y=camera:Transform(attackbox.x,attackbox.y)
        gc.rectangle("fill",x,y,camera.z*attackbox.w,camera.z*attackbox.h)
    end
end

function Player:drawInjury()
    local injury=self.injuryNum
    local camera=self.scene.camera
    for i=1,#injury do
        local d=injury[i]
        local x,y=camera:Transform(d[1],d[2])
        if d[4]<40 then
            text(d[3],x,y,0,2,2,10,10)
        else
            local z=.066*(70-d[4])
            text(d[3],x,y,0,z,z,10,10)
        end
    end
end

local function hsv(h,s,v)
    local i=int(h*6)
    local f=h*6-i;
    local p=v*(1-s)
    local q=v*(1-f*s)
    local t=v*(1-(1-f)*s)
    if i==0     then color(v,t,p)
    elseif i==1 then color(q,v,p)
    elseif i==2 then color(p,v,t)
    elseif i==3 then color(p,q,v)
    elseif i==4 then color(t,p,v)
    elseif i==5 then color(v,p,q)
    end
end

function Player:drawStatus()
    local x,y=20,20
    local w,h=480,24
    hsv(.13,.9+.1*math.sin(self.scene.frames*.1),1)
    mask(x,y,w*self.hp/self.hpmax,h)
    rect("fill",x,y,w,h,12,12)
    hsv(.13,.7+.1*math.sin(self.scene.frames*.1),1)
    mask(x,y,w*self.hp/self.hpmax,8)
    rect("fill",x,y,w,h,12,12)
    mask()
    color(1,1,1)
    gc.setLineWidth(3)
    rect("line",x,y,w,h,12,12)
    gc.setLineWidth(1)
end

function Player:draw()
    local camera=self.scene.camera
    local scale=camera.z
    local x,y=camera:Transform(self.x,self.y)
    if self.injuryTimer>0 then
        color(1,0,0,1)
    end
    if self.isRight then
        draw(self.image,self.quads[self.act],x,y,0,scale,scale,64,64)
    else
        draw(self.image,self.quads[self.act],x,y,0,-scale,scale,64,64)
    end
    drawAttackbox(self)
    color(1,1,1,1)
end
