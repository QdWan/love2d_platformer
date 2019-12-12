local newQuad=love.graphics.newQuad
local quads={}
local hitbox={}
local attackbox={
    {x=0,y=0,w=0,h=0},
    {x=0,y=0,w=0,h=0},
    {x=0,y=0,w=0,h=0},
    {x=0,y=0,w=0,h=0},
    {x=0,y=0,w=0,h=0},
    {x=-27,y=-34,w=37,h=23},
    {x=11,y=-25,w=37,h=34},
    {x=20,y=-2,w=31,h=20},
    {x=0,y=0,w=0,h=0},
    {x=0,y=0,w=0,h=0},
    {x=0,y=0,w=0,h=0},
    {x=0,y=0,w=0,h=0},
    {x=5,y=-32,w=41,h=36},
    {x=-30,y=-47,w=49,h=26},
    {x=0,y=0,w=0,h=0},
    {x=0,y=0,w=0,h=0},
}
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
