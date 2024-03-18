function game_load()
    controls = {
        left = 0,
        right = 0,
        up = 0,
        down = 0,
        z = 0
    }
    bufferedControl = false

    objects = {}
    objects.player = {}
    objects.blobs = {}
    objects.walls = {}
    objects.holes = {}
    objects.affectors = {}
    objects.particles = {}

    -- coordinates to draw floor tiles (dark checkerboard color)
    floors = {}

    loadLevel(levelMap[currentLevel].levelIdx)

    if oldGameState == "levelSelect" then
        animationState = animStates.open
        sounds.open:stop()
        sounds.open:play()
    else
        animationState = animStates.ready
    end
    animationFrame = 0

    if levelMap[currentLevel].challenge then
        currentWorld = 3
    end
end

function game_update(delta)
    --update and delete particles
    for i = 1, #objects.particles do
        objects.particles[i]:update()
    end
    for i = #objects.particles, 1, -1 do
        if not objects.particles[i].alive then
            table.remove(objects.particles, i)
        end
    end

    --update animation and state
    animationFrame = animationFrame + 1

    if animationState == animStates.ready then
        if checkPlayerMoving() then
            --play step sound
            local stepNum = math.floor(love.math.random()*2) + 1
            if checkObjectMoving() then
                stepNum = stepNum + 2
            end
            sounds["step" .. stepNum]:stop()
            sounds["step" .. stepNum]:play()

            bufferedControl = false
            changeAnimationState(animStates.moving)
        end
    elseif animationState == animStates.moving then
        if animationFrame == animLengths.moveTime then
            applyMove()

            if checkAffect() then
                changeAnimationState(animStates.affect)
            elseif checkConnect() then
                changeAnimationState(animStates.connect)
            elseif checkFill() then
                changeAnimationState(animStates.fill)
            else
                changeAnimationState(animStates.waiting)
            end
        end
    elseif animationState == animStates.affect then
        if animationFrame == animLengths.affectTime then
            applyAffect()
        elseif animationFrame == animLengths.affectTime*2 then
            if checkConnect() then
                changeAnimationState(animStates.connect)
            elseif checkFill() then
                changeAnimationState(animStates.fill)
            else
                changeAnimationState(animStates.ready)
            end
        end
    elseif animationState == animStates.connect then
        if animationFrame == animLengths.connectTime then
            applyConnect()
        elseif animationFrame == animLengths.connectTime*2 then
            if checkFill() then
                changeAnimationState(animStates.fill)
            else
                changeAnimationState(animStates.ready)
            end
        end
    elseif animationState == animStates.fill then
        if animationFrame == animLengths.fillTime then
            sounds.holefill:stop()
            sounds.holefill:play()
            applyFill()
            if checkVictory() then
                changeAnimationState(animStates.victory)
                sounds.victory:play()
            else
                changeAnimationState(animStates.ready)
            end
        end
    elseif animationState == animStates.victory then
        if animationFrame == animLengths.victoryTime then
            setLevelComplete(currentLevel)
            saveProgress()
            sounds.disolve1:play()
            disolveToGameState("levelSelect")
        end
    elseif animationState == animStates.open then
        if animationFrame == animLengths.openTime then
            changeAnimationState(animStates.ready)
        end
    elseif animationState == animStates.waiting then
        if animationFrame == animLengths.waitTime then
            changeAnimationState(animStates.ready)
        end
    end

    --update controls
    for k, v in pairs(controls) do
        if v > 0 then controls[k] = v + 1
        else controls[k] = v - 1
        end
    end
end

function game_draw()
    love.graphics.setCanvas(gameCanvas)

    love.graphics.setColor(colors.checkerLight[currentWorld])
    love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)

    for i = 1, #floors do
        love.graphics.setColor(colors.checkerDark[currentWorld])
        love.graphics.rectangle("fill", floors[i].x*tileSize, floors[i].y*tileSize, tileSize, tileSize)
    end

    for i = 1, #objects.affectors do
        objects.affectors[i]:draw()
    end

    objects.player[1]:draw()
    
    for i = 1, #objects.holes do
        objects.holes[i]:draw()
    end

    for i = 1, #objects.blobs do
        objects.blobs[i]:draw()
    end

    for i = 1, #objects.walls do
        objects.walls[i]:draw()
    end

    for i = 1, #objects.particles do
        objects.particles[i]:draw()
    end

    if animationState == animStates.open then
        drawOpenAnimation()
    elseif animationState == animStates.victory then
        drawVictoryAnimation()
    end

    love.graphics.setColor(colors.checkerDark[currentWorld])
    love.graphics.setFont(font)
    str = "Arrows to move    R to restart    ESC to exit"
    love.graphics.print(str, screenWidth/2-font:getWidth(str)/2, screenHeight-font:getHeight(str)-4)
