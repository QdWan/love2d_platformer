local newSource=love.audio.newSource
local soundlist={
    "jump",
    "laser"
}
sound={}
for i=1,#soundlist do
    sound[soundlist[i]]=newSource("sound/"..soundlist[i]..".ogg","stream")
end
