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
        for i=1,len+1 do
            -- 取出字符 计算宽度
            table.insert(pos,utf8.offset(str,i))
            s=str:sub(pos[i-1],pos[i]-1)
            w=font:getWidth(s)
            -- 超出宽度换行
            if cx+w>MAX_WIDTH then
                cx,cy=x,cy+size
            end
            table.insert(t,{x=cx,y=cy,t=s})
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
    return new
end

function Text:draw()
    local color=love.graphics.setColor
    local text=love.graphics.print
    if self.mode==1 then
        --静态文本
        color(1,1,1,1)
        for _,t in ipairs(self.data) do
            text(t.t,t.x,t.y)
        end
    elseif self.mode==2 then
        --描边文本
        for _,t in ipairs(self.data) do
            color(0,0,0,.8)
            text(t.t,t.x-2,t.y)
            text(t.t,t.x+2,t.y)
            text(t.t,t.x,t.y-2)
            text(t.t,t.x,t.y+2)
            color(1,1,1,1)
            text(t.t,t.x,t.y)
        end
    elseif self.mode==3 then
        --动画文本
    end
end

function Text:update()

end