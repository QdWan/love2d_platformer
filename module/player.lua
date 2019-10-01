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
    self.canJump=false
    self.hitbox={}
    self.attackbox={}
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

local function collide()

end

function Player:update()
    if not self.scene then return end
    local tilesize=self.scene.map.tilesize
    local int=math.floor
    local x=int(self.x/tilesize)
    local y=int(self.y/tilesize)
    -- local mi,mj=int(self.y/ts+1.5),int(self.x/ts)
    -- local mid,mjd=self.y/ts+1.5-mi,self.x/ts-mj
    -- local map=player.scene.map
    if self:isInMap() then
        local hitbox=self.hitbox[self.act]
        local map=self.scene.map
        if self.vx>0 then--检测右侧碰撞
            local x2=self.x+hitbox.x+hitbox.w
            if map:notPassable(x,y) then
                local xobj=int(x2/tilesize)*tilesize

            elseif map:notPassable(x+1,y) then

            end
        elseif self.vx<0 then--检测左侧碰撞

        end
        if self.vy>0 then--检测下面碰撞

        elseif self.vy<0 then--检测上面碰撞

        end
    end
    self.x=self.x+self.vx
    self.y=self.y+self.vy
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

-- function Player:draw()
--     local zoom=self.scene.camera.z
--     --调试使用
--     local gc=love.graphics
--     local int=math.floor
--     local ts=self.scene.map.tilesize
--     local mx,my=int(self.x/ts)*ts,self.y
--     x,y=self.scene.camera:Transform(mx,my+23)
--     gc.setColor(255,255,255,1)
--     gc.setLineWidth(2)
--     love.graphics.rectangle("line",x,y,ts*zoom,ts*zoom)
--     --
--     local x,y=self.scene.camera:Transform(self.x-64,self.y-64)
--     love.graphics.draw(self.image,self.quads[1][4],x,y,0,zoom)
-- end

function Player:draw()
    local camera=self.scene.camera
    local gc=love.graphics
    local int=math.floor
    local tilesize=self.scene.map.tilesize
    local x,y=camera:Transform(self.x-64,self.y-64)
    love.graphics.draw(self.image,self.quads[self.act],x,y,0,camera.z)
end

function Player:setPosition(x,y)
    self.x,self.y=x,y
end
