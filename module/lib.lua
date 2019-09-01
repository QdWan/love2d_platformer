Lib={}

function Lib:new()
    local new={}
    setmetatable(new,Lib)
    self.__index=self
    return new
end

function Lib:Linear(x0,x1,t)
    return (1-t)*x0+t*x1
end
