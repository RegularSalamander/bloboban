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
        c = 0
    }
    bufferedControl = false

    --objects are anything we should call an update and/or draw function on each frame
    objects = {}
    objects.player = {}
    objects.blobs = {}
    objects.walls = {}
    objects.holes = {}
    objects.affectors = {}

    loadLevel(1)

    animationState = animStates.ready
    animationFrame = 0
end

function game_update(delta)
    --default frame rate is 60, delta time is dealt with in frames
    delta = delta * 60
    --if we're at less than 30 fps that probably means the game was unfocused
    delta = math.min(delta, 2)

    animationFrame = animationFrame + 1

    if animationState == animStates.ready then
        if checkPlayerMoving() then
            bufferedControl = false
            changeAnimationState(animStates.moving)
        end
    elseif animationState == animStates.moving then
        if animationFrame == moveTime then
            applyMovement()

            --check if any blobs will connect
            --if yes, go to preconnect
            --if not go to waiting
            local nextState = animStates.waiting
            for i = 1, #objects.blobs do
                if objects.blobs[i]:testChanges() then
                    nextState = animStates.preconnect
                end
            end

            if nextState == animStates.waiting then
                checkHoleFilling()
            end

            changeAnimationState(nextState)
        end
    elseif animationState == animStates.preconnect then
        if animationFrame == preconnectTime then
            applyChanges()
            changeAnimationState(animStates.postconnect)
        end
    elseif animationState == animStates.postconnect then
        if animationFrame == postconnectTime then
            checkHoleFilling()

            changeAnimationState(animStates.waiting)
        end
    elseif animationState == animStates.waiting then
        if animationFrame == waitTime then
            changeAnimationState(animStates.ready)
        end
    end


    --keys are updated last so that objects can see if they're 1 or -1
    for k, v in pairs(controls) do
        if v > 0 then controls[k] = v + delta
        else controls[k] = v - delta
        end
    end
end

function game_draw()
    love.graphics.setCanvas(gameCanvas)

    love.graphics.setBackgroundColor(1, 1, 1)
    love.graphics.clear()

    for x = 0, screenWidth/tileSize do
        for y = 0, screenHeight/tileSize do
            if (x+y)%2 == 0 then
                love.graphics.setColor(colors.checkerLight)
            else
                love.graphics.setColor(colors.checkerDark)
            end
            love.graphics.rectangle("fill", x*tileSize, y*tileSize, tileSize, tileSize)
        end
    end

    for i = 1, #objects.affectors do
        if objects.affectors[i].draw then
            objects.affectors[i]:draw()
        end
    end

    objects.player[1]:draw()
    
    for i = 1, #objects.holes do
        if objects.holes[i].draw then
            objects.holes[i]:draw()
        end
    end

    for i = 1, #objects.blobs do
        if objects.blobs[i].draw then
            objects.blobs[i]:draw()
        end
    end

    for i = 1, #objects.walls do
        if objects.walls[i].draw then
            objects.walls[i]:draw()
        end
    end
end

function game_keypressed(key, scancode, isrepeat)
    --if you want to remap keys, do it by changing the scancode
    if isrepeat then return end
    if scancode == "up" or scancode == "left" or scancode == "right" or scancode == "down" and animationState ~= animStates.ready then
        bufferedControl = true
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
    local rv =  objects.player[1]:control()

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

function applyMovement()
    --apply movement
    objects.player[1]:applyMove()

    for i = 1, #objects.blobs do
        objects.blobs[i]:applyMove()
    end
    for i = 1, #objects.holes do
        objects.holes[i]:applyMove()
    end
end

function applyChanges()
    --affect the connections between objects
    for i = 1, #objects.blobs do
        objects.blobs[i]:applyChanges()
    end
    for i = 1, #objects.holes do
        objects.holes[i]:applyChanges()
    end
end

function checkHoleFilling()
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

function changeAnimationState(newState)
    animationState = newState
    animationFrame = 0
end