end

function drawOpenAnimation()
    local letters
    local quadX
    local quadY
    
    if levelMap[currentLevel].challenge then
        letters = 10
        quadY = 28
    else
        letters = 5
        quadY = 14
    end

    local spacing = 10
    local offset = 3

    for i = 0, letters-1 do
        local x = (animationFrame - i*offset)/(animLengths.openTime-offset*7)
        local drawx = screenWidth/2 - letters*(8+spacing)/2 + i*(8+spacing)
        local drawy = screenHeight - victoryAnimationY(x, currentWorld, currentLevel)

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(
            images.text,
            love.graphics.newQuad(i*8, quadY, 8, 14, 80, 56),
            math.floor(drawx),
            math.floor(drawy - 4),
            0,
            1,
            1
        )
    end

    letters = #levelMap[currentLevel].levelName
    for i = 0, letters-1 do
        local currentLetter = util.charAt(levelMap[currentLevel].levelName, i+1)

        if currentLetter == "-" then
            quadX = 48
            quadY = 14
        elseif currentLetter == "A" then
            quadX = 16
            quadY = 28
        elseif currentLetter == "B" then
            quadX = 40
            quadY = 14
        else
            quadX = 8*(string.byte(currentLetter)-48)
            quadY = 42
        end

        local x = (animationFrame - i*offset)/(animLengths.openTime-offset*7)
        local drawx = screenWidth/2 - letters*(8+spacing)/2 + i*(8+spacing)
        local drawy = screenHeight - victoryAnimationY(x, currentWorld, currentLevel)

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(
            images.text,
            love.graphics.newQuad(quadX, quadY, 8, 14, 80, 56),
            math.floor(drawx),
            math.floor(drawy + 15),
            0,
            1,
            1
        )
    end
end

function drawVictoryAnimation()
    for i = 0, 6 do
        local spacing = 10
        local offset = 3
        local x = (animationFrame - i*offset)/(animLengths.victoryTime-offset*7)

        local drawx = screenWidth/2 - 7*(8+spacing)/2 + i*(8+spacing)
        local drawy = victoryAnimationY(x, currentWorld, currentLevel)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(
            images.text,
            love.graphics.newQuad(i*8, 0, 8, 14, 80, 56),
            math.floor(drawx),
            math.floor(drawy - 4),
            0,
            1,
            1
        )
    end
end

function victoryAnimationY(x, w, l)
    if (w+l)%4 == 0 then
        return 0.5*(math.pow(2*x-1, 4)+1) * screenHeight
    elseif (w+l)%4 == 1 then
        return screenHeight - 0.5*(math.pow(2*x-1, 5)+1) * screenHeight
    elseif (w+l)%4 == 2 then
        return screenHeight - 0.5*(math.pow(2*x-1, 4)+1) * screenHeight
    else
        return 0.5*(math.pow(2*x-1, 5)+1) * screenHeight
    end
end

function game_keypressed(key, scancode, isrepeat)
    --remap keys
    if scancode == "w" then scancode = "up" end
    if scancode == "a" then scancode = "left" end
    if scancode == "s" then scancode = "down" end
    if scancode == "d" then scancode = "right" end

    if isrepeat then return end

    --buffer control
    if (scancode == "up" or scancode == "left" or scancode == "right" or scancode == "down")
    and animationState ~= animStates.ready and animationState ~= animStates.open then
        bufferedControl = true
    end

    if animationState ~= animStates.victory then
        if scancode == "escape" then
            sounds.disolve1:stop()
            sounds.disolve1:play()
            disolveToGameState("levelSelect")
            return
        end
        if scancode == "r" then
            sounds.disolve2:stop()
            sounds.disolve2:play()
            disolveToGameState("game")
            return
        end
    end

    if controls[scancode] then controls[scancode] = 1 end
