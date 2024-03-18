function levelSelect_load()
    -- resetSave()
    if not currentLevel then
        currentLevel = 1
        for i = 1, #levelMap do
            if not levelMap[i].complete then
                levelMap[i].complete = false
            end
        end

        loadSave()
        currentWorld = levelMap[currentLevel].world

        mapPlayerPos = {x=levelMap[currentLevel].x, y=levelMap[currentLevel].y}
        mapPlayerDir = 0
        mapPlayerFrame = 0

        if currentWorld == 1 then
            camY = -mapTileSize
        elseif currentWorld == 2 then
            camY = mapTileSize*15
        end
    end

    restartProgress = 0
    restarting = false
end

function levelSelect_update()
    mapPlayerPos.x = util.approach(mapPlayerPos.x, levelMap[currentLevel].x, 0.1)
    mapPlayerPos.y = util.approach(mapPlayerPos.y, levelMap[currentLevel].y, 0.1)

    if mapPlayerPos.x == levelMap[currentLevel].x and mapPlayerPos.y == levelMap[currentLevel].y
    and mapPlayerDir == 3 then
        mapPlayerDir = 0
    end

    if currentWorld == 1 then
        camY = util.approach(camY, -mapTileSize, 2)
    elseif currentWorld == 2 then
        camY = util.approach(camY, mapTileSize*15, 2)
    end

    if restarting then
        restartProgress = restartProgress + 1
        if restartProgress >= restartTime then
            sounds.disolve2:play()
            resetSave()
            disolveToGameState("levelSelect")
        end
    else
        restartProgress = restartProgress - 1
    end
end

function levelSelect_draw()
    love.graphics.setCanvas(gameCanvas)

    -- love.graphics.setColor(colors.checkerLight[currentWorld])
    -- love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)

    love.graphics.push()
    love.graphics.translate(0, -math.floor(camY))

    love.graphics.setColor(colors.checkerLight[1])
    love.graphics.rectangle("fill", 0, -mapTileSize, screenWidth, 16*mapTileSize)
    love.graphics.setColor(colors.checkerLight[2])
    love.graphics.rectangle("fill", 0, mapTileSize*15, screenWidth, 16*mapTileSize)
    drawCheckerboard(1, 4, -1, 19, 16)
    drawCheckerboard(2, 4, 15, 19, 16)

    for i = 1, #levelMap do
        if levelMap[i].up then
            connectLevels(i, "up")
        end
        if levelMap[i].left then
            connectLevels(i, "left")
        end
        if levelMap[i].right then
            connectLevels(i, "right")
        end
        if levelMap[i].down then
            connectLevels(i, "down")
        end
    end
    
    for i = 1, #levelMap do
        if levelMap[i].levelIdx then
            love.graphics.setColor(1, 1, 1, 1)
            if levelMap[i].complete then
                love.graphics.draw(
                    images.level,
                    love.graphics.newQuad(mapTileSize, 0, mapTileSize, mapTileSize, mapTileSize*2, mapTileSize),
                    levelMap[i].x*mapTileSize,
                    levelMap[i].y*mapTileSize,
                    0,
                    1,
                    1
                )
            else
                love.graphics.draw(
                    images.level,
                    love.graphics.newQuad(0, 0, mapTileSize, mapTileSize, mapTileSize*2, mapTileSize),
                    levelMap[i].x*mapTileSize,
                    levelMap[i].y*mapTileSize,
                    0,
                    1,
                    1
                )
            end
        end
    end

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(
        images.player,
        love.graphics.newQuad(mapPlayerDir*tileSize, mapPlayerFrame*tileSize, tileSize, tileSize, tileSize*4, tileSize*2),
        mapPlayerPos.x*mapTileSize,
        mapPlayerPos.y*mapTileSize - 6,
        0,
        1,
        1
    )

    love.graphics.pop()

    love.graphics.setColor(colors.checkerLight[currentWorld])
    love.graphics.rectangle("fill", 0, screenHeight-20, screenWidth, 20)

    love.graphics.setColor(colors.checkerDark[1])
    love.graphics.setFont(font)
    str = "Arrows to move    Z to enter    ESC to exit    Hold R to reset"
    love.graphics.print(str, screenWidth/2-font:getWidth(str)/2, screenHeight-font:getHeight(str)-4)

    if restartTime > 0 then
        local restartOpacity = restartProgress/restartTime
        love.graphics.setColor(1, 1, 1, restartOpacity)
        love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)
    end
