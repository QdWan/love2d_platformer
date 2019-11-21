Text={}

local function parseData(str,font,size,mode)
    local utf8=require("utf8")
    local MAX_WIDTH=640
    local x,y=20,600
    local t={}
    local len=utf8.len(str)
    local pos={[0]=0}
    local cx,cy=x,y
    local s,w
    -- 计算宽度
    if mode<=2 then
        local linestart=1
        for i=1,len+1 do
            -- 取出字符 计算宽度
            table.insert(pos,utf8.offset(str,i))
            s=str:sub(pos[i-1],pos[i]-1)
            w=font:getWidth(s)
            -- 超出宽度或者结尾把当前字符全部加进去
            if cx+w>MAX_WIDTH or s=="\n" or i==len+1 then
                table.insert(t,{x=x,y=cy,t=str:sub(linestart,pos[i]-1)})
                -- 换行
                cx,cy=x,cy+size
                linestart=pos[i]
            else
                cx=cx+w
            end
        end
        return t
    elseif mode==3 then
        local i=1
        for i=1,len+1 do
            table.insert(pos,utf8.offset(str,i))
        end
        while i<=len+1 do
            -- 取出字符 计算宽度
            s=str:sub(pos[i-1],pos[i]-1)
            if s=="\\" then
                local br=str:find("}",pos[i])
                s=str:sub(pos[i-1],br)
                i=i+utf8.len(s)-1
                w=0
            else
                w=font:getWidth(s)
                -- 超出宽度换行
                if cx+w>MAX_WIDTH or s=="\n" then
                    cx,cy=x,cy+size+2
                end
            end
            table.insert(t,{x=cx,y=cy,t=s})
            cx=cx+w
            i=i+1
        end
        return t
    end
end

function Text:move(dx,dy)
    for _,t in ipairs(self.data) do
        t.x,t.y=t.x+dx,t.y+dy
    end
end

function Text:New(str,font,mode)
    local new={}
    setmetatable(new,Text)
    self.__index=Text
    self.mode=mode
    self.font=font
    self.data=parseData(str,font,18,mode)
    self.timer=0
    self.delay=0
    self.aniDelay=2
    self.aniDuration=20
    return new
end

local function strokedText(s,x,y,a)
    local color=love.graphics.setColor
    local text=love.graphics.print
    local a=a or 1
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
            if t.t:sub(1,1)=="\\" then
                strokedText(t.t,t.x,t.y-20)
            else
                if x>0 then
                    if x<self.aniDuration then
                        strokedText(t.t,t.x,t.y+0.5*(self.aniDuration-x),0.01*x*x)
                    else
                        strokedText(t.t,t.x,t.y)
                    end
                end
            end
        end
    end
end

function Text:update()
    if self.delay>0 then
        self.delay=self.delay-1
    else
        self.timer=self.timer+1
    end
end
