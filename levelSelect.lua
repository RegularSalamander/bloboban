function levelSelect_load()
    currentWorld = 1
    currentLevel = 1 --level within world
end

function levelSelect_update()

end

function levelSelect_draw()
    love.graphics.setCanvas(gameCanvas)

    love.graphics.setBackgroundColor(0, 0, 0)
    love.graphics.clear()

    for j = 1, #levelMap do
        for i = 1, #levelMap[j] do
            if levelMap[j][i].up then
                connectLevels(j, i, "up")
            end
            if levelMap[j][i].left then
                connectLevels(j, i, "left")
            end
            if levelMap[j][i].right then
                connectLevels(j, i, "right")
            end
            if levelMap[j][i].down then
                connectLevels(j, i, "down")
            end
        end
    end
    

    for j = 1, #levelMap do
        for i = 1, #levelMap[j] do
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.draw(
                images.level,
                love.graphics.newQuad(0, 0, mapTileSize, mapTileSize, mapTileSize*2, mapTileSize),
                levelMap[j][i].x*mapTileSize,
                levelMap[j][i].y*mapTileSize,
                0,
                1,
                1
            )
        end
    end


    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(currentLevel, 20, 20)
end

function levelSelect_keypressed(key, scancode, isrepeat)
    if isrepeat then return end
    if scancode == "up" or scancode == "left" or scancode == "right" or scancode == "down" then
        if levelMap[currentWorld][currentLevel][scancode] then
            local newWorld = levelMap[currentWorld][currentLevel][scancode][1]
            local newLevel = levelMap[currentWorld][currentLevel][scancode][2]

            currentWorld = newWorld
            currentLevel = newLevel
        end
    end
    if scancode == "z" then
        setGameState("game")
    end
end

function connectLevels(w, l, i)
    love.graphics.line(
        levelMap[w][l].x * mapTileSize + mapTileSize/2,
        levelMap[w][l].y * mapTileSize + mapTileSize/2,
        levelMap[ levelMap[w][l][i][1] ][ levelMap[w][l][i][2] ].x * mapTileSize + mapTileSize/2,
        levelMap[ levelMap[w][l][i][1] ][ levelMap[w][l][i][2] ].y * mapTileSize + mapTileSize/2
    )
end