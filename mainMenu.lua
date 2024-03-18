function mainMenu_load()
    animationFrame = 0

    quitProgress = 0
    quitting = false
end

function mainMenu_update()
    if animationFrame > 0 then
        animationFrame = animationFrame + 1
    end

    if animationFrame == 40 then
        sounds.disolve2:stop()
        sounds.disolve2:play()
        disolveToGameState("levelSelect")
    end

    if quitting then
        quitProgress = quitProgress + 1
        if quitProgress >= quitTime then
            love.event.quit()
        end
    else
        quitProgress =  quitProgress - 1
    end
end

function mainMenu_draw()
    love.graphics.setCanvas(gameCanvas)

    if animationFrame == 0 or math.floor(animationFrame/10)%2 == 1 then
        love.graphics.setColor(colors.checkerLight[1])
    else
        love.graphics.setColor(colors.checkerDark[1])
    end
    love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(
        images.title,
        math.floor((screenWidth-415)/2),
        40
    )

    if animationFrame == 0 or math.floor(animationFrame/10)%2 == 1 then
        love.graphics.setColor(colors.checkerDark[1])
    else
        love.graphics.setColor(colors.checkerLight[1])
    end
    love.graphics.setFont(largeFont)
    love.graphics.print("Z to begin", screenWidth/2-largeFont:getWidth("Z to begin")/2, 150)
    love.graphics.setFont(largeFont)
    love.graphics.print("Hold ESC to exit", screenWidth/2-largeFont:getWidth("Hold ESC to exit")/2, 170)

    if quitTime > 0 then
        local quitOpacity = quitProgress/quitTime
        love.graphics.setColor(0, 0, 0, quitOpacity)
        love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)
    end
end

function mainMenu_keypressed(key, scancode, isrepeat)
    if isrepeat then return end
    if scancode == "return" then scancode = "z" end
    if scancode == "space" then scancode = "z" end

    if scancode == "escape" then
        quitting = true
        quitProgress = math.max(quitProgress, 0)
    end

    if scancode == "z" then
        sounds.holefill:play()
        animationFrame = 1
    end
end

function mainMenu_keyreleased(key, scancode, isrepeat)
    if isrepeat then return end

    if scancode == "escape" then
        quitting = false
    end
end