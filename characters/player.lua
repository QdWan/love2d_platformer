local data={
    image="img/player.png",
    quads={},
    hitbox={},
    attackbox={}
}
local newQuad=love.graphics.newQuad
local append=table.insert
for i=0,1 do
    local t={}
    for j=0,6 do
        append(t,newQuad(128*j,128*i,128,128,896,256))
    end
    append(data.quads,t)
end
for i=0,1 do
    local t={}
    for j=0,6 do
        append(t,{x=-8,y=-12,w=16,h=40})
    end
    append(data.hitbox,t)
end
return data