end

function levelSelect_keypressed(key, scancode, isrepeat)
    --remapping wasd
    if scancode == "w" then scancode = "up" end
    if scancode == "a" then scancode = "left" end
    if scancode == "s" then scancode = "down" end
    if scancode == "d" then scancode = "right" end
    if scancode == "e" then scancode = "z" end
    if scancode == "return" then scancode = "z" end
    if scancode == "space" then scancode = "z" end
    
    if isrepeat then return end

    if scancode == "escape" then
        sounds.disolve1:stop()
        sounds.disolve1:play()
        disolveToGameState("mainMenu")
    end

    if scancode == "r" then
        restarting = true
        restartProgress = math.max(restartProgress, 0)
    end

    if mapPlayerPos.x ~= levelMap[currentLevel].x
    or mapPlayerPos.y ~= levelMap[currentLevel].y then
        return
    end

    if scancode == "up" or scancode == "left" or scancode == "right" or scancode == "down" then
        if levelMap[currentLevel][scancode] then
            if levelMap[currentLevel].complete or levelMap[levelMap[currentLevel][scancode]].complete 
            or debugMode then
                currentLevel = levelMap[currentLevel][scancode]
                currentWorld = levelMap[currentLevel].world

                if scancode == "down" then mapPlayerDir = 0
                elseif scancode == "left" then mapPlayerDir = 1
                elseif scancode == "right" then mapPlayerDir = 2
                else mapPlayerDir = 3 end

                mapPlayerFrame = (mapPlayerFrame + 1)%2

                local stepNum = math.floor(love.math.random()*2) + 1
                sounds["step" .. stepNum]:stop()
                sounds["step" .. stepNum]:play()
            end
        end
    end
    if scancode == "z" and levelMap[currentLevel].levelIdx then
        sounds.disolve2:stop()
        sounds.disolve2:play()
        disolveToGameState("game")
    end
end

function levelSelect_keyreleased(key, scancode, isrepeat)
    if isrepeat then return end

    if scancode == "r" then
        restarting = false
    end
end

function connectLevels(l, i)
    love.graphics.setColor(colors.outline)
    love.graphics.line(
        levelMap[l].x * mapTileSize + mapTileSize/2,
        levelMap[l].y * mapTileSize + mapTileSize/2,
        levelMap[levelMap[l][i]].x * mapTileSize + mapTileSize/2,
        levelMap[levelMap[l][i]].y * mapTileSize + mapTileSize/2
    )
end

function getLevelById(id)
    for i = 1, #levelMap do
        if levelMap[i].id == id then
            return levelMap[i]
        end
    end
end

function setLevelComplete(idx)
    --recursively set nil spaces surrounding the level to complete

    if levelMap[idx].complete then return end

    levelMap[idx].complete = true

    if levelMap[idx].up and not levelMap[levelMap[idx].up].levelIdx then
        setLevelComplete(levelMap[idx].up)
    end
    if levelMap[idx].left and not levelMap[levelMap[idx].left].levelIdx then
        setLevelComplete(levelMap[idx].left)
    end
    if levelMap[idx].right and not levelMap[levelMap[idx].right].levelIdx then
        setLevelComplete(levelMap[idx].right)
    end
    if levelMap[idx].down and not levelMap[levelMap[idx].down].levelIdx then
        setLevelComplete(levelMap[idx].down)
    end
end

function drawCheckerboard(c, x, y, w, h)
    for i = x, x+w-1 do
        for j = y, y+h-1 do
            if (i+j)%2 == 0 then
                love.graphics.setColor(colors.checkerDark[c])
            else
                love.graphics.setColor(colors.checkerLight[c])
            end
            love.graphics.rectangle("fill", i*mapTileSize, j*mapTileSize, mapTileSize, mapTileSize)
        end
    end
end