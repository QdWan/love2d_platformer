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
    self.danmaku={}     --弹幕
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
    if self.vx>0 then
        --右侧碰撞
        if map:notPassable(x2,y1) or map:notPassable(x2,y2) or map:notPassable(x2,y1+16) or map:notPassable(x2,y1+32) then
            xNew=int(x2/tilesize)*tilesize-hitbox.w-hitbox.x
            self.vx=0
        end
    elseif self.vx<0 then
        --左侧碰撞
        if map:notPassable(x1,y1) or map:notPassable(x1,y2) or map:notPassable(x1,y1+16) or map:notPassable(x2,y1+32)then
            xNew=int(x1/tilesize+1)*tilesize-hitbox.x
            self.vx=0
        end
    end
    x1,y1,x2,y2=getRect(hitbox,xNew,yNew)
    self.onGround=false
    if self.vy>0 then
        --下侧碰撞
        if map:notPassable(x1,y2) or map:notPassable(x2,y2) or map:notPassable(x1+16,y2) then
            yNew=int(y2/tilesize)*tilesize-hitbox.h-hitbox.y
            self.onGround=true
            self.vy=0
        end
    elseif self.vy<0 then
        --上侧碰撞
        if map:notPassable(x1,y1) or map:notPassable(x2,y1) or map:notPassable(x1+16,y2) then
            yNew=int(y1/tilesize+1)*tilesize-hitbox.y
            self.vy=0
        end
    end
    self.x,self.y=xNew,yNew
end

local function processAct(self)
    self.act=math.floor(self.scene.frames/self.aniSpeed)%10+1
end

local function updateTask(self)
    local frames=self.scene.frames
    local rand=math.random
    if self.task==0 then
        if frames%10==0 and rand()<0.1 then
            self.task,self.taskTimer=rand(3),0
        end
    elseif self.task==1 then
        if self.taskTimer>120 then
            self.task,self.taskTimer=0,0
        end
    elseif self.task==2 then
        if self.taskTimer>120 then
            self.task,self.taskTimer=0,0
        end
    elseif self.task==3 then
        if self.taskTimer>120 then
            self.task,self.taskTimer=0,0
        end
    end
    self.taskTimer=self.taskTimer+1
end

function Enemy1:update()
    self.vy=self.vy+0.3;
    collideMap(self)
    processAct(self)
    updateTask(self)
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
    local danmaku={}
    local _=1
    for i=1,#self.danmaku do
        local d=self.danmaku[i]
        local x,y=camera:Transform(d[1],d[2])
        --不保留屏幕外的
        if x>0 and x<1280 and y>0 and y<720 and not map:notPassable(d[1],d[2]) then
            draw(imgDanmaku,x,y,0,camera.z*.2,camera.z*.2,16,16)
            danmaku[_]=d
            _=_+1
        end
    end
    self.danmaku=danmaku
    love.graphics.print(string.format("num: %d",#self.danmaku),0,120)
    love.graphics.print(string.format("task: %d, timer: %d",self.task,self.taskTimer),0,140)
end

function Enemy1:updateDanmaku()
    local danmaku=self.danmaku
    local cos,sin,pi=math.cos,math.sin,math.pi
    local int=math.floor
    -------------------------------------------------------
    -- Danmaku1
    -- if self.scene.frames%10==0 then
    --     local _=#danmaku
    --     local x,y=self.x,self.y
    --     if self.scene.frames%20==0 then
    --         for i=0,2*pi,pi/8 do
    --             local vx,vy=cos(i)*2,sin(i)*2
    --             _=_+1
    --             danmaku[_]={x,y,vx,vy,0,0}
    --         end
    --     else
    --         for i=pi/16,2*pi,pi/8 do
    --             local vx,vy=cos(i)*2,sin(i)*2
    --             _=_+1
    --             danmaku[_]={x,y,vx,vy,0,0}
    --         end
    --     end
    -- end
    -------------------------------------------------------
    -- Danmaku2
    -- if self.scene.frames%4==0 then
    --     local _=#danmaku
    --     local x,y=self.x,self.y
    --     local m=int(self.scene.frames/4)%8
    --     local d=pi/64
    --     for i=m*d,2*pi,d*8 do
    --         local vx,vy=cos(i)*2,sin(i)*2
    --         _=_+1
    --         danmaku[_]={x,y,vx,vy,0,0}
    --     end
    -- end
    -------------------------------------------------------
    -- Danmaku3
    if self.scene.frames%4==0 then
        local _=#danmaku
        local x,y=self.x,self.y
        local m=int(self.scene.frames/4)%8
        local d=pi/64
        for i=m*d,2*pi,d*8 do
            local vx,vy=cos(i)*2,sin(i)*2
            _=_+1
            danmaku[_]={x,y,vx,vy,0,0}
        end
    end
    --更新弹幕
    for i=1,#self.danmaku do
        local d=self.danmaku[i]
        d[1],d[2]=d[1]+d[3],d[2]+d[4]
        d[3],d[4]=d[3]+d[5],d[4]+d[6]
    end
end
