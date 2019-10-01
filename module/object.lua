Object={}
local insert=table.insert

function Object:new()
    local new={}
    setmetatable(new,Object)
    self.__index=self
    --位置和速度
    self.x=0
    self.y=0
    self.vx=0
    self.vy=0
    --状态
    self.moving=false
    self.jumping=false
    self.airjump=0
    self.act=1
    self.timer=0
    self.hitboxes={}
    --动画
    self.image=nil
    self.quads=nil
    return new
end

function Object:addHitbox()

end

function Object:loadObjectData(file)
    return file
end

function Object:addHitbox(hitbox)
    insert(self.hitboxes,hitbox)
end

function Object:isMoving()
    return self.moving
end

function Object:isJumping()
    return self.jumping
end
