Text={}

local function parseData(str,font,size,mode)
    local utf8=require("utf8")
    local len,off=utf8.len,utf8.offset
    local MAX_WIDTH=1280-32*2
    local x,y=32,540
    local t={}
    local length=len(str)
    local p0,p1=0,0
    local cx,cy=x,y
    local s,w
    -- 计算宽度
    if mode<=2 then
        --[[local linestart=1
        for i=1,length+1 do
            -- 取出字符 计算宽度
            table.insert(pos,utf8.offset(str,i))
            s=str:sub(pos[i-1],pos[i]-1)
            w=font:getWidth(s)
            -- 超出宽度或者结尾把当前字符全部加进去
            if cx+w>MAX_WIDTH or s=="\n" or i==length+1 then
                table.insert(t,{x=x,y=cy,t=str:sub(linestart,pos[i]-1)})
                -- 换行
                cx,cy=x,cy+size
                linestart=pos[i]
            else
                cx=cx+w
            end
        end]]
        return t
    elseif mode==3 then
        local i,_=1,1
        while i<length do
            -- 取出字符 计算宽度
            p1=off(str,i+1)
            s=str:sub(p0,p1-1)
            if s=="\\" then
                p1=str:find("}",p0)
                s=str:sub(p0,p1)
                i,w,p1=i+len(s),0,p1+1
            else
                w=font:getWidth(s)
                -- 超出宽度换行
                if cx+w>MAX_WIDTH or s=="\n" then
                    cx,cy=x,cy+size
                end
            end
            t[_],_={cx,cy,s},_+1
            cx,p0,i=cx+w,p1,i+1
        end
        return t
    end
end

function Text:New(str,font,mode)
    local new={}
    setmetatable(new,Text)
    self.__index=Text
    new.mode=mode
    new.font=font
    new.data=parseData(str,font,font:getHeight(),mode)
    new.timer=0
    new.delay=0
    new.aniDelay=2
    new.aniDuration=20
    return new
end

local function strokedText(s,x,y,a)
    local color=love.graphics.setColor
    local text=love.graphics.print
    a=a or 1
    color(0,0,0,a*.6)
    text(s,x-2,y)
    text(s,x+2,y)
    text(s,x,y-2)
    text(s,x,y+2)
    color(1,1,1,a)
    text(s,x,y)
end

function Text:draw()
    local color=love.graphics.setColor
    local text=love.graphics.print
    local font=love.graphics.setFont
    font(self.font)
    if self.mode==1 then
        --静态文本
        color(1,1,1,1)
        for i=1,#self.data do
            local t=self.data[i]
            text(t.t,t.x,t.y)
        end
    elseif self.mode==2 then
        --描边文本
        for i=1,#self.data do
            local t=self.data[i]
            strokedText(t.t,t.x,t.y)
        end
    elseif self.mode==3 then
        --动画文本
        for i=1,#self.data do
            local x=self.timer-i*self.aniDelay
            local t=self.data[i]
            if t[3]:sub(1,1)=="\\" then
                strokedText(t[3],t[1],t[2]-20)
            else
                if x>0 then
                    if x<self.aniDuration then
                        strokedText(t[3],t[1],t[2]+0.5*(self.aniDuration-x),0.01*x*x)
                    else
                        strokedText(t[3],t[1],t[2])
                    end
                end
            end
        end
    end
    font(FONT)
end

function Text:update()
    if self.delay>0 then
        self.delay=self.delay-1
    else
        self.timer=self.timer+1
    end
end
