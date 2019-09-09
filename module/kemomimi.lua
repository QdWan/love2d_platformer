Kemomimi={}

function Kemomimi:new()
    local new={}
    setmetatable(new,Kemomimi)
    self.__index=self
    self.scene=nil
    self.x=0
    self.y=0            --坐标
    self.v=0            --垂直速度
    self.j=0            --跳跃时间
    self.d=0            --动作
    self.t=0            --动作时间
    self.image=nil      --贴图
    self.quads=nil      --切片
    self.aniMove=true   --行走动画
    self.aniStand=false --踏步动画
    self.aniSpeed=6     --动画速度
    return new
end

function Kemomimi:update()
    
end
