local newQuad=love.graphics.newQuad
local quads={}
local hitbox={}
local attackbox={
    {x=0,y=0,w=0,h=0},
    {x=0,y=0,w=0,h=0},
    {x=0,y=0,w=0,h=0},
    {x=0,y=0,w=0,h=0},
    {x=0,y=0,w=0,h=0},
    {x=37,y=30,w=37,h=23},
    {x=75,y=39,w=37,h=34},
    {x=84,y=62,w=31,h=20},
    {x=0,y=0,w=0,h=0},
    {x=0,y=0,w=0,h=0},
    {x=0,y=0,w=0,h=0},
    {x=0,y=0,w=0,h=0},
    {x=69,y=32,w=41,h=36},
    {x=34,y=17,w=49,h=26},
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
