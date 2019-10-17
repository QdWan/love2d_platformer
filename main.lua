require "module.base"
require "module.tiledmap"
require "module.weather"
require "module.camera"
require "module.scene"
require "module.player"

function love.load()
	love.graphics.setDefaultFilter("linear","nearest",1)
	--love.graphics.setFont(love.graphics.newFont("loli2.ttf",18))
	love.graphics.setColor(255,255,255,1)

	scene=Scene:new()
	scene:loadMap("map.map01")
	scene.camera:setXYZ(220,360,3)
	scene.weather:setWeather("snow",100)

	player=Player:new()
	player:loadData("characters.player")
	Player:setPosition(600,100)

	scene:addPlayer(player)
end

function love.update(dt)
	scene:update()
	if love.keyboard.isDown("left") then scene.camera.x=scene.camera.x-1 end
	if love.keyboard.isDown("right") then scene.camera.x=scene.camera.x+1 end
	if love.keyboard.isDown("up") then scene.camera.y=scene.camera.y-1 end
	if love.keyboard.isDown("down") then scene.camera.y=scene.camera.y+1 end
	if love.keyboard.isDown("kp+") then scene.camera.z=scene.camera.z*1.01 end
	if love.keyboard.isDown("kp-") then scene.camera.z=scene.camera.z/1.01 end
	if love.keyboard.isDown(",") then scene.weather:setWeather("rain",100) end
	if love.keyboard.isDown(".") then scene.weather:setWeather("snow",100) end

	player.vx=0
	if love.keyboard.isDown("a") then player.vx=-1 end
	if love.keyboard.isDown("d") then player.vx=1 end
	if love.keyboard.isDown("j") and player.onGround then player.vy=-8 end
	if love.keyboard.isDown("h") then player.y,player.vy=264,0 end
end

function love.draw(d)
	scene:draw()

	love.graphics.setColor(255,255,255,1)
	love.graphics.print(string.format("camera = %d, %d, zoom=%.2f",scene.camera.x,scene.camera.y,scene.camera.z),0,0)
	love.graphics.print(string.format("player = %d, %d",scene.player[1].x,scene.player[1].y),0,20)
end

function love.keypressed(key)

end

function love.mousepressed(key,x,y)

end
