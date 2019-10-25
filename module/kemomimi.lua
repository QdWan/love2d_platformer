Kemomimi={}

function Kemomimi:new()
    local new={}
    setmetatable(new,Kemomimi)
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

function Kemomimi:update()
    
end
