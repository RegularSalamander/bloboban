function game_load()
    --[[
        ints for controls
        -1 always means it was just released this frame
        1 always means it was just pressed this frame
        above 1 means the amount of time it's been pressed (in 1/60th seconds)
        below -1 means the amount of time since it was last pressed (times -1)
    ]]
    controls = {
        left = 0,
        right = 0,
        up = 0,
        down = 0,
        z = 0,
        x = 0,
        c = 0,
        r = 0,
        escape = 0
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

    animationState = animStates.ready
    animationFrame = 0
end

function game_update(delta)
    --update and kill particles
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
            applyFill()
            if checkVictory() then
                changeAnimationState(animStates.victory)
                -- setGameState("levelSelect")
            else
                changeAnimationState(animStates.ready)
            end
        end
    elseif animationState == animStates.victory then
        if animationFrame == animLengths.victoryTime then
            setLevelComplete(currentLevel)
            disolveToGameState("levelSelect")
        end
    elseif animationState == animStates.waiting then
        if animationFrame == animLengths.waitTime then
            changeAnimationState(animStates.ready)
        end
    end

    --keys are updated last so that objects can see if they're 1 or -1
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

    if animationState == animStates.victory then
        drawVictoryAnimation()
    end
end

function drawVictoryAnimation()
    for i = 0, 6 do
        local spacing = 20
        local offset = 3
        local x = (animationFrame - i*offset)/(animLengths.victoryTime-offset*7)

        local drawx = screenWidth/2 - 7*(8+spacing)/2 + i*(8+spacing)
        local drawy = victoryAnimationY(x, currentWorld, currentLevel)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(
            images.victory,
            love.graphics.newQuad(i*8, 0, 8, 14, 8*7, 14),
            math.floor(drawx),
            math.floor(drawy),
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
    --if you want to remap keys, do it by changing the scancode
    if isrepeat then return end
    if scancode == "up" or scancode == "left" or scancode == "right" or scancode == "down" and animationState ~= animStates.ready then
        bufferedControl = true
    end
    if animationState ~= animStates.victory then
        if scancode == "escape" then
            disolveToGameState("levelSelect")
            return
        end
        if scancode == "r" then
            disolveToGameState("game")
            return
        end
    end

    if controls[scancode] ~= nil then controls[scancode] = 1 end
end

function game_keyreleased(key, scancode, isrepeat)
    if isrepeat then return end
    if controls[scancode] ~= nil then controls[scancode] = 0 end
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

function checkAffect()
    local rv = false
    
    for i = 1, #objects.blobs do
        if objects.blobs[i]:checkAffect() then
            rv = true
        end
    end

    for i = 1, #objects.holes do
        if objects.holes[i]:checkAffect() then
            rv = true
        end
    end

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

    return rv
end

function applyConnect()
    for i = 1, #objects.blobs do
        objects.blobs[i]:applyConnect()
    end
end

function checkFill()
    --check for filled holes and fill them
    for i = 1, #objects.holes do
        if objects.holes[i]:checkFill() then
            return true
        end
    end
end

function applyFill()
    --check for filled holes and fill them
    for i = 1, #objects.holes do
        if objects.holes[i]:checkFill() then
            objects.holes[i]:applyFill()
        end
    end

    --delete blobs from filled holes
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