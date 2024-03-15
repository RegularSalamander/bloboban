function levelSelect_load()
    if not currentLevel then
        currentLevel = 1
        currentWorld = levelMap[currentLevel].world
        for i = 1, #levelMap do
            levelMap[i].completed = false
        end

        mapPlayerPos = {x=levelMap[currentLevel].x, y=levelMap[currentLevel].y}
    end
end

function levelSelect_update()
    mapPlayerPos.x = util.approach(mapPlayerPos.x, levelMap[currentLevel].x, 0.1)
    mapPlayerPos.y = util.approach(mapPlayerPos.y, levelMap[currentLevel].y, 0.1)
end

function levelSelect_draw()
    love.graphics.setCanvas(gameCanvas)

    love.graphics.setColor(colors.checkerLight[currentWorld])
    love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)

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
            if levelMap[i].completed then
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
        mapPlayerPos.x*mapTileSize,
        mapPlayerPos.y*mapTileSize - 6
    )
end

function levelSelect_keypressed(key, scancode, isrepeat)
    if isrepeat then return end

    if mapPlayerPos.x ~= levelMap[currentLevel].x
    or mapPlayerPos.y ~= levelMap[currentLevel].y then
        return
    end

    if scancode == "up" or scancode == "left" or scancode == "right" or scancode == "down" then
        if levelMap[currentLevel][scancode] then
            if levelMap[currentLevel].completed or 
            levelMap[levelMap[currentLevel][scancode]].completed or debugMode then
                currentLevel = levelMap[currentLevel][scancode]
                currentWorld = levelMap[currentLevel].world
            end
        end
    end
    if scancode == "z" then
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