Text={}

local function parseData(str,font,size,mode)
    local MAX_WIDTH=1240
    local x,y=20,600
    local t={}
    local len=utf8.len(str)
    local pos={}
    local cx,cy=x,y
    local s,w
    -- 计算宽度
    pos[0]=0
    if mode<=2 then
        for i=1,len do
            -- 取出字符 计算宽度
            table.insert(pos,utf8.offset(i))
            s=str:sub(pos[i-1],pos[i])
            w=font:getWidth(s)
            -- 超出宽度换行
            if cx+w>MAX_WIDTH then
                
            end
            table.insert(t,{x=cx,y=cy,t=s})
        end
        table.insert(t,{x=x,y=y,t=str})
    elseif mode==3 then
        for i=1,len do
            -- 取出字符 计算宽度
            table.insert(pos,utf8.offset(i))
            s=str:sub(pos[i-1],pos[i])
            w=font:getWidth(s)
            -- 超出宽度换行
            if cx+w>MAX_WIDTH then
                cx,cy=x,cy+size
            end
            table.insert(t,{x=cx,y=cy,t=s})
        end
    end
end

function Text:New(str,mode)
    local new={}
    setmetatable(new,Text)
    self.__index=Text
    self.mode=mode
    self.data=parseData(str,mode)
    return new
end

function Text:draw()
    if self.mode==1 then
        --静态文本
    elseif self.mode==2 then
        --描边文本
    elseif self.mode==3 then
        --动画文本
    end
end

function Text:update()

end