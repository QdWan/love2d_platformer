Enemy1={}

function Enemy1:new()
    local new={}
    setmetatable(new,Enemy1)
    self.__index=self
    self.scene=Scene
    self.x=0
    self.y=0            --坐标
    self.vx=0
    self.vy=0           --速度
    self.vMax=2         --最大速度
    self.isRight=true   --朝向
    self.jumpTimer=0
    self.jumping=false
    self.onGround=false
    self.hitbox={}      --碰撞箱
    self.attackbox={}   --攻击判定箱
    self.act=1          --动作
    self.actTimer=0     --动作计时器
    self.image=nil      --贴图
    self.quads=nil      --切片
    self.aniSpeed=3     --动画速度
    self.task=0         --攻击
    self.taskTimer=0    --攻击计时器
    self.danmaku={{},{}}--弹幕
    self.imgDanmaku=love.graphics.newImage("img/danmaku.png")
    return new
end

function Enemy1:loadData(datafile)
    local data=require(datafile)
    self.image=love.graphics.newImage(data.image)
    self.quads=data.quads
    self.hitbox=data.hitbox
    self.attackbox=data.attackbox
end

function Scene:addEnemy1(obj)
    obj.scene=self
    table.insert(self.objects,obj)
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
        if collide(map,x2,y1) or collide(map,x2,y2) or collide(map,x2,y1+16) or collide(map,x2,y1+32) then
            xNew=int(x2/tilesize)*tilesize-hitbox.w-hitbox.x
            self.vx=0
        end
    elseif self.vx<0 then
        --左侧碰撞
        if collide(map,x1,y1) or collide(map,x1,y2) or collide(map,x1,y1+16) or collide(map,x2,y1+32)then
            xNew=int(x1/tilesize+1)*tilesize-hitbox.x
            self.vx=0
        end
    end
    x1,y1,x2,y2=getRect(hitbox,xNew,yNew)
    self.onGround=false
    if self.vy>0 then
        --下侧碰撞
        if collide(map,x1,y2) or collide(map,x2,y2) or collide(map,x1+16,y2) then
            yNew=int(y2/tilesize)*tilesize-hitbox.h-hitbox.y
            self.onGround=true
            self.vy=0
        end
    elseif self.vy<0 then
        --上侧碰撞
        if collide(map,x1,y1) or collide(map,x2,y1) or collide(map,x1+16,y2) then
            yNew=int(y1/tilesize+1)*tilesize-hitbox.y
            self.vy=0
        end
    end
    self.x,self.y=xNew,yNew
end

local function processAct(self)
    self.act=math.floor(self.scene.frames/self.aniSpeed)%10+1
end

-- 弹幕属性列表
-- 1 匀速直线运动 [x,y,vx,vy]
-- 2 带旋转的 [x,y,vx,vy,dir,t]
local function updateTask(self)
    local frames=self.taskTimer
    local rand,int,cos,sin,pi=math.random,math.floor,math.cos,math.sin,math.pi
    local x,y=self.x,self.y
    if self.task==0 then
        if frames%10==0 and rand()<0.1 then
            self.task,self.taskTimer=rand(4),0
        end
    elseif self.task==1 then
        local danmaku=self.danmaku[1]
        local _=#danmaku
        if frames%10==0 then
            if frames%20==0 then
                for i=0,2*pi,pi/8 do
                    local vx,vy=cos(i)*2,sin(i)*2
                    _=_+1
                    danmaku[_]={x,y,vx,vy}
                end
            else
                for i=pi/16,2*pi,pi/8 do
                    local vx,vy=cos(i)*2,sin(i)*2
                    _=_+1
                    danmaku[_]={x,y,vx,vy}
                end
            end
        end
        if self.taskTimer>120 then
            self.task,self.taskTimer=0,0
        end
    elseif self.task==2 then
        local danmaku=self.danmaku[1]
        local _=#danmaku
        if frames%4==0 then
            local m=int(frames/4)%8
            local d=pi/64
            for i=m*d,2*pi,d*8 do
                local vx,vy=cos(i)*2,sin(i)*2
                _=_+1
                danmaku[_]={x,y,vx,vy}
            end
        end
        if self.taskTimer>120 then
            self.task,self.taskTimer=0,0
        end
    elseif self.task==3 then
        local danmaku=self.danmaku[1]
        local _=#danmaku
        if self.taskTimer<60 then
            local a,v,vx,vy
            for __=1,3 do
                a,v=rand()*2*pi,rand()+1
                vx,vy,_=cos(a)*2,sin(a)*2,_+1
                danmaku[_]={x,y,vx*v,vy*v}
            end
        end
        if self.taskTimer>90 then
            self.task,self.taskTimer=0,0
        end
    elseif self.task==4 then
        local danmaku=self.danmaku[2]
        local _=#danmaku
        if self.taskTimer%10==0 then
            for i=0,2*pi,pi/8 do
                local vx,vy
                vx,vy,_,i=cos(i)*2,sin(i)*2,_+1,i+pi/16
                danmaku[_]={x,y,vx,vy,true,0}
                vx,vy,_=cos(i)*2,sin(i)*2,_+1
                danmaku[_]={x,y,vx,vy,false,0}
            end
        end
        if self.taskTimer>90 then
            self.task,self.taskTimer=0,0
        end
    end
    self.taskTimer=self.taskTimer+1
