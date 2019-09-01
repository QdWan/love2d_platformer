Camera={}

function Camera:new()
    local new=Camera:newXYZ()
    setmetatable(new,Camera)
    self.__index=self
    self.width,self.height=love.graphics.getPixelDimensions()
    self.from=Camera:newXYZ()
    self.to=Camera:newXYZ()
    self.t=0
    self.dt=0
    return new
end

function Camera:newXYZ(x,y,z)
    return x and {x=x,y=y,z=z} or {x=0,y=0,z=1}
end

function Camera:setXYZ(x,y,z)
    self.x,self.y,self.z=x,y,z
end

function Camera:clone()
    return {x=self.x,y=self.y,z=self.z}
end

function Camera:Transform(x,y)
    local scrx=(x-self.x)*self.z+.5*self.width
    local scry=(y-self.y)*self.z+.5*self.height
    return scrx,scry
end

function Camera:InvTransform(scrx,scry)
    local x=(scrx-.5*self.width)/self.z+self.x
    local y=(scry-.5*self.height)/self.z+self.y
    return x,y
end

function Camera:linear(a,b,t)
    local s=1-t
    self.x=a.x*s+b.x*t
    self.y=a.y*s+b.y*t
    self.z=a.z*s+b.z*t
end

function Camera:update()
    if self.dt>0 then
        if self.t<1 then
            self.t=self.t+self.dt
        else
            self.dt=0
        end
        self:linear(self.from,self.to,self.t)
    end
end
