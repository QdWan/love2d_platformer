local newQuad=love.graphics.newQuad
local quads={}
local hitbox={}
local attackbox={}
local _=1
for i=0,3 do
    for j=0,3 do
        quads[_]=newQuad(128*j,128*i,128,128,512,512)
        _=_+1
    end
end
for i=1,16 do
    hitbox[i]={x=-8,y=-10,w=16,h=32}
end
return {
    image="img/player.png",
    quads=quads,
    hitbox=hitbox,
    attackbox=attackbox
}
