local newQuad=love.graphics.newQuad
local data={{},{},{},{},{},{},{}}
for i=1,8 do
    data[1][i]=newQuad((i-1)*16,0 ,16,16,128,128)
    data[2][i]=newQuad((i-1)*16,16,16,16,128,128)
    data[3][i]=newQuad((i-1)*16,32,1 ,16,128,128)
    data[6][i]=newQuad((i-1)*16,80,16,16,128,128)
end
for i=1,4 do
    data[4][i]=newQuad((i-1)*32,48,32,16,128,128)
    data[5][i]=newQuad((i-1)*32,64,32,16,128,128)
    data[7][i]=newQuad((i-1)*32,96,32,32,128,128)
end
return data
