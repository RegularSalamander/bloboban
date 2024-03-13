require "class"
util = require "utils"

require "variables"
require "levels"
require "levelLoader"

require "game"

require "player"
require "blob"
require "hole"
require "wall"
require "colorChanger"
require "holeAffectors"
require "particle"

gameState = ""

function love.load()
    math.randomseed(os.time())
    
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setLineStyle("rough")
    
    love.window.setMode(screenWidth*defaultScale, screenHeight*defaultScale, { vsync = true, msaa = 0, highdpi = true })
    love.window.setTitle("Cleric of the Sun God")

    images = {}
    images.player = love.graphics.newImage("assets/player.png")
    images.blob = love.graphics.newImage("assets/blob.png")
    images.hole = love.graphics.newImage("assets/hole.png")
    images.filledhole = love.graphics.newImage("assets/filledhole.png")
    images.wall = love.graphics.newImage("assets/wall.png")
    images.colorChanger = love.graphics.newImage("assets/colorChanger.png")
    images.holeAffector = love.graphics.newImage("assets/holeAffector.png")

    sounds = {}
    --sounds.musicStart = love.audio.newSource("assets/DRONEKILLER_start.mp3", "stream")
    --sounds.explosion1 = love.audio.newSource("assets/explosion1.wav", "static")

    --font = love.graphics.newFont("assets/fancySalamander.ttf", 16)
    --font:setFilter("nearest", "nearest")

    gameCanvas = love.graphics.newCanvas(screenWidth, screenHeight)

    setGameState("game")

    for i = 1, 13 do
        io.write('"')
        levels[i] = compileLevel(i)
        io.write('",\n')
    end
    setGameState("game")
end

function love.update(dt)
    --don't run in background
    if not love.window.hasFocus() then return end
    
    --run gamestate's update function
    if _G[gameState .. "_update"] then
        _G[gameState .. "_update"](dt)
    end
end

function love.draw()
    --each draw function is responsible for setting the canvas itself
    if _G[gameState .. "_draw"] then
        _G[gameState .. "_draw"]()
    end

    --draw the gameCanvas onto the screen, at maximum integer resolution
    love.graphics.setCanvas()
    local w, h = love.graphics.getDimensions()
    local scl = math.floor(math.min(w/screenWidth, h/screenHeight))*1
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(gameCanvas, w/2, h/2, 0, scl, scl, screenWidth/2, screenHeight/2)
end

function love.keypressed(key, scancode, isrepeat)
	if _G[gameState .. "_keypressed"] then
		_G[gameState .. "_keypressed"](key, scancode, isrepeat)
	end
end

function love.keyreleased(key, scancode, isrepeat)
	if _G[gameState .. "_keyreleased"] then
		_G[gameState .. "_keyreleased"](key, scancode, isrepeat)
	end
end

function setGameState(newGameState)
    --set the gamestate and do its load function (if applicable)
    gameState = newGameState

    if _G[gameState .. "_load"] then
        _G[gameState .. "_load"]()
    end
end