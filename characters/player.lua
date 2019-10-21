local data={
    image="img/player.png",
    quads={},
    hitbox={},
    attackbox={}
}
local newQuad=love.graphics.newQuad
local append=table.insert
for i=0,3 do
    for j=0,3 do
        append(data.quads,newQuad(128*j,128*i,128,128,512,512))
    end
end
for i=1,16 do
    append(data.hitbox,{x=-8,y=-10,w=16,h=32})
end
return data