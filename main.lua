require "module.control"
require "module.scene"
require "module.tiledmap"
require "module.weather"
require "module.camera"
require "module.player"
require "module.editor"
require "module.text"
require "enemy.enemy1"

function love.load()
	os.execute("echo 0 >> .vscode/buildcount")
	love.graphics.setDefaultFilter("linear","nearest",1)
	FONT=love.graphics.newFont("loli2.ttf",18)
	FONT_MSG=love.graphics.newFont("loli2.ttf",28)
	love.graphics.setFont(FONT)
	love.graphics.setColor(255,255,255,1)

	control:init()

	scene=Scene:new()
	scene:loadMap("map.map01")
	scene.camera:setZoom(1)
	player=Player:new()
	player:loadData("characters.player")
	player.x,player.y=30,394
	-- scene.weather=Weather:new()
	-- scene.weather:setWeather("rain",100)
	scene:addPlayer(player)
	text=Text:New("从英文翻译而来-LÖVE是一款用于开发2D电脑游戏的开源跨平台引擎。它是用C++设计的，它使用Lua作为编程语言。它是在zlib许可下发布的。引擎提供的API可以通过库SDL和OpenGL访问主机的视频和声音功能，或者从版本0.10开始也可以通过OpenGL ES 2和3访问。字体可以由引擎FreeType呈现。",FONT_MSG,3)
	--text=Text:New("\\name{旁白}测试名字暂停30帧\\d{30}暂停60帧\\d{60}测试",FONT_MSG,3)
	editor=Editor:new(scene)
	e=Enemy1:new()
	e:loadData("characters.enemy1")
	scene:addEnemy1(e)
	e.x=200
	e.y=300
end

function love.update(dt)
	control:update()
	scene:update()
	if love.keyboard.isDown("left") then scene.camera.x=scene.camera.x-1 end
	if love.keyboard.isDown("right") then scene.camera.x=scene.camera.x+1 end
	if love.keyboard.isDown("up") then scene.camera.y=scene.camera.y-1 end
	if love.keyboard.isDown("down") then scene.camera.y=scene.camera.y+1 end
	if love.keyboard.isDown("kp+") then scene.camera.z=scene.camera.z*1.01 end
	if love.keyboard.isDown("kp-") then scene.camera.z=scene.camera.z/1.01 end
	if love.keyboard.isDown(",") then scene.weather:setWeather("rain",100) end
	if love.keyboard.isDown(".") then scene.weather:setWeather("snow",100) end
end

function love.draw(d)
	scene:draw()
	love.graphics.setColor(255,255,255,1)
	love.graphics.print(string.format("camera = %d, %d, zoom=%.2f",scene.camera.x,scene.camera.y,scene.camera.z),0,0)
	love.graphics.print(string.format("player = %d, %d",scene.players[1].x,scene.players[1].y),0,20)
	love.graphics.print(string.format("fps: %d",love.timer.getFPS()),0,40)
end

function love.wheelmoved(x,y)
    local b=editor.box
	if y>0 and b.id>0 then
		b.id=b.id-1
    elseif y<0 and b.id<50 then
		b.id=b.id+1
    end
end
