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

    for i = 1, #levelMap[currentWorld] do
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("fill", levelMap[currentWorld][i].x*10, levelMap[currentWorld][i].y*10, 10, 10)
        if levelMap[currentWorld][i].up then
            connectLevels(currentWorld, i, "up")
        end
        if levelMap[currentWorld][i].left then
            connectLevels(currentWorld, i, "left")
        end
        if levelMap[currentWorld][i].right then
            connectLevels(currentWorld, i, "right")
        end
        if levelMap[currentWorld][i].down then
            connectLevels(currentWorld, i, "down")
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
        levelMap[w][l].x * 10 + 5,
        levelMap[w][l].y * 10 + 5,
        levelMap[ levelMap[w][l][i][1] ][ levelMap[w][l][i][2] ].x * 10 + 5,
        levelMap[ levelMap[w][l][i][1] ][ levelMap[w][l][i][2] ].y * 10 + 5
    )
end