end

local function updateDanmaku(self)
    local camera=self.scene.camera
    local x1,y1=camera:InvTransform(0,0)
    local x2,y2=camera:InvTransform(1280,720)
    local map,collide=map,Map.notPassable
    local danmaku,new,_
    danmaku,new,_=self.danmaku[1],{},1
    for i=1,#danmaku do
        local d=danmaku[i]
        d[1],d[2]=d[1]+d[3],d[2]+d[4]
        if d[1]>x1 and d[1]<x2 and d[2]>y1 and d[2]<y2 and not collide(map,d[1],d[2]) then
            new[_],_=d,_+1
        end
    end
    self.danmaku[1]=new
    danmaku,new,_=self.danmaku[2],{},1
    for i=1,#danmaku do
        local d=danmaku[i]
        local k=d[6]*0.02
        d[1],d[2]=d[1]+d[3],d[2]+d[4]
        if d[5] then
            d[1],d[2]=d[1]+k*d[4],d[2]-k*d[3] --顺时针[y,-x]
        else
            d[1],d[2]=d[1]-k*d[4],d[2]+k*d[3] --逆时针[-y,x]
        end
        d[6]=d[6]+1
        if d[1]>x1 and d[1]<x2 and d[2]>y1 and d[2]<y2 and not collide(map,d[1],d[2]) then
            new[_],_=d,_+1
        end
    end
    self.danmaku[2]=new
end

function Enemy1:update()
    self.vy=self.vy+0.3;
    collideMap(self)
    processAct(self)
    updateTask(self)
    updateDanmaku(self)
    if self.vx>0 then
        self.isRight=true
    elseif self.vx<0 then
        self.isRight=false
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

function Enemy1:draw()
    local camera=self.scene.camera
    local scale=camera.z
    local x,y=camera:Transform(self.x,self.y)
    love.graphics.setColor(1,1,1,1)
    if self.isRight then
        love.graphics.draw(self.image,self.quads[self.act],x,y,0,scale,scale,24,40)
    else
        love.graphics.draw(self.image,self.quads[self.act],x,y,0,-scale,scale,24,40)
    end
    drawHitbox(self)
end

function Enemy1:drawDanmaku()
    local draw=love.graphics.draw
    local imgDanmaku=self.imgDanmaku
    local camera=self.scene.camera
    local map=self.scene.map
    local danmaku=self.danmaku[1]
    for i=1,#danmaku do
        local d=danmaku[i]
        local x,y=camera:Transform(d[1],d[2])
        draw(imgDanmaku,x,y,0,camera.z*.25,camera.z*.25,16,16)
    end
    danmaku=self.danmaku[2]
    for i=1,#danmaku do
        local d=danmaku[i]
        local x,y=camera:Transform(d[1],d[2])
        draw(imgDanmaku,x,y,0,camera.z*.25,camera.z*.25,16,16)
    end
    love.graphics.print(string.format("num: %d",#self.danmaku[1]+#self.danmaku[2]),0,120)
    love.graphics.print(string.format("task: %d, timer: %d",self.task,self.taskTimer),0,140)
end
