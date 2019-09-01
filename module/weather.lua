Weather={}
local rand=math.random
function Weather:new(weather)
    local new={}
    setmetatable(new,Weather)
    self.__index=self
    self.width,self.height=love.graphics.getPixelDimensions()
    self.weather=weather or "none"
    self.quant=0
    self.data={}
    return new
end

function Weather:setWeather(weather,quant)
    self.data={}
    self.weather=weather
    self.quant=quant or 100
end

function Weather:newDrop()
    local o={
        x=self.width*rand(),
        y=self.height*(rand()-1),
        v=rand()*10+20
    }
    return o
end

function Weather:newSnow()
    local o={
        x=self.width*rand(),
        y=self.height*(rand()-1),
        u=(rand()-0.2)*2,
        v=rand()*2+2
    }
    return o
end

function Weather:update()
    if self.weather=="rain" then
        local len=#self.data
        if len<self.quant then
            for i=len+1,self.quant do
                self.data[i]=self:newDrop()
            end
        end
        for i=1,self.quant do
            local d=self.data[i]
            d.y=d.y+d.v
            if d.y>self.height then
                self.data[i]=self:newDrop()
            end
        end
    elseif self.weather=="snow" then
        local len=#self.data
        if len<self.quant then
            for i=len+1,self.quant do
                self.data[i]=self:newSnow()
            end
        end
        for i=1,self.quant do
            local d=self.data[i]
            if d.y>0 then
                d.x=d.x+d.u
            end
            d.y=d.y+d.v
            if d.y>self.height then
                self.data[i]=self:newSnow()
            end
        end
    end
end

function Weather:draw()
    local gc=love.graphics
    if self.weather=="rain" then
        gc.setColor(255,255,255,0.5)
        gc.setLineWidth(2)
        for i=1,#self.data do
            local d=self.data[i]
            if d.y>0 then
                gc.line(d.x,d.y,d.x,d.y+d.v)
            end
        end
    elseif self.weather=="snow" then
        for i=1,#self.data do
            gc.setColor(255,255,255,1)
            local d=self.data[i]
            if d.y>0 then
                gc.circle("fill",d.x,d.y,6-d.v,6)
            end
        end
    end
end
