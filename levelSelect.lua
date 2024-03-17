function levelSelect_load()
    if not currentLevel then
        currentLevel = 1
        currentWorld = levelMap[currentLevel].world
        for i = 1, #levelMap do
            if not levelMap[i].complete then
                levelMap[i].complete = false
            end
        end

        mapPlayerPos = {x=levelMap[currentLevel].x, y=levelMap[currentLevel].y}
        mapPlayerDir = 0
        mapPlayerFrame = 0

        camY = -mapTileSize
    end
end

function levelSelect_update()
    mapPlayerPos.x = util.approach(mapPlayerPos.x, levelMap[currentLevel].x, 0.1)
    mapPlayerPos.y = util.approach(mapPlayerPos.y, levelMap[currentLevel].y, 0.1)

    if mapPlayerPos.x == levelMap[currentLevel].x and mapPlayerPos.y == levelMap[currentLevel].y
    and mapPlayerDir == 3 then
        mapPlayerDir = 0
    end

    if currentWorld == 1 then
        camY = util.approach(camY, -mapTileSize, 1)
    elseif currentWorld == 2 then
        camY = util.approach(camY, mapTileSize*12, 1)
    end
end

function levelSelect_draw()
    love.graphics.setCanvas(gameCanvas)

    -- love.graphics.setColor(colors.checkerLight[currentWorld])
    -- love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)

    love.graphics.push()
    love.graphics.translate(0, -math.floor(camY))

    for i = 1, #levelCheckers do
        drawCheckerboard(
            levelCheckers[i][1],
            levelCheckers[i][2],
            levelCheckers[i][3],
            levelCheckers[i][4],
            levelCheckers[i][5]
        )
    end

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
end

function levelSelect_keypressed(key, scancode, isrepeat)
    --remapping wasd
    if scancode == "w" then scancode = "up" end
    if scancode == "a" then scancode = "left" end
    if scancode == "s" then scancode = "down" end
    if scancode == "d" then scancode = "right" end
    
    if isrepeat then return end

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