end

function game_keyreleased(key, scancode, isrepeat)
    --remap keys
    if scancode == "w" then scancode = "up" end
    if scancode == "a" then scancode = "left" end
    if scancode == "s" then scancode = "down" end
    if scancode == "d" then scancode = "right" end
    
    if isrepeat then return end
    if controls[scancode] then controls[scancode] = 0 end
end

function getObjectAt(x, y)
    local rv = {
        wall = nil,
        blob = nil,
        hole = nil,
        affector = nil
    }
    
    for i = 1, #objects.walls do
        if objects.walls[i].pos.x == x and objects.walls[i].pos.y == y then
            rv.wall = objects.walls[i]
            break
        end
    end
    for i = 1, #objects.blobs do
        if objects.blobs[i].pos.x == x and objects.blobs[i].pos.y == y then
            rv.blob = objects.blobs[i] 
            break
        end
    end
    for i = 1, #objects.holes do
        if objects.holes[i].pos.x == x and objects.holes[i].pos.y == y then
            rv.hole = objects.holes[i] 
            break
        end
    end
    for i = 1, #objects.affectors do
        if objects.affectors[i].pos.x == x and objects.affectors[i].pos.y == y then
            rv.affector = objects.affectors[i] 
            break
        end
    end
    
    return rv
end

function checkPlayerMoving()
    local rv = objects.player[1]:control()

    if not rv then
        for i = 1, #objects.blobs do
            objects.blobs[i]:cancelMove()
        end
        for i = 1, #objects.holes do
            objects.holes[i]:cancelMove()
        end
    end

    return rv
end

function applyMove()
    objects.player[1]:applyMove()

    for i = 1, #objects.blobs do
        objects.blobs[i]:applyMove()
    end
    for i = 1, #objects.holes do
        objects.holes[i]:applyMove()
    end
end

function checkObjectMoving()
    for i = 1, #objects.blobs do
        if objects.blobs[i].pos.x ~= objects.blobs[i].nextPos.x or objects.blobs[i].pos.y ~= objects.blobs[i].nextPos.y then
            return true
        end
    end

    for i = 1, #objects.holes do
        if objects.holes[i].pos.x ~= objects.holes[i].nextPos.x or objects.holes[i].pos.y ~= objects.holes[i].nextPos.y then
            return true
        end
    end
end

function checkAffect()
    local rv = false
    local playHoleSound = false
    
    for i = 1, #objects.blobs do
        if objects.blobs[i]:checkAffect() then
            rv = true
        end
    end

    if rv then sounds.colorchange:play() end

    for i = 1, #objects.holes do
        if objects.holes[i]:checkAffect() then
            rv = true
            playHoleSound = true
        end
    end

    if playHoleSound then sounds.holeaffect:play() end

    return rv
end

function applyAffect()
    for i = 1, #objects.blobs do
        objects.blobs[i]:applyAffect()
    end

    for i = 1, #objects.holes do
        objects.holes[i]:applyAffect()
    end
end


function checkConnect()
    local rv = false
    
    for i = 1, #objects.blobs do
        if objects.blobs[i]:checkConnect() then
            rv = true
        end
    end

    if rv then sounds.blobconnect:play() end

    return rv
end

function applyConnect()
    for i = 1, #objects.blobs do
        objects.blobs[i]:applyConnect()
    end
end

function checkFill()
    for i = 1, #objects.holes do
        if objects.holes[i]:checkFill() then
            return true
        end
    end
end

function applyFill()
    for i = 1, #objects.holes do
        if objects.holes[i]:checkFill() then
            objects.holes[i]:applyFill()
        end
    end

    --delete blobs that holes
    for i = #objects.blobs, 1, -1 do
        if not objects.blobs[i].alive then
            table.remove(objects.blobs, i)
        end
    end
end

function checkVictory()
    for i = 1, #objects.holes do
        if not objects.holes[i].filled then
            return false
        end
    end

    return true
end

function changeAnimationState(newState)
    animationState = newState
    animationFrame = 0
end