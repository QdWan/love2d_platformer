control={
    key={},
    okey={},
    settings={
        up="w",
        down="s",
        left="a",
        right="d",
        jump="j",
        attack="k",
        dash="l",
        boost="u"
    }
}

function control:init()
    for k,v in pairs(self.settings) do
        self.key[k],self.okey[k]=false,false
    end
end

function control:update()
    local p=love.keyboard.isDown
    for k,v in pairs(self.settings) do
        self.okey[k],self.key[k]=self.key[k],p(v)
    end
end

function control:isPress(k)
    return self.key[k] and not self.okey[k]
end
