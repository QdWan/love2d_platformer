local newQuad=love.graphics.newQuad
local quads={}
local hitbox={}
local attackbox={}
for i=0,10 do
    quads[i+1]=newQuad(64*i,0,64,64,640,64)
end
for i=1,10 do
    hitbox[i]={x=0,y=0,w=8,h=16}
end
return {
    image="img/kemomimi.png",
    quads=quads,
    hitbox=hitbox,
    attackbox=attackbox
}
