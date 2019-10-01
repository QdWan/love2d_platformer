--Player<Scene
Player={}

function Player:new()
    local new={}
    setmetatable(new,Player)
    self.__index=self
    self.scene=nil
    self.x=0
    self.y=0            --坐标
    self.vx=0
    self.vy=0           --速度
    self.jumping=0      --跳跃时间
    self.canJump=false
    self.act=0
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

    end
end

function Scene:addPlayer(player)
    player.scene=self
    table.insert(self.player,player)
end

function Player:setImage(image)
    self.image=love.graphics.newImage(image)
    self.quads={}
    local w,h=self.image:getDimensions()
    local tw,th=128,128
    local newQuad=love.graphics.newQuad
    local append=table.insert
    for i=0,1 do
        local t={}
        append(self.quads,t)
        for j=0,6 do
            append(t,newQuad(tw*j,th*i,tw,th,w,h))
        end
    end
end

function Player:isInMap()
    local map=self.scene.map
    return x>0 and 
end

function Player:update()
    local ts=self.scene.map.tilesize
    local int=math.floor
    --local mi,mj=int(self.y/ts+1.5),int(self.x/ts)
    --local mid,mjd=self.y/ts+1.5-mi,self.x/ts-mj
    local map=player.scene.map
    if self.scene.map:isInMap() then

    end
    -- print(mi,mid,map.data[mi][mj])
    -- if mi>0 and mi<=map.height and mj>0 and mj<=map.width and mid<0.4 and map.data[mi][mj]>0 then
    --     self.y=mi*ts-22
    --     if love.keyboard.isDown("j") then player.v=-5 end
    --     if self.v>0 then
    --         self.v=0
    --     end
    -- else
    --     self.v=self.v+0.2
    --     self.v=math.min(self.v,6)
    -- end
    -- self.y=self.y+self.v
end

function Player:draw()
    local zoom=self.scene.camera.z
    --调试使用
    local gc=love.graphics
    local int=math.floor
    local ts=self.scene.map.tilesize
    local mx,my=int(self.x/ts)*ts,self.y
    x,y=self.scene.camera:Transform(mx,my+23)
    gc.setColor(255,255,255,1)
    gc.setLineWidth(2)
    love.graphics.rectangle("line",x,y,ts*zoom,ts*zoom)
    --
    local x,y=self.scene.camera:Transform(self.x-64,self.y-64)
    love.graphics.draw(self.image,self.quads[1][4],x,y,0,zoom)
end

function Player:setPosition(x,y)
    self.x,self.y=x,